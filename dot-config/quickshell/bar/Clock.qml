import Quickshell.Io
import QtQuick
import "../config.js" as Config

Pill {
    Text {
        id: clock

        color: Config.theme.primary
        font: Config.font
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
