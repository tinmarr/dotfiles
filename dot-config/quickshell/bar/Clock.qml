import Quickshell.Io
import QtQuick
import "../config.js" as Config

Pill {
    BarText {
        id: clock
        color: Config.colors.pink

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
