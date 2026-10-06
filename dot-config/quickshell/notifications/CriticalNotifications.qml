import Quickshell
import QtQuick
import "../bar"

IslandPopup {
    id: root
    sourceItem: pill
    required property var targetScreen
    readonly property bool critical: true
    readonly property var cards: Service.cardsFor(targetScreen, critical)
    readonly property bool hasNotifications: cards.some(p => !p.closing)
    readonly property real contentHeight: cards.reduce((sum, p) => sum + p.occupiedHeight, 0)
    property real heldHeight: 0
    property alias body: notificationBody

    dismissOnOutsideClick: false
    dismissOnEscape: false
    reservedBodyHeight: targetScreen ? Math.max(1, targetScreen.height - headerHeight - padding * 2 - 5) : 1

    onContentHeightChanged: { if (hasNotifications) heldHeight = contentHeight; }
    onHasNotificationsChanged: {
        if (hasNotifications) {
            heldHeight = contentHeight;
            open();
        } else {
            // Keep the body size until IslandPopup has contracted into the clock.
            close();
        }
    }
    Component.onCompleted: Service.stacks = [...Service.stacks, root]
    Component.onDestruction: Service.stacks = Service.stacks.filter(s => s !== root)

    Item {
        id: notificationBody
        implicitWidth: 290
        implicitHeight: root.hasNotifications ? root.contentHeight : root.heldHeight
    }
}
