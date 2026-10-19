pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../widgets" as Widgets
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
        configuration.focus = false;
        root.forceActiveFocus();
    }
    onKindChanged: {
        configuration.popup.close();
        focusMenu();
        selectedId = "";
        Qt.callLater(() => { ensureSelection(); focusMenu(); });
    }
    onItemsChanged: ensureSelection()
    onOpenedChanged: if (opened) { Service.refresh(); forceActiveFocus(); }
    function send(action, value) {
        if (selected && (tab < 4 || action === "profile")) Service.send(action, {kind: kind, id: selected.id, value: value});
    }
    function configure() {
        if (!selected) return;
        configuration.openMenu();
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
        case Qt.Key_J: case Qt.Key_Down: list.move(1); break;
        case Qt.Key_K: case Qt.Key_Up: list.move(-1); break;
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
                Widgets.ActionButton {
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
        Widgets.DeviceList {
            id: list
            model: root.items
            keyRole: "id"
            selectedKey: root.selectedId
            titleFor: item => item.label
            subtitleFor: item => root.tab === 4 ? item.profileLabel : (item.default ? "Default · " : "") + (item.muted ? "Muted" : item.volume + "%")
            colorFor: item => item.default ? Config.colors.yellow : Config.colors.text
            onSelected: (key, byMouse) => { root.selectedId = key; if (byMouse) root.forceActiveFocus(); }
            onActivated: root.configure()
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
            Widgets.ActionButton { text: root.selected && root.selected.muted ? "Unmute" : "Mute"; onClicked: root.send("mute") }
            Widgets.ActionButton { visible: root.tab < 2; text: "Set default"; enabled: !!root.selected && !root.selected.default; onClicked: root.send("default") }
        }
        DeviceSelector {
            id: configuration
            onMenuClosed: root.focusMenu()
            Layout.fillWidth: true
            readonly property string optionKey: root.tab === 4 ? "profile" : root.tab < 2 ? "port" : "device"
            readonly property string action: root.tab === 4 ? "profile" : root.tab < 2 ? "port" : "move"
            readonly property string valueKey: root.tab >= 2 && root.tab < 4 ? "id" : "name"
            visible: !!root.selected && count > 0
            model: !root.selected ? [] : root.tab === 4 ? root.selected.profiles : root.tab < 2 ? root.selected.ports : root.devices
            textRole: "label"
            selectedIndex: root.selected ? model.findIndex(option => option[valueKey] === root.selected[optionKey]) : -1
            onActivated: index => root.send(action, model[index][valueKey])
            Accessible.name: root.tab === 4 ? "Device profile" : root.tab < 2 ? "Device port" : "Route application to device"
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
