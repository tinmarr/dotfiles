pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../config.js" as Config

ListView {
    id: root
    required property string keyRole
    required property string selectedKey
    required property var titleFor
    required property var subtitleFor
    property var colorFor: item => Config.colors.text
    signal selected(string key, bool byMouse)
    signal activated()
    function move(delta) {
        if (!model.length) return;
        const index = (model.findIndex(item => item[keyRole] === selectedKey) + delta + model.length) % model.length;
        selected(model[index][keyRole], false);
        positionViewAtIndex(index, ListView.Contain);
    }
    Layout.fillWidth: true
    Layout.preferredHeight: Math.min(280, contentHeight)
    clip: true
    spacing: 3
    boundsBehavior: Flickable.StopAtBounds
    ScrollBar.vertical: ScrollBar {}
    delegate: Rectangle {
        id: row
        required property var modelData
        width: root.width
        height: 55
        radius: 5
        readonly property bool selected: root.selectedKey === modelData[root.keyRole]
        color: selected ? Config.colors.surface0 : hitbox.containsMouse ? Config.colors.mantle : "transparent"
        border.width: selected ? 1 : 0
        border.color: Config.colors.surface2
        Column {
            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 10 }
            spacing: 3
            Text {
                width: parent.width
                text: root.titleFor(row.modelData)
                color: root.colorFor(row.modelData)
                elide: Text.ElideRight
                font.family: Config.font.family
                font.pointSize: Config.font.pointSize
            }
            Text {
                width: parent.width
                text: root.subtitleFor(row.modelData)
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
            onClicked: root.selected(row.modelData[root.keyRole], true)
            onDoubleClicked: root.activated()
        }
    }
}
