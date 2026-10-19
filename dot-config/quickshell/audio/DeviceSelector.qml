pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import "../config.js" as Config

ComboBox {
    id: root
    activeFocusOnTab: false
    signal menuClosed()
    property int menuIndex: -1
    property int selectedIndex: -1
    currentIndex: { const choices = model; return selectedIndex; }
    function openMenu() {
        if (!visible || !enabled || !count) return;
        forceActiveFocus();
        popup.open();
    }
    function handleKey(event) {
        if (!visible) return;
        if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            event.accepted = true;
            if (!popup.visible) openMenu();
            else if (menuIndex >= 0) {
                activated(menuIndex);
                popup.close();
            }
        } else if (popup.visible && (event.key === Qt.Key_J || event.key === Qt.Key_Down || event.key === Qt.Key_K || event.key === Qt.Key_Up)) {
            if (count) {
                const delta = event.key === Qt.Key_J || event.key === Qt.Key_Down ? 1 : -1;
                menuIndex = (menuIndex + delta + count) % count;
                options.positionViewAtIndex(menuIndex, ListView.Contain);
            }
        } else if (popup.visible && (event.key === Qt.Key_Escape || event.key === Qt.Key_Q)) {
            popup.close();
        } else return;
        event.accepted = true;
    }
    function pressKey(event) {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
            event.accepted = true;
        else handleKey(event);
    }
    function releaseKey(event) {
        if (visible && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter))
            handleKey(event);
    }
    Keys.onPressed: event => pressKey(event)
    Keys.onReleased: event => releaseKey(event)
    font.family: Config.font.family
    font.pointSize: Config.font.pointSize
    padding: 9
    leftPadding: 10
    rightPadding: 32
    hoverEnabled: true
    implicitHeight: 36

    contentItem: Text {
        text: root.displayText
        font: root.font
        color: root.enabled ? Config.colors.text : Config.colors.overlay0
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    indicator: Text {
        x: root.width - width - 12
        anchors.verticalCenter: parent.verticalCenter
        text: root.popup.visible ? "󰅃" : "󰅀"
        font: root.font
        color: root.popup.visible || root.activeFocus ? Config.theme.primary : Config.colors.subtext0
    }
    background: Rectangle {
        radius: 5
        color: root.hovered || root.down ? Config.colors.surface0 : Config.colors.mantle
        border.width: 1
        border.color: root.activeFocus || root.popup.visible ? Config.border.color : Config.colors.surface1
    }
    delegate: ItemDelegate {
        id: option
        required property int index
        width: root.width - 10
        height: 36
        highlighted: root.menuIndex === index
        hoverEnabled: true
        contentItem: Text {
            text: root.textAt(option.index)
            font: root.font
            color: option.index === root.currentIndex ? Config.colors.yellow : Config.colors.text
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        background: Rectangle {
            radius: 4
            color: option.highlighted ? Config.colors.surface0 : option.hovered ? Config.colors.mantle : "transparent"
            border.width: option.highlighted ? 1 : 0
            border.color: Config.colors.surface2
        }
    }
    popup: Popup {
        focus: true
        onOpened: {
            root.menuIndex = root.selectedIndex >= 0 ? root.selectedIndex : (root.count ? 0 : -1);
            options.positionViewAtIndex(root.menuIndex, ListView.Contain);
            options.forceActiveFocus();
        }
        // Keep the list inside the bar popup on its first keyboard opening.
        y: -implicitHeight - 4
        width: root.width
        padding: 5
        implicitHeight: Math.min(240, root.count * 36 + Math.max(0, root.count - 1) * 3 + padding * 2)
        contentItem: ListView {
            id: options
            Keys.onPressed: event => root.pressKey(event)
            Keys.onReleased: event => root.releaseKey(event)
            clip: true
            implicitHeight: contentHeight
            model: root.delegateModel
            currentIndex: root.menuIndex
            highlightMoveDuration: 0
            spacing: 3
            boundsBehavior: Flickable.StopAtBounds
            ScrollIndicator.vertical: ScrollIndicator {}
        }
        background: Rectangle {
            color: Config.theme.bg
            radius: 5
            border.width: Config.border.width
            border.color: Config.border.color
        }
        onClosed: root.menuClosed()
    }
}
