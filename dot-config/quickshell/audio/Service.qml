pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: root
    property var metadata: ({"sinks": [], "sources": [], "sink-inputs": [], "source-outputs": [], "cards": []})
    readonly property var nodes: Pipewire.nodes.values.filter(node => node.audio !== null)
    readonly property var groups: ({
        "sinks": entries("sinks", false, true),
        "sources": entries("sources", false, false),
        "sink-inputs": entries("sink-inputs", true, true),
        "source-outputs": entries("source-outputs", true, false),
        "cards": metadata.cards || []
    })
    PwObjectTracker { objects: root.nodes }
    function entries(kind, stream, sink) {
        return nodes.filter(node => node.ready && node.isStream === stream && node.isSink === sink
                            && (stream || node.properties["device.class"] !== "monitor"))
            .map(node => {
                const extra = (metadata[kind] || []).find(item => item.serial === String(node.properties["object.serial"]))
                    || (!stream ? (metadata[kind] || []).find(item => item.name === node.name) : null);
                const targetKind = kind === "sink-inputs" ? "sinks" : "sources";
                const route = extra ? (metadata[targetKind] || []).find(device => device.id === extra.device) : null;
                const target = route ? nodes.find(target => String(target.properties["object.serial"]) === route.serial) : null;
                return {
                    id: String(node.id), node: node, name: node.name,
                    label: (stream ? node.properties["application.name"] || node.properties["media.name"] : node.description || node.nickname) || node.name,
                    // Read live state at the UI binding, without rebuilding the list.
                    get volume() { return Math.round(node.audio.volume * 100); },
                    get muted() { return node.audio.muted; },
                    get default() { return node === (sink ? Pipewire.defaultAudioSink : Pipewire.defaultAudioSource); },
                    bridgeId: extra ? extra.id : "", device: target ? String(target.id) : "",
                    ports: extra ? extra.ports : [], port: extra ? extra.port : ""
                };
            });
    }
    property string error: ""
    signal toggleRequested()
    function send(action, args = {}) {
        const item = (groups[args.kind] || []).find(entry => entry.id === args.id);
        if (["volume", "mute", "default"].includes(action)) {
            if (!item || !item.node) return;
            if (action === "volume") item.node.audio.volume = Math.max(0, Math.min(150, args.value)) / 100;
            else if (action === "mute") item.node.audio.muted = !item.node.audio.muted;
            else if (args.kind === "sinks") Pipewire.preferredDefaultAudioSink = item.node;
            else if (args.kind === "sources") Pipewire.preferredDefaultAudioSource = item.node;
            return;
        }
        if (!backend.running) { error = "Audio configuration bridge stopped. Reopen the popup to retry."; return; }
        if (action !== "refresh") {
            if (!item) return;
            if (action !== "profile") {
                if (!item.bridgeId) { error = "This native PipeWire stream does not support pactl configuration."; return; }
                args.id = item.bridgeId;
            }
            if (action === "move") {
                const target = (groups[args.kind === "sink-inputs" ? "sinks" : "sources"] || []).find(entry => entry.id === args.value);
                if (!target || !target.bridgeId) { error = "Routing destination unavailable."; return; }
                args.value = target.bridgeId;
            }
        }
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
                    for (const key of Object.keys(update)) {
                        if (key !== "metadata" || JSON.stringify(root.metadata) !== JSON.stringify(update.metadata))
                            root[key] = update[key];
                    }
                } catch (error) { root.error = "Invalid Audio service response."; }
            }
        }
        stderr: SplitParser { onRead: data => console.warn("Audio backend: " + data) }
        onExited: { root.error = "Audio configuration bridge stopped. Volume and mute remain available."; }
    }
    IpcHandler {
        target: "audio"
        function toggle(): void { root.toggleRequested(); }
    }
}
