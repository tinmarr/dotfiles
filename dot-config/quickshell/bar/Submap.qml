import Quickshell.Hyprland
import QtQuick
import "../config.js" as Config

Pill {
    id: root
    visible: false

    BarText {
        id: text
        color: Config.colors.text
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name == "submap") {
                text.text = event.data;
                root.visible = text.text != "";
            }
        }
    }
}
