import QtQuick
import "../config.js" as Config

Rectangle {
    id: root
    default property alias contentData: content.data

    property var activePopup: null
    property bool relocatingContent: false

    property bool square: false
    property int padding: parent.height / 2

    border.color: activePopup ? "transparent" : Config.border.color
    border.width: Config.border.width
    radius: parent.height / 2

    color: activePopup ? "transparent" : Config.theme.bg

    implicitHeight: parent.height
    implicitWidth: square ? parent.height : content.implicitWidth + (padding * 2)

    // Keep the live icons and their hitboxes inside the expanded surface.
    onActivePopupChanged: {
        relocatingContent = true;
        content.parent = activePopup ? activePopup.headerItem : root;
        relocatingContent = false;
    }

    Row {
        id: content

        spacing: 10
        anchors.centerIn: parent

        onVisibleChildrenChanged: {
            if (!root.activePopup && !root.relocatingContent)
                root.visible = this.visibleChildren.length > 0;
        }
    }
}
