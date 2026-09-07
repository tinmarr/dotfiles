import QtQuick
import "../config.js" as Config

Rectangle {
    default property alias contentData: content.data

    property bool square: false
    property int padding: parent.height / 2

    border.color: Config.border.color
    border.width: Config.border.width
    radius: parent.height / 2

    color: Config.theme.bg

    implicitHeight: parent.height
    implicitWidth: square ? parent.height : content.implicitWidth + (padding * 2)

    Row {
        id: content

        spacing: 10
        anchors.centerIn: parent
    }
}
