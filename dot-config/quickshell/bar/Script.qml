import Quickshell.Io
import QtQuick
import "../config.js" as Config

Pill {
    id: root
    visible: false
    required property list<string> command
    required property int ms
    property string textColor: Config.colors.text
    property string prefix: ""
    property string postfix: ""

    BarText {
        id: weather
        color: root.textColor

        Process {
            id: dateProc
            command: root.command
            running: true

            stdout: StdioCollector {
                onStreamFinished: {
                    weather.text = this.text.trim();
                    root.visible = weather.text != "";

                    weather.text = `${root.prefix}${weather.text}${root.postfix}`;
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
