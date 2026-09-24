import Quickshell.Services.UPower
import QtQuick
import "../config.js" as Config

Item {
    id: root
    implicitWidth: icon.width
    implicitHeight: childrenRect.height

    BarText {
        id: icon
        color: Config.colors.peach
        text: {
            root.visible = PowerProfiles.hasPerformanceProfile;
            switch (PowerProfiles.profile) {
            case PowerProfile.Performance:
                return "󱐋";
            case PowerProfile.PowerSaver:
                return "󰌪";
            case PowerProfile.Balanced:
                return "󰗑";
            default:
                return "";
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            switch (PowerProfiles.profile) {
            case PowerProfile.Performance:
                PowerProfiles.profile = PowerProfile.Balanced;
                break;
            case PowerProfile.Balanced:
                PowerProfiles.profile = PowerProfile.PowerSaver;
                break;
            case PowerProfile.PowerSaver:
                PowerProfiles.profile = PowerProfile.Performance;
                break;
            }
        }
    }
}
