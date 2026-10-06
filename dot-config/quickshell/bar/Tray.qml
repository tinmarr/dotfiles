pragma ComponentBehavior: Bound

import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick

Pill {
    id: root
    padding: 5
    visible: false

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

                child: IconImage {
                    source: cont.modelData.icon
                    mipmap: true

                    DropdownMenu {
                        parentPill: root
                        enabled: cont.modelData.hasMenu
                        cursorShape: Qt.PointingHandCursor
                        menuHandle: cont.modelData.menu
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                        cursorShape: Qt.PointingHandCursor

                        onClicked: mouse => {
                            if (mouse.button == Qt.LeftButton) {
                                cont.modelData.activate();
                            }
                            if (mouse.button == Qt.MiddleButton) {
                                cont.modelData.secondaryActivate();
                            }
                        }
                    }
                }
            }

            onCountChanged: {
                root.visible = count > 0;
            }
        }
    }
}
