import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick
import "../config.js" as Config

Pill {
    id: root
    implicitWidth: row.childrenRect.width + 10

    Row {
        id: row
        anchors.centerIn: parent

        Repeater {
            model: SystemTray.items

            delegate: WrapperItem {
                id: cont
                required property var modelData

                implicitHeight: root.height
                implicitWidth: root.height

                margin: 4

                IconImage {
                    source: cont.modelData.icon
                    anchors.centerIn: parent
                    mipmap: true
                }
            }
        }
    }
}
