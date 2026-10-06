import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes
import "../config.js" as Config

PanelWindow {
    id: root
    required property var targetScreen
    screen: targetScreen
    readonly property bool critical: false
    readonly property var cards: Service.cardsFor(targetScreen, critical)
    readonly property var firstCard: cards[0] || null
    readonly property bool solo: cards.length === 1 && !firstCard.stacked
    readonly property real stackHeight: cards.reduce((sum, p) => sum + p.occupiedHeight, 0)
    readonly property color accent: firstCard ? firstCard.accent : Config.theme.primary
    property alias body: body

    // Keep the Wayland surface fixed. All motion happens in one scene graph.
    anchors { top: true; bottom: true; right: true }
    // The 6px shoulder plus this offset matches Hyprland's 10px outer gap.
    margins.top: 4
    implicitWidth: Math.min(270, targetScreen ? targetScreen.width : 270)
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-notifications"
    color: "transparent"
    visible: cards.length > 0
    mask: Region { item: surface }

    Component.onCompleted: Service.stacks = [...Service.stacks, root]
    Component.onDestruction: Service.stacks = Service.stacks.filter(s => s !== root)

    Item {
        id: surface
        anchors.right: parent.right
        property real widthReveal: root.solo ? root.firstCard.reveal : 1
        Behavior on widthReveal {
            enabled: !root.solo
            NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
        }
        width: 4 + (root.width - 4) * widthReveal
        height: root.solo ? 12 + (root.stackHeight - 12) * root.firstCard.reveal : root.stackHeight
        y: root.solo ? (root.stackHeight - height) / 2 : 0
        clip: true

        Shape {
            id: outline
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            readonly property real shoulder: Math.min(6, height / 4)
            readonly property real corner: Math.min(12, Math.max(0, (height - shoulder * 2) / 2), width / 2)
            ShapePath {
                strokeColor: root.accent
                strokeWidth: Config.border.width
                fillColor: Config.theme.bg
                startX: outline.width + 1
                startY: 0
                PathQuad {
                    x: outline.width - outline.shoulder; y: outline.shoulder
                    controlX: outline.width; controlY: outline.shoulder
                }
                PathLine { x: outline.corner + 0.5; y: outline.shoulder }
                PathQuad {
                    x: 0.5; y: outline.shoulder + outline.corner
                    controlX: 0.5; controlY: outline.shoulder
                }
                PathLine { x: 0.5; y: outline.height - outline.shoulder - outline.corner }
                PathQuad {
                    x: outline.corner + 0.5; y: outline.height - outline.shoulder
                    controlX: 0.5; controlY: outline.height - outline.shoulder
                }
                PathLine { x: outline.width - outline.shoulder; y: outline.height - outline.shoulder }
                PathQuad {
                    x: outline.width + 1; y: outline.height
                    controlX: outline.width; controlY: outline.height - outline.shoulder
                }
                PathLine { x: outline.width + 1; y: 0 }
            }
        }
        Item {
            id: body
            width: root.width
            height: root.stackHeight
            // Solo content stays in place while the surface grows around it.
            y: root.solo ? -surface.y : 0
        }
    }
}
