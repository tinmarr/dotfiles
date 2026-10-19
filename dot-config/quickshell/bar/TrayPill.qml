import QtQuick

// Keep the tray's window handoff separate, but share normal pill styling.
Pill {
    id: root
    property var popupSnapshot: null
    property size popupSnapshotSize: Qt.size(0, 0)

    function preparePopup(callback) {
        const size = Qt.size(contentItem.width, contentItem.height);
        contentItem.grabToImage(result => {
            popupSnapshotSize = size;
            popupSnapshot = result;
            if (callback) callback();
        });
    }

    // Cover the gap between moving the controls and the popup being mapped.
    Image {
        parent: root
        anchors.centerIn: parent
        width: root.popupSnapshotSize.width
        height: root.popupSnapshotSize.height
        source: root.popupSnapshot ? root.popupSnapshot.url : ""
        visible: root.activePopup !== null
    }

    // Keep the live icons and their hitboxes inside the expanded surface.
    onActivePopupChanged: {
        contentItem.parent = activePopup ? activePopup.headerItem : root;
    }

}
