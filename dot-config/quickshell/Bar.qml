import Quickshell
import Quickshell.Wayland
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

    color: "transparent"
    property int barHeight: 25

    // One stable surface holds both the bar and its expanded menus.
    implicitHeight: screen ? screen.height - margins.top : barHeight + 1
    exclusiveZone: barHeight + 1
    property var popups: []
    property alias popupLayer: popupLayer
    readonly property bool menuOpen: popups.some(popup => popup.opened && popup.dismissOnOutsideClick)
    WlrLayershell.keyboardFocus: menuOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    mask: Region {
        width: root.width
        height: root.menuOpen ? root.height : barStrip.height
        regions: root.popups.map(popup => popup.inputRegion)
    }
    function addPopup(popup) {
        if (!popups.includes(popup)) popups = [...popups, popup];
    }
    function removePopup(popup) {
        popups = popups.filter(item => item !== popup);
    }
    MouseArea {
        anchors.fill: parent
        visible: root.menuOpen
        acceptedButtons: Qt.AllButtons
        onPressed: {
            for (const popup of root.popups)
                if (popup.dismissOnOutsideClick) popup.close();
        }
    }
    Item {
        id: popupLayer
        anchors.fill: parent
    }
    Item {
        id: barStrip
        width: parent.width
        height: root.barHeight + 1

        TapHandler {
            onTapped: eventPoint => {
                for (const popup of root.popups) {
                    const target = popup.pill || popup.sourceItem;
                    if (popup.dismissOnOutsideClick && target && !target.contains(target.mapFromItem(barStrip, eventPoint.position))) popup.close();
                }
            }
        }

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
                id: connectivityPill
                Widgets.Audio { pill: connectivityPill; screenName: root.screen.name }
                Widgets.Bluetooth { pill: connectivityPill; screenName: root.screen.name }
                Widgets.Network { pill: connectivityPill; screenName: root.screen.name }
            }

            Widgets.NotificationDND {}
        }
    }
}
