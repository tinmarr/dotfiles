pragma Singleton
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import "../widgets" as Widgets
import QtQuick

Singleton {
    id: root
    property var adapter: Bluetooth.defaultAdapter
    property bool agentReady: false
    property var prompt: null
    property string error: ""
    function reply(accept, value = "") { agent.request("reply", {accept: accept, value: value}); }
    function cancelPrompt() { agent.request("cancel"); }
    Widgets.JsonProcess {
        id: agent
        label: "Bluetooth agent"
        property string failure: ""
        stderr: SplitParser {
            onRead: data => {
                agent.failure = data;
                console.warn("Bluetooth agent: " + data);
            }
        }
        command: ["python", "-u", Qt.resolvedUrl("agent.py").toString().replace("file://", "")]
        onResponse: update => {
            if (Object.prototype.hasOwnProperty.call(update, "ready")) root.agentReady = update.ready;
            if (Object.prototype.hasOwnProperty.call(update, "prompt")) root.prompt = update.prompt;
            if (Object.prototype.hasOwnProperty.call(update, "error")) root.error = update.error;
        }
        onInvalidResponse: root.error = "Invalid Bluetooth agent response."
        onBackendExited: {
            root.agentReady = false;
            root.prompt = null;
            root.error = "Bluetooth agent stopped." + (agent.failure ? " " + agent.failure : "") + " Restart Quickshell to retry.";
        }
    }
    property bool ownsScan: false
    signal toggleRequested()

    function scan() {
        if (!adapter || !adapter.enabled) return;
        if (ownsScan) stopScan();
        else if (!adapter.discovering) {
            adapter.discovering = true;
            ownsScan = true;
            scanTimeout.restart();
        }
    }
    function stopScan() {
        if (ownsScan && adapter) adapter.discovering = false;
        ownsScan = false;
        scanTimeout.stop();
    }
    Timer { id: scanTimeout; interval: 60000; onTriggered: root.stopScan() }
    IpcHandler {
        target: "bluetooth"
        function toggle(): void { root.toggleRequested(); }
    }
}
