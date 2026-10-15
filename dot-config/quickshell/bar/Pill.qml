import QtQuick
import "../config.js" as Config

Rectangle {
    id: root
    default property alias contentData: content.data

    property var activePopup: null
    property var popupSnapshot: null
    property bool square: false
    property int padding: parent.height / 2

    border.color: Config.border.color
    border.width: Config.border.width
    radius: parent.height / 2

    visible: activePopup !== null || content.visibleChildren.length > 0
    color: Config.theme.bg

    implicitHeight: parent.height
    implicitWidth: square ? parent.height : content.implicitWidth + (padding * 2)

    function preparePopup(callback) {
        content.grabToImage(result => {
            popupSnapshot = result;
            callback();
        });
    }

    // Cover the gap between moving the controls and the popup being mapped.
    Image {
        anchors.centerIn: parent
        width: content.width
        height: content.height
        source: root.popupSnapshot ? root.popupSnapshot.url : ""
        visible: root.activePopup !== null
    }

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
