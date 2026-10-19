import Quickshell.Hyprland
import QtQuick
import "../network" as NetworkUi
import "../config.js" as Config

Item {
    id: root
    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight
    property Pill pill: null
    property string screenName: ""
    readonly property var connected: NetworkUi.Service.networks.find(n => n.connected) || null

    function toggle() { if (popup.opened) popup.close(); else popup.open(); }
    BarText {
        id: icon
        color: Config.colors.maroon
        text: !NetworkUi.Service.powered ? "" : NetworkUi.Service.state === "connecting" ? "󰓦" : !root.connected ? "󰤮" : root.connected.signal > -50 ? "󰤨" : root.connected.signal > -60 ? "󰤥" : root.connected.signal > -67 ? "󰤢" : root.connected.signal > -80 ? "󰤟" : "󰤯"
    }
    MouseArea {
        anchors.fill: parent
        onClicked: root.toggle()
        cursorShape: Qt.PointingHandCursor
    }
    IslandPopup {
        id: popup
        title: "Wi-Fi"
        pill: root.pill
        sourceItem: root
        cornerRadius: 5
        dismissOnEscape: false
        padding: 12
        NetworkUi.Manager { opened: popup.opened; onDismiss: popup.close() }
    }
    Connections {
        target: NetworkUi.Service
        function onToggleRequested() {
            if (!Hyprland.focusedMonitor || Hyprland.focusedMonitor.name === root.screenName) root.toggle();
        }
    }
}
