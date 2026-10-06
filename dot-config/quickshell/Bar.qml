import Quickshell
import QtQuick
import qs.bar as Widgets
import "./config.js" as Config

PanelWindow {
    id: root

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

    property int barHeight: 25

    // Leave room below the pills for their antialiased edges.
    implicitHeight: barHeight + 1
    color: "transparent"

    Row {
        height: root.barHeight
        spacing: 5
        anchors.left: parent.left

        Widgets.Icon {}
        Widgets.Workspaces {
            screen: root.screen
        }
        Widgets.Script {
            command: ["weather"]
            ms: 15 * 90 * 1000
            textColor: Config.colors.peach
        }
        Widgets.Voxtype {}
        Widgets.Submap {}
    }

    Widgets.Clock {
        screen: root.screen
        height: root.barHeight
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
    }

    Row {
        height: root.barHeight
        spacing: 5
        anchors.right: parent.right

        Widgets.Tray {}

        Widgets.Script {
            command: ["dualsense"]
            ms: 5 * 60 * 1000
            textColor: Config.colors.lavender
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Quickshell.execDetached(["sh", "-c", "dualsensectl power-off"]);
                }
            }
        }

        Widgets.Script {
            command: ["level"]
            ms: 5 * 60 * 1000
            textColor: Config.colors.lavender
            postfix: " 󰥻"
        }

        Widgets.Pill {
            Widgets.PowerProfiles {}
            Widgets.Battery {}
            Widgets.Brightness {}
        }

        Widgets.Pill {
            Widgets.Audio {}
            Widgets.Bluetooth {}
            Widgets.Network {}
        }

        Widgets.NotificationDND {}
    }
}
