pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import "../config.js" as Config

// Supply one Item whose implicit size determines the expanded content area.
Item {
    id: root
    default property alias content: body.child

    property string title: ""
    property Pill pill: null
    property Item sourceItem: parent
    property bool dismissOnOutsideClick: true
    property bool dismissOnEscape: true
    property real cornerRadius: 16
    property int padding: 5
    property int horizontalPadding: padding
    // Reserve a stable Wayland surface for content whose height is animated.
    property real reservedBodyHeight: 0
    readonly property real expandedHeight: body.implicitHeight + headerHeight + padding * 2
    readonly property alias headerItem: header
    readonly property bool opened: popupWindow.visible && !popupWindow.closing
    readonly property real headerHeight: pill ? pill.height : 0

    function positionPopup() {
        const anchor = popupWindow.anchor;
        const target = root.pill || root.sourceItem;
        if (!target || !anchor.window) return;
        const center = target.width / 2;
        const point = target.mapToItem(anchor.window.contentItem, center, root.pill ? 0 : target.height);
        const x = Math.round(Math.max(0, Math.min(anchor.window.width - popupWindow.width, point.x - popupWindow.width / 2)));
        const y = Math.round(point.y);
        if (anchor.rect.x !== x) anchor.rect.x = x;
        if (anchor.rect.y !== y) anchor.rect.y = y;
        header.x = point.x - x - header.width / 2;
    }
    function updateAnchor() {
        if (popupWindow.visible) positionPopup();
    }
    function scheduleAnchorUpdate() { Qt.callLater(root.updateAnchor); }
    Connections {
        target: root.pill || root.sourceItem
        function onWidthChanged() { root.scheduleAnchorUpdate(); }
        function onHeightChanged() { root.scheduleAnchorUpdate(); }
        function onXChanged() { root.scheduleAnchorUpdate(); }
        function onYChanged() { root.scheduleAnchorUpdate(); }
    }
    Connections {
        target: (root.pill || root.sourceItem)?.parent ?? null
        function onXChanged() { root.scheduleAnchorUpdate(); }
        function onYChanged() { root.scheduleAnchorUpdate(); }
    }

    function open() {
        if (!popupWindow.visible && pill)
            pill.preparePopup(() => root.showPopup());
        else
            showPopup();
    }

    function showPopup() {
        transition.stop();
        popupWindow.closing = false;
        if (popupWindow.visible) {
            transition.start();
        } else {
            popupWindow.visible = true;
        }
    }

    function close(immediate = false) {
        if (!popupWindow.visible)
            return;
        transition.stop();
        popupWindow.closing = true;
        focusGrab.active = false;
        if (immediate) {
            popupWindow.visible = false;
        } else {
            transition.start();
        }
    }

    Component.onDestruction: {
        if (pill && pill.activePopup === root)
            pill.activePopup = null;
    }

    Rectangle {
        parent: root.sourceItem
        anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
        anchors.top: parent ? parent.bottom : undefined
        anchors.topMargin: 2
        width: 3
        height: 3
        radius: width / 2
        color: Config.border.color
        visible: root.sourceItem !== null && root.pill !== null && root.pill.activePopup === root
    }

    PopupWindow {
        id: popupWindow

        anchor.window: root.pill ? root.pill.QsWindow.window : root.sourceItem.QsWindow.window
        anchor.onAnchoring: root.positionPopup()
        implicitWidth: Math.max(root.pill ? root.pill.width + 48 : 80, body.implicitWidth + root.horizontalPadding * 2)
        // Leave room for the bottom antialiased edge at fractional display scales.
        // Keep the background, reveal clip and input mask at their content size.
        implicitHeight: (root.reservedBodyHeight > 0 ? root.reservedBodyHeight : body.implicitHeight) + root.headerHeight + root.padding * 2 + 1
        color: "transparent"
        visible: false
        mask: Region { item: surface }
        // Hyprland grabs also work when opened by IPC without prior pointer input.
        grabFocus: false
        property bool closing: false
        property real reveal: 0

        HyprlandFocusGrab {
            id: focusGrab
            windows: [popupWindow]
            active: false
            onCleared: {
                if (popupWindow.visible && !popupWindow.closing)
                    root.close();
            }
        }

        NumberAnimation {
            id: transition
            target: popupWindow
            property: "reveal"
            to: popupWindow.closing ? 0 : 1
            duration: popupWindow.closing ? 210 : 260
            easing.type: popupWindow.closing ? Easing.InOutCubic : Easing.OutCubic
            onFinished: {
                if (popupWindow.closing) {
                    popupWindow.visible = false;
                } else if (popupWindow.visible) {
                    // Wait until the popup is mapped before grabbing outside clicks.
                    focusGrab.active = root.dismissOnOutsideClick;
                }
            }
        }

        onVisibleChanged: {
            transition.stop();
            closing = false;
            reveal = 0;
            if (visible)
                transition.start();
            if (!root.pill)
                return;
            if (visible) {
                const previous = root.pill.activePopup;
                if (previous && previous !== root)
                    previous.close(true);
                root.pill.activePopup = root;
            } else if (root.pill.activePopup === root) {
                root.pill.activePopup = null;
            }
        }

        Rectangle {
            id: surface
            x: header.x * (1 - popupWindow.reveal)
            width: header.width + (popupWindow.width - header.width) * popupWindow.reveal
            height: root.headerHeight + (root.expandedHeight - root.headerHeight) * popupWindow.reveal
            color: Config.theme.bg
            border.color: Config.border.color
            border.width: Config.border.width
            radius: root.headerHeight / 2 + (root.cornerRadius - root.headerHeight / 2) * popupWindow.reveal
        }

        Item {
            id: header
            focus: true
            Keys.onEscapePressed: { if (root.dismissOnEscape) root.close(); }
            width: root.pill ? root.pill.width : 0
            height: root.headerHeight
        }

        // Keep content inside the background throughout the reveal.
        Item {
            id: revealClip
            x: surface.x
            width: surface.width
            height: surface.height
            clip: true
        }

        Text {
            parent: revealClip
            x: root.horizontalPadding - revealClip.x
            width: Math.max(0, header.x - root.horizontalPadding * 2)
            height: root.headerHeight
            text: root.title
            color: Config.border.color
            font.bold: true
            font.family: Config.font.family
            font.pointSize: Config.font.pointSize
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            opacity: body.opacity
        }

        WrapperItem {
            id: body
            parent: revealClip
            opacity: Math.max(0, Math.min(1, (popupWindow.reveal - 0.25) / 0.75))
            enabled: !popupWindow.closing && popupWindow.reveal > 0.7
            x: root.horizontalPadding - revealClip.x
            y: root.headerHeight + root.padding
            width: popupWindow.width - root.horizontalPadding * 2
        }
    }
}
