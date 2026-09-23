import Quickshell.Io
import QtQuick
import "../config.js" as Config

Item {
    id: root
    implicitWidth: icon.width
    implicitHeight: childrenRect.height

    BarText {
        id: icon
        color: Config.colors.sky
    }

    Process {
        id: watchBrightness
        command: ["udevadm", "monitor", "--property", "--subsystem-match=backlight"]
        running: true

        stdout: SplitParser {
            onRead: line => {
                getBrightness.running = true;
            }
        }
    }

    Process {
        id: getBrightness
        command: ["sh", "-c", "brightnessctl -d amdgpu_bl1 -m | cut -d, -f4"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                icon.text = this.text.trim() + " 󰃠";
            }
        }
    }
}
