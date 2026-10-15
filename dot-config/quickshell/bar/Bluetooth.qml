import Quickshell.Bluetooth
import Quickshell.Hyprland
import QtQuick
import "../bluetooth" as BluetoothUi
import "../config.js" as Config

Item {
    id: root
    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight
    property Pill pill: null
    property string screenName: ""
    readonly property var adapter: BluetoothUi.Service.adapter

    function toggle() { if (popup.opened) popup.close(); else popup.open(); }
    BarText {
        id: icon
        color: Config.colors.teal
        text: !root.adapter || !root.adapter.enabled ? "󰂲" : Bluetooth.devices.values.some(d => d.connected) ? "󰂱" : "󰂯"
    }
    MouseArea {
        anchors.fill: parent
        onClicked: root.toggle()
        cursorShape: Qt.PointingHandCursor
    }
    IslandPopup {
        id: popup
        title: "Bluetooth"
        pill: root.pill
        sourceItem: root
        cornerRadius: 5
        dismissOnEscape: false
        padding: 12
        BluetoothUi.Manager { opened: popup.opened; onDismiss: popup.close() }
    }
    Connections {
        target: BluetoothUi.Service
        function onToggleRequested() {
            if (!Hyprland.focusedMonitor || Hyprland.focusedMonitor.name === root.screenName) root.toggle();
        }
    }
}
