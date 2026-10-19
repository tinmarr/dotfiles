pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../bluetooth" as BluetoothUi
import "../config.js" as Config

FocusScope {
    id: root
    implicitWidth: 430
    implicitHeight: layout.implicitHeight
    property bool opened: false
    property bool savedOnly: true
    property bool searching: false
    property bool hiddenNetwork: false
    property string selectedPath: ""
    property string forgetPath: ""
    readonly property var networks: Service.networks.filter(n => (!savedOnly || n.known) && n.name.toLowerCase().includes(search.text.toLowerCase()))
    readonly property var selected: networks.find(n => n.path === selectedPath) || null
    readonly property bool credentials: Service.prompt !== ""
    signal dismiss()
    onNetworksChanged: if (!selected) selectedPath = networks.length ? networks[0].path : ""
    onSelectedPathChanged: forgetPath = ""
    onSearchingChanged: {
        if (!searching) { search.focus = false; search.clear(); }
    }
    onOpenedChanged: {
        if (opened) { Service.refresh(); forceActiveFocus(); }
        else { Service.send("cancel"); password.clear(); username.clear(); search.clear(); searching = false; hiddenNetwork = false; forgetPath = ""; }
    }
    Connections {
        target: Service
        function onPromptChanged() {
            password.clear(); username.clear();
            if (root.credentials && root.opened) {
                if (Service.prompt === "RequestUserNameAndPassword") username.forceActiveFocus();
                else password.forceActiveFocus();
            } else if (root.opened) root.forceActiveFocus();
        }
    }
    function move(delta) {
        if (!networks.length) return;
        const index = (networks.findIndex(n => n.path === selectedPath) + delta + networks.length) % networks.length;
        selectedPath = networks[index].path;
        list.positionViewAtIndex(index, ListView.Contain);
    }
    function activate() {
        if (!selected || Service.busy || !Service.powered) return;
        if (selected.connected) Service.send("disconnect");
        else Service.send("connect", {path: selected.path});
    }
    function forget() {
        if (!selected || !selected.known || Service.busy) return;
        if (forgetPath === selectedPath) { Service.send("forget", {path: selected.known}); forgetPath = ""; }
        else forgetPath = selectedPath;
    }
    function scan() {
        savedOnly = false;
        if (Service.powered && !Service.busy && !Service.scanning) Service.send("scan");
    }
    function toggleAutoconnect() {
        if (selected && selected.known && !Service.busy)
            Service.send("autoconnect", {path: selected.known, value: !selected.autoconnect});
    }
    function joinHidden() {
        if (!ssid.text || Service.busy) return;
        Service.send("hidden", {ssid: ssid.text});
        hiddenNetwork = false;
        ssid.clear();
    }
    function submitCredentials() {
        Service.send("credentials", {password: password.text, username: username.text, usernameRequired: Service.prompt === "RequestUserNameAndPassword"});
        password.clear(); username.clear();
    }
    Keys.onPressed: event => {
        const editing = search.activeFocus || password.activeFocus || username.activeFocus || ssid.activeFocus;
        if (!editing && (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab)) {
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Escape) {
            if (credentials) Service.send("cancel");
            else if (hiddenNetwork) hiddenNetwork = false;
            else if (searching) { searching = false; root.forceActiveFocus(); }
            else if (forgetPath) forgetPath = "";
            else root.dismiss();
        } else if (search.activeFocus && event.key === Qt.Key_Down) move(1);
        else if (search.activeFocus && event.key === Qt.Key_Up) move(-1);
        else {
            if (editing) return;
            switch (event.key) {
            case Qt.Key_J: case Qt.Key_Down: move(1); break;
            case Qt.Key_K: case Qt.Key_Up: move(-1); break;
            case Qt.Key_H: case Qt.Key_Left: savedOnly = true; break;
            case Qt.Key_L: case Qt.Key_Right: savedOnly = false; break;
            case Qt.Key_S: scan(); break;
            case Qt.Key_T: toggleAutoconnect(); break;
            case Qt.Key_Return: case Qt.Key_Enter: activate(); break;
            case Qt.Key_X: case Qt.Key_Delete: forget(); break;
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
            visible: Service.devices.length > 1
            Repeater {
                model: Service.devices
                BluetoothUi.ActionButton {
                    required property var modelData
                    text: modelData.name
                    highlighted: modelData.path === Service.device
                    enabled: !Service.busy
                    onClicked: Service.send("device", {path: modelData.path})
                }
            }
        }
        RowLayout {
            BluetoothUi.ActionButton { text: "Saved"; highlighted: root.savedOnly; onClicked: root.savedOnly = true }
            BluetoothUi.ActionButton { text: "All networks"; highlighted: !root.savedOnly; onClicked: root.savedOnly = false }
            Item { Layout.fillWidth: true }
            BluetoothUi.ActionButton { text: Service.scanning ? "Scanning…" : "Scan"; enabled: Service.powered && !Service.scanning && !Service.busy; onClicked: root.scan() }
            BluetoothUi.ActionButton { text: Service.powered ? "On" : "Off"; enabled: Service.devices.length > 0 && !Service.busy; onClicked: Service.send("power", {value: !Service.powered}) }
        }
        TextField {
            id: search
            focusPolicy: Qt.ClickFocus
            visible: root.searching
            Layout.fillWidth: true
            placeholderText: "Filter networks"
            color: Config.colors.text
            placeholderTextColor: Config.colors.overlay1
            font.family: Config.font.family
            font.pointSize: Config.font.pointSize
            padding: 8
            background: Rectangle { color: Config.colors.mantle; radius: 5; border.width: 1; border.color: Config.colors.surface1 }
            Accessible.name: "Filter networks"
        }
        Text {
            Layout.fillWidth: true
            text: Service.error || (!Service.devices.length ? "No Wi-Fi adapter found." : !Service.powered ? "Wi-Fi is off." : Service.busy ? "Working…" : !root.networks.length ? "No matching networks. Scan to find networks." : Service.state)
            color: Service.error ? Config.colors.red : Config.colors.subtext0
            font.family: Config.font.family
            wrapMode: Text.WordWrap
        }
        ListView {
            id: list
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(280, contentHeight)
            clip: true
            spacing: 3
            model: root.networks
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar {}
            delegate: Rectangle {
                id: row
                required property var modelData
                width: list.width
                height: 55
                radius: 5
                color: root.selectedPath === modelData.path ? Config.colors.surface0 : hitbox.containsMouse ? Config.colors.mantle : "transparent"
                border.width: root.selectedPath === modelData.path ? 1 : 0
                border.color: Config.colors.surface2
                Column {
                    anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 10 }
                    spacing: 3
                    Text { width: parent.width; text: row.modelData.name; elide: Text.ElideRight; color: row.modelData.connected ? Config.colors.maroon : Config.colors.text; font.family: Config.font.family; font.pointSize: Config.font.pointSize }
                    Text {
                        width: parent.width
                        text: (row.modelData.connected ? "Connected · " : "") + row.modelData.security + (row.modelData.known ? " · Saved" : "") + " · " + row.modelData.signal + " dBm"
                        elide: Text.ElideRight
                        color: Config.colors.subtext0
                        font.family: Config.font.family
                        font.pointSize: Config.font.pointSize - 1
                    }
                }
                MouseArea {
                    id: hitbox
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { root.selectedPath = row.modelData.path; root.forceActiveFocus(); }
                    onDoubleClicked: root.activate()
                }
            }
        }
        RowLayout {
            enabled: !Service.busy && !root.credentials
            BluetoothUi.ActionButton { text: root.selected && root.selected.connected ? "Disconnect" : "Connect"; enabled: !!root.selected && Service.powered; onClicked: root.activate() }
            BluetoothUi.ActionButton { text: root.forgetPath ? "Confirm?" : "Forget"; enabled: !!root.selected && !!root.selected.known; onClicked: root.forget() }
            BluetoothUi.ActionButton { text: root.selected && root.selected.autoconnect ? "Auto: on" : "Auto: off"; enabled: !!root.selected && !!root.selected.known; onClicked: root.toggleAutoconnect() }
            BluetoothUi.ActionButton { text: "Hidden…"; enabled: Service.powered; onClicked: { root.hiddenNetwork = !root.hiddenNetwork; ssid.forceActiveFocus(); } }
        }
        RowLayout {
            visible: root.hiddenNetwork
            TextField { id: ssid; Layout.fillWidth: true; placeholderText: "Hidden network name"; Accessible.name: "Hidden network name"; onAccepted: root.joinHidden() }
            BluetoothUi.ActionButton { text: "Join"; enabled: !!ssid.text && !Service.busy; onClicked: root.joinHidden() }
        }
        ColumnLayout {
            visible: root.credentials
            Layout.fillWidth: true
            Text { text: Service.prompt === "RequestPrivateKeyPassphrase" ? "Private key passphrase" : "Network credentials"; color: Config.colors.text; font.family: Config.font.family }
            TextField { id: username; visible: Service.prompt === "RequestUserNameAndPassword"; Layout.fillWidth: true; placeholderText: "Username"; Accessible.name: "Username"; onAccepted: password.forceActiveFocus() }
            TextField { id: password; Layout.fillWidth: true; placeholderText: "Password"; echoMode: TextInput.Password; Accessible.name: "Wi-Fi password"; onAccepted: root.submitCredentials() }
            RowLayout {
                BluetoothUi.ActionButton { text: "Connect"; onClicked: root.submitCredentials() }
                BluetoothUi.ActionButton { text: "Cancel"; onClicked: Service.send("cancel") }
            }
        }
        Text {
            Layout.fillWidth: true
            text: "j/k Select · h/l Saved/All · Enter Connect\nt Auto-connect · s Scan\n/ Filter · x Forget · q Close"
            color: Config.colors.overlay2
            font.family: Config.font.family
            font.pointSize: Config.font.pointSize - 1
        }
    }
}
