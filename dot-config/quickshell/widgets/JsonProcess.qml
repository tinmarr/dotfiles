import Quickshell.Io

Process {
    id: root
    required property string label
    signal response(var update)
    signal invalidResponse()
    signal backendExited()
    running: true
    stdinEnabled: true
    function request(action, args = {}) {
        write(JSON.stringify(Object.assign({}, args, {action: action})) + "\n");
    }
    function refresh() {
        if (!running) running = true;
        else request("refresh");
    }
    stdout: SplitParser {
        onRead: data => {
            let update;
            try { update = JSON.parse(data); }
            catch (error) { root.invalidResponse(); return; }
            root.response(update);
        }
    }
    stderr: SplitParser { onRead: data => console.warn(root.label + " backend: " + data) }
    onExited: root.backendExited()
}
