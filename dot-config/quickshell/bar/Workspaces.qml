import Quickshell.Hyprland
import Quickshell
import QtQuick
import "../config.js" as Config

Pill {
    id: root
    required property var screen
    padding: 0

    Row {
        Repeater {
            model: ScriptModel {
                values: {
                    const monitor = Hyprland.monitorFor(root.screen);
                    return monitor
                        ? Hyprland.workspaces.values.filter(workspace =>
                            workspace.monitor && workspace.monitor.name === monitor.name
                        )
                        : [];
                }
            }

            delegate: Rectangle {
                id: cont
                required property var modelData
                color: modelData.focused ? Config.theme.primary : "transparent"

                implicitHeight: root.height
                implicitWidth: root.height
                radius: 32

                Text {
                    text: cont.modelData.name
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: cont.modelData.focused ? Config.theme.bg : Config.theme.primary
                    font: Config.font
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: cont.modelData.activate()
                }
            }
        }
    }
}
