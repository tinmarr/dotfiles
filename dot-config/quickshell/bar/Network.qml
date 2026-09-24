import Quickshell.Io
import QtQuick
import "../config.js" as Config

Item {
    id: root
    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height
    property string station: "wlan0"

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
        id: getStation
        running: true
        command: ["sh", "-c", "iwctl station list | rg 'wlan\\d' -o"]

        stdout: SplitParser {
            onRead: data => {
                root.station = data;
                setPowerState.running = true;
            }
        }
    }

    Process {
        id: setPowerState
        running: true
        command: ["iwctl", "station", root.station, "show"]

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
        command: ["sh", "-c", `iwctl station ${root.station} show | rg '\s*State\s*(.*)' -or '$1' | tr -d ' '`]

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
        command: ["sh", "-c", `iwctl station ${root.station} show | rg '\s*AverageRSSI\s*(.*) dBm' -or '$1' | tr -d ' '`]

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
