import Quickshell.Hyprland
import QtQuick
import "../audio" as AudioUi
import "../config.js" as Config

Item {
    id: root
    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight
    property Pill pill: null
    property string screenName: ""
    readonly property var output: AudioUi.Service.groups.sinks.find(item => item.default) || null

    function toggle() { if (popup.opened) popup.close(); else popup.open(); }
    BarText {
        id: icon
        color: Config.colors.yellow
        text: !root.output ? "󰝟" : (root.output.muted ? "󰝟" : root.output.volume + "% " + (/headphones|headset/.test(root.output.port) ? "󰋋" : root.output.volume < 33 ? "󰕿" : root.output.volume < 66 ? "󰖀" : "󰕾")) + (root.output.name.includes("bluez") ? "󰂯" : "")
    }
    MouseArea {
        anchors.fill: parent
        onClicked: root.toggle()
        cursorShape: Qt.PointingHandCursor
    }
    IslandPopup {
        id: popup
        title: "Audio"
        pill: root.pill
        sourceItem: root
        cornerRadius: 5
        dismissOnEscape: false
        padding: 12
        AudioUi.Manager { opened: popup.opened; onDismiss: popup.close() }
    }
    Connections {
        target: AudioUi.Service
        function onToggleRequested() {
            if (!Hyprland.focusedMonitor || Hyprland.focusedMonitor.name === root.screenName) root.toggle();
        }
    }
}
