pragma ComponentBehavior: Bound

import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick

Pill {
    id: root
    padding: 5

    Row {
        id: row

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
