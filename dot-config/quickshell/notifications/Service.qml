pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick
import QtQml.Models

Scope {
    id: root
    property bool paused: false
    property var popups: []
    property var stacks: []
    property var pending: []
    property var criticalBacklog: []
    onPausedChanged: {
        if (paused) {
            for (const popup of popups.slice()) {
                if (!popup.closing && popup.notification.urgency !== NotificationUrgency.Critical) {
                    enqueue(popup.notification);
                    popup.suspend();
                }
            }
        } else {
            const unread = pending.slice();
            pending = [];
            for (const notification of unread)
                show(notification);
        }
    }

    function enqueue(notification) {
        if (!pending.includes(notification))
            pending = [...pending, notification];
    }

    function show(notification) {
        const critical = notification.urgency === NotificationUrgency.Critical;
        const existing = popups.find(p => p.notification === notification);
        criticalBacklog = criticalBacklog.filter(entry => entry.notification !== notification);
        if (critical) {
            for (const popup of popups.slice()) {
                if (popup.critical && !popup.closing && popup.notification !== notification) {
                    if (!criticalBacklog.some(entry => entry.notification === popup.notification))
                        criticalBacklog = [...criticalBacklog, {notification: popup.notification, screen: popup.screen}];
                    popup.suspend();
                }
            }
        }
        if (existing && existing.critical === critical) {
            if (existing.suspended)
                existing.resume();
            else
                existing.restartTimeout();
            return;
        }
        const monitor = Hyprland.focusedMonitor;
        const screen = Quickshell.screens.find(s => monitor && s.name === monitor.name) || Quickshell.screens[0];
        const stack = stacks.find(s => s.targetScreen === screen && s.critical === critical);
        if (!stack) {
            enqueue(notification);
            return;
        }
        if (existing) {
            existing.parent = stack.body;
            existing.screen = screen;
            existing.critical = critical;
            existing.resume();
            return;
        }
        const popup = popupComponent.createObject(stack.body, { notification, screen, critical });
        popups = [...popups, popup];
    }

    // Both queues retain live notifications, so replacements and withdrawals work.
    Instantiator {
        model: root.pending.concat(root.criticalBacklog.map(entry => entry.notification))
        delegate: Connections {
            required property var modelData
            target: modelData
            function onClosed() {
                const notification = target;
                // Updating a queue can destroy this connection delegate.
                const service = root;
                service.pending = service.pending.filter(n => n !== notification);
                service.criticalBacklog = service.criticalBacklog.filter(entry => entry.notification !== notification);
            }
        }
    }

    function closeAll() {
        const criticalUnread = criticalBacklog.slice();
        criticalBacklog = [];
        for (const entry of criticalUnread)
            entry.notification.dismiss();
        for (const popup of popups.slice())
            popup.dismiss();
    }

    function action(index) {
        const popup = popups.filter(p => !p.closing)[index];
        if (popup)
            popup.invokeDefault();
    }

    function remove(popup) {
        popups = popups.filter(p => p !== popup);
        const revealPrevious = popup.critical && !popup.suspended;
        const screen = popup.screen;
        popup.destroy();
        if (revealPrevious) {
            Qt.callLater(() => {
                if (!popups.some(p => p.critical && !p.closing && p.screen === screen)) {
                    const previous = criticalBacklog.filter(entry => entry.screen === screen).pop();
                    if (previous)
                        show(previous.notification);
                }
            });
        }
    }

    function cardsFor(screen, critical) {
        return popups.filter(p => p.screen === screen && p.critical === critical && !(critical && p.suspended));
    }

    function offset(popup) {
        const cards = cardsFor(popup.screen, popup.critical);
        return cards.slice(0, Math.max(0, cards.indexOf(popup))).reduce((sum, p) => sum + p.occupiedHeight, 0);
    }

    NotificationServer {
        actionsSupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        imageSupported: true
        onNotification: notification => {
            notification.tracked = true;
            if (root.paused && notification.urgency !== NotificationUrgency.Critical) {
                root.enqueue(notification);
                return;
            }
            root.pending = root.pending.filter(n => n !== notification);
            root.show(notification);
        }
    }

    Variants {
        model: Quickshell.screens
        NotificationStack {
            required property var modelData
            targetScreen: modelData
        }
    }

    Component {
        id: popupComponent
        NotificationCard {}
    }

    IpcHandler {
        target: "notifications"
        function status(): string {
            const visible = root.popups.filter(p => !p.closing);
            return JSON.stringify({
                paused: root.paused,
                visible: visible.length,
                unread: root.pending.length,
                criticalUnread: root.criticalBacklog.length,
                critical: visible.filter(p => p.critical).length
            });
        }
        function closeAll(): void { root.closeAll(); }
        function togglePaused(): void { root.paused = !root.paused; }
        function clearHistory(): void {
            const unread = root.pending.slice();
            root.pending = [];
            for (const notification of unread)
                notification.dismiss();
        }
        function action(index: int): void { root.action(index); }
    }
}
