import QtQuick
import QtQuick.Window
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "WindowRegistry.js" as Registry

PanelWindow {
    id: masterWindow

    color: "transparent"

    WlrLayershell.namespace: "qs-master"
    WlrLayershell.layer: WlrLayer.Overlay

    exclusionMode: ExclusionMode.Ignore
    focusable: true

    width: Screen.width
    height: Screen.height

    visible: isVisible

    mask: Region {
        item: topBarHole
        intersection: Intersection.Xor
    }

    Item {
        id: topBarHole
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 65
    }

    MouseArea {
        anchors.fill: parent
        enabled: masterWindow.isVisible
        onClicked: switchWidget("hidden", "")
    }

    Component.onCompleted: {
        Quickshell.execDetached(["bash", "-c", "echo '" + currentActive + "' > /tmp/qs_active_widget"]);
    }

    property string currentActive: "hidden"
    property bool isVisible: false
    property string activeArg: ""
    property bool disableMorph: false
    property int morphDuration: 500
    property int exitDuration: 300 // Controls how fast the outgoing widget disappears

    property real animW: 1
    property real animH: 1
    property real animX: 0
    property real animY: 0

    property real targetW: 1
    property real targetH: 1

    property real globalUiScale: SharedConfig.uiScale
    property var themeColors: SharedConfig.themeColors

    // =========================================================
    // --- DAEMON: NOTIFICATION HANDLING
    // =========================================================
    NotificationServer {
        id: globalNotificationServer
        bodySupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: n => {
            console.log("Notification:", n.appName, "-", n.summary);

            let iconUrl = "";
            if (n.image && n.image.source && n.image.source.toString() !== "") {
                iconUrl = n.image.source.toString();
            } else if (n.appIcon !== "") {
                iconUrl = n.appIcon;
            }

            Quickshell.execDetached(["bash", "-c", 'printf "%s\n" "$1" > /tmp/qs_island_notif', "qs_notif_sender", JSON.stringify({
                    appName: n.appName !== "" ? n.appName : "System",
                    title: n.summary !== "" ? n.summary : "No Title",
                    body: n.body !== "" ? n.body : "",
                    icon: iconUrl
                })]);
        }
    }

    // =========================================================

    onGlobalUiScaleChanged: {
        handleNativeScreenChange();
    }

    function getLayout(name) {
        return Registry.getLayout(name, 0, 0, Screen.width, Screen.height, masterWindow.globalUiScale);
    }

    Connections {
        target: Screen
        function onWidthChanged() {
            handleNativeScreenChange();
        }
        function onHeightChanged() {
            handleNativeScreenChange();
        }
    }

    function handleNativeScreenChange() {
        if (masterWindow.currentActive === "hidden")
            return;

        let t = getLayout(masterWindow.currentActive);
        if (t) {
            masterWindow.animX = t.rx;
            masterWindow.animY = t.ry;
            masterWindow.animW = t.w;
            masterWindow.animH = t.h;
            masterWindow.targetW = t.w;
            masterWindow.targetH = t.h;
        }
    }

    onIsVisibleChanged: {
        if (isVisible)
            masterWindow.requestActivate();
    }

    Item {
        x: masterWindow.animX
        y: masterWindow.animY
        width: masterWindow.animW
        height: masterWindow.animH
        clip: true

        // Smoother easing type
        Behavior on x {
            enabled: !masterWindow.disableMorph
            NumberAnimation {
                duration: masterWindow.morphDuration
                easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1]
            }
        }
        Behavior on y {
            enabled: !masterWindow.disableMorph
            NumberAnimation {
                duration: masterWindow.morphDuration
                easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1]
            }
        }
        Behavior on width {
            enabled: !masterWindow.disableMorph
            NumberAnimation {
                duration: masterWindow.morphDuration
                easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1]
            }
        }
        Behavior on height {
            enabled: !masterWindow.disableMorph
            NumberAnimation {
                duration: masterWindow.morphDuration
                easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1]
            }
        }

        opacity: masterWindow.isVisible ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation {
                duration: masterWindow.morphDuration === 500 ? 300 : 200
                easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1]
            }
        }

        MouseArea {
            anchors.fill: parent
        }

        Item {
            anchors.centerIn: parent
            width: masterWindow.targetW
            height: masterWindow.targetH

            StackView {
                id: widgetStack
                anchors.fill: parent
                focus: true

                Keys.onEscapePressed: {
                    switchWidget("hidden", "");
                    event.accepted = true;
                }

                onCurrentItemChanged: {
                    if (currentItem)
                        currentItem.forceActiveFocus();
                }

                replaceEnter: Transition {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            from: 0.0
                            to: 1.0
                            duration: 400
                            easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1]
                        }
                        NumberAnimation {
                            property: "scale"
                            from: 0.97
                            to: 1.0
                            duration: 400
                            easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1]
                        }
                    }
                }
                replaceExit: Transition {
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            from: 1.0
                            to: 0.0
                            duration: masterWindow.exitDuration
                            easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1]
                        }
                        NumberAnimation {
                            property: "scale"
                            from: 1.0
                            to: 0.98
                            duration: masterWindow.exitDuration
                            easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1]
                        }
                    }
                }
            }
        }
    }

    function switchWidget(newWidget, arg) {
        Quickshell.execDetached(["bash", "-c", "echo '" + newWidget + "' > /tmp/qs_active_widget"]);

        prepTimer.stop();
        delayedClear.stop();

        if (newWidget === "hidden") {
            if (currentActive !== "hidden") {
                masterWindow.morphDuration = 250;
                masterWindow.exitDuration = 250;
                masterWindow.disableMorph = false;

                masterWindow.animW = 1;
                masterWindow.animH = 1;
                masterWindow.isVisible = false;

                delayedClear.start();
            }
        } else {
            if (currentActive === "hidden") {
                masterWindow.morphDuration = 400; // Snappy but smooth
                masterWindow.exitDuration = 300;
                masterWindow.disableMorph = false;

                // Polymorphic start point: top center where the island is
                masterWindow.animX = Math.floor(Screen.width / 2);
                masterWindow.animY = 35;
                masterWindow.animW = 1;
                masterWindow.animH = 1;

                prepTimer.newWidget = newWidget;
                prepTimer.newArg = arg;
                prepTimer.start();
            } else {
                masterWindow.morphDuration = 500;
                masterWindow.disableMorph = false;
                masterWindow.exitDuration = 300;

                executeSwitch(newWidget, arg, false);
            }
        }
    }

    Timer {
        id: prepTimer
        interval: 50
        property string newWidget: ""
        property string newArg: ""
        onTriggered: executeSwitch(newWidget, newArg, false)
    }

    function executeSwitch(newWidget, arg, immediate) {
        masterWindow.currentActive = newWidget;
        masterWindow.activeArg = arg;

        let t = getLayout(newWidget);
        masterWindow.animX = t.rx;
        masterWindow.animY = t.ry;
        masterWindow.animW = t.w;
        masterWindow.animH = t.h;
        masterWindow.targetW = t.w;
        masterWindow.targetH = t.h;

        let props = {};

        if (immediate) {
            widgetStack.replace(t.comp, props, StackView.Immediate);
        } else {
            widgetStack.replace(t.comp, props);
        }

        widgetStack.currentItem.globalUiScale = Qt.binding(function() { return masterWindow.globalUiScale; });
        widgetStack.currentItem.themeColors = Qt.binding(function() { return masterWindow.themeColors; });

        masterWindow.isVisible = true;
    }

    // =========================================================
    // --- CONSOLIDATED IPC: EVENT-DRIVEN WATCHER ---
    // Replaces the old ipcWatcher pattern that spawned a new process on every event.
    // Uses SplitParser + JSON-on-one-line protocol for incremental reading.
    // Each event outputs: {"event":"QS_WIDGET","data":"..."}\n
    // =========================================================
    Process {
        id: ipcWatcher
        command: ["bash", "-c",
            "stdbuf -oL inotifywait -m -e close_write,moved_to /tmp/ --include 'qs_' 2>/dev/null | " +
            "while read -r dir action file; do " +
            "  case \"$file\" in " +
            "    qs_widget_state) " +
            "      v=$(cat /tmp/qs_widget_state 2>/dev/null); rm -f /tmp/qs_widget_state; " +
            "      printf '%s\\n' \"{\\\"event\\\":\\\"QS_WIDGET\\\",\\\"data\\\":\\\"$v\\\"}\" ;; " +
            "  esac; " +
            "done"
        ]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (line) => {
                if (!line || line.trim() === "") return;
                let obj;
                try { obj = JSON.parse(line.trim()); } catch(e) { return; }
                if (obj.event !== "QS_WIDGET") return;

                let rawCmd = (obj.data || "").trim();
                if (rawCmd === "") return;

                let parts = rawCmd.split(":");
                let cmd = parts[0];
                let arg = parts.length > 1 ? parts[1] : "";

                if (cmd === "close") {
                    switchWidget("hidden", "");
                } else if (getLayout(cmd)) {
                    delayedClear.stop();
                    if (cmd === masterWindow.currentActive) {
                        switchWidget("hidden", "");
                    } else {
                        switchWidget(cmd, arg);
                    }
                }
            }
        }
        running: true
    }

    Timer {
        id: delayedClear
        interval: masterWindow.morphDuration
        onTriggered: {
            masterWindow.currentActive = "hidden";
            widgetStack.clear();
            masterWindow.disableMorph = false;
        }
    }
}
