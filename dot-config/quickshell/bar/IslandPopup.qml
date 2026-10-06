pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import "../config.js" as Config

// Supply one Item whose implicit size determines the expanded content area.
Item {
    id: root
    default property alias content: body.child

    property Pill pill: null
    property Item sourceItem: parent
    property bool dismissOnOutsideClick: true
    property int padding: 5
    property int horizontalPadding: padding
    readonly property alias headerItem: header
    readonly property bool opened: popupWindow.visible && !popupWindow.closing
    readonly property real headerHeight: pill ? pill.height : 0

    function open() {
        transition.stop();
        popupWindow.closing = false;
        if (popupWindow.visible) {
            transition.start();
        } else {
            popupWindow.visible = true;
        }
    }

    function close(immediate = false) {
        if (!popupWindow.visible)
            return;
        transition.stop();
        popupWindow.closing = true;
        focusGrab.active = false;
        if (immediate) {
            popupWindow.visible = false;
        } else {
            transition.start();
        }
    }

    Component.onDestruction: {
        if (pill && pill.activePopup === root)
            pill.activePopup = null;
    }

    Rectangle {
        parent: root.sourceItem
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        anchors.topMargin: 2
        width: 3
        height: 3
        radius: width / 2
        color: Config.border.color
        visible: root.sourceItem !== null && root.pill !== null && root.pill.activePopup === root
    }

    PopupWindow {
        id: popupWindow

        anchor.window: root.pill ? root.pill.QsWindow.window : root.sourceItem.QsWindow.window
        anchor.onAnchoring: {
            const target = root.pill || root.sourceItem;
            const center = root.pill ? root.pill.width / 2 : root.sourceItem.width / 2;
            const point = target.mapToItem(anchor.window.contentItem, center, root.pill ? 0 : target.height);
            anchor.rect.x = Math.max(0, Math.min(anchor.window.width - popupWindow.width, point.x - popupWindow.width / 2));
            anchor.rect.y = point.y;
            header.x = point.x - anchor.rect.x - header.width / 2;
        }
        implicitWidth: Math.max(root.pill ? root.pill.width + 48 : 80, body.implicitWidth + root.horizontalPadding * 2)
        implicitHeight: body.implicitHeight + root.headerHeight + root.padding * 2
        color: "transparent"
        visible: false
        // Own dismissal so the surface can contract before it is hidden.
        grabFocus: false
        property bool closing: false
        property real reveal: 0

        HyprlandFocusGrab {
            id: focusGrab
            windows: [popupWindow]
            active: false
            onCleared: {
                if (popupWindow.visible && !popupWindow.closing)
                    root.close();
            }
        }

        NumberAnimation {
            id: transition
            target: popupWindow
            property: "reveal"
            to: popupWindow.closing ? 0 : 1
            duration: popupWindow.closing ? 210 : 260
            easing.type: popupWindow.closing ? Easing.InOutCubic : Easing.OutCubic
            onFinished: {
                if (popupWindow.closing) {
                    popupWindow.visible = false;
                } else if (popupWindow.visible) {
                    // Wait until the popup is mapped before grabbing outside clicks.
                    focusGrab.active = root.dismissOnOutsideClick;
                }
            }
        }

        onVisibleChanged: {
            transition.stop();
            closing = false;
            reveal = 0;
            if (visible)
                transition.start();
            if (!root.pill)
                return;
            if (visible) {
                const previous = root.pill.activePopup;
                if (previous && previous !== root)
                    previous.close(true);
                root.pill.activePopup = root;
            } else if (root.pill.activePopup === root) {
                root.pill.activePopup = null;
            }
        }

        Rectangle {
            id: surface
            x: header.x * (1 - popupWindow.reveal)
            width: header.width + (popupWindow.width - header.width) * popupWindow.reveal
            height: root.headerHeight + (popupWindow.height - root.headerHeight) * popupWindow.reveal
            color: Config.theme.bg
            border.color: Config.border.color
            border.width: Config.border.width
            radius: root.headerHeight / 2 + (16 - root.headerHeight / 2) * popupWindow.reveal
        }

        Item {
            id: header
            focus: true
            Keys.onEscapePressed: root.close()
            width: root.pill ? root.pill.width : 0
            height: root.headerHeight
        }

        Item {
            id: revealClip
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: surface.height
            clip: true
        }

        WrapperItem {
            id: body
            parent: revealClip
            opacity: Math.max(0, Math.min(1, (popupWindow.reveal - 0.25) / 0.75))
            enabled: !popupWindow.closing && popupWindow.reveal > 0.7
            x: root.horizontalPadding
            y: root.headerHeight + root.padding
            width: popupWindow.width - root.horizontalPadding * 2
        }
    }
}
