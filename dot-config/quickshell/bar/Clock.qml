import Quickshell
import Quickshell.Io
import QtQuick
import "../config.js" as Config

Pill {
    implicitWidth: clock.implicitWidth + parent.height
    Text {
        id: clock

        color: Config.theme.primary
        font: Config.font
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        Process {
            id: dateProc
            command: ["date", "+%a %d %b %H:%M:%S"]
            running: true

            stdout: StdioCollector {
                onStreamFinished: clock.text = this.text
            }
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: dateProc.running = true
        }
    }
}
