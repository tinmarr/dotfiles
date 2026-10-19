import Quickshell.Bluetooth
import QtQuick
import "../bluetooth" as BluetoothUi
import "../config.js" as Config

PopupButton {
    id: root
    title: "Bluetooth"
    toggleSource: BluetoothUi.Service
    readonly property var adapter: BluetoothUi.Service.adapter
    color: Config.colors.teal
    text: !root.adapter || !root.adapter.enabled ? "󰂲" : Bluetooth.devices.values.some(d => d.connected) ? "󰂱" : "󰂯"
    BluetoothUi.Manager { opened: root.opened; onDismiss: root.close() }
}
