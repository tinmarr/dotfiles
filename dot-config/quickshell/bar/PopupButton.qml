import Quickshell.Hyprland
import QtQuick

Item {
    id: root
    default property alias content: popup.content
    property alias text: icon.text
    property alias color: icon.color
    property alias title: popup.title
    property alias pill: popup.pill
    property string screenName: ""
    required property var toggleSource
    readonly property bool opened: popup.opened
    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight
    function toggle() { if (popup.opened) popup.close(); else popup.open(); }
    function close() { popup.close(); }
    BarText { id: icon }
    MouseArea {
        anchors.fill: parent
        onClicked: root.toggle()
        cursorShape: Qt.PointingHandCursor
    }
    IslandPopup {
        id: popup
        sourceItem: root
        cornerRadius: 5
        dismissOnEscape: false
        padding: 12
    }
    Connections {
        target: root.toggleSource
        function onToggleRequested() {
            if (!Hyprland.focusedMonitor || Hyprland.focusedMonitor.name === root.screenName) root.toggle();
        }
    }
}
