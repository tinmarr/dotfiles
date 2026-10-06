import QtQuick
import "../notifications"
import "../config.js" as Config

Pill {
    visible: Service.paused
    BarText {
        text: "󰂛"
        color: Config.colors.blue
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Service.paused = false
        }
    }
}
