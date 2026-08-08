import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io

Item {
    id: root
    property var island

    // ── Now-playing state ─────────────────────────────────────────
    property string nowStatus: ""
    property string nowArtist: ""
    property string nowTitle: ""
    property string nowPlayer: ""
    property string nowArt: ""
    property real nowPos: 0
    property real nowLen: 0
    property bool nowActive: false
    readonly property bool nowVisible: nowActive && nowTitle !== ""
    readonly property bool nowIsPlaying: nowStatus === "playing"

    function fmtTime(ms) {
        let s = Math.floor(ms / 1000)
        if (!isFinite(s) || s < 0) s = 0
        let h = Math.floor(s / 3600)
        let m = Math.floor((s % 3600) / 60)
        let sec = s % 60
        let mm = m < 10 ? "0" + m : "" + m
        let ss = sec < 10 ? "0" + sec : "" + sec
        return h > 0 ? h + ":" + mm + ":" + ss : mm + ":" + ss
    }

    function toggleNowPlay() {
        if (root.nowPlayer === "") return
        let p = root.nowPlayer.replace(/'/g, "'\\''")
        island.exec("playerctl -p '" + p + "' play-pause")
    }

    // ── Brightness state (no shared watcher exists; polled) ───────
    property int brightValue: 60

    Process {
        id: playerPoller
        running: root.visible && island.expanded && island.currentPage === "clock"
        command: ["bash", "-lc",
            "command -v playerctl >/dev/null 2>&1 || exit 0; " +
            "plf=$(printf '{{playerName}}\\t{{status}}\\t{{artist}}\\t{{title}}\\t{{position}}\\t{{mpris:length}}\\t{{mpris:artUrl}}'); " +
            "while true; do " +
            "  out=$(playerctl -a metadata --format \"$plf\" 2>/dev/null); " +
            "  if [ -n \"$out\" ]; then " +
            "    line=$(printf '%s\\n' \"$out\" | grep -P '\\tPlaying\\t' | head -1); " +
            "    [ -z \"$line\" ] && line=$(printf '%s\\n' \"$out\" | head -1); " +
            "    printf '%s\\n' \"$line\"; " +
            "  fi; " +
            "  sleep 1; " +
            "done"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                let parts = line.split("\t")
                if (parts.length >= 5) {
                    root.nowPlayer = parts[0]
                    root.nowStatus = parts[1].toLowerCase()
                    root.nowArtist = parts[2]
                    root.nowTitle = parts[3]
                    root.nowPos = (parseFloat(parts[4]) || 0) / 1000
                    root.nowLen = (parseFloat(parts[5]) || 0) / 1000
                    root.nowArt = parts[6] || ""
                    root.nowActive = true
                } else {
                    root.nowActive = false
                }
            }
        }
    }

    Process {
        id: brightPoller
        running: root.visible && island.expanded && island.currentPage === "clock"
        command: ["bash", "-lc",
            "command -v brightnessctl >/dev/null 2>&1 || exit 0; " +
            "while true; do brightnessctl -m 2>/dev/null | awk -F, '{gsub(/%/,\"\",$4); print int($4)}'; sleep 2; done"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                let v = parseInt(line.trim())
                if (!isNaN(v)) root.brightValue = v
            }
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: island.s(28)
        anchors.bottomMargin: island.s(44)

        ColumnLayout {
            width: parent.width
            spacing: island.s(12)

            // ── Clock / Date ──────────────────────────────────
            Item {
                id: clockBlock
                Layout.alignment: Qt.AlignHCenter
                width: island.s(132)
                height: island.s(96)

                Text {
                    anchors.centerIn: parent
                    text: island.timeStrSec
                    font.family: island.monoFont; font.pixelSize: island.s(52); font.weight: Font.Black
                    color: island.mauve
                }
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: island.dateStr
                font.family: island.monoFont; font.pixelSize: island.s(15); font.weight: Font.Medium
                color: island.subtext0
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: island.greetingStr
                visible: island.greetingStr !== "" && !root.nowVisible
                font.family: island.monoFont; font.pixelSize: island.s(22); font.weight: Font.Black
                color: island.subtext0
                opacity: 0.65
            }

            // ── Now playing ────────────────────────────────────
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: island.s(54)
                visible: root.nowVisible

                Rectangle {
                    anchors.fill: parent
                    radius: island.s(12)
                    color: npHover.containsMouse
                        ? Qt.rgba(island.surface0.r, island.surface0.g, island.surface0.b, 0.65)
                        : Qt.rgba(island.surface0.r, island.surface0.g, island.surface0.b, 0.4)
                    border.width: 1
                    border.color: root.nowIsPlaying
                        ? Qt.rgba(island.green.r, island.green.g, island.green.b, 0.22)
                        : Qt.rgba(island.text.r, island.text.g, island.text.b, 0.07)
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                RowLayout {
                    anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                    anchors.leftMargin: island.s(8); anchors.rightMargin: island.s(8); anchors.topMargin: island.s(6)
                    spacing: island.s(10)

                    Item {
                        id: npCover
                        Layout.preferredWidth: island.s(32); Layout.preferredHeight: island.s(32)
                        Layout.alignment: Qt.AlignVCenter

                        Rectangle {
                            id: npCoverMask
                            anchors.fill: parent
                            radius: island.s(9)
                            visible: false
                            layer.enabled: true
                        }
                        Rectangle {
                            anchors.fill: parent
                            radius: island.s(9)
                            color: Qt.rgba(island.surface1.r, island.surface1.g, island.surface1.b, 0.5)
                            Text {
                                anchors.centerIn: parent
                                text: root.nowIsPlaying ? "󰝚" : "󰏤"
                                font.family: island.nerdFont; font.pixelSize: island.s(14)
                                color: island.mauve
                            }
                        }
                        Image {
                            id: npArt
                            anchors.fill: parent
                            source: root.nowArt
                            fillMode: Image.PreserveAspectCrop
                            visible: false
                            asynchronous: true
                            cache: true
                        }
                        MultiEffect {
                            anchors.fill: npArt
                            source: npArt
                            maskEnabled: true
                            maskSource: npCoverMask
                            visible: npArt.status === Image.Ready
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: island.s(2)

                        Text {
                            text: root.nowTitle
                            font.family: island.monoFont; font.pixelSize: island.s(12); font.weight: Font.Black
                            color: island.text; elide: Text.ElideRight; Layout.fillWidth: true
                        }
                        Text {
                            text: root.nowArtist
                            visible: root.nowArtist !== ""
                            font.family: island.monoFont; font.pixelSize: island.s(9)
                            color: island.subtext0; elide: Text.ElideRight; Layout.fillWidth: true
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: island.s(24); Layout.preferredHeight: island.s(24)
                        Layout.alignment: Qt.AlignVCenter
                        radius: island.s(12)
                        color: Qt.rgba(island.surface1.r, island.surface1.g, island.surface1.b, 0.4)
                        Text {
                            anchors.centerIn: parent
                            text: root.nowIsPlaying ? "󰏤" : "󰐎"
                            font.family: island.nerdFont; font.pixelSize: island.s(13)
                            color: root.nowIsPlaying ? island.green : island.mauve
                        }
                    }
                }

                RowLayout {
                    anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
                    anchors.leftMargin: island.s(9); anchors.rightMargin: island.s(9); anchors.bottomMargin: island.s(5)
                    spacing: island.s(6)

                    Text {
                        text: root.fmtTime(root.nowPos)
                        font.family: island.monoFont; font.pixelSize: island.s(9)
                        color: island.subtext0
                    }
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: island.s(3); Layout.alignment: Qt.AlignVCenter
                        radius: island.s(1.5)
                        color: Qt.rgba(island.surface1.r, island.surface1.g, island.surface1.b, 0.4)
                        clip: true

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            height: parent.height
                            width: parent.width * (root.nowLen > 0 ? Math.min(Math.max(root.nowPos / root.nowLen, 0), 1) : 0)
                            radius: island.s(1.5)
                            color: island.mauve
                            Behavior on width { NumberAnimation { duration: 1000; easing.type: Easing.Linear } }
                        }
                        Rectangle {
                            width: parent.width * 0.4; height: parent.height * 4
                            y: -parent.height * 1.5
                            rotation: 12
                            color: "transparent"
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "transparent" }
                                GradientStop { position: 0.5; color: Qt.rgba(island.text.r, island.text.g, island.text.b, 0.35) }
                                GradientStop { position: 1.0; color: "transparent" }
                            }
                            SequentialAnimation on x {
                                running: root.nowIsPlaying
                                loops: Animation.Infinite
                                PauseAnimation { duration: 800 }
                                NumberAnimation { from: -width; to: parent.parent.width + width; duration: 1400; easing.type: Easing.InOutQuad }
                            }
                        }
                    }
                    Text {
                        text: root.fmtTime(root.nowLen)
                        font.family: island.monoFont; font.pixelSize: island.s(9)
                        color: island.subtext0
                    }
                }

                MouseArea {
                    id: npHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggleNowPlay()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: island.s(8); Layout.bottomMargin: island.s(4)
                height: 1
                color: Qt.rgba(island.text.r, island.text.g, island.text.b, 0.08)
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: island.s(20)

                // WiFi
                RowLayout {
                    spacing: island.s(8)
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        id: wifiIcon
                        text: {
                            if (island.wifiSignal <= 0) return "󰤮";
                            if (island.wifiSignal < 25) return "󰤟";
                            if (island.wifiSignal < 50) return "󰤢";
                            if (island.wifiSignal < 75) return "󰤥";
                            return "󰤨";
                        }
                        font.family: island.nerdFont; font.pixelSize: island.s(24)
                        color: island.wifiSignal > 0 ? island.blue : island.overlay0

                        // Subtle wave animation for active WiFi
                        SequentialAnimation on opacity {
                            running: island.wifiSignal > 0
                            loops: Animation.Infinite
                            NumberAnimation { from: 1.0; to: 0.6; duration: 1200; easing.type: Easing.InOutSine }
                            NumberAnimation { from: 0.6; to: 1.0; duration: 1200; easing.type: Easing.InOutSine }
                        }
                    }
                    ColumnLayout {
                        spacing: island.s(1)
                        Text {
                            text: island.wifiSsid !== "" ? island.wifiSsid : "Disconnected"
                            font.family: island.monoFont; font.pixelSize: island.s(14); font.weight: Font.Bold
                            color: island.wifiSsid !== "" ? island.text : island.overlay0
                        }
                    }
                    Rectangle {
                        width: island.s(48); height: island.s(24); radius: island.s(12)
                        color: island.wifiSignal > 0 ? Qt.rgba(island.blue.r, island.blue.g, island.blue.b, 0.2) : island.surface0
                        border.color: island.wifiSignal > 0 ? island.blue : island.overlay0
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: island.wifiSignal > 0 ? "ON" : "OFF"
                            font.family: island.monoFont; font.pixelSize: island.s(10); font.weight: Font.Black
                            color: island.wifiSignal > 0 ? island.blue : island.overlay0
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: island.exec("nmcli radio wifi " + (island.wifiSignal > 0 ? "off" : "on"))
                        }
                    }
                }

                // Bluetooth
                RowLayout {
                    spacing: island.s(8)
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text: "󰂯"
                        font.family: island.nerdFont; font.pixelSize: island.s(24)
                        color: island.bluetoothOn ? island.blue : island.overlay0
                    }
                    ColumnLayout {
                        spacing: island.s(1)
                        Text {
                            text: island.bluetoothOn ? "On" : "Off"
                            font.family: island.monoFont; font.pixelSize: island.s(14); font.weight: Font.Bold
                            color: island.bluetoothOn ? island.text : island.overlay0
                        }
                        Text {
                            text: island.bluetoothDevices > 0 ? island.bluetoothDevices + " device" + (island.bluetoothDevices === 1 ? "" : "s") : ""
                            visible: island.bluetoothOn
                            font.family: island.monoFont; font.pixelSize: island.s(11)
                            color: island.subtext0
                        }
                    }
                    Rectangle {
                        width: island.s(48); height: island.s(24); radius: island.s(12)
                        color: island.bluetoothOn ? Qt.rgba(island.blue.r, island.blue.g, island.blue.b, 0.2) : island.surface0
                        border.color: island.bluetoothOn ? island.blue : island.overlay0
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: island.bluetoothOn ? "ON" : "OFF"
                            font.family: island.monoFont; font.pixelSize: island.s(10); font.weight: Font.Black
                            color: island.bluetoothOn ? island.blue : island.overlay0
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: island.exec("bluetoothctl power " + (island.bluetoothOn ? "off" : "on"))
                        }
                    }

                    // Connected device name on the right
                    Text {
                        text: island.btDeviceList.length > 0 ? "󰋋  " + island.btDeviceList[0].name : ""
                        visible: island.bluetoothOn && island.btDeviceList.length > 0
                        font.family: island.monoFont; font.pixelSize: island.s(12); font.weight: Font.Bold
                        color: island.text
                        Layout.leftMargin: island.s(8)
                    }
                }
            }

            // ── Volume / Brightness sliders ────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: island.s(14)

                RowLayout {
                    Layout.fillWidth: true
                    spacing: island.s(8)

                    Text {
                        text: island.volMuted ? "󰝟" : (island.volIcon !== "" ? island.volIcon : "󰕾")
                        font.family: island.nerdFont; font.pixelSize: island.s(15)
                        color: island.volMuted ? island.red : island.blue
                        Layout.preferredWidth: island.s(22)
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Rectangle {
                        id: volTrack
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        height: island.s(20)
                        radius: island.s(10)
                        clip: true
                        color: Qt.rgba(island.surface0.r, island.surface0.g, island.surface0.b, 0.65)
                        border.color: Qt.rgba(island.text.r, island.text.g, island.text.b, 0.06)
                        border.width: 1

                        property real pct: island.volMuted ? 0 : (parseInt(island.volPercent) || 0)

                        Rectangle {
                            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                            width: parent.width * (parent.pct / 100)
                            height: parent.height
                            radius: island.s(10)
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: Qt.rgba(island.blue.r, island.blue.g, island.blue.b, 0.85) }
                                GradientStop { position: 1.0; color: Qt.rgba(island.mauve.r, island.mauve.g, island.mauve.b, 0.85) }
                            }
                            Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            property int last: -1
                            function setVol(x) {
                                let p = Math.round(Math.max(0, Math.min(1, x / parent.width)) * 100)
                                if (p !== last) {
                                    last = p
                                    island.exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ " + p + "% && wpctl set-mute @DEFAULT_AUDIO_SINK@ 0")
                                }
                            }
                            onPressed: (m) => { last = -1; setVol(m.x) }
                            onPositionChanged: (m) => { if (pressed) setVol(m.x) }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: island.s(8)

                    Text {
                        text: "󰃟"
                        color: island.peach
                        font.family: island.nerdFont; font.pixelSize: island.s(15)
                        Layout.preferredWidth: island.s(22)
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Rectangle {
                        id: brightTrack
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        height: island.s(20)
                        radius: island.s(10)
                        clip: true
                        color: Qt.rgba(island.surface0.r, island.surface0.g, island.surface0.b, 0.65)
                        border.color: Qt.rgba(island.text.r, island.text.g, island.text.b, 0.06)
                        border.width: 1

                        property real pct: root.brightValue

                        Rectangle {
                            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                            width: parent.width * (parent.pct / 100)
                            height: parent.height
                            radius: island.s(10)
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.85) }
                                GradientStop { position: 1.0; color: Qt.rgba(island.mocha.yellow.r, island.mocha.yellow.g, island.mocha.yellow.b, 0.85) }
                            }
                            Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            property int last: -1
                            function setBright(x) {
                                let p = Math.round(Math.max(0, Math.min(1, x / parent.width)) * 100)
                                if (p !== last) {
                                    last = p
                                    root.brightValue = p
                                    island.exec("brightnessctl set " + p + "%")
                                }
                            }
                            onPressed: e => { last = -1; setBright(e.x) }
                            onPositionChanged: (e) => { if (pressed) setBright(e.x) }
                        }
                    }
                }
            }

            // ── Quick actions ──────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(island.text.r, island.text.g, island.text.b, 0.08)
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: island.s(10)

                Rectangle {
                    width: island.s(36); height: island.s(28); radius: island.s(8)
                    color: island.dndEnabled
                        ? (dndMouse.containsMouse
                            ? Qt.rgba(island.mauve.r, island.mauve.g, island.mauve.b, 0.25)
                            : Qt.rgba(island.mauve.r, island.mauve.g, island.mauve.b, 0.15))
                        : (dndMouse.containsMouse
                            ? Qt.rgba(island.surface1.r, island.surface1.g, island.surface1.b, 0.6)
                            : island.surface0)
                    Behavior on color { ColorAnimation { duration: 180 } }
                    border.color: island.dndEnabled ? island.mauve : island.overlay0
                    border.width: 1
                    scale: dndMouse.pressed ? 0.95 : (dndMouse.containsMouse ? 1.08 : 1.0)
                    Behavior on scale {
                        NumberAnimation {
                            duration: dndMouse.pressed ? 100 : 200
                            easing.type: dndMouse.pressed ? Easing.OutQuad : Easing.OutBack
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: island.dndEnabled ? "󰂛" : "󰂚"
                        font.family: island.nerdFont; font.pixelSize: island.s(16)
                        color: island.dndEnabled ? island.mauve : island.overlay0
                    }
                    MouseArea {
                        id: dndMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true
                        onClicked: {
                            island.dndEnabled = !island.dndEnabled
                            island.exec("mkdir -p ~/.cache && echo '" + (island.dndEnabled ? "1" : "0") + "' > ~/.cache/qs_dnd")
                        }
                    }
                }

                Rectangle {
                    width: island.s(36); height: island.s(28); radius: island.s(8)
                    color: island.caffeineEnabled
                        ? (caffeineMouse.containsMouse
                            ? Qt.rgba(island.green.r, island.green.g, island.green.b, 0.25)
                            : Qt.rgba(island.green.r, island.green.g, island.green.b, 0.15))
                        : (caffeineMouse.containsMouse
                            ? Qt.rgba(island.surface1.r, island.surface1.g, island.surface1.b, 0.6)
                            : island.surface0)
                    Behavior on color { ColorAnimation { duration: 180 } }
                    border.color: island.caffeineEnabled ? island.green : island.overlay0
                    border.width: 1
                    scale: caffeineMouse.pressed ? 0.95 : (caffeineMouse.containsMouse ? 1.08 : 1.0)
                    Behavior on scale {
                        NumberAnimation {
                            duration: caffeineMouse.pressed ? 100 : 200
                            easing.type: caffeineMouse.pressed ? Easing.OutQuad : Easing.OutBack
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.family: island.nerdFont; font.pixelSize: island.s(16)
                        color: island.caffeineEnabled ? island.green : island.overlay0
                    }
                    MouseArea {
                        id: caffeineMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true
                        onClicked: island.toggleCaffeine()
                    }
                }

                Rectangle {
                    width: island.s(36); height: island.s(28); radius: island.s(8)
                    color: island.currentPage === "calendar"
                        ? (calMouse.containsMouse
                            ? Qt.rgba(island.mauve.r, island.mauve.g, island.mauve.b, 0.25)
                            : Qt.rgba(island.mauve.r, island.mauve.g, island.mauve.b, 0.15))
                        : (calMouse.containsMouse
                            ? Qt.rgba(island.surface1.r, island.surface1.g, island.surface1.b, 0.6)
                            : island.surface0)
                    Behavior on color { ColorAnimation { duration: 180 } }
                    border.color: island.currentPage === "calendar" ? island.mauve : island.overlay0
                    border.width: 1
                    scale: calMouse.pressed ? 0.95 : (calMouse.containsMouse ? 1.08 : 1.0)
                    Behavior on scale {
                        NumberAnimation {
                            duration: calMouse.pressed ? 100 : 200
                            easing.type: calMouse.pressed ? Easing.OutQuad : Easing.OutBack
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.family: island.nerdFont; font.pixelSize: island.s(16)
                        color: island.currentPage === "calendar" ? island.mauve : island.overlay0
                    }
                    MouseArea {
                        id: calMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true
                        onClicked: {
                            island.currentPage = "calendar"
                            island.expanded = true
                        }
                    }
                }

                Rectangle {
                    width: island.s(36); height: island.s(28); radius: island.s(8)
                    visible: island.availablePages.length > 1
                    color: notifMouse.containsMouse
                        ? Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.22)
                        : Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.12)
                    Behavior on color { ColorAnimation { duration: 180 } }
                    border.color: notifMouse.containsMouse
                        ? Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.5)
                        : Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.3)
                    Behavior on border.color { ColorAnimation { duration: 180 } }
                    border.width: 1
                    scale: notifMouse.pressed ? 0.95 : (notifMouse.containsMouse ? 1.08 : 1.0)
                    Behavior on scale {
                        NumberAnimation {
                            duration: notifMouse.pressed ? 100 : 200
                            easing.type: notifMouse.pressed ? Easing.OutQuad : Easing.OutBack
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "󰎟"
                        font.family: island.nerdFont; font.pixelSize: island.s(16)
                        color: island.peach
                    }
                    MouseArea {
                        id: notifMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true
                        onClicked: {
                            island.currentPage = "notifs"
                            island.expanded = true
                        }
                    }
                    Rectangle {
                        anchors.top: parent.top; anchors.right: parent.right
                        anchors.topMargin: -3; anchors.rightMargin: -3
                        width: island.s(15); height: island.s(15); radius: island.s(7.5)
                        visible: island.notifHistory.count > 0
                        color: island.peach
                        Text {
                            anchors.centerIn: parent
                            text: island.notifHistory.count > 9 ? "9+" : island.notifHistory.count
                            font.family: island.monoFont; font.pixelSize: island.s(9); font.weight: Font.Black
                            color: island.base
                        }
                    }
                }
            }
        }
    }
}