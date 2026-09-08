import Quickshell.Io
import QtQuick
import "../config.js" as Config

Item {
    id: root
    implicitWidth: icon.width
    implicitHeight: childrenRect.height

    BarText {
        id: icon
        color: Config.colors.yellow
    }

    MouseArea {
        anchors.fill: parent
        onClicked: wiremix.running = true
        cursorShape: Qt.PointingHandCursor
    }

    Process {
        id: wiremix
        running: false
        command: ["ghostty", "+new-window", "--title='-float-'", "-e", "wiremix"]
    }

    Process {
        running: true
        command: ["sh", "-c", "pactl subscribe | rg --line-buffered sink"]

        stdout: SplitParser {
            onRead: getInfo.running = true
        }
    }

    Process {
        running: true
        command: ["sh", "-c", "pactl subscribe | rg --line-buffered server"]

        stdout: SplitParser {
            onRead: getInfo.running = true
        }
    }

    Process {
        id: getInfo
        running: true
        command: ["sh", "-c", "pactl --format=json list sinks | jq --arg sink $(pactl get-default-sink) '.[] | select(.name == $sink) | .name, .volume.\"front-left\".value_percent, .mute, .active_port' -r"]

        stdout: StdioCollector {
            onStreamFinished: {
                // name, volume, muted, port
                let values = this.text.split("\n");

                let volDisplay = "";
                let volume = -1;
                if (values[2] == "false") {
                    volDisplay = values[1];
                    volume = parseInt(volDisplay);
                }

                if (/headphones|headset/.test(values[3])) {
                    icon.text = "󰋋";
                    if (volume == -1) {
                        icon.text = "󰟎";
                    }
                } else {
                    switch (Math.floor(volume / 33)) {
                    case -1:
                        icon.text = "󰝟";
                        break;
                    case 0:
                        icon.text = "󰕿";
                        break;
                    case 1:
                        icon.text = "󰖀";
                        break;
                    case 2:
                    default:
                        icon.text = "󰕾";
                        break;
                    }
                }

                if (values[0].includes("bluez"))
                    icon.text += "󰂯";

                if (volDisplay) {
                    icon.text = `${volDisplay} ${icon.text}`;
                }
            }
        }
    }
}
