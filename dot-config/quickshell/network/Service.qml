pragma Singleton
import Quickshell
import Quickshell.Io
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
        args.action = action;
        backend.write(JSON.stringify(args) + "\n");
    }
    function refresh() {
        if (!backend.running) backend.running = true;
        else send("refresh");
    }
    Process {
        id: backend
        command: ["python", "-u", Qt.resolvedUrl("backend.py").toString().replace("file://", "")]
        running: true
        stdinEnabled: true
        stdout: SplitParser {
            onRead: data => {
                try {
                    const update = JSON.parse(data);
                    for (const key of Object.keys(update)) root[key] = update[key];
                } catch (error) { root.error = "Invalid Wi-Fi service response."; }
            }
        }
        stderr: SplitParser { onRead: data => console.warn("Wi-Fi backend: " + data) }
        onExited: { root.busy = false; root.prompt = ""; root.state = "unavailable"; root.error = "Wi-Fi service stopped. Requires python-gobject and iwd."; }
    }
    IpcHandler {
        target: "network"
        function toggle(): void { root.toggleRequested(); }
    }
}
