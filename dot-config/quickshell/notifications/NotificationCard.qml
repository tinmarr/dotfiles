import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import "../config.js" as Config

Item {
    id: root
    required property Notification notification
    required property var screen
    required property bool critical
    property bool closing: false
    property bool suspended: false
    property real reveal: 0
    readonly property var siblings: Service.cardsFor(screen, critical)
    // Once joined to a stack, expand vertically so shared edges stay aligned.
    property bool stacked: false
    onSiblingsChanged: { if (siblings.length > 1) stacked = true; }
    readonly property var nextSibling: siblings[siblings.indexOf(root) + 1] || null
    readonly property real bottomRoundness: nextSibling ? 1 - nextSibling.reveal : 1
    Behavior on topPadding {
        NumberAnimation { duration: 210; easing.type: Easing.InOutCubic }
    }
    property real topPadding: siblings.indexOf(root) <= 0 ? 14 : 8
    readonly property real bottomPadding: 8 + 6 * bottomRoundness
    readonly property real expandedHeight: content.implicitHeight + topPadding + bottomPadding
    readonly property real occupiedHeight: critical && siblings.every(p => p.closing)
        ? expandedHeight : stacked ? expandedHeight * reveal : expandedHeight
    readonly property color accent: notification.urgency === NotificationUrgency.Critical
        ? Config.colors.red : notification.urgency === NotificationUrgency.Low
        ? Config.colors.lavender : Config.theme.primary
    readonly property real timeout: notification.urgency === NotificationUrgency.Critical
        ? 0 : notification.expireTimeout < 0 ? 10000 : notification.expireTimeout

    visible: !critical || !suspended
    width: parent.width
    height: occupiedHeight
    y: Service.offset(root)

    function suspend() {
        suspended = true;
        closing = true;
        expiry.stop();
        transition.restart();
    }
    function resume() {
        suspended = false;
        closing = false;
        transition.restart();
        restartTimeout();
    }

    function restartTimeout() {
        expiry.stop();
        if (timeout > 0 && !closing && !hover.containsMouse)
            expiry.start();
    }
    function dismiss() {
        if (!closing)
            notification.dismiss();
    }
    function invokeDefault() {
        if (closing)
            return;
        const action = notification.actions.find(a => a.identifier === "default") || notification.actions[0];
        if (action)
            action.invoke();
        else
            dismiss();
    }

    RetainableLock { object: root.notification; locked: true }
    Connections {
        target: root.notification
        function onClosed() {
            if (root.closing && !root.suspended)
                return;
            root.suspended = false;
            root.closing = true;
            expiry.stop();
            transition.restart();
        }
        function onExpireTimeoutChanged() { root.restartTimeout(); }
    }
    Timer {
        id: expiry
        interval: Math.max(1, root.timeout)
        onTriggered: root.notification.expire()
    }
    NumberAnimation {
        id: transition
        target: root
        property: "reveal"
        to: root.closing ? 0 : 1
        duration: root.closing ? 210 : 260
        easing.type: root.closing ? Easing.InOutCubic : Easing.OutCubic
        onFinished: { if (root.closing) Service.remove(root); }
    }
    Component.onCompleted: { transition.start(); restartTimeout(); }

    Item {
        id: surface
        width: root.width
        height: root.height
        clip: true

        Rectangle {
            visible: root.bottomRoundness < 1
            anchors.bottom: parent.bottom
            x: Config.border.width
            width: parent.width - Config.border.width
            height: Config.border.width
            color: Config.colors.surface2
            opacity: root.reveal * (1 - root.bottomRoundness)
        }
        MouseArea {
            id: hover
            anchors.fill: parent
            hoverEnabled: true
            onContainsMouseChanged: {
                if (containsMouse) expiry.stop();
                else root.restartTimeout();
            }
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: event => {
                if (event.button === Qt.RightButton) root.dismiss();
                else root.invokeDefault();
            }
        }
        Column {
            id: content
            x: 12
            y: root.topPadding
            width: root.width - 24
            spacing: 2
            opacity: Math.max(0, (root.reveal - 0.25) / 0.75)
            enabled: !root.closing && root.reveal > 0.7

            Row {
                width: parent.width
                spacing: 6
                Image {
                    width: 16; height: 16
                    visible: source.toString() !== ""
                    source: root.notification.appIcon
                        ? (root.notification.appIcon.includes(":") || root.notification.appIcon.startsWith("/")
                            ? root.notification.appIcon : Quickshell.iconPath(root.notification.appIcon)) : ""
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    width: parent.width - (root.notification.appIcon ? 22 : 0)
                    text: root.notification.appName || "Notification"
                    textFormat: Text.PlainText
                    elide: Text.ElideRight
                    color: root.accent
                    font.family: Config.font.family
                    font.pointSize: Config.font.pointSize
                }
            }
            Text {
                width: parent.width
                text: root.notification.summary
                textFormat: Text.PlainText
                color: Config.theme.text
                font.family: Config.font.family
                font.pointSize: Config.font.pointSize
                font.bold: true
                wrapMode: Text.Wrap
                maximumLineCount: 3
                elide: Text.ElideRight
            }
            Text {
                width: parent.width
                visible: text !== ""
                text: root.notification.body
                textFormat: Text.StyledText
                color: Config.colors.subtext1
                linkColor: root.accent
                font.family: Config.font.family
                font.pointSize: Config.font.pointSize
                wrapMode: Text.Wrap
                maximumLineCount: 4
                elide: Text.ElideRight
                onLinkActivated: link => Qt.openUrlExternally(link)
            }
            Image {
                visible: source.toString() !== ""
                source: root.notification.image
                width: parent.width
                height: visible ? 100 : 0
                fillMode: Image.PreserveAspectFit
            }
            Rectangle {
                visible: root.notification.hints.value !== undefined
                width: parent.width
                height: visible ? 4 : 0
                radius: 2
                color: Config.colors.surface1
                Rectangle {
                    width: parent.width * Math.max(0, Math.min(100, Number(root.notification.hints.value || 0))) / 100
                    height: parent.height
                    radius: 2
                    color: root.accent
                }
            }
            Flow {
                width: parent.width
                spacing: 6
                Repeater {
                    model: root.notification.actions
                    Rectangle {
                        required property var modelData
                        visible: modelData.identifier !== "default"
                        width: visible ? label.implicitWidth + 18 : 0
                        height: visible ? 26 : 0
                        radius: 13
                        color: actionMouse.containsMouse ? Config.colors.surface1 : Config.colors.surface0
                        Text {
                            id: label
                            anchors.centerIn: parent
                            text: modelData.text
                            color: root.accent
                            font.family: Config.font.family
                            font.pointSize: Config.font.pointSize
                        }
                        MouseArea {
                            id: actionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { if (!root.closing) modelData.invoke(); }
                        }
                    }
                }
            }
        }
    }
}
