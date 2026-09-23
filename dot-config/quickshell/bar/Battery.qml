import Quickshell.Services.UPower
import QtQuick
import "../config.js" as Config

Item {
    id: root
    implicitWidth: icon.width
    implicitHeight: childrenRect.height

    BarText {
        id: icon
        color: Config.colors.green
        text: {
            let dev = UPower.displayDevice;

            if (!dev.isLaptopBattery) return "";

            let glyphs = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"];

            return Math.round(dev.percentage * 100) + "% " + glyphs[Math.round(dev.percentage * 10)];
        }
    }
}
