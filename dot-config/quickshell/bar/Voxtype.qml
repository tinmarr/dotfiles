import Quickshell.Io
import QtQuick
import "../config.js" as Config

Pill {
    id: root
    visible: false

    BarText {
        id: icon
    }

    Process {
        id: getInfo
        command: ["sh", "-c", "voxtype status --follow --format json"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                data = data.trim();
                root.visible = true;
                switch (JSON.parse(data).class) {
                case "recording":
                    icon.text = "󰍬";
                    icon.color = Config.colors.red;
                    break;
                case "transcribing":
                    icon.text = "";
                    icon.color = Config.colors.yellow;
                    break;
                default:
                    root.visible = false;
                }
            }
        }
    }
}
