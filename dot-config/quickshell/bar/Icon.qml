import Quickshell.Io
import QtQuick
import "../config.js" as Config

Pill {
    id: root
    square: true

    Item {
        implicitWidth: root.width
        implicitHeight: root.height

        BarText {
            text: ""
            color: Config.colors.sapphire
            anchors.fill: parent
        }

        MouseArea {
            cursorShape: Qt.PointingHandCursor
            onClicked: onClickProc.running = true
        }
    }

    Process {
        id: onClickProc
        command: ["elephant", "menu", "system-control"]
        running: false
    }
}
