import Quickshell
import QtQuick
import "../config.js" as Config

Rectangle {
    id: root
    default property alias contentData: content.data
    readonly property alias contentItem: content

    property var activePopup: null
    property bool square: false
    property int padding: parent.height / 2

    // Blend every pill covered by an expanded surface into its background.
    readonly property bool covered: {
        const window = root.QsWindow.window;
        if (!window || !window.popups) return false;
        let x = 0;
        for (let item = root; item && item !== window.contentItem; item = item.parent) x += item.x;
        return window.popups.some(popup => {
            const surface = popup.inputRegion.item;
            const left = surface.parent.x + surface.x;
            return x < left + surface.width && x + root.width > left;
        });
    }
    border.color: Config.border.color
    border.width: covered ? 0 : Config.border.width
    radius: parent.height / 2
    visible: content.visibleChildren.length > 0
    color: covered ? "transparent" : Config.theme.bg
    implicitHeight: parent.height
    implicitWidth: square ? parent.height : content.implicitWidth + padding * 2

    function attachPopup(popup) {
        if (activePopup && activePopup !== popup) activePopup.close(true);
        activePopup = popup;
    }
    function detachPopup(popup) {
        if (activePopup === popup) activePopup = null;
    }

    Row {
        id: content
        spacing: 10
        anchors.centerIn: parent
    }
}
