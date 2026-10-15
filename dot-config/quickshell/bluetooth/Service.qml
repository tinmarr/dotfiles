pragma Singleton
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property var adapter: Bluetooth.defaultAdapter
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
