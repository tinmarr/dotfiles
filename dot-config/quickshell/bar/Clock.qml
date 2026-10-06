import Quickshell.Io
import QtQuick
import "../notifications" as Notifications
import "../config.js" as Config

Pill {
    id: root
    required property var screen
    property var criticalPopup: Notifications.CriticalNotifications {
        pill: root
        targetScreen: root.screen
    }

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
