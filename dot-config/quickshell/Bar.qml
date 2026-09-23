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
            Widgets.Script {
                command: ["weather"]
                ms: 15 * 90 * 1000
            }
            Widgets.Voxtype {}
            Widgets.Submap {}
        }

        Widgets.Clock {
            anchors.centerIn: parent
        }

        Row {
            height: parent.height
            spacing: 5
            anchors.right: parent.right

            Widgets.Tray {}

            Widgets.Script {
                command: ["dualsense"]
                ms: 5 * 60 * 1000
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Quickshell.execDetached(["sh", "-c", "dualsensectl power-off && killall -SIGUSR2 waybar"]);
                    }
                }
            }

            Widgets.Script {
                command: ["level"]
                ms: 5 * 60 * 1000
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
        }
    }
}
