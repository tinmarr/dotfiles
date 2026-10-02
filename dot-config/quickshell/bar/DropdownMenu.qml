pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../config.js" as Config

Item {
    id: root
    anchors.fill: parent

    property var model: []
    property QsMenuHandle menuHandle: null
    property QsMenuHandle currentMenu: menuHandle
    property var menuHistory: []
    property int cursorShape: Qt.ArrowCursor

    // Keep the entry owning each submenu alive while navigating its children.
    QsMenuOpener {
        menu: root.menuHandle
    }

    Instantiator {
        model: ScriptModel {
            values: root.menuHistory
        }

        delegate: QsMenuOpener {
            required property var modelData
            menu: modelData
        }
    }

    QsMenuOpener {
        id: menuOpener
        menu: root.currentMenu
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        cursorShape: root.cursorShape

        onClicked: mouse => {
            root.currentMenu = root.menuHandle;
            root.menuHistory = [];
            contextMenu.visible = true;
        }
    }

    PopupWindow {
        id: contextMenu

        anchor.window: root.QsWindow.window
        anchor.rect.y: anchor.window ? anchor.window.height : 0
        anchor.onAnchoring: {
            anchor.rect.x = root.mapToItem(anchor.window.contentItem, 0, 0).x;
        }
        implicitWidth: actions.implicitWidth + (Config.border.width * 2)
        implicitHeight: actions.implicitHeight + (Config.border.width * 2)
        color: "transparent"
        visible: false
        grabFocus: true

        WrapperRectangle {
            id: actions

            color: Config.theme.bg
            border.color: Config.colors.lavender
            border.width: Config.border.width
            radius: 5

            margin: Config.border.width

            ColumnLayout {
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    visible: root.menuHistory.length > 0
                    text: "󰅁 Back"
                    color: Config.colors.lavender
                    padding: 3

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            const history = root.menuHistory.slice();
                            root.currentMenu = history.pop();
                            root.menuHistory = history;
                        }
                    }
                }

                Repeater {
                    id: repeat
                    model: root.menuHandle ? menuOpener.children : root.model

                    delegate: Rectangle {
                        id: action
                        Layout.fillWidth: true
                        required property int index
                        required property var modelData
                        readonly property bool separator: root.menuHandle && modelData.isSeparator
                        color: Config.theme.bg
                        implicitWidth: separator ? 30 : actionContent.implicitWidth
                        implicitHeight: separator ? Config.border.width + 6 : actionContent.implicitHeight

                        Rectangle {
                            visible: action.separator
                            anchors.centerIn: parent
                            width: parent.width
                            height: Config.border.width
                            color: Config.colors.surface2
                        }

                        ColumnLayout {
                            id: actionContent
                            anchors.fill: parent
                            spacing: 0
                            visible: !action.separator

                            Text {
                                Layout.alignment: Qt.Left | Qt.AlignVCenter
                                text: root.menuHandle ? (action.modelData.checkState === Qt.Checked ? "󰄬 " : "") + action.modelData.text + (action.modelData.hasChildren ? " 󰅂" : "") : action.modelData.label
                                font.family: Config.font.family
                                font.pointSize: Config.font.pointSize - 1
                                color: Config.colors.lavender
                                opacity: root.menuHandle && !action.modelData.enabled ? 0.5 : 1
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.Left
                                padding: 3
                            }

                            Rectangle {
                                visible: !root.menuHandle && repeat.count - 1 != action.index
                                Layout.fillWidth: true

                                height: Config.border.width
                                color: Config.colors.surface2
                            }
                        }

                        MouseArea {
                            id: hitbox
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: !action.separator && (!root.menuHandle || action.modelData.enabled)
                            onClicked: {
                                if (root.menuHandle && action.modelData.hasChildren) {
                                    root.menuHistory = root.menuHistory.concat([root.currentMenu]);
                                    root.currentMenu = action.modelData;
                                    return;
                                }
                                contextMenu.visible = false;
                                if (root.menuHandle) {
                                    action.modelData.triggered();
                                } else {
                                    Quickshell.execDetached(action.modelData.command);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
