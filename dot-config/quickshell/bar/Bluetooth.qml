import Quickshell.Bluetooth
import Quickshell.Io
import QtQuick
import "../config.js" as Config

Item {
    id: root
    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height

    property var adapter: Bluetooth.defaultAdapter

    BarText {
        id: icon
        color: Config.colors.teal

        text: {
            if (root.adapter == null) {
                return "󰂲";
            }

            let numConnected = Bluetooth.devices.values.reduce((t, v) => t + (v.connected ? 1 : 0), 0);

            return root.adapter.enabled ? numConnected == 0 ? "󰂯" : "󰂱" : "󰂲";
        }
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
