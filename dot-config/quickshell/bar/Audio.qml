import QtQuick
import "../audio" as AudioUi
import "../config.js" as Config

PopupButton {
    id: root
    title: "Audio"
    toggleSource: AudioUi.Service
    readonly property var output: AudioUi.Service.groups.sinks.find(item => item.default) || null
    color: Config.colors.yellow
    text: !root.output ? "󰝟" : (root.output.muted ? "󰝟" : root.output.volume + "% " + (/headphones|headset/.test(root.output.port) ? "󰋋" : root.output.volume < 33 ? "󰕿" : root.output.volume < 66 ? "󰖀" : "󰕾")) + (root.output.name.includes("bluez") ? "󰂯" : "")
    AudioUi.Manager { opened: root.opened; onDismiss: root.close() }
}
