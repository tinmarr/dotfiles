import QtQuick
import QtQuick.Controls
import "../config.js" as Config

Button {
    id: root
    font.family: Config.font.family
    font.pointSize: Config.font.pointSize
    focusPolicy: Qt.NoFocus
    padding: 7
    horizontalPadding: 10
    contentItem: Text {
        text: root.text
        font: root.font
        color: root.enabled ? Config.colors.text : Config.colors.overlay0
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    background: Rectangle {
        radius: 5
        color: root.down || root.highlighted ? Config.colors.surface1 : root.hovered ? Config.colors.surface0 : "transparent"
    }
    Accessible.name: text
}
