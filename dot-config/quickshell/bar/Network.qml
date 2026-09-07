import Quickshell.Io
import QtQuick
import "../config.js" as Config

Item {
    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height

    BarText {
        id: icon
        color: Config.colors.maroon
    }

    MouseArea {
        anchors.fill: parent
        onClicked: impala.running = true
        cursorShape: Qt.PointingHandCursor
    }

    Process {
        running: true
        command: ["gdbus", "monitor", "--system", "--dest", "net.connman.iwd"]

        stdout: SplitParser {
            onRead: setPowerState.running = true
        }
    }

    Process {
        id: impala
        running: false
        command: ["ghostty", "+new-window", "--title='-float-'", "-e", "impala"]
    }

    Process {
        id: setPowerState
        running: true
        command: ["iwctl", "station", "wlan0", "show"]

        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text.startsWith("No station")) {
                    icon.text = "";
                } else {
                    setState.running = true;
                }
            }
        }
    }

    Process {
        id: setState
        running: false
        command: ["sh", "-c", "iwctl station wlan0 show | rg '\s*State\s*(.*)' -or '$1' | tr -d ' '"]

        stdout: SplitParser {
            onRead: data => {
                switch (data) {
                case "connected":
                    setRSSI.running = true;
                    break;
                case "connecting":
                    icon.text = "󰓦";
                    break;
                case "disconnected":
                    icon.text = "󰤮";
                    break;
                }
            }
        }
    }

    Process {
        id: setRSSI
        running: false
        command: ["sh", "-c", "iwctl station wlan0 show | rg '\s*AverageRSSI\s*(.*) dBm' -or '$1' | tr -d ' '"]

        stdout: SplitParser {
            onRead: data => {
                let rssi = parseInt(data);

                if (rssi > -50) {
                    icon.text = "󰤨";
                } else if (rssi > -60) {
                    icon.text = "󰤥";
                } else if (rssi > -67) {
                    icon.text = "󰤢";
                } else if (rssi > -80) {
                    icon.text = "󰤟";
                } else {
                    icon.text = "󰤯";
                }
            }
        }
    }
}
