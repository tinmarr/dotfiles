import QtQuick
import "../config.js" as Config

Rectangle {
    id: root
    default property alias contentData: content.data

    property var activePopup: null
    property bool square: false
    property int padding: parent.height / 2

    border.color: activePopup ? "transparent" : Config.border.color
    border.width: Config.border.width
    radius: parent.height / 2

    visible: activePopup !== null || content.visibleChildren.length > 0
    color: activePopup ? "transparent" : Config.theme.bg

    implicitHeight: parent.height
    implicitWidth: square ? parent.height : content.implicitWidth + (padding * 2)

    // Keep the live icons and their hitboxes inside the expanded surface.
    onActivePopupChanged: {
        content.parent = activePopup ? activePopup.headerItem : root;
    }

    Row {
        id: content

        spacing: 10
        anchors.centerIn: parent
    }
}
