pragma ComponentBehavior: Bound
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../config.js" as Config
import "../widgets" as Widgets

FocusScope {
    id: root
    implicitWidth: 430
    implicitHeight: layout.implicitHeight
    property bool opened: false
    property bool savedOnly: true
    property bool searching: false
    property string selectedPath: ""
    property string forgetPath: ""
    readonly property var adapter: Service.adapter
    readonly property var devices: {
        const query = search.text.toLowerCase();
        return (adapter ? adapter.devices.values : []).filter(d =>
            (!savedOnly || d.paired || d.bonded || d.trusted) &&
            (d.name.toLowerCase().includes(query) || d.address.toLowerCase().includes(query)))
            .sort((a, b) => Number(b.connected) - Number(a.connected) || a.name.localeCompare(b.name) || a.address.localeCompare(b.address));
    }
    readonly property var selected: devices.find(d => d.dbusPath === selectedPath) || null
    readonly property bool busy: selected && (selected.pairing || selected.state === BluetoothDeviceState.Connecting || selected.state === BluetoothDeviceState.Disconnecting)
    signal dismiss()
    onDevicesChanged: {
        if (!devices.some(d => d.dbusPath === selectedPath)) selectedPath = devices.length ? devices[0].dbusPath : "";
    }
    onSelectedPathChanged: forgetPath = ""
    onSearchingChanged: {
        if (!searching) {
            search.focus = false;
            search.clear();
        }
    }
    onOpenedChanged: {
        if (opened) {
            forceActiveFocus();
        } else {
            Service.stopScan();
            searching = false;
            forgetPath = "";
        }
    }
    function activateSelected() {
        if (!selected || !adapter || !adapter.enabled) return;
        if (selected.pairing) selected.cancelPair();
        else if (busy) return;
        else if (selected.connected) selected.disconnect();
        else if (!selected.paired) selected.pair();
        else selected.connect();
    }
    function forgetSelected() {
        if (!selected || busy) return;
        if (forgetPath === selectedPath) {
            selected.forget();
            forgetPath = "";
        } else forgetPath = selectedPath;
    }
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
            event.accepted = true;
            return;
        }
        const editing = search.activeFocus;
        if (event.key === Qt.Key_Escape) {
            if (forgetPath) forgetPath = "";
            else root.dismiss();
        } else if (event.key === Qt.Key_Down) list.move(1);
        else if (event.key === Qt.Key_Up) list.move(-1);
        else {
            if (editing) return;
            switch (event.key) {
            case Qt.Key_J: list.move(1); break;
            case Qt.Key_K: list.move(-1); break;
            case Qt.Key_Left:
            case Qt.Key_H: savedOnly = true; break;
            case Qt.Key_Right:
            case Qt.Key_L: savedOnly = false; break;
            case Qt.Key_M: savedOnly = !savedOnly; break;
            case Qt.Key_S: savedOnly = false; Service.scan(); break;
            case Qt.Key_T: if (selected) selected.trusted = !selected.trusted; break;
            case Qt.Key_P: if (selected && !selected.paired && !busy) selected.pair(); break;
            case Qt.Key_X:
            case Qt.Key_Delete: forgetSelected(); break;
            case Qt.Key_Return:
            case Qt.Key_Enter: activateSelected(); break;
            case Qt.Key_Slash: searching = true; search.forceActiveFocus(); break;
            case Qt.Key_Q: if (forgetPath) forgetPath = ""; else root.dismiss(); break;
            default: return;
            }
        }
        event.accepted = true;
    }

    ColumnLayout {
        id: layout
        width: parent.width
        spacing: 8
        RowLayout {
            visible: Bluetooth.adapters.values.length > 1
            Repeater {
                model: Bluetooth.adapters.values
                Widgets.ActionButton {
                    required property var modelData
                    text: modelData.name
                    highlighted: root.adapter === modelData
                    onClicked: { Service.stopScan(); Service.adapter = modelData; }
                }
            }
        }
        RowLayout {
            Widgets.ActionButton { text: "Saved"; highlighted: root.savedOnly; onClicked: root.savedOnly = true }
            Widgets.ActionButton { text: "All devices"; highlighted: !root.savedOnly; onClicked: root.savedOnly = false }
            Item { Layout.fillWidth: true }
            Widgets.ActionButton {
                text: root.adapter && root.adapter.discovering ? "Stop scan" : "Scan"
                enabled: !!root.adapter && root.adapter.enabled && (!root.adapter.discovering || Service.ownsScan)
                onClicked: { root.savedOnly = false; Service.scan(); }
            }
            Widgets.ActionButton { text: root.adapter && root.adapter.enabled ? "On" : "Off"; enabled: !!root.adapter; onClicked: { Service.stopScan(); root.adapter.enabled = !root.adapter.enabled; } }
        }
        TextField {
            id: search
            focusPolicy: Qt.ClickFocus
            visible: root.searching
            Layout.fillWidth: true
            placeholderText: "Filter by name or address"
            color: Config.colors.text
            placeholderTextColor: Config.colors.overlay1
            font.family: Config.font.family
            font.pointSize: Config.font.pointSize
            padding: 8
            background: Rectangle { color: Config.colors.mantle; radius: 5; border.width: 1; border.color: Config.colors.surface1 }
            Accessible.name: "Filter devices"
            Keys.onEscapePressed: { root.searching = false; root.forceActiveFocus(); }
        }
        Text {
            Layout.fillWidth: true
            visible: !root.adapter || !root.adapter.enabled || root.devices.length === 0
            text: !root.adapter ? "No Bluetooth adapter found." : !root.adapter.enabled ? "Bluetooth is " + BluetoothAdapterState.toString(root.adapter.state).toLowerCase() + "." : root.savedOnly ? "No saved devices. Scan to find devices." : root.adapter.discovering ? "Searching for nearby devices…" : "No matching devices. Start a scan."
            color: Config.colors.subtext0
            wrapMode: Text.WordWrap
            font.family: Config.font.family
            padding: 8
        }
        Widgets.DeviceList {
            id: list
            model: root.devices
            keyRole: "dbusPath"
            selectedKey: root.selectedPath
            titleFor: item => item.name || item.address
            subtitleFor: item => item.address + " · " + (item.pairing ? "Pairing…" : BluetoothDeviceState.toString(item.state)) + (item.paired ? " · Paired" : "") + (item.trusted ? " · Trusted" : "") + (item.batteryAvailable ? " · " + Math.round(item.battery * 100) + "%" : "")
            colorFor: item => item.connected ? Config.colors.teal : Config.colors.text
            onSelected: (key, byMouse) => { root.selectedPath = key; if (byMouse) root.forceActiveFocus(); }
            onActivated: root.activateSelected()
        }
        RowLayout {
            Layout.fillWidth: true
            enabled: !!root.selected && !!root.adapter && root.adapter.enabled
            Widgets.ActionButton {
                text: !root.selected ? "Pair" : root.selected.pairing ? "Cancel pair" : root.selected.connected ? "Disconnect" : root.selected.paired ? "Connect" : "Pair"
                enabled: !!root.selected && (!root.busy || root.selected.pairing)
                onClicked: root.activateSelected()
            }
            Widgets.ActionButton { text: root.selected && root.selected.trusted ? "Untrust" : "Trust"; onClicked: root.selected.trusted = !root.selected.trusted }
            Widgets.ActionButton { text: root.forgetPath ? "Confirm?" : "Forget"; enabled: !root.busy; onClicked: root.forgetSelected() }
        }
        Text {
            Layout.fillWidth: true
            text: "j/k Select · h/l Saved/All · Enter Pair/Connect\np Pair · t Trust · s Scan · / Filter · x Forget · q Close"
            color: Config.colors.overlay2
            font.family: Config.font.family
            font.pointSize: Config.font.pointSize - 1
        }
    }
}
