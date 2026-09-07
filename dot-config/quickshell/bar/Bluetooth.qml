import Quickshell.Bluetooth
import Quickshell.Io
import QtQuick
import "../config.js" as Config

Item {
    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height

    BarText {
        id: icon
        color: Config.colors.teal

        text: Bluetooth.defaultAdapter.enabled ? Bluetooth.devices.values.length == 0 ? "󰂯" : "󰂱" : "󰂲"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: bluetui.running = true
        cursorShape: Qt.PointingHandCursor
    }

    Process {
        id: bluetui
        running: false
        command: ["ghostty", "+new-window", "--title='-float-'", "-e", "bluetui"]
    }
}
