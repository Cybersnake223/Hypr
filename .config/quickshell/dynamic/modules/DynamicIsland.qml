import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick.Effects
import "./pages"
import "./collapsed"

PanelWindow {
    id: islandWindow

    property real uiScale: SharedConfig.uiScale

    WlrLayershell.namespace: "qs-island"
    WlrLayershell.layer: (expanded || osdActive) ? WlrLayer.Overlay : WlrLayer.Top

    anchors {
        top: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Ignore
    focusable: expanded
    color: "transparent"
    implicitHeight: s(600)
    mask: expanded ? null : maskedRegion

    Scaler {
        id: scaler
        currentWidth: Screen.width
        uiScale: islandWindow.uiScale
    }

    function s(v) {
        return scaler.s(v)
    }

    function exec(cmd) {
        Quickshell.execDetached(["bash", "-lc", cmd])
    }

    function saveNotifHistory() {
        let items = []
        for (let i = 0; i < Math.min(notifHistory.count, 50); ++i) {
            let it = notifHistory.get(i)
            items.push({
                appName: it.appName,
                title: it.title,
                body: it.body,
                icon: it.icon,
                timestamp: it.timestamp
            })
        }
        Quickshell.execDetached([
            "bash",
            "-lc",
            "mkdir -p ~/.cache/quickshell && printf '%s' \"$1\" > ~/.cache/quickshell/notifications.json",
            "qs_save",
            JSON.stringify(items)
        ])
    }

    function queueNotifSave() {
        notifDirty = true
        notifSaveDebounce.restart()
    }

    function navigateNext() {
        if (availablePages.length < 2)
            return
        let i = availablePages.indexOf(currentPage)
        currentPage = availablePages[(i + 1) % availablePages.length]
    }

    function navigatePrev() {
        if (availablePages.length < 2)
            return
        let i = availablePages.indexOf(currentPage)
        currentPage = availablePages[(i - 1 + availablePages.length) % availablePages.length]
    }

    function toggleCaffeine() {
        var newState = !SharedConfig.caffeineEnabled
        SharedConfig.caffeineEnabled = newState
        exec("mkdir -p /tmp; echo '" + (newState ? "on" : "off") + "' > /tmp/qs_caffeine")
        if (newState)
            exec("systemd-inhibit --what=sleep:idle --who=qs-caffeine --why='Caffeine mode' sleep infinity &")
        else
            exec("pkill -f 'systemd-inhibit.*qs-caffeine' 2>/dev/null")
    }

    function dismissNotif() {
        notifHideTimer.stop()
        notifActive = false
        notifData = null
        notifBadgeVisible = false
        pendingNotifs = []
    }

    function notifSection(ts) {
        if (!ts) return "Earlier"
        let d = new Date(ts)
        let now = new Date()
        let today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
        let thatDay = new Date(d.getFullYear(), d.getMonth(), d.getDate())
        let diffDays = Math.round((today - thatDay) / 86400000)
        if (diffDays === 0) return "Today"
        if (diffDays === 1) return "Yesterday"
        return "Earlier"
    }

    function playSound(type) {
        if (type === "notification")
            exec("[ -f '/usr/share/sounds/freedesktop/stereo/message.oga' ] && paplay '/usr/share/sounds/freedesktop/stereo/message.oga' 2>/dev/null &")
        else if (type === "volume")
            exec("[ -f '/usr/share/sounds/freedesktop/stereo/audio-volume-change.oga' ] && paplay '/usr/share/sounds/freedesktop/stereo/audio-volume-change.oga' 2>/dev/null &")
    }

    function handleIpcEvent(marker, data) {
        switch (marker) {
        case "QS_LAUNCHER":
            launcherActive = (data === "1")
            break
        case "QS_DISMISS":
            dismissNotif()
            break
        case "QS_DND":
            if (data === "toggle")
                dndEnabled = !dndEnabled
            else if (data === "on")
                dndEnabled = true
            else if (data === "off")
                dndEnabled = false
            exec("mkdir -p ~/.cache && printf '%s' '" + (dndEnabled ? "1" : "0") + "' > ~/.cache/qs_dnd")
            break
        case "QS_OSD": {
            let parts = (data || "").split("|")
            if (parts.length >= 2) {
                osdType = parts[0]
                osdValue = parts[1]
                osdMuted = parts.length >= 3 && parts[2] === "muted"
                osdActive = true
                osdTimer.restart()
            }
            break
        }
        case "QS_TOGGLE":
            if (data === "toggle")
                expanded = !expanded
            else if (data === "expand")
                expanded = true
            else if (data === "collapse")
                expanded = false
            break
        case "QS_NOTIFS_PANEL":
            notifBadgeVisible = false
            if (currentPage === "notifs" && expanded) {
                currentPage = "clock"
                expanded = false
            } else {
                currentPage = "notifs"
                expanded = true
            }
            break
        case "QS_CALENDAR":
            if (currentPage === "calendar" && expanded) {
                currentPage = "clock"
                expanded = false
            } else {
                currentPage = "calendar"
                expanded = true
            }
            break
        case "QS_CLEAR":
            notifHistory.clear()
            saveNotifHistory()
            break
        case "QS_NOTIF": {
            try {
                let n = (typeof data === "string") ? JSON.parse(data) : data
                let item = {
                    appName: n.appName || "System",
                    title: n.title || "",
                    body: n.body || "",
                    icon: n.icon || "",
                    timestamp: Date.now()
                }
                item.section = islandWindow.notifSection(item.timestamp)
                notifHistory.insert(0, item)
                while (notifHistory.count > 50)
                    notifHistory.remove(notifHistory.count - 1)
                queueNotifSave()
                if (!dndEnabled) {
                    pendingNotifs.push(item)
                    if (pendingNotifs.length > maxPending) pendingNotifs.shift()
                    playSound("notification")
                    notifData = pendingNotifs[pendingNotifs.length - 1]
                    notifActive = true
                    notifBadgeVisible = true
                    wasExpandedBeforeNotif = expanded
                    expanded = true
                    notifHideTimer.restart()
                } else if (!expanded) {
                    pendingNotifs.push(item)
                    if (pendingNotifs.length > maxPending) pendingNotifs.shift()
                    notifBadgeVisible = true
                }
            } catch (e) {
                console.warn(e)
            }
            break
        }
        }
    }

    readonly property var mocha: SharedConfig.mocha
    readonly property color base: mocha.base
    readonly property color surface0: mocha.surface0
    readonly property color surface1: mocha.surface1
    readonly property color surface2: mocha.surface2
    readonly property color text: mocha.text
    readonly property color subtext0: mocha.subtext0
    readonly property color mauve: mocha.mauve
    readonly property color blue: mocha.blue
    readonly property color peach: mocha.peach
    readonly property color green: mocha.green
    readonly property color pink: mocha.pink
    readonly property color teal: mocha.teal
    readonly property color red: mocha.red

    readonly property string monoFont: SharedConfig.monoFont
    readonly property string nerdFont: SharedConfig.nerdFont

    property bool expanded: false
    property bool hovered: false
    property string currentPage: "clock"
    property string prevPage: "clock"

    property bool notifActive: false
    property var notifData: null
    property bool wasExpandedBeforeNotif: false
    property bool notifBadgeVisible: false
    property bool dndEnabled: false
    property var pendingNotifs: []
    property int maxPending: 3

    property bool launcherActive: false

    property bool osdActive: false
    property string osdType: ""
    property string osdValue: ""
    property bool osdMuted: false

    property string timeStr: ""
    property string timeStrSec: ""
    property string dayStr: ""
    property string dateStr: ""
    property string greetingStr: ""
    property bool capsLockOn: false
    property bool numLockOn: false

    // ── Watcher data: forwarded from SharedConfig (single source of truth) ──
    property string weatherIcon: SharedConfig.weatherIcon
    property string weatherTemp: SharedConfig.weatherTemp
    property string weatherHex: SharedConfig.weatherHex
    property bool weatherLoaded: SharedConfig.weatherLoaded
    property bool caffeineEnabled: SharedConfig.caffeineEnabled
    property string wifiSsid: SharedConfig.wifiSsid
    property int wifiSignal: SharedConfig.wifiSignal
    property bool bluetoothOn: SharedConfig.bluetoothOn
    property int bluetoothDevices: SharedConfig.bluetoothDevices
    property var btDeviceList: SharedConfig.btDeviceList
    property string volPercent: SharedConfig.volPercent
    property string volIcon: SharedConfig.volIcon
    property bool volMuted: SharedConfig.volMuted

    property bool notifDirty: false
    property real notifPulse: 0.9

    property var availablePages: {
        let p = ["clock"]
        if (notifHistory.count > 0 || notifActive)
            p.push("notifs")
        p.push("calendar")
        return p
    }

    property var pageRegistry: [
        { name: "clock",    expandedH: 440, comp: clockPageComp },
        { name: "notifs",   expandedH: 500, comp: notifsPageComp },
        { name: "calendar", expandedH: 520, comp: calendarPageComp }
    ]

    readonly property bool showCollapsed: !expanded
    readonly property bool showExpandedPage: expanded && !notifActive
    readonly property bool showExpandedNotif: expanded && notifActive

    property bool slideForward: true

    onCurrentPageChanged: {
        if (currentPage !== "notifs") {
            let prevIdx = pageRegistry.findIndex(p => p.name === prevPage)
            let currIdx = pageRegistry.findIndex(p => p.name === currentPage)
            if (prevIdx >= 0 && currIdx >= 0)
                slideForward = currIdx > prevIdx
            prevPage = currentPage
        }
    }

    onAvailablePagesChanged: {
        if (availablePages.indexOf(currentPage) < 0)
            currentPage = availablePages.length > 0 ? availablePages[0] : "clock"
    }

    onExpandedChanged: {
        if (expanded) {
            notifBadgeVisible = false
            notifPageRevertTimer.stop()
            islandShape.forceActiveFocus()
            popDownAnim.restart()
            morphAnim.restart()
            stretchAnim.restart()
        } else {
            notifBadgeVisible = notifHistory.count > 0
            if (currentPage === "notifs") {
                notifPageRevertTimer.restart()
            }
            morphAnimReverse.restart()
        }
    }

    onNotifActiveChanged: {
        if (notifActive) {
            notifBadgeVisible = false
            notifPulse = 0.9
            notifPulseAnim.restart()
            notifBounceAnim.restart()
        }
    }

    ListModel { id: notifHistoryList }
    property alias notifHistory: notifHistoryList
    property var notifGroups: []
    property string expandedGroup: ""

    function rebuildNotifGroups() {
        let groups = {}
        for (let i = 0; i < notifHistory.count; i++) {
            let n = notifHistory.get(i)
            let app = n.appName || "System"
            if (!groups[app]) groups[app] = { app: app, items: [], icon: n.icon || "", count: 0 }
            groups[app].items.push(n)
            groups[app].count++
        }
        let result = []
        for (let k in groups) result.push(groups[k])
        notifGroups = result
        if (expandedGroup !== "" && !groups[expandedGroup]) expandedGroup = ""
    }

    function appAccentColor(appName) {
        let colors = [mauve, blue, peach, green, teal, red, pink]
        let hash = 0
        for (let i = 0; i < appName.length; i++) hash = ((hash << 5) - hash) + appName.charCodeAt(i)
        return colors[Math.abs(hash) % colors.length]
    }

    Connections {
        target: notifHistory
        function onCountChanged() { rebuildNotifGroups() }
    }

    Timer {
        id: osdTimer
        interval: 1000
        running: osdActive
        onTriggered: osdActive = false
    }

    Timer {
        id: notifSaveDebounce
        interval: 5000
        running: notifDirty
        onTriggered: {
            saveNotifHistory()
            notifDirty = false
        }
    }

    SequentialAnimation on notifPulse {
        id: notifPulseAnim
        running: notifActive
        loops: 3
        NumberAnimation { to: 0.3; duration: 900; easing.type: Easing.InOutSine }
        NumberAnimation { to: 0.9; duration: 900; easing.type: Easing.InOutSine }
    }

    function updateTime(showSeconds) {
        let d = new Date()
        timeStr = Qt.formatDateTime(d, "HH:mm")
        if (showSeconds)
            timeStrSec = Qt.formatDateTime(d, "HH:mm:ss")
        dayStr = Qt.formatDateTime(d, "ddd")
        dateStr = Qt.formatDateTime(d, "ddd, MMM dd")
        let h = d.getHours()
        if (h !== lastGreetingHour) {
            lastGreetingHour = h
            if (h >= 5 && h < 12) greetingStr = "Good morning"
            else if (h >= 12 && h < 17) greetingStr = "Good afternoon"
            else if (h >= 17 && h < 21) greetingStr = "Good evening"
            else greetingStr = "Good night"
        }
    }

    property int lastGreetingHour: -1

    Timer {
        interval: 60000
        running: !expanded && (currentPage === "clock" || osdActive)
        repeat: true
        triggeredOnStart: true
        onTriggered: updateTime(false)
    }

    Timer {
        interval: 1000
        running: expanded && (currentPage === "clock" || osdActive)
        repeat: true
        triggeredOnStart: true
        onTriggered: updateTime(true)
    }



    Timer {
        id: notifHideTimer
        interval: 3000
        onTriggered: {
            notifActive = false
            notifData = null
            pendingNotifs = []
            if (!wasExpandedBeforeNotif)
                expanded = false
        }
    }

    Timer {
        id: notifPageRevertTimer
        interval: 2500
        onTriggered: {
            if (!expanded && currentPage === "notifs")
                currentPage = prevPage
        }
    }

    Process {
        id: dndStateLoader
        running: true
        command: ["bash", "-lc", "cat ~/.cache/qs_dnd 2>/dev/null || echo 0"]
        stdout: StdioCollector {
            onStreamFinished: dndEnabled = (this.text.trim() === "1")
        }
    }

    Process {
        id: notifHistoryLoader
        running: true
        command: ["bash", "-lc", "cat ~/.cache/quickshell/notifications.json 2>/dev/null || echo '[]'"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let items = JSON.parse(this.text.trim())
                    if (Array.isArray(items)) {
                        for (let i = 0; i < Math.min(items.length, 50); ++i) {
                            notifHistory.append({
                                appName: items[i].appName || "System",
                                title: items[i].title || "",
                                body: items[i].body || "",
                                icon: items[i].icon || "",
                                timestamp: items[i].timestamp || 0,
                                section: islandWindow.notifSection(items[i].timestamp || 0)
                            })
                        }
                        rebuildNotifGroups()
                    }
                } catch (e) {
                    console.warn(e)
                }
            }
        }
    }

    // ── Caps/Num Lock (udev monitor — event-driven, zero polling) ──
    Process {
        id: lockWatcher
        running: true
        command: ["bash", "-c",
            "udevadm monitor --property --subsystem-match=input 2>/dev/null | " +
            "stdbuf -oL grep -m1 LED_ | while read line; do " +
            "  cl=$(cat /sys/class/leds/input*::capslock/brightness 2>/dev/null); " +
            "  nl=$(cat /sys/class/leds/input*::numlock/brightness 2>/dev/null); " +
            "  printf '{\"caps\":%s,\"num\":%s}\\n' \"$cl\" \"$nl\"; " +
            "done"
        ]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                try {
                    let d = JSON.parse(line.trim())
                    let cState = d.caps === "1"
                    let nState = d.num === "1"
                    if (cState !== capsLockOn) {
                        capsLockOn = cState
                        osdType = "capslock"
                        osdValue = capsLockOn ? "ON" : "OFF"
                        osdActive = true
                        osdTimer.restart()
                    }
                    if (nState !== numLockOn) {
                        numLockOn = nState
                        osdType = "numlock"
                        osdValue = numLockOn ? "ON" : "OFF"
                        osdActive = true
                        osdTimer.restart()
                    }
                } catch(e) { console.warn(e) }
            }
        }
        onExited: running = true
    }

    Item {
        id: maskBounds
        x: Math.floor((Screen.width - islandShape.width) / 2) - s(14)
        y: 0
        width: islandShape.width + s(28) + (notifBadgeVisible ? s(60) : 0)
        height: Math.max(islandShape.height, s(32))
    }

    Region {
        id: maskedRegion
        item: maskBounds
    }

    MouseArea {
        anchors.fill: parent
        enabled: expanded
        visible: expanded
        z: 0
        onClicked: {
            if (notifActive) {
                notifHideTimer.stop()
                notifActive = false
                notifData = null
            }
            expanded = false
        }
    }

    // Backdrop overlay behind expanded island (iOS frosted-glass look with blur)
    Rectangle {
        id: backdropOverlay
        anchors.fill: parent
        z: 5
        visible: expanded
        color: "transparent"
        opacity: expanded ? 1.0 : 0.0
        Behavior on opacity { PropertyAnimation { duration: 300; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: Qt.rgba(base.r, base.g, base.b, 0.65) }
            GradientStop { position: 0.25; color: Qt.rgba(base.r, base.g, base.b, 0.35) }
            GradientStop { position: 1.0; color: "transparent" }
        }
        }

    Item {
        id: islandShape
        z: 10
        focus: expanded

        property int collapsedW: {
            if (osdActive)
                return osdCollapsed.preferredWidth + s(16)
            if (currentPage === "notifs")
                return notifsCollapsed.preferredWidth + s(16)
            return clockCollapsed.preferredWidth + s(16)
        }

        property int collapsedH: osdActive ? s(52) : s(36)
        property int expandedW: Math.min(s(680), Screen.width - s(32))
        property int expandedH: {
            if (notifActive)
                return pendingNotifs.length > 1 ? s(130) : s(88)
            for (let i = 0; i < pageRegistry.length; ++i) {
                let page = pageRegistry[i]
                if (page.name === currentPage)
                    return s(page.expandedH)
            }
            return s(350)
        }

        width: expanded ? expandedW : collapsedW
        height: expanded ? expandedH : collapsedH
        x: Math.floor((Screen.width - width) / 2)
        y: 0
        property real breathingScale: 1.0
        property real morphProgress: 0.0
        property real stretchY: 1.0
        scale: (hovered && !expanded ? 1.025 : 1.0) * breathingScale
        opacity: launcherActive ? 0.0 : 1.0
        transform: [
            Translate { id: swipeTranslate },
            Translate { id: popDownTranslate; y: 0 },
            Scale { id: stretchScale; yScale: islandShape.stretchY }
        ]

        SequentialAnimation {
            id: morphAnim
            PropertyAnimation { target: islandShape; property: "morphProgress"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
        }

        SequentialAnimation {
            id: morphAnimReverse
            PropertyAnimation { target: islandShape; property: "morphProgress"; from: 1; to: 0; duration: 180; easing.type: Easing.OutCubic }
        }

        SequentialAnimation {
            id: stretchAnim
            PropertyAnimation { target: islandShape; property: "stretchY"; from: 1.0; to: 1.08; duration: 100; easing.type: Easing.OutQuad }
            PropertyAnimation { target: islandShape; property: "stretchY"; to: 1.0; duration: 150; easing.type: Easing.OutBack; easing.overshoot: 1.1 }
        }

        SequentialAnimation {
            id: breathingAnim
            running: notifBadgeVisible && !expanded
            loops: Animation.Infinite
            NumberAnimation { target: islandShape; property: "breathingScale"; from: 1.0; to: 1.015; duration: 1800; easing.type: Easing.InOutSine }
            NumberAnimation { target: islandShape; property: "breathingScale"; from: 1.015; to: 1.0; duration: 1800; easing.type: Easing.InOutSine }
            onRunningChanged: if (!running) islandShape.breathingScale = 1.0
        }

        NumberAnimation {
            id: snapBackAnim; target: swipeTranslate; property: "x"; to: 0
            duration: 250; easing.type: Easing.OutBack; easing.overshoot: 1.2
        }

        SequentialAnimation {
            id: popDownAnim
            PropertyAnimation { target: popDownTranslate; property: "y"; from: s(8); to: s(4); duration: 120; easing.type: Easing.OutCubic }
            PropertyAnimation { target: popDownTranslate; property: "y"; to: 0; duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1.0 }
        }

        SequentialAnimation {
            id: notifBounceAnim
            PropertyAnimation { target: popDownTranslate; property: "y"; from: 0; to: -s(4); duration: 80; easing.type: Easing.OutQuad }
            PropertyAnimation { target: popDownTranslate; property: "y"; to: 0; duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
        }

        Behavior on width { PropertyAnimation { duration: 180; easing.type: Easing.OutBack; easing.overshoot: 1.15 } }
        Behavior on height { PropertyAnimation { duration: expanded ? 180 : 120; easing.type: Easing.OutBack; easing.overshoot: expanded ? 1.15 : 1.0 } }
        Behavior on scale { PropertyAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }
        Behavior on opacity { PropertyAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }

        Keys.onEscapePressed: {
            if (expanded) {
                expanded = false
                event.accepted = true
            }
        }
        Keys.onLeftPressed: {
            if (expanded && !notifActive) {
                navigatePrev()
                event.accepted = true
            }
        }
        Keys.onRightPressed: {
            if (expanded && !notifActive) {
                navigateNext()
                event.accepted = true
            }
        }

        MouseArea {
            id: islandMouse
            anchors.fill: parent
            anchors.leftMargin: -s(14)
            anchors.rightMargin: -s(14)
            anchors.bottomMargin: -s(8)
            hoverEnabled: true
            onEntered: hovered = true
            onExited: hovered = false
            onClicked: {
                if (!expanded)
                    expanded = true
            }
        }

        // Swipe to dismiss via DragHandler
        DragHandler {
            id: swipeDismiss
            target: null
            enabled: notifActive
            margin: s(14)
            onTranslationChanged: {
                if (notifActive) {
                    snapBackAnim.stop()
                    let tx = translation.x
                    let maxShift = islandShape.width * 0.5
                    let clamped = Math.max(-maxShift, Math.min(maxShift, tx))
                    swipeTranslate.x = clamped
                    islandShape.opacity = 1.0 - Math.abs(clamped) / maxShift * 0.5
                }
            }
            onActiveChanged: {
                if (!active && notifActive) {
                    let tx = translation.x
                    if (Math.abs(tx) > islandShape.width * 0.25) {
                        dismissNotif()
                    } else {
                        snapBackAnim.start()
                    }
                    islandShape.opacity = 1.0
                }
            }
            grabPermissions: PointerDevice.CanTakeOverFromItems
        }

        Timer {
            id: scrollCooldown
            interval: 240
        }

        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            target: null
            onWheel: function(event) {
                if (scrollCooldown.running || notifActive) {
                    event.accepted = true
                    return
                }
                if (event.angleDelta.y > 0)
                    navigatePrev()
                else
                    navigateNext()
                scrollCooldown.start()
                event.accepted = true
            }
        }

        Rectangle {
            id: bg
            anchors.fill: parent
            radius: height / 2 + islandShape.morphProgress * (s(36) - height / 2)
            antialiasing: true
            opacity: (expanded || hovered) ? 1.0 : 0.9

            layer.enabled: !expanded
            layer.effect: MultiEffect {
                id: bgEffect
                shadowEnabled: true
                shadowColor: "#000000"
                shadowBlur: 6.0
                shadowOpacity: 0.15
                shadowVerticalOffset: s(2)
                blurEnabled: false
            }

            // Top light-catch hairline (glass edge)
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                radius: 0
                color: "transparent"
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.3; color: "transparent" }
                    GradientStop { position: 0.5; color: Qt.rgba(text.r, text.g, text.b, 0.22) }
                    GradientStop { position: 0.7; color: "transparent" }
                }
            }

            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: Qt.rgba(base.r, base.g, base.b, 0.72) }
                GradientStop { position: 1.0; color: Qt.rgba(base.r, base.g, base.b, 0.82) }
            }
            border.width: notifActive ? 2 : (hovered && !expanded ? 1.5 : 1)
            border.color: {
                if (osdActive && !expanded) {
                    if (osdType === "volume")
                        return Qt.rgba(blue.r, blue.g, blue.b, 0.55)
                    if (osdType === "brightness")
                        return Qt.rgba(peach.r, peach.g, peach.b, 0.55)
                    return Qt.rgba(teal.r, teal.g, teal.b, 0.55)
                }
                if (notifActive)
                    return Qt.rgba(peach.r, peach.g, peach.b, notifPulse)
                if (hovered)
                    return Qt.rgba(mauve.r, mauve.g, mauve.b, 0.65)
                return SharedConfig.hairline
            }
            Behavior on radius { PropertyAnimation { duration: 150; easing.type: Easing.OutCubic } }
            Behavior on opacity { PropertyAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }
            Behavior on border.width { PropertyAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }
        }

        Item {
            id: collapsedContent
            anchors.fill: parent
            clip: true
            visible: showCollapsed
            enabled: showCollapsed
            opacity: showCollapsed ? 1.0 : 0.0
            Behavior on opacity { PropertyAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }

            OSDCollapsed {
                id: osdCollapsed
                island: islandWindow
                anchors.centerIn: parent
                visible: osdActive
                enabled: visible
            }

            ClockCollapsed {
                id: clockCollapsed
                island: islandWindow
                anchors.centerIn: parent
                visible: !osdActive && currentPage === "clock"
                enabled: visible
            }

            NotifsCollapsed {
                id: notifsCollapsed
                island: islandWindow
                anchors.centerIn: parent
                visible: !osdActive && currentPage === "notifs"
                enabled: visible
            }

        }

        Item {
            id: expandedStack
            anchors.fill: parent
            visible: expanded
            enabled: expanded

                Repeater {
                    model: pageRegistry
                    delegate: Loader {
                        anchors.fill: parent
                        active: expanded && modelData.name === islandWindow.currentPage
                        sourceComponent: modelData.comp
                    property bool isCurrent: showExpandedPage && currentPage === modelData.name
                    visible: opacity > 0.01
                    enabled: visible
                    opacity: isCurrent ? 1.0 : 0.0
                    x: {
                        if (isCurrent) return 0
                        let myIdx = pageRegistry.findIndex(p => p.name === modelData.name)
                        let curIdx = pageRegistry.findIndex(p => p.name === currentPage)
                        if (myIdx < 0 || curIdx < 0) return 0
                        if (myIdx < curIdx) return -s(30)
                        return s(30)
                    }
                    scale: isCurrent ? 1.0 : 0.95
                    Behavior on opacity { NumberAnimation { duration: isCurrent ? 220 : 100; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }
                    Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }
                }
            }

            Loader {
                anchors.fill: parent
                active: expanded
                sourceComponent: notifExpandedComp
                visible: opacity > 0.01
                enabled: visible
                opacity: showExpandedNotif ? 1.0 : 0.0
                y: showExpandedNotif ? 0 : s(8)
                Behavior on opacity { PropertyAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }
                Behavior on y { PropertyAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }
            }
        }

        // ── Page indicator (bottom band) ──────────────────────────
        Item {
            id: pageIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: islandWindow.s(14)
            z: 12
            visible: expanded && !notifActive
            enabled: visible
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { PropertyAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }

            Row {
                anchors.centerIn: parent
                spacing: islandWindow.s(6)

                Repeater {
                    model: islandWindow.availablePages

                    delegate: Item {
                        required property var modelData
                        width: dotMouse.containsMouse ? islandWindow.s(16) : (islandWindow.currentPage === modelData ? islandWindow.s(20) : islandWindow.s(6))
                        height: islandWindow.s(6)
                        Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

                        Rectangle {
                            anchors.fill: parent
                            radius: height / 2
                            color: islandWindow.currentPage === modelData
                                ? Qt.rgba(mauve.r, mauve.g, mauve.b, 0.95)
                                : Qt.rgba(surface2.r, surface2.g, surface2.b, 0.55)
                            Behavior on color { ColorAnimation { duration: 180 } }
                        }

                        MouseArea {
                            id: dotMouse
                            anchors.fill: parent
                            anchors.margins: -islandWindow.s(4)
                            hoverEnabled: true
                            onClicked: islandWindow.currentPage = modelData
                        }
                    }
                }
            }
        }

    }

    Item {
        id: badgeBubble
        z: 11
        property int sz: s(36)
        anchors.left: islandShape.right
        anchors.leftMargin: s(12)
        anchors.verticalCenter: islandShape.verticalCenter
        width: sz
        height: sz
        visible: opacity > 0.01
        enabled: visible
        opacity: notifBadgeVisible && !expanded ? 1.0 : 0.0
        scale: notifBadgeVisible && !expanded ? 1.0 : 0.5
        transformOrigin: Item.Left
        Behavior on opacity { PropertyAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }
        Behavior on scale { PropertyAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }

        Rectangle {
            anchors.fill: parent
            radius: parent.width / 2
            color: Qt.rgba(base.r, base.g, base.b, 0.78)
            border.width: 1
            property real glowPulse: 0.25
            // Burst a few times when a new notification arrives, then settle —
            // avoids perpetual repaint of the always-visible island layer.
            SequentialAnimation on glowPulse {
                id: badgeGlow
                loops: 3
                NumberAnimation { to: 0.8; duration: 1100; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0.25; duration: 1100; easing.type: Easing.InOutSine }
            }
            border.color: Qt.rgba(peach.r, peach.g, peach.b, glowPulse)
        }

        onVisibleChanged: if (visible) badgeGlow.restart()

        Text {
            anchors.centerIn: parent
            text: notifHistory.count > 9 ? "9+" : (notifHistory.count > 1 ? notifHistory.count.toString() : "󰂚")
            font.family: notifHistory.count > 1 ? islandWindow.monoFont : islandWindow.nerdFont
            font.weight: notifHistory.count > 1 ? Font.Black : Font.Normal
            font.pixelSize: notifHistory.count > 1 ? parent.sz * 0.40 : parent.sz * 0.48
            color: peach
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                notifBadgeVisible = false
                currentPage = "notifs"
                expanded = true
            }
        }

        // Particle burst effect for new notifications
        Repeater {
            id: notifParticles
            model: notifBadgeVisible && !expanded ? 6 : 0

            delegate: Rectangle {
                property real angle: index * 60
                property real dist: 0

                width: s(4); height: s(4); radius: s(2)
                color: Qt.rgba(peach.r, peach.g, peach.b, 0.85)

                x: badgeBubble.width / 2 + Math.cos(angle * Math.PI / 180) * dist - width / 2
                y: badgeBubble.height / 2 + Math.sin(angle * Math.PI / 180) * dist - height / 2

                NumberAnimation on dist { from: 0; to: s(40); duration: 500; easing.type: Easing.OutQuad }
                SequentialAnimation on opacity {
                    running: true
                    NumberAnimation { from: 1; to: 0; duration: 500; easing.type: Easing.InQuad }
                }
            }
        }
    }

    Component {
        id: clockPageComp
        ClockPage { island: islandWindow }
    }

    Component {
        id: notifsPageComp
        NotifsPage { island: islandWindow }
    }

    Component {
        id: notifExpandedComp
        NotifExpandedPage { island: islandWindow }
    }

    Component {
        id: calendarPageComp
        CalendarPage { island: islandWindow }
    }
}

