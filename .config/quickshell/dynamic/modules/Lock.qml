import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import QtCore
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import "../"

ShellRoot {
    id: root
    MatugenColors { id: _theme; colorOverrides: SharedConfig.themeColors }
    readonly property color base: _theme.base
    readonly property color crust: _theme.crust
    readonly property color mantle: _theme.mantle
    readonly property color text: _theme.text
    readonly property color subtext0: _theme.subtext0
    readonly property color overlay0: _theme.overlay0
    readonly property color overlay2: _theme.overlay2
    readonly property color surface0: _theme.surface0
    readonly property color surface1: _theme.surface1
    readonly property color surface2: _theme.surface2

    readonly property color mauve: _theme.mauve
    readonly property color red: _theme.red
    readonly property color peach: _theme.peach
    readonly property color blue: _theme.blue
    readonly property color green: _theme.green

    // Consistent font tokens (deduped from SharedConfig)
    readonly property string nerdFont: SharedConfig.nerdFont
    readonly property string monoFont: SharedConfig.monoFont
    readonly property string nerdPropoFont: SharedConfig.nerdPropoFont

    // Persistent Settings
    Settings {
        id: lockSettings
        category: "QuickshellLockscreen"
        property bool hidePassword: false
        property int revealDuration: 300
    }

    // Shared state across all monitors
    QtObject {
        id: lockUI
        property bool failed: false
        property bool authenticating: false
        property string statusText: "Locked"
    }

    // System Authentication hook
    PamContext {
        id: pam

        Component.onCompleted: pam.start()

        onCompleted: (result) => {
            lockUI.authenticating = false;
            if (result === PamResult.Success) {
                rootLock.locked = false;
                Qt.quit();
            } else {
                lockUI.failed = true;
                lockUI.statusText = "Access Denied";
                pam.start();
            }
        }
    }

    Process {
        id: suspendProcess
        command: ["systemctl", "suspend"]
    }

    Process {
        id: poweroffProcess
        command: ["systemctl", "poweroff"]
    }

    Process {
        id: reloadProcess
        command: ["systemctl", "reboot"]
    }

    WlSessionLock {
        id: rootLock
        locked: true

        WlSessionLockSurface {
            id: surface

            Item {
                id: screenRoot
                anchors.fill: parent

                // --- Responsive Scaling Logic ---
                // We use a property binding instead of a function to ensure
                // continuous updates even if surface width starts at 0.
                Scaler {
                    id: scaler
                    currentWidth: screenRoot.width > 0 ? screenRoot.width : Screen.width
                }
                readonly property real sc: scaler.baseScale
                // --------------------------------

                property string staticWallpaperPath: "file:///tmp/lock_bg.png"

                property string batPct: "100"
                property string batStatus: "AC"
                property string currentUser: "User"
                property string faceIconPath: ""
                property string kbLayout: "US"
                property string weatherIcon: ""
                property string weatherTemp: "--°C"

                // UI States
                property real introState: 0.0
                property bool powerMenuOpen: false
                property bool inputActive: false
                property bool isPlayingIntro: true
                property bool isDesktop: false

                Component.onCompleted: {
                    introSequence.start();
                }

                property real globalOrbitAngle: 0
                NumberAnimation on globalOrbitAngle {
                    from: 0; to: Math.PI * 2; duration: 90000; loops: Animation.Infinite; running: screenRoot.isPlayingIntro || screenRoot.inputActive
                }

                // Auto-hide input field if empty and idle for 15 seconds
                Timer {
                    id: idleTimer
                    interval: 15000
                    running: screenRoot.inputActive && inputField.text.length === 0
                    repeat: false
                    onTriggered: screenRoot.inputActive = false
                }

                // ---------------------------------------------------------
                // BACKGROUND DATA POLLING
                // ---------------------------------------------------------

                Process {
                    id: chassisDetector
                    running: true
                    command: ["bash", "-c", "if ls /sys/class/power_supply/BAT* 1> /dev/null 2>&1; then echo 'laptop'; else echo 'desktop'; fi"]
                    stdout: StdioCollector {
                        onStreamFinished: {
                            screenRoot.isDesktop = (this.text.trim() === "desktop");
                        }
                    }
                }

                Process {
                    id: userPoller
                    command: [
                        "bash",
                        "-c",
                        "USER_VAR=$(whoami); ICON_PATH=\"\"; if [ -f ~/.face.icon ]; then ICON_PATH=$(readlink -f ~/.face.icon); elif [ -f ~/.face ]; then ICON_PATH=$(readlink -f ~/.face); fi; echo -n \"$USER_VAR|$ICON_PATH\""
                    ]
                    stdout: StdioCollector {
                        onStreamFinished: {
                            let parts = this.text.trim().split("|");
                            if (parts.length > 0 && parts[0] !== "") screenRoot.currentUser = parts[0];
                            if (parts.length > 1 && parts[1].trim() !== "") {
                                let path = parts[1].trim();
                                screenRoot.faceIconPath = path.startsWith("file://") ? path : "file://" + path;
                            }
                        }
                    }
                    Component.onCompleted: running = true
                }

                Process {
                    id: kbPoller
                    command: ["bash", "-c", "hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap' | head -n1 | cut -c1-2 | tr '[:lower:]' '[:upper:]'"]
                    stdout: StdioCollector {
                        onStreamFinished: {
                            let layout = this.text.trim();
                            if (layout !== "" && layout !== "null") {
                                screenRoot.kbLayout = layout;
                            }
                        }
                    }
                }
                Timer { interval: 10000; running: true; repeat: true; triggeredOnStart: true; onTriggered: kbPoller.running = true }

                Process {
                    id: batPoller
                    running: !screenRoot.isDesktop
                    command: ["bash", "-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1 || echo '100'; cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n1 || echo 'AC'"]
                    stdout: StdioCollector {
                        onStreamFinished: {
                            let lines = this.text.trim().split("\n");
                            if (lines.length >= 2) {
                                screenRoot.batPct = lines[0] || "100";
                                screenRoot.batStatus = lines[1] || "Unknown";
                            }
                        }
                    }
                }
                Timer { interval: 5000; running: !screenRoot.isDesktop; repeat: true; triggeredOnStart: true; onTriggered: batPoller.running = true }

                Process {
                    id: weatherPoller
                    property string scriptPath: Qt.resolvedUrl("calendar/weather.sh").toString().replace(/^file:\/\//, "")
                    command: ["bash", "-c", '"' + scriptPath + '" --island']
                    stdout: StdioCollector {
                        onStreamFinished: {
                            let f = this.text.trim().split("\t");
                            if (f.length >= 12) {
                                screenRoot.weatherIcon = f[10] || "";
                                screenRoot.weatherTemp = f[11] || "--°C";
                            }
                        }
                    }
                }
                Timer { interval: 900000; running: true; repeat: true; triggeredOnStart: true; onTriggered: weatherPoller.running = true }

                // ---------------------------------------------------------
                // 1. LIVING BACKGROUND
                // ---------------------------------------------------------

                Rectangle {
                    anchors.fill: parent
                    color: root.base
                }

                Image {
                    id: bgWallpaper
                    anchors.fill: parent
                    source: screenRoot.staticWallpaperPath
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: false
                    cache: true
                }

                MultiEffect {
                    source: bgWallpaper
                    anchors.fill: bgWallpaper
                    blurEnabled: true
                    blurMax: 28 * screenRoot.sc
                    blur: 0.5
                }

                Rectangle {
                    id: dimmer
                    anchors.fill: parent
                    color: "black"
                    opacity: 0.25
                }

                Item {
                    anchors.fill: parent

                    Rectangle {
                        width: parent.width * 0.8; height: width; radius: width / 2
                        x: (parent.width / 2 - width / 2) + Math.cos(screenRoot.globalOrbitAngle * 2) * (200 * screenRoot.sc)
                        y: (parent.height / 2 - height / 2) + Math.sin(screenRoot.globalOrbitAngle * 2) * (150 * screenRoot.sc)
                        scale: 1.0 + Math.sin(screenRoot.globalOrbitAngle * 6) * 0.05
                        opacity: screenRoot.inputActive ? 0.04 : 0.08
                        color: Qt.hsla((screenRoot.globalOrbitAngle / (Math.PI * 2) + 0.0) % 1.0, 0.6, 0.5, 1.0)
                        Behavior on opacity { NumberAnimation { duration: 600 } }
                    }

                    Rectangle {
                        width: parent.width * 0.9; height: width; radius: width / 2
                        x: (parent.width / 2 - width / 2) + Math.sin(screenRoot.globalOrbitAngle * 1.5) * (-200 * screenRoot.sc)
                        y: (parent.height / 2 - height / 2) + Math.cos(screenRoot.globalOrbitAngle * 1.5) * (-150 * screenRoot.sc)
                        scale: 1.0 + Math.cos(screenRoot.globalOrbitAngle * 5) * 0.05
                        opacity: screenRoot.inputActive ? 0.03 : 0.06
                        color: Qt.hsla((screenRoot.globalOrbitAngle / (Math.PI * 2) + 0.33) % 1.0, 0.6, 0.5, 1.0)
                        Behavior on opacity { NumberAnimation { duration: 600 } }
                    }

                    Item {
                        anchors.fill: parent
                        opacity: screenRoot.introState
                        scale: 1.1 - (0.1 * screenRoot.introState)

                        Repeater {
                            model: 4
                            Rectangle {
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: -40 * screenRoot.sc
                                width: (400 * screenRoot.sc) + (index * (220 * screenRoot.sc))
                                height: width
                                radius: width / 2
                                color: "transparent"
                                border.color: lockUI.failed ? root.red : root.text
                                border.width: Math.max(1, 1 * screenRoot.sc)
                                opacity: lockUI.failed ? (0.1 - (index * 0.02)) : (screenRoot.inputActive ? (0.02 - (index * 0.005)) : (0.04 - (index * 0.01)))
                                Behavior on border.color { ColorAnimation { duration: 600; easing.type: Easing.OutExpo } }
                                Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
                            }
                        }
                    }
                }

                // ---------------------------------------------------------
                // 2. MAIN CONTENT LAYER
                // ---------------------------------------------------------
                MouseArea {
                    anchors.fill: parent
                    enabled: !screenRoot.isPlayingIntro
                    onClicked: {
                        if (screenRoot.powerMenuOpen) screenRoot.powerMenuOpen = false;
                        if (!screenRoot.inputActive) screenRoot.inputActive = true;
                        inputField.forceActiveFocus();
                    }
                }

                Item {
                    anchors.fill: parent
                    opacity: screenRoot.introState
                    transform: Translate { y: (30 * screenRoot.sc) * (1.0 - screenRoot.introState) }

                    // --- CLOCK MODULE (Idle State) ---
                    ColumnLayout {
                        id: clockModule
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: screenRoot.inputActive ? (-120 * screenRoot.sc) : (-40 * screenRoot.sc)
                        spacing: -10 * screenRoot.sc

                        opacity: screenRoot.inputActive ? 0.0 : 1.0
                        scale: screenRoot.inputActive ? 0.9 : 1.0
                        visible: opacity > 0.01

                        Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
                        Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                        Behavior on scale { NumberAnimation { duration: 500; easing.type: Easing.OutBack } }

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 0

                            Text {
                                id: clockHours
                                font.family: root.nerdPropoFont
                                font.pixelSize: 140 * screenRoot.sc
                                font.weight: Font.Bold
                                color: root.text
                                Behavior on color { ColorAnimation { duration: 300 } }
                            }
                            Text {
                                text: ":"
                                font.family: root.nerdPropoFont
                                font.pixelSize: 140 * screenRoot.sc
                                font.weight: Font.Bold
                                opacity: 0.5
                                color: root.text
                                Behavior on color { ColorAnimation { duration: 300 } }
                            }
                            Text {
                                id: clockMinutes
                                font.family: root.nerdPropoFont
                                font.pixelSize: 140 * screenRoot.sc
                                font.weight: Font.Bold
                                color: root.text
                                Behavior on color { ColorAnimation { duration: 300 } }
                            }
                        }

                        Text {
                            id: dateText
                            Layout.alignment: Qt.AlignHCenter
                            font.family: root.nerdPropoFont
                            font.pixelSize: 22 * screenRoot.sc
                            font.weight: Font.Bold
                            color: root.text
                        }

                        Timer {
                            interval: 1000; running: true; repeat: true; triggeredOnStart: true
                            onTriggered: {
                                let d = new Date();
                                clockHours.text = Qt.formatDateTime(d, "hh");
                                clockMinutes.text = Qt.formatDateTime(d, "mm");
                                dateText.text = Qt.formatDateTime(d, "dddd, MMMM dd");
                            }
                        }
                    }

                    // --- AUTHENTICATION MODULE (Input State) ---
                    RowLayout {
                        id: authModule
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: screenRoot.inputActive ? (-40 * screenRoot.sc) : (40 * screenRoot.sc)
                        spacing: 32 * screenRoot.sc

                        opacity: screenRoot.inputActive ? 1.0 : 0.0
                        scale: screenRoot.inputActive ? 1.0 : 0.9
                        visible: opacity > 0.01

                        Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
                        Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                        Behavior on scale { NumberAnimation { duration: 500; easing.type: Easing.OutBack } }

                        // Left: Enlarged Avatar
                        Item {
                            Layout.alignment: Qt.AlignVCenter
                            width: 170 * screenRoot.sc
                            height: width // Force square aspect ratio

                            Rectangle {
                                id: avatarMask
                                anchors.fill: parent
                                radius: height / 2 // Dynamic perfect radius
                                color: "black"
                                visible: false
                                layer.enabled: true
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: height / 2
                                color: Qt.rgba(root.surface0.r, root.surface0.g, root.surface0.b, 0.5)
                                visible: avatarImg.status !== Image.Ready

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰄽"
                                    font.family: root.nerdPropoFont
                                    font.pixelSize: 64 * screenRoot.sc
                                    color: root.subtext0
                                }
                            }

                            Image {
                                id: avatarImg
                                anchors.fill: parent
                                source: screenRoot.faceIconPath !== "" ? screenRoot.faceIconPath : ""
                                fillMode: Image.PreserveAspectCrop
                                visible: false
                                cache: false
                                asynchronous: true
                            }

                            MultiEffect {
                                source: avatarImg
                                anchors.fill: avatarImg
                                maskEnabled: true
                                maskSource: avatarMask
                                visible: avatarImg.status === Image.Ready
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: height / 2
                                color: "transparent"
                                border.color: lockUI.failed ? root.red : (lockUI.authenticating ? root.peach : Qt.rgba(root.text.r, root.text.g, root.text.b, 0.5))
                                border.width: Math.max(1, 3 * screenRoot.sc)
                                Behavior on border.color { ColorAnimation { duration: 300 } }
                            }
                        }

                        // Right: Text Details & Input
                        ColumnLayout {
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 16 * screenRoot.sc

                            Text {
                                Layout.alignment: Qt.AlignLeft
                                text: screenRoot.currentUser
                                font.family: root.nerdPropoFont
                                font.pixelSize: 28 * screenRoot.sc
                                font.weight: Font.Bold
                                color: root.text
                            }

                            RowLayout {
                                Layout.alignment: Qt.AlignLeft
                                spacing: 12 * screenRoot.sc

                                Rectangle {
                                    width: 36 * screenRoot.sc
                                    height: width // Force square
                                    radius: height / 2 // Perfect circle

                                    color: lockUI.failed
                                        ? Qt.rgba(root.red.r,   root.red.g,   root.red.b,   0.2)
                                        : (lockUI.authenticating
                                            ? Qt.rgba(root.peach.r, root.peach.g, root.peach.b, 0.2)
                                            : Qt.rgba(root.mauve.r, root.mauve.g, root.mauve.b, 0.15))
                                    border.color: lockUI.failed
                                        ? root.red
                                        : (lockUI.authenticating ? root.peach : root.mauve)
                                    border.width: Math.max(1, 1 * screenRoot.sc)
                                    Behavior on color { ColorAnimation { duration: 300 } }
                                    Behavior on border.color { ColorAnimation { duration: 300 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: lockUI.failed ? "󰌾" : (lockUI.authenticating ? "󰌿" : "󰌾")
                                        font.family: root.nerdPropoFont
                                        font.pixelSize: 18 * screenRoot.sc
                                        color: lockUI.failed
                                            ? root.red
                                            : (lockUI.authenticating ? root.peach : root.mauve)
                                        Behavior on color { ColorAnimation { duration: 300 } }
                                    }
                                }

                                Text {
                                    font.family: root.nerdPropoFont
                                    font.pixelSize: 14 * screenRoot.sc
                                    font.weight: Font.Medium
                                    font.letterSpacing: 2.0
                                    color: lockUI.failed
                                        ? root.red
                                        : (lockUI.authenticating ? root.peach : root.text)
                                    text: lockUI.statusText.toUpperCase()
                                    Behavior on color { ColorAnimation { duration: 300 } }
                                }
                            }

                            Rectangle {
                                id: pinPill
                                Layout.alignment: Qt.AlignLeft
                                width: 280 * screenRoot.sc
                                height: 60 * screenRoot.sc
                                radius: height / 2 // Perfect pill shape natively!
                                clip: true

                                color: lockUI.failed ? Qt.rgba(root.red.r, root.red.g, root.red.b, 0.1) : Qt.rgba(root.surface0.r, root.surface0.g, root.surface0.b, 0.5)
                                border.width: Math.max(1, 2 * screenRoot.sc)
                                border.color: {
                                    if (lockUI.failed) return root.red;
                                    if (lockUI.authenticating) return root.peach;
                                    if (inputField.text.length > 0) return root.text;
                                    return Qt.rgba(root.text.r, root.text.g, root.text.b, 0.08);
                                }

                                Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutExpo } }
                                Behavior on border.color { ColorAnimation { duration: 250; easing.type: Easing.OutExpo } }

                                scale: lockUI.failed ? 1.05 : (lockUI.authenticating ? 0.98 : 1.0)
                                Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

                                transform: Translate { id: shakeTranslate; x: 0 }

                                SequentialAnimation {
                                    id: shakeAnim
                                    NumberAnimation { target: shakeTranslate; property: "x"; from: 0; to: -8 * screenRoot.sc; duration: 120; easing.type: Easing.InOutSine }
                                    NumberAnimation { target: shakeTranslate; property: "x"; from: -8 * screenRoot.sc; to: 8 * screenRoot.sc; duration: 120; easing.type: Easing.InOutSine }
                                    NumberAnimation { target: shakeTranslate; property: "x"; from: 8 * screenRoot.sc; to: 0; duration: 120; easing.type: Easing.InOutSine }
                                }

                                Connections {
                                    target: lockUI
                                    function onFailedChanged() {
                                        if (lockUI.failed) shakeAnim.restart();
                                    }
                                }

                                TextInput {
                                    id: inputField
                                    anchors.fill: parent
                                    opacity: 0
                                    echoMode: TextInput.Password
                                    enabled: !screenRoot.isPlayingIntro

                                    property string oldText: ""

                                    Component.onCompleted: forceActiveFocus()

                                    onActiveFocusChanged: {
                                        if (!activeFocus && !screenRoot.powerMenuOpen && !screenRoot.isPlayingIntro) {
                                            forceActiveFocus();
                                        }
                                    }

                                    Keys.onPressed: (event) => {
                                        if (event.key === Qt.Key_Escape) {
                                            screenRoot.inputActive = false;
                                            text = "";
                                            passModel.clear();
                                            event.accepted = true;
                                        }
                                        else if (!screenRoot.inputActive) {
                                            screenRoot.inputActive = true;
                                        }
                                    }

                                    onAccepted: {
                                        if (text.length > 0 && pam.responseRequired && !lockUI.authenticating) {
                                            lockUI.authenticating = true;
                                            lockUI.statusText = "Authenticating...";
                                            lockUI.failed = false;
                                            pam.respond(text);
                                            text = "";
                                            oldText = "";
                                            passModel.clear();
                                        }
                                    }

                                    onTextChanged: {
                                        if (lockUI.authenticating) return;

                                        if (text.length > 0 && !screenRoot.inputActive) {
                                            screenRoot.inputActive = true;
                                        }

                                        idleTimer.restart();

                                        if (text !== oldText) {
                                            if (text.length > oldText.length) {
                                                for (let i = oldText.length; i < text.length; i++) {
                                                    passModel.append({ "charStr": text.charAt(i), "isDot": lockSettings.hidePassword });
                                                }
                                            } else if (text.length < oldText.length) {
                                                let diff = oldText.length - text.length;
                                                for (let i = 0; i < diff; i++) {
                                                    passModel.remove(passModel.count - 1);
                                                }
                                            } else {
                                                passModel.clear();
                                                for (let i = 0; i < text.length; i++) {
                                                    passModel.append({ "charStr": text.charAt(i), "isDot": lockSettings.hidePassword });
                                                }
                                            }
                                            oldText = text;
                                        }

                                        if (text.length > 0) {
                                            lockUI.failed = false;
                                            lockUI.statusText = "Enter PIN";
                                        } else {
                                            if (!lockUI.failed) lockUI.statusText = "Locked";
                                        }
                                    }
                                }

                                ListModel {
                                    id: passModel
                                }

                                Item {
                                    anchors.fill: parent
                                    anchors.leftMargin: 20 * screenRoot.sc
                                    anchors.rightMargin: 20 * screenRoot.sc
                                    clip: true

                                    Row {
                                        id: dotRow
                                        anchors.centerIn: parent
                                        spacing: 4 * screenRoot.sc

                                        Repeater {
                                            model: passModel
                                            // Render text directly as the delegate to avoid circular layout loops
                                            delegate: Text {
                                                text: model.isDot ? "•" : model.charStr
                                                font.family: root.nerdPropoFont
                                                font.pixelSize: model.isDot ? (32 * screenRoot.sc) : (24 * screenRoot.sc)
                                                font.weight: Font.Bold
                                                color: lockUI.failed ? root.red : (lockUI.authenticating ? root.peach : root.text)
                                                verticalAlignment: Text.AlignVCenter
                                                height: pinPill.height

                                                NumberAnimation on opacity { from: 0; to: 1; duration: 150 }

                                                Timer {
                                                    interval: lockSettings.revealDuration
                                                    running: !model.isDot && !lockSettings.hidePassword
                                                    onTriggered: {
                                                        if (index >= 0 && index < passModel.count) {
                                                            passModel.setProperty(index, "isDot", true);
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ---------------------------------------------------------
                // 3. BOTTOM SYSTEM INFO PILLS
                // ---------------------------------------------------------
                RowLayout {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 40 * screenRoot.sc
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 16 * screenRoot.sc

                    opacity: screenRoot.introState
                    transform: Translate { y: (20 * screenRoot.sc) * (1.0 - screenRoot.introState) }

                    // KB Layout Pill
                    Rectangle {
                        property bool isHovered: kbMouse.containsMouse
                        Layout.preferredHeight: 48 * screenRoot.sc
                        Layout.preferredWidth: kbLayoutRow.implicitWidth + (36 * screenRoot.sc)
                        radius: height / 2 // Dynamic pill shape

                        color: isHovered ? Qt.rgba(root.surface1.r, root.surface1.g, root.surface1.b, 0.6) : Qt.rgba(root.surface0.r, root.surface0.g, root.surface0.b, 0.4)
                        border.color: isHovered ? root.mauve : Qt.rgba(root.text.r, root.text.g, root.text.b, 0.08)
                        border.width: Math.max(1, 1 * screenRoot.sc)

                        scale: isHovered ? 1.05 : 1.0
                        Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Behavior on border.color { ColorAnimation { duration: 200 } }

                        RowLayout {
                            id: kbLayoutRow; anchors.centerIn: parent; spacing: 8 * screenRoot.sc
                            Text { text: "󰌌"; font.family: root.nerdPropoFont; font.pixelSize: 18 * screenRoot.sc; color: parent.parent.isHovered ? root.mauve : root.overlay2; Behavior on color { ColorAnimation { duration: 200 } } }
                            Text { text: screenRoot.kbLayout; font.family: root.nerdPropoFont; font.pixelSize: 14 * screenRoot.sc; font.weight: Font.Black; color: root.text }
                        }
                        MouseArea { id: kbMouse; anchors.fill: parent; hoverEnabled: true; enabled: !screenRoot.isPlayingIntro }
                    }

                    // Battery Pill
                    Rectangle {
                        property bool isHovered: batMouse.containsMouse
                        visible: !screenRoot.isDesktop
                        Layout.preferredHeight: 48 * screenRoot.sc
                        Layout.preferredWidth: batLayoutRow.implicitWidth + (36 * screenRoot.sc)
                        radius: height / 2

                        color: isHovered ? Qt.rgba(root.surface1.r, root.surface1.g, root.surface1.b, 0.6) : Qt.rgba(root.surface0.r, root.surface0.g, root.surface0.b, 0.4)
                        border.color: isHovered ? batLayoutRow.dynamicBatColor : Qt.rgba(root.text.r, root.text.g, root.text.b, 0.08)
                        border.width: Math.max(1, 1 * screenRoot.sc)

                        scale: isHovered ? 1.05 : 1.0
                        Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Behavior on border.color { ColorAnimation { duration: 200 } }

                        RowLayout {
                            id: batLayoutRow; anchors.centerIn: parent; spacing: 8 * screenRoot.sc

                            property color dynamicBatColor: {
                                if (screenRoot.batStatus === "Charging") return root.green;
                                let pct = parseInt(screenRoot.batPct);
                                if (pct >= 60) return root.green;
                                if (pct >= 25) return root.peach;
                                return root.red;
                            }

                            Text {
                                text: screenRoot.batStatus === "Charging" ? "󰂄" : (parseInt(screenRoot.batPct) < 20 ? "󰂃" : "󰁹")
                                font.family: root.nerdPropoFont
                                font.pixelSize: 20 * screenRoot.sc
                                color: batLayoutRow.dynamicBatColor
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                            Text {
                                text: screenRoot.batPct + "%"
                                font.family: root.nerdPropoFont
                                font.pixelSize: 14 * screenRoot.sc
                                font.weight: Font.Black
                                color: batLayoutRow.dynamicBatColor
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                        }
                        MouseArea { id: batMouse; anchors.fill: parent; hoverEnabled: true; enabled: !screenRoot.isPlayingIntro }
                    }

                    // Weather Pill
                    Rectangle {
                        property bool isHovered: weatherMouse.containsMouse
                        Layout.preferredHeight: 48 * screenRoot.sc
                        Layout.preferredWidth: weatherLayoutRow.implicitWidth + (36 * screenRoot.sc)
                        radius: height / 2

                        color: isHovered ? Qt.rgba(root.surface1.r, root.surface1.g, root.surface1.b, 0.6) : Qt.rgba(root.surface0.r, root.surface0.g, root.surface0.b, 0.4)
                        border.color: isHovered ? root.blue : Qt.rgba(root.text.r, root.text.g, root.text.b, 0.08)
                        border.width: Math.max(1, 1 * screenRoot.sc)

                        scale: isHovered ? 1.05 : 1.0
                        Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Behavior on border.color { ColorAnimation { duration: 200 } }

                        RowLayout {
                            id: weatherLayoutRow; anchors.centerIn: parent; spacing: 8 * screenRoot.sc
                            Text {
                                text: screenRoot.weatherIcon
                                font.family: root.nerdPropoFont
                                font.pixelSize: 20 * screenRoot.sc
                                color: parent.parent.isHovered ? root.blue : root.text
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                            Text {
                                text: screenRoot.weatherTemp
                                font.family: root.nerdPropoFont
                                font.pixelSize: 14 * screenRoot.sc
                                font.weight: Font.Black
                                color: root.text
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                        }
                        MouseArea { id: weatherMouse; anchors.fill: parent; hoverEnabled: true; enabled: !screenRoot.isPlayingIntro }
                    }
                }

                // ---------------------------------------------------------
                // 4. POWER MENU
                // ---------------------------------------------------------
                Rectangle {
                    id: powerMenu
                    anchors.bottom: powerBtn.top
                    anchors.right: parent.right
                    anchors.bottomMargin: 15 * screenRoot.sc
                    anchors.rightMargin: 40 * screenRoot.sc
                    width: 280 * screenRoot.sc
                    height: screenRoot.powerMenuOpen ? (menuLayout.implicitHeight + (20 * screenRoot.sc)) : 0
                    radius: 18 * screenRoot.sc
                    clip: true
                    opacity: screenRoot.powerMenuOpen ? 1 : 0

                    color: Qt.rgba(root.surface0.r, root.surface0.g, root.surface0.b, 0.95)
                    border.color: Qt.rgba(root.mauve.r, root.mauve.g, root.mauve.b, 0.25)
                    border.width: Math.max(1, 1 * screenRoot.sc)

                    Behavior on height { NumberAnimation { duration: 350; easing.type: Easing.OutExpo } }
                    Behavior on opacity { NumberAnimation { duration: 250 } }

                    ColumnLayout {
                        id: menuLayout
                        anchors.top: parent.top
                        anchors.topMargin: 10 * screenRoot.sc
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 6 * screenRoot.sc

                        // --- SETTINGS SECTION ---
                        Text {
                            text: "SETTINGS"
                            font.family: root.nerdPropoFont
                            font.weight: Font.Black
                            font.pixelSize: 12 * screenRoot.sc
                            font.letterSpacing: 1.5
                            color: root.mauve
                            Layout.leftMargin: 18 * screenRoot.sc; Layout.topMargin: 4 * screenRoot.sc; Layout.bottomMargin: 4 * screenRoot.sc
                        }

                        // Hide Password Toggle
                        RowLayout {
                            Layout.fillWidth: true; Layout.leftMargin: 18 * screenRoot.sc; Layout.rightMargin: 18 * screenRoot.sc; Layout.topMargin: 4 * screenRoot.sc
                            Text {
                                text: "Hide password"
                                font.family: root.nerdPropoFont
                                font.pixelSize: 14 * screenRoot.sc
                                font.weight: Font.Medium
                                color: root.text
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                width: 40 * screenRoot.sc; height: 22 * screenRoot.sc; radius: height / 2
                                color: lockSettings.hidePassword ? root.mauve : root.surface2
                                Behavior on color { ColorAnimation { duration: 250 } }

                                Rectangle {
                                    width: height; height: 18 * screenRoot.sc; radius: height / 2
                                    x: lockSettings.hidePassword ? parent.width - width - (2 * screenRoot.sc) : (2 * screenRoot.sc)
                                    y: (parent.height - height) / 2
                                    color: root.base
                                    Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                                }
                                MouseArea {
                                    anchors.fill: parent;
                                    onClicked: {
                                        lockSettings.hidePassword = !lockSettings.hidePassword;
                                        if (lockSettings.hidePassword) {
                                            for(let i = 0; i < passModel.count; i++) passModel.setProperty(i, "isDot", true);
                                        }
                                    }
                                }
                            }
                        }

                        // Reveal Delay Slider
                        ColumnLayout {
                            Layout.fillWidth: true; Layout.leftMargin: 18 * screenRoot.sc; Layout.rightMargin: 18 * screenRoot.sc; Layout.topMargin: 8 * screenRoot.sc; Layout.bottomMargin: 8 * screenRoot.sc; spacing: 8 * screenRoot.sc
                            opacity: lockSettings.hidePassword ? 0.3 : 1.0
                            Behavior on opacity { NumberAnimation { duration: 200 } }

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "Reveal delay"
                                    font.family: root.nerdPropoFont
                                    font.pixelSize: 14 * screenRoot.sc
                                    font.weight: Font.Medium
                                    color: root.blue
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: lockSettings.revealDuration >= 1000 ? (lockSettings.revealDuration / 1000).toFixed(1) + " s" : lockSettings.revealDuration + " ms"
                                    font.family: root.nerdPropoFont
                                    font.pixelSize: 13 * screenRoot.sc
                                    font.weight: Font.Bold
                                    color: root.peach
                                }
                            }

                            Item {
                                Layout.fillWidth: true; Layout.preferredHeight: 28 * screenRoot.sc

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width; height: 8 * screenRoot.sc; radius: height / 2; color: root.surface2
                                    Rectangle {
                                        width: ((lockSettings.revealDuration - 100) / 2900) * parent.width
                                        height: parent.height; radius: height / 2; color: root.mauve
                                    }
                                }

                                Rectangle {
                                    id: sliderThumb
                                    width: 20 * screenRoot.sc
                                    height: width
                                    radius: height / 2
                                    color: root.peach
                                    border.color: root.crust; border.width: Math.max(1, 2 * screenRoot.sc)
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: Math.max(0, Math.min(((lockSettings.revealDuration - 100) / 2900) * parent.width - (width / 2), parent.width - width))

                                    scale: sliderMouse.pressed ? 1.3 : (sliderMouse.containsMouse ? 1.15 : 1.0)
                                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                                }

                                MultiEffect {
                                    source: sliderThumb
                                    anchors.fill: sliderThumb
                                    shadowEnabled: true
                                    shadowBlur: 0.5
                                    shadowColor: "#000000"
                                    shadowOpacity: 0.4
                                    shadowVerticalOffset: 2 * screenRoot.sc
                                }

                                MouseArea {
                                    id: sliderMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    enabled: !lockSettings.hidePassword
                                    preventStealing: true

                                    function updateVal(mouseX) {
                                        let pct = Math.max(0, Math.min(1, mouseX / width));
                                        let ms = Math.round(100 + (pct * 2900));
                                        if (ms % 100 < 10) ms -= (ms % 100);
                                        else if (ms % 100 > 90) ms += (100 - (ms % 100));
                                        lockSettings.revealDuration = ms;
                                    }

                                    onPositionChanged: (mouse) => {
                                        if (pressed) {
                                            updateVal(mouse.x);
                                        }
                                    }
                                    onPressed: (mouse) => updateVal(mouse.x)
                                }
                            }
                        }

                        // Separator
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: Math.max(1, 1 * screenRoot.sc)
                            color: Qt.rgba(root.mauve.r, root.mauve.g, root.mauve.b, 0.2)
                            Layout.leftMargin: 18 * screenRoot.sc; Layout.rightMargin: 18 * screenRoot.sc; Layout.topMargin: 4 * screenRoot.sc; Layout.bottomMargin: 4 * screenRoot.sc
                        }

                        // --- SYSTEM ACTIONS SECTION ---
                        Text {
                            text: "SYSTEM"
                            font.family: root.nerdPropoFont
                            font.weight: Font.Black
                            font.pixelSize: 12 * screenRoot.sc
                            font.letterSpacing: 1.5
                            color: root.mauve
                            Layout.leftMargin: 18 * screenRoot.sc; Layout.bottomMargin: 4 * screenRoot.sc
                        }

                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 48 * screenRoot.sc; Layout.leftMargin: 10 * screenRoot.sc; Layout.rightMargin: 10 * screenRoot.sc; radius: 12 * screenRoot.sc
                            color: ma1.containsMouse ? Qt.rgba(root.blue.r, root.blue.g, root.blue.b, 0.15) : Qt.rgba(root.blue.r, root.blue.g, root.blue.b, 0.04)
                            scale: ma1.pressed ? 0.95 : (ma1.containsMouse ? 1.02 : 1.0)
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 16 * screenRoot.sc; anchors.rightMargin: 16 * screenRoot.sc; spacing: 0
                                Text { text: "󰜉"; font.family: root.nerdPropoFont; font.pixelSize: 18 * screenRoot.sc; color: ma1.containsMouse ? root.blue : Qt.rgba(root.blue.r, root.blue.g, root.blue.b, 0.6); Behavior on color { ColorAnimation { duration: 200 } } }
                                Item { Layout.fillWidth: true }
                                Text { text: "Reboot"; font.family: root.nerdPropoFont; font.pixelSize: 15 * screenRoot.sc; font.weight: Font.Medium; color: ma1.containsMouse ? root.blue : Qt.rgba(root.blue.r, root.blue.g, root.blue.b, 0.6); Behavior on color { ColorAnimation { duration: 200 } } }
                            }
                            MouseArea {
                                id: ma1; anchors.fill: parent; hoverEnabled: true;
                                onClicked: {
                                    screenRoot.powerMenuOpen = false;
                                    reloadProcess.running = true;
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 48 * screenRoot.sc; Layout.leftMargin: 10 * screenRoot.sc; Layout.rightMargin: 10 * screenRoot.sc; radius: 12 * screenRoot.sc
                            color: ma2.containsMouse ? Qt.rgba(root.mauve.r, root.mauve.g, root.mauve.b, 0.15) : Qt.rgba(root.mauve.r, root.mauve.g, root.mauve.b, 0.04)
                            scale: ma2.pressed ? 0.95 : (ma2.containsMouse ? 1.02 : 1.0)
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 16 * screenRoot.sc; anchors.rightMargin: 16 * screenRoot.sc; spacing: 0
                                Text { text: "󰒲"; font.family: root.nerdPropoFont; font.pixelSize: 18 * screenRoot.sc; color: ma2.containsMouse ? root.mauve : Qt.rgba(root.mauve.r, root.mauve.g, root.mauve.b, 0.6); Behavior on color { ColorAnimation { duration: 200 } } }
                                Item { Layout.fillWidth: true }
                                Text { text: "Suspend"; font.family: root.nerdPropoFont; font.pixelSize: 15 * screenRoot.sc; font.weight: Font.Medium; color: ma2.containsMouse ? root.mauve : Qt.rgba(root.mauve.r, root.mauve.g, root.mauve.b, 0.6); Behavior on color { ColorAnimation { duration: 200 } } }
                            }
                            MouseArea {
                                id: ma2; anchors.fill: parent; hoverEnabled: true;
                                onClicked: {
                                    screenRoot.powerMenuOpen = false;
                                    suspendProcess.running = true;
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 48 * screenRoot.sc; Layout.leftMargin: 10 * screenRoot.sc; Layout.rightMargin: 10 * screenRoot.sc; Layout.bottomMargin: 8 * screenRoot.sc; radius: 12 * screenRoot.sc
                            color: ma3.containsMouse ? Qt.rgba(root.red.r, root.red.g, root.red.b, 0.15) : Qt.rgba(root.red.r, root.red.g, root.red.b, 0.04)
                            scale: ma3.pressed ? 0.95 : (ma3.containsMouse ? 1.02 : 1.0)
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 16 * screenRoot.sc; anchors.rightMargin: 16 * screenRoot.sc; spacing: 0
                                Text { text: "󰐥"; font.family: root.nerdPropoFont; font.pixelSize: 18 * screenRoot.sc; color: ma3.containsMouse ? root.red : Qt.rgba(root.red.r, root.red.g, root.red.b, 0.6); Behavior on color { ColorAnimation { duration: 200 } } }
                                Item { Layout.fillWidth: true }
                                Text { text: "Power Off"; font.family: root.nerdPropoFont; font.pixelSize: 15 * screenRoot.sc; font.weight: Font.Medium; color: ma3.containsMouse ? root.red : Qt.rgba(root.red.r, root.red.g, root.red.b, 0.6); Behavior on color { ColorAnimation { duration: 200 } } }
                            }
                            MouseArea {
                                id: ma3; anchors.fill: parent; hoverEnabled: true;
                                onClicked: {
                                    screenRoot.powerMenuOpen = false;
                                    poweroffProcess.running = true;
                                }
                            }
                        }
                    }
                }

                // Enlarged Power Button
                Rectangle {
                    id: powerBtn
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.margins: 40 * screenRoot.sc
                    width: 52 * screenRoot.sc
                    height: width
                    radius: height / 2

                    color: screenRoot.powerMenuOpen
                            ? root.surface2
                            : (powerBtnMa.containsMouse ? Qt.rgba(root.surface1.r, root.surface1.g, root.surface1.b, 0.8) : Qt.rgba(root.surface0.r, root.surface0.g, root.surface0.b, 0.4))
                    border.color: screenRoot.powerMenuOpen ? root.red : Qt.rgba(root.text.r, root.text.g, root.text.b, 0.15)
                    border.width: Math.max(1, 1 * screenRoot.sc)

                    opacity: screenRoot.introState
                    transform: Translate { y: (20 * screenRoot.sc) * (1.0 - screenRoot.introState) }

                    scale: powerBtnMa.pressed ? 0.9 : (powerBtnMa.containsMouse ? 1.08 : 1.0)

                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on border.color { ColorAnimation { duration: 200 } }
                    Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

                    Text {
                        anchors.centerIn: parent
                        text: "󰐥"
                        font.family: root.nerdPropoFont
                        font.pixelSize: 22 * screenRoot.sc
                        color: screenRoot.powerMenuOpen ? root.red : (powerBtnMa.containsMouse ? root.text : root.subtext0)
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }

                    MouseArea {
                        id: powerBtnMa
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: !screenRoot.isPlayingIntro
                        onClicked: {
                            screenRoot.powerMenuOpen = !screenRoot.powerMenuOpen;
                            if (!screenRoot.powerMenuOpen) inputField.forceActiveFocus();
                        }
                    }
                }

                // ---------------------------------------------------------
                // 5. INTRO ANIMATION OVERLAY
                // ---------------------------------------------------------
                Item {
                    id: introOverlay
                    anchors.fill: parent
                    z: 999
                    visible: screenRoot.isPlayingIntro || opacity > 0

                    Rectangle {
                        id: ring3
                        width: 360 * screenRoot.sc
                        height: width
                        radius: height / 2
                        anchors.centerIn: parent
                        color: "transparent"
                        border.color: root.mauve
                        border.width: Math.max(1, 1 * screenRoot.sc)
                        scale: 0.5
                        opacity: 0.0
                    }
                    Rectangle {
                        id: ring2
                        width: 300 * screenRoot.sc
                        height: width
                        radius: height / 2
                        anchors.centerIn: parent
                        color: "transparent"
                        border.color: root.text
                        border.width: Math.max(1, 1 * screenRoot.sc)
                        scale: 0.8
                        opacity: 0.0
                    }
                    Rectangle {
                        id: ring1
                        width: 240 * screenRoot.sc
                        height: width
                        radius: height / 2
                        anchors.centerIn: parent
                        color: "transparent"
                        border.color: root.text
                        border.width: Math.max(1, 2 * screenRoot.sc)
                        scale: 0.8
                        opacity: 0.0
                    }

                    Item {
                        id: introLockOrb
                        width: 170 * screenRoot.sc
                        height: width
                        anchors.centerIn: parent
                        scale: 0.0
                        opacity: 0.0

                        Rectangle {
                            anchors.fill: parent
                            radius: height / 2
                            color: Qt.rgba(root.surface0.r, root.surface0.g, root.surface0.b, 0.9)
                            border.color: root.text
                            border.width: Math.max(1, 2 * screenRoot.sc)
                        }

                        Text {
                            id: introIconUnlocked
                            anchors.centerIn: parent
                            text: "󰌿"
                            font.family: root.nerdPropoFont
                            font.pixelSize: 64 * screenRoot.sc
                            color: root.text
                            opacity: 1.0
                            scale: 1.0
                            transformOrigin: Item.Center
                        }

                        Text {
                            id: introIconLocked
                            anchors.centerIn: parent
                            text: "󰌾"
                            font.family: root.nerdPropoFont
                            font.pixelSize: 64 * screenRoot.sc
                            color: root.text
                            opacity: 0.0
                            scale: 1.6
                            transformOrigin: Item.Center
                        }
                    }

                    SequentialAnimation {
                        id: introSequence

                        ParallelAnimation {
                            NumberAnimation { target: introLockOrb; property: "scale"; from: 0.0; to: 1.0; duration: 300; easing.type: Easing.OutCubic }
                            NumberAnimation { target: introLockOrb; property: "opacity"; from: 0.0; to: 1.0; duration: 200; easing.type: Easing.OutCubic }

                            NumberAnimation { target: ring1; property: "scale"; from: 0.8; to: 1.25; duration: 250; easing.type: Easing.OutCubic }
                            NumberAnimation { target: ring1; property: "opacity"; from: 0.6; to: 0.0; duration: 250; easing.type: Easing.OutCubic }

                            NumberAnimation { target: ring2; property: "scale"; from: 0.8; to: 1.4; duration: 300; easing.type: Easing.OutCubic }
                            NumberAnimation { target: ring2; property: "opacity"; from: 0.4; to: 0.0; duration: 300; easing.type: Easing.OutCubic }

                            NumberAnimation { target: ring3; property: "scale"; from: 0.5; to: 1.5; duration: 350; easing.type: Easing.OutCubic }
                            NumberAnimation { target: ring3; property: "opacity"; from: 0.3; to: 0.0; duration: 350; easing.type: Easing.OutCubic }

                            SequentialAnimation {
                                PauseAnimation { duration: 300 }
                                ParallelAnimation {
                                    NumberAnimation { target: introIconUnlocked; property: "scale"; from: 1.0; to: 0.5; duration: 100; easing.type: Easing.InCubic }
                                    NumberAnimation { target: introIconUnlocked; property: "opacity"; from: 1.0; to: 0.0; duration: 50 }

                                    NumberAnimation { target: introIconLocked; property: "scale"; from: 1.6; to: 1.0; duration: 200; easing.type: Easing.OutBack }
                                    NumberAnimation { target: introIconLocked; property: "opacity"; from: 0.0; to: 1.0; duration: 100 }

                                    SequentialAnimation {
                                        NumberAnimation { target: introLockOrb; property: "anchors.verticalCenterOffset"; from: 0; to: 3 * screenRoot.sc; duration: 40; easing.type: Easing.OutQuad }
                                        NumberAnimation { target: introLockOrb; property: "anchors.verticalCenterOffset"; from: 3 * screenRoot.sc; to: 0; duration: 120; easing.type: Easing.OutBack }
                                    }
                                }
                            }
                        }

                        PauseAnimation { duration: 50 }

                        SequentialAnimation {
                            ParallelAnimation {
                                NumberAnimation { target: introLockOrb; property: "scale"; to: 1.8; duration: 100; easing.type: Easing.InCubic }
                                NumberAnimation { target: introOverlay; property: "opacity"; to: 0.0; duration: 100; easing.type: Easing.InCubic }
                            }

                            NumberAnimation { target: screenRoot; property: "introState"; from: 0.0; to: 1.0; duration: 100; easing.type: Easing.OutCubic }
                        }

                        PropertyAction { target: screenRoot; property: "isPlayingIntro"; value: false }
                        ScriptAction { script: { inputField.text = ""; inputField.forceActiveFocus(); } }
                    }
                }
            }
        }
    }
}
