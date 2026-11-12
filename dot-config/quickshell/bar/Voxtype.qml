import Quickshell.Io
import QtQuick
import "../config.js" as Config

Pill {
    id: root
    visible: dictationState === "recording" || dictationState === "transcribing" || meetingState !== ""

    property string dictationState: ""
    property string meetingState: ""
    property bool stopRequested: false
    readonly property bool meetingStopping: stopRequested || meetingState === "stopping"
    readonly property bool canStopMeeting: (meetingState === "recording" || meetingState === "paused")
        && !meetingStopping && !stopMeeting.running

    BarText {
        id: icon
        visible: root.dictationState === "recording" || root.dictationState === "transcribing"
    }

    Item {
        id: meetingIcon
        visible: root.meetingState !== ""
        implicitWidth: meetingContent.implicitWidth
        implicitHeight: meetingContent.implicitHeight

        Row {
            id: meetingContent
            spacing: 5

            BarText {
                visible: root.meetingStopping || (root.meetingState !== "recording" && root.meetingState !== "paused")
                text: ""
                color: Config.colors.yellow
                RotationAnimator on rotation {
                    from: 0
                    to: 360
                    duration: 1000
                    loops: Animation.Infinite
                    running: meetingIcon.visible && parent.visible
                }
            }

            BarText {
                text: root.meetingState === "paused" && !root.meetingStopping ? " " : ""
                color: root.meetingState === "recording" && !root.meetingStopping ? Config.colors.red : Config.colors.yellow
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.canStopMeeting
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.stopRequested = true;
                stopMeeting.running = true;
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: meetingStatus.running = true
    }

    Process {
        id: meetingStatus
        command: ["voxtype", "meeting", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                const match = text.match(/^Meeting Status: (\w+)/m);
                const state = match ? match[1].toLowerCase() : "";
                root.meetingState = state === "idle" || state === "completed" ? "" : state;
                if (state === "stopping") root.stopRequested = true;
                if (root.meetingState === "" && !stopMeeting.running) root.stopRequested = false;
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) root.meetingState = "";
        }
    }

    Process {
        id: stopMeeting
        command: ["voxtype", "meeting", "stop"]
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) root.stopRequested = false;
            if (!meetingStatus.running) meetingStatus.running = true;
        }
    }

    Process {
        id: getInfo
        command: ["sh", "-c", "voxtype status --follow --format json"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                data = data.trim();
                root.dictationState = JSON.parse(data).class;
                switch (root.dictationState) {
                case "recording":
                    icon.text = "󰍬";
                    icon.color = Config.colors.red;
                    break;
                case "transcribing":
                    icon.text = "";
                    icon.color = Config.colors.yellow;
                    break;
                }
            }
        }
    }
}
