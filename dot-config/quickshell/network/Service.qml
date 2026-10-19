pragma Singleton
import Quickshell
import Quickshell.Io
import "../widgets" as Widgets
import QtQuick

Singleton {
    id: root
    property var devices: []
    property var networks: []
    property string device: ""
    property string state: "unavailable"
    property bool powered: false
    property bool scanning: false
    property bool busy: false
    property string error: ""
    property string prompt: ""
    signal toggleRequested()
    function send(action, args = {}) {
        if (!backend.running) { error = "Wi-Fi service stopped. Reopen the popup to retry."; return; }
        backend.request(action, args);
    }
    function refresh() { backend.refresh(); }
    Widgets.JsonProcess {
        id: backend
        label: "Wi-Fi"
        command: ["python", "-u", Qt.resolvedUrl("backend.py").toString().replace("file://", "")]
        onInvalidResponse: root.error = "Invalid Wi-Fi service response."
        onResponse: update => {
            for (const key of ["devices", "networks", "device", "state", "powered", "scanning", "busy", "error", "prompt"])
                if (Object.prototype.hasOwnProperty.call(update, key)) root[key] = update[key];
        }
        onBackendExited: { root.busy = false; root.prompt = ""; root.state = "unavailable"; root.error = "Wi-Fi service stopped. Requires python-gobject and iwd."; }
    }
    IpcHandler {
        target: "network"
        function toggle(): void { root.toggleRequested(); }
    }
}
