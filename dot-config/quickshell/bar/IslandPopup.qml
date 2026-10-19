pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import QtQuick
import "../config.js" as Config

// Expanded content shares the bar's surface; the live pill never moves.
Item {
    id: root
    default property alias content: body.child

    property string title: ""
    property Pill pill: null
    property Item sourceItem: parent
    property bool dismissOnOutsideClick: true
    property bool dismissOnEscape: true
    property real cornerRadius: 16
    property int padding: 5
    property int horizontalPadding: padding
    readonly property real headerHeight: pill ? pill.height : 0
    readonly property real expandedHeight: body.implicitHeight + headerHeight + padding * 2
    readonly property bool opened: scene.visible && !closing
    readonly property var host: (pill || sourceItem)?.QsWindow.window ?? null
    readonly property Region inputRegion: Region { item: surface }
    property bool closing: false

    function open() {
        if (!host) return;
        transition.stop();
        host.addPopup(root);
        if (pill) pill.attachPopup(root);
        closing = false;
        scene.visible = true;
        transition.start();
    }
    function close(immediate = false) {
        if (!scene.visible) return;
        transition.stop();
        closing = true;
        if (immediate) finishClose();
        else transition.start();
    }
    function finishClose() {
        scene.visible = false;
        if (pill) pill.detachPopup(root);
        if (host) host.removePopup(root);
    }
    Component.onDestruction: {
        if (pill) pill.detachPopup(root);
        if (host) host.removePopup(root);
    }

    Rectangle {
        parent: root.sourceItem
        anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
        anchors.top: parent ? parent.bottom : undefined
        anchors.topMargin: 2
        width: 3
        height: 3
        radius: width / 2
        color: Config.border.color
        visible: root.opened && root.pill !== null
    }

    FocusScope {
        id: scene
        parent: root.host ? root.host.popupLayer : null
        visible: false
        focus: root.dismissOnEscape
        property real reveal: 0
        readonly property Item target: root.pill || root.sourceItem
        // The bar uses translated layouts. Read each ancestor so this binding
        // follows Row positioning, including its first layout and later resizes.
        readonly property rect targetRect: {
            if (!target || !parent) return Qt.rect(0, 0, 0, 0);
            let x = 0, y = 0;
            for (let item = target; item && item !== parent; item = item.parent) {
                x += item.x;
                y += item.y;
            }
            return Qt.rect(x, y, target.width, target.height);
        }
        readonly property real headerX: targetRect.x - x
        x: Math.round(Math.max(0, Math.min(parent ? parent.width - width : 0,
            targetRect.x + targetRect.width / 2 - width / 2)))
        y: root.pill ? targetRect.y : targetRect.y + targetRect.height
        width: Math.max(root.pill ? root.pill.width + 48 : 80, body.implicitWidth + root.horizontalPadding * 2)
        height: root.expandedHeight
        Keys.onEscapePressed: { if (root.dismissOnEscape) root.close(); }

        NumberAnimation {
            id: transition
            target: scene
            property: "reveal"
            to: root.closing ? 0 : 1
            duration: root.closing ? 210 : 260
            easing.type: root.closing ? Easing.InOutCubic : Easing.OutCubic
            onFinished: {
                if (root.closing) root.finishClose();
            }
        }

        Rectangle {
            id: surface
            x: scene.headerX * (1 - scene.reveal)
            width: (root.pill ? root.pill.width : 0) * (1 - scene.reveal) + scene.width * scene.reveal
            height: root.headerHeight + (root.expandedHeight - root.headerHeight) * scene.reveal
            color: Config.theme.bg
            border.color: Config.border.color
            border.width: Config.border.width
            radius: root.headerHeight / 2 + (root.cornerRadius - root.headerHeight / 2) * scene.reveal
        }

        Item {
            id: revealClip
            x: surface.x
            width: surface.width
            height: surface.height
            clip: true
        }
        Text {
            parent: revealClip
            x: root.horizontalPadding - revealClip.x
            width: Math.max(0, scene.headerX - root.horizontalPadding * 2)
            height: root.headerHeight
            text: root.title
            color: Config.border.color
            font.bold: true
            font.family: Config.font.family
            font.pointSize: Config.font.pointSize
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            opacity: body.opacity
        }
        WrapperItem {
            id: body
            parent: revealClip
            opacity: Math.max(0, Math.min(1, (scene.reveal - 0.25) / 0.75))
            enabled: !root.closing && scene.reveal > 0.7
            x: root.horizontalPadding - revealClip.x
            y: root.headerHeight + root.padding
            width: scene.width - root.horizontalPadding * 2
        }
    }
}
