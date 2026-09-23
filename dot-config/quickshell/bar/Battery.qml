import Quickshell.Services.UPower
import QtQuick
import "../config.js" as Config

Item {
    id: root
    implicitWidth: icon.width
    implicitHeight: childrenRect.height

    BarText {
        id: icon
        text: {
            let dev = UPower.displayDevice;

            if (!dev.isLaptopBattery)
                return "";

            let glyphs;
            if (UPower.onBattery) {
                glyphs = ["󰂎", "󱊡", "󱊢", "󱊣"];
            } else {
                glyphs = ["󰢟", "󱊤", "󱊥", "󱊦"];
            }

            color = dev.percentage <= .2 ? "#FF0000" : Config.colors.green;

            return Math.round(dev.percentage * 100) + "% " + glyphs[Math.ceil(dev.percentage * 10 / 4)];
        }
    }
}
