pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../bluetooth" as BluetoothUi
import "../config.js" as Config

FocusScope {
    id: root
    implicitWidth: 550
    implicitHeight: layout.implicitHeight
    property bool opened: false
    property int tab: 0
    property string selectedId: ""
    readonly property var kinds: ["sinks", "sources", "sink-inputs", "source-outputs", "cards"]
    readonly property string kind: kinds[tab]
    readonly property var items: Service.groups[kind] || []
    readonly property var selected: items.find(item => item.id === selectedId) || null
    readonly property var devices: Service.groups[tab === 2 ? "sinks" : "sources"] || []
    signal dismiss()
    function ensureSelection() {
        if (!items.some(item => item.id === selectedId)) {
            const preferred = items.find(item => item.default) || items[0];
            selectedId = preferred ? preferred.id : "";
        }
    }
    function focusMenu() {
        portSelector.focus = false;
        routeSelector.focus = false;
        profileSelector.focus = false;
        root.forceActiveFocus();
    }
    onKindChanged: {
        portSelector.popup.close();
        routeSelector.popup.close();
        profileSelector.popup.close();
        focusMenu();
        selectedId = "";
        Qt.callLater(() => { ensureSelection(); focusMenu(); });
    }
    onItemsChanged: ensureSelection()
    onOpenedChanged: if (opened) { Service.refresh(); forceActiveFocus(); }
    function send(action, value) {
        if (selected && (tab < 4 || action === "profile")) Service.send(action, {kind: kind, id: selected.id, value: value});
    }
    function move(delta) {
        if (!items.length) return;
        const index = (items.findIndex(item => item.id === selectedId) + delta + items.length) % items.length;
        selectedId = items[index].id;
        list.positionViewAtIndex(index, ListView.Contain);
    }
    function configure() {
        if (!selected) return;
        const control = tab === 4 ? profileSelector : tab < 2 ? portSelector : routeSelector;
        if (!control.visible || !control.count) return;
        control.openMenu();
    }
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
            event.accepted = true;
            return;
        }
        if ((event.modifiers & Qt.ShiftModifier) && (event.key === Qt.Key_H || event.key === Qt.Key_L)) {
            if (selected) send("volume", selected.volume + (event.key === Qt.Key_H ? -5 : 5));
            event.accepted = true;
            return;
        }
        switch (event.key) {
        case Qt.Key_Escape: case Qt.Key_Q: root.dismiss(); break;
        case Qt.Key_J: case Qt.Key_Down: move(1); break;
        case Qt.Key_K: case Qt.Key_Up: move(-1); break;
        case Qt.Key_H: case Qt.Key_Left: tab = (tab + kinds.length - 1) % kinds.length; break;
        case Qt.Key_L: case Qt.Key_Right: tab = (tab + 1) % kinds.length; break;
        case Qt.Key_M: send("mute"); break;
        case Qt.Key_Minus: if (selected) send("volume", selected.volume - 5); break;
        case Qt.Key_Plus: case Qt.Key_Equal: if (selected) send("volume", selected.volume + 5); break;
        case Qt.Key_D: if (tab < 2) send("default"); break;
        case Qt.Key_Return: case Qt.Key_Enter: break;
        default: return;
        }
        event.accepted = true;
    }
    Keys.onReleased: event => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            event.accepted = true;
            configure();
        }
    }
    ColumnLayout {
        id: layout
        width: parent.width
        spacing: 8
        RowLayout {
            Repeater {
                model: ["Outputs", "Inputs", "Playback", "Recording", "Profiles"]
                BluetoothUi.ActionButton {
                    required property int index
                    required property string modelData
                    text: modelData
                    highlighted: root.tab === index
                    onClicked: { root.tab = index; root.forceActiveFocus(); }
                }
            }
        }
        Text {
            Layout.fillWidth: true
            visible: text !== ""
            text: Service.error || (!root.items.length ? "No audio devices or streams." : "")
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
            model: root.items
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar {}
            delegate: Rectangle {
                id: row
                required property var modelData
                width: list.width
                height: 55
                radius: 5
                color: root.selectedId === modelData.id ? Config.colors.surface0 : hitbox.containsMouse ? Config.colors.mantle : "transparent"
                border.width: root.selectedId === modelData.id ? 1 : 0
                border.color: Config.colors.surface2
                Column {
                    anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 10 }
                    spacing: 3
                    Text { width: parent.width; text: row.modelData.label; elide: Text.ElideRight; color: row.modelData.default ? Config.colors.yellow : Config.colors.text; font.family: Config.font.family; font.pointSize: Config.font.pointSize }
                    Text { text: root.tab === 4 ? row.modelData.profileLabel : (row.modelData.default ? "Default · " : "") + (row.modelData.muted ? "Muted" : row.modelData.volume + "%"); color: Config.colors.subtext0; font.family: Config.font.family; font.pointSize: Config.font.pointSize - 1 }
                }
                MouseArea {
                    id: hitbox
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { root.selectedId = row.modelData.id; root.forceActiveFocus(); }
                    onDoubleClicked: root.configure()
                }
            }
        }
        RowLayout {
            visible: root.tab < 4
            enabled: !!root.selected
            Text { Layout.preferredWidth: 50; text: root.selected ? (root.selected.muted ? "Muted" : root.selected.volume + "%") : ""; color: Config.colors.text; font.family: Config.font.family }
            Slider {
                id: volumeSlider
                activeFocusOnTab: false
                Layout.fillWidth: true
                implicitHeight: 28
                hoverEnabled: true
                background: Rectangle {
                    x: volumeSlider.leftPadding
                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                    width: volumeSlider.availableWidth
                    height: 6
                    radius: 3
                    color: Config.colors.mantle
                    border.width: 1
                    border.color: Config.colors.surface1
                    Rectangle {
                        width: volumeSlider.visualPosition * parent.width
                        height: parent.height
                        radius: parent.radius
                        color: volumeSlider.enabled ? Config.theme.primary : Config.colors.surface2
                    }
                }
                handle: Rectangle {
                    x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                    implicitWidth: 14
                    implicitHeight: 14
                    radius: 7
                    color: volumeSlider.pressed ? Config.theme.primary : volumeSlider.hovered ? Config.colors.surface1 : Config.theme.bg
                    border.width: volumeSlider.activeFocus ? 2 : 1
                    border.color: volumeSlider.enabled ? Config.border.color : Config.colors.surface2
                }
                from: 0
                to: 150
                stepSize: 1
                Binding {
                    target: volumeSlider
                    property: "value"
                    value: root.selected ? root.selected.volume : 0
                    when: !volumeSlider.pressed
                    restoreMode: Binding.RestoreNone
                }
                property bool volumePending: false
                property int requestedVolume: 0
                onMoved: {
                    requestedVolume = Math.round(value);
                    volumePending = true;
                    if (!volumeUpdates.running) volumeUpdates.start();
                }
                onPressedChanged: if (!pressed && volumePending) {
                    volumeUpdates.stop();
                    volumePending = false;
                    root.send("volume", requestedVolume);
                }
                Timer {
                    id: volumeUpdates
                    interval: 60
                    onTriggered: {
                        volumeSlider.volumePending = false;
                        root.send("volume", volumeSlider.requestedVolume);
                    }
                }
                Accessible.name: "Volume"
            }
            BluetoothUi.ActionButton { text: root.selected && root.selected.muted ? "Unmute" : "Mute"; onClicked: root.send("mute") }
            BluetoothUi.ActionButton { visible: root.tab < 2; text: "Set default"; enabled: !!root.selected && !root.selected.default; onClicked: root.send("default") }
        }
        DeviceSelector {
            id: portSelector
            onMenuClosed: root.focusMenu()
            Layout.fillWidth: true
            visible: root.tab < 2 && count > 0
            model: root.selected && root.tab < 2 ? root.selected.ports : []
            textRole: "label"
            selectedIndex: root.selected && root.tab < 2 ? root.selected.ports.findIndex(port => port.name === root.selected.port) : -1
            onActivated: index => root.send("port", model[index].name)
            Accessible.name: "Device port"
        }
        DeviceSelector {
            id: routeSelector
            onMenuClosed: root.focusMenu()
            Layout.fillWidth: true
            visible: root.tab >= 2 && root.tab < 4 && !!root.selected
            model: root.devices
            textRole: "label"
            selectedIndex: root.selected ? root.devices.findIndex(device => device.id === root.selected.device) : -1
            onActivated: index => root.send("move", root.devices[index].id)
            Accessible.name: "Route application to device"
        }
        DeviceSelector {
            id: profileSelector
            onMenuClosed: root.focusMenu()
            Layout.fillWidth: true
            visible: root.tab === 4 && !!root.selected
            model: root.selected && root.tab === 4 ? root.selected.profiles : []
            textRole: "label"
            selectedIndex: root.selected && root.tab === 4 ? root.selected.profiles.findIndex(profile => profile.name === root.selected.profile) : -1
            onActivated: index => root.send("profile", model[index].name)
            Accessible.name: "Device profile"
        }
        Text {
            Layout.fillWidth: true
            text: "j/k Select · h/l Tab · d Set default\nShift+h/l Volume −/+ · Enter Configure\nm Mute · q Close"
            color: Config.colors.overlay2
            font.family: Config.font.family
            font.pointSize: Config.font.pointSize - 1
        }
    }
}
