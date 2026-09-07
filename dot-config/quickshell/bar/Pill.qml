import Quickshell
import QtQuick
import "../config.js" as Config

Rectangle {
    border.color: Config.border.color
    border.width: Config.border.width
    radius: 32

    color: Config.theme.bg

    implicitHeight: parent.height
    implicitWidth: childrenRect.width + parent.height
}
