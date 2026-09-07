import Quickshell
import Quickshell.Io
import QtQuick
import "../config.js" as Config

Pill {
    width: this.height

    Text {
        text: ""
        font: Config.font
        color: Config.colors.sapphire
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: onClickProc.running = true
    }

    Process {
        id: onClickProc
        command: ["elephant", "menu", "system-control"]
        running: false
    }
}
