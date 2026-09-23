import Quickshell.Io
import QtQuick
import "../config.js" as Config

Pill {
    id: root
    visible: false
    required property list<string> command
    required property int ms

    BarText {
        id: weather
        color: Config.colors.peach

        Process {
            id: dateProc
            command: root.command
            running: true

            stdout: StdioCollector {
                onStreamFinished: {
                    weather.text = this.text.trim();
                    root.visible = weather.text != "";
                }
            }
        }

        Timer {
            interval: root.ms
            running: true
            repeat: true
            onTriggered: dateProc.running = true
        }
    }
}
