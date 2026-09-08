import Quickshell
import QtQuick
import qs.bar as Widgets

Scope {
    id: root

    PanelWindow {
        anchors {
            top: true
            left: true
            right: true
        }

        margins {
            top: 5
            left: 10
            right: 10
        }

        implicitHeight: 25
        color: "transparent"

        Row {
            height: parent.height
            spacing: 5
            anchors.left: parent.left

            Widgets.Icon {}

            Widgets.Workspaces {}
        }

        Widgets.Clock {
            anchors.centerIn: parent
        }

        Row {
            height: parent.height
            spacing: 5
            anchors.right: parent.right

            Widgets.Tray {}

            Widgets.Pill {
                Widgets.Audio {}
                Widgets.Bluetooth {}
                Widgets.Network {}
            }
        }
    }
}
