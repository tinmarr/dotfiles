import Quickshell.Io
import QtQuick
import "../config.js" as Config

Pill {
    id: root

    BarText {
        text: "󰂛"
        color: Config.colors.blue
    }

    Process {
        id: monitor
        running: true
        command: ["dbus-monitor", "path='/org/freedesktop/Notifications',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged'", "--profile"]
        stdout: SplitParser {
            onRead: _ => getStatus.running = true
        }
    }

    Process {
        id: getStatus
        running: true
        command: ["dunstctl", "is-paused"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.visible = this.text.trim() == "true";
            }
        }
    }
}
