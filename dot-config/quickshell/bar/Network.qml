import QtQuick
import "../network" as NetworkUi
import "../config.js" as Config

PopupButton {
    id: root
    title: "Wi-Fi"
    toggleSource: NetworkUi.Service
    readonly property var connected: NetworkUi.Service.networks.find(n => n.connected) || null
    color: Config.colors.maroon
    text: !NetworkUi.Service.powered ? "" : NetworkUi.Service.state === "connecting" ? "󰓦" : !root.connected ? "󰤮" : root.connected.signal > -50 ? "󰤨" : root.connected.signal > -60 ? "󰤥" : root.connected.signal > -67 ? "󰤢" : root.connected.signal > -80 ? "󰤟" : "󰤯"
    NetworkUi.Manager { opened: root.opened; onDismiss: root.close() }
}
