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

    function dismissNotif() {
        notifHideTimer.stop()
        notifActive = false
        notifData = null
        notifBadgeVisible = false
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
                notifHistory.insert(0, item)
                while (notifHistory.count > 50)
                    notifHistory.remove(notifHistory.count - 1)
                queueNotifSave()
                if (!dndEnabled) {
                    playSound("notification")
                    notifData = item
                    notifActive = true
                    notifBadgeVisible = true
                    wasExpandedBeforeNotif = expanded
                    expanded = true
                    notifHideTimer.restart()
                } else if (!expanded) {
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
    property bool notifAutoSwitched: false

    property bool notifActive: false
    property var notifData: null
    property bool wasExpandedBeforeNotif: false
    property bool notifBadgeVisible: false
    property bool dndEnabled: false
    property bool caffeineEnabled: false

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
    property string weatherIcon: ""
    property string weatherDesc: ""
    property string weatherTemp: "--°"
    property string weatherMin: ""
    property string weatherFeels: ""
    property string weatherHumidity: ""
    property string weatherWind: ""
    property string weatherPop: ""
    property string weatherHex: "#cdd6f4"
    property string weatherUnit: "°C"
    property string weatherForecast: ""
    property string weatherCurIcon: ""
    property string weatherCurTemp: ""
    property bool weatherLoaded: false
    property bool capsLockOn: false
    property bool numLockOn: false
    property int pkgUpdates: 0
    property var pkgUpdatesList: []

    property string wifiSsid: ""
    property int wifiSignal: 0
    property bool bluetoothOn: false
    property int bluetoothDevices: 0
    property var btDeviceList: []

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
        { name: "clock",    expandedH: 380, comp: clockPageComp },
        { name: "notifs",   expandedH: 500, comp: notifsPageComp },
        { name: "calendar", expandedH: 520, comp: calendarPageComp },
        
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
            notifAutoSwitched = false
        }
        if (currentPage === "notifs" && !expanded && notifAutoSwitched)
            notifPageRevertTimer.restart()
        else
            notifPageRevertTimer.stop()
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
        } else {
            notifBadgeVisible = notifHistory.count > 0
            if (currentPage === "notifs") {
                notifPageRevertTimer.restart()
            }
        }
    }

    onNotifActiveChanged: {
        if (notifActive)
            notifBadgeVisible = false
    }

    ListModel { id: notifHistoryList }
    property alias notifHistory: notifHistoryList

    Timer {
        id: osdTimer
        interval: 1000
        onTriggered: osdActive = false
    }

    Timer {
        id: notifSaveDebounce
        interval: 5000
        onTriggered: {
            if (notifDirty) {
                saveNotifHistory()
                notifDirty = false
            }
        }
    }

    SequentialAnimation on notifPulse {
        running: notifActive && (!expanded || !visible)
        loops: Animation.Infinite
        NumberAnimation { to: 0.3; duration: 900; easing.type: Easing.InOutSine }
        NumberAnimation { to: 0.9; duration: 900; easing.type: Easing.InOutSine }
    }

    property int lastGreetingHour: -1

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            let d = new Date()
            timeStr = Qt.formatDateTime(d, "HH:mm")
            timeStrSec = Qt.formatDateTime(d, "HH:mm:ss")
            dayStr = Qt.formatDateTime(d, "ddd")
            dateStr = Qt.formatDateTime(d, "ddd, MMM dd")
            // Greeting only changes at hour boundaries — skip the per-second recompute.
            let h = d.getHours()
            if (h !== lastGreetingHour) {
                lastGreetingHour = h
                if (h >= 5 && h < 12) greetingStr = "Good morning"
                else if (h >= 12 && h < 17) greetingStr = "Good afternoon"
                else if (h >= 17 && h < 21) greetingStr = "Good evening"
                else greetingStr = "Good night"
            }
        }
    }

    // ── Combined island watcher (weather, pkg, caffeine, wifi, bt — one process) ──
    Process {
        id: islandWatchers
        running: true
        command: ["bash", "-c", "~/.config/quickshell/dynamic/modules/watchers/island_combined.sh"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                let txt = line.trim()
                if (txt === "" || txt === "{}") return
                let colonIdx = txt.indexOf(":")
                if (colonIdx < 0) return
                let tag = txt.substring(0, colonIdx)
                let data = txt.substring(colonIdx + 1)

                if (tag === "weatherout") {
                    // 12 tab-separated fields: icon, desc, max, min, feels, humidity, wind, pop, hex, unit, curIcon, curTemp
                    let parts = data.split("\t")
                    if (parts.length >= 10) {
                        weatherLoaded = true
                        if (parts[1]) weatherDesc = parts[1]
                        if (parts[9]) weatherUnit = parts[9]
                        if (parts[2]) weatherMin = parts[2] + weatherUnit
                        if (parts[3]) weatherMin = parts[3] + weatherUnit
                        if (parts[4]) weatherFeels = parts[4] + weatherUnit
                        if (parts[5]) weatherHumidity = parts[5]
                        if (parts[6]) weatherWind = parts[6]
                        if (parts[7]) weatherPop = parts[7]
                        if (parts[8]) weatherHex = parts[8]
                        // Use current hourly icon/temp when available, else fall back to daily values
                        weatherCurIcon = parts[10] || ""
                        weatherCurTemp = parts[11] || ""
                        weatherIcon = weatherCurIcon !== "" ? weatherCurIcon : (parts[0] || "")
                        weatherTemp = weatherCurTemp !== "" ? weatherCurTemp : (parts[2] ? parts[2] + weatherUnit : "--°")
                        let w = JSON.stringify({icon: weatherIcon, temp: weatherTemp, unit: weatherUnit})
                        Quickshell.execDetached(["bash", "-c",
                            "printf '%s\\n' '" + w.replace(/'/g, "'\\''") + "' > /tmp/qs_weather.json"])
                    }
                    return
                }

                if (tag === "forecastout") {
                    weatherForecast = data
                    return
                }

                if (tag === "pkgout") {
                    try {
                        let d = JSON.parse(data)
                        pkgUpdates = d.count || 0
                        pkgUpdatesList = d.packages || []
                    } catch (e) { pkgUpdates = 0; pkgUpdatesList = [] }
                    return
                }

                if (tag === "caffeineout") {
                    caffeineEnabled = (data.trim() === "on")
                    return
                }

                if (tag === "wifiout") {
                    try {
                        let d = JSON.parse(data)
                        wifiSsid = d.ssid || ""
                        wifiSignal = d.signal || 0
                    } catch (e) {}
                    return
                }

                if (tag === "btout") {
                    try {
                        let d = JSON.parse(data)
                        bluetoothOn = (d.powered === "yes")
                        bluetoothDevices = d.count || 0
                        btDeviceList = d.devices || []
                    } catch (e) { bluetoothOn = false; bluetoothDevices = 0; btDeviceList = [] }
                    return
                }

            }
        }
    }

    Timer {
        id: notifHideTimer
        interval: 3000
        onTriggered: {
            notifActive = false
            notifData = null
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
        id: islandIpcManager
        running: true
        command: [
            "bash",
            "-lc",
            "stdbuf -oL inotifywait -m -e close_write,moved_to /tmp/ --include 'qs_' 2>/dev/null | while read -r dir action file; do case \"$file\" in qs_launcher_state) v=$(cat /tmp/qs_launcher_state 2>/dev/null); printf '{\\\"event\\\":\\\"QS_LAUNCHER\\\",\\\"data\\\":\\\"%s\\\"}\\n' \"$v\" ;; qs_island_dismiss) rm -f /tmp/qs_island_dismiss; printf '{\\\"event\\\":\\\"QS_DISMISS\\\",\\\"data\\\":\\\"\\\"}\\n' ;; qs_island_dnd) v=$(cat /tmp/qs_island_dnd 2>/dev/null); rm -f /tmp/qs_island_dnd; printf '{\\\"event\\\":\\\"QS_DND\\\",\\\"data\\\":\\\"%s\\\"}\\n' \"$v\" ;; qs_osd) v=$(cat /tmp/qs_osd 2>/dev/null); printf '{\\\"event\\\":\\\"QS_OSD\\\",\\\"data\\\":\\\"%s\\\"}\\n' \"$v\" ;; qs_island_toggle) v=$(cat /tmp/qs_island_toggle 2>/dev/null); rm -f /tmp/qs_island_toggle; printf '{\\\"event\\\":\\\"QS_TOGGLE\\\",\\\"data\\\":\\\"%s\\\"}\\n' \"$v\" ;; qs_island_clear_notifs) rm -f /tmp/qs_island_clear_notifs; printf '{\\\"event\\\":\\\"QS_CLEAR\\\",\\\"data\\\":\\\"\\\"}\\n' ;; qs_island_notifs_panel) rm -f /tmp/qs_island_notifs_panel; printf '{\\\"event\\\":\\\"QS_NOTIFS_PANEL\\\",\\\"data\\\":\\\"\\\"}\\n' ;; qs_island_calendar) rm -f /tmp/qs_island_calendar; printf '{\\\"event\\\":\\\"QS_CALENDAR\\\",\\\"data\\\":\\\"\\\"}\\n' ;; qs_island_notif) if [ -f /tmp/qs_island_notif ]; then while IFS= read -r j; do [ -n \"$j\" ] && printf '{\\\"event\\\":\\\"QS_NOTIF\\\",\\\"data\\\":%s}\\n' \"$j\"; done < <(jq -c '.' /tmp/qs_island_notif 2>/dev/null); rm -f /tmp/qs_island_notif; fi ;; esac; done"
        ]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                if (!line || line.trim() === "")
                    return
                try {
                    let obj = JSON.parse(line.trim())
                    handleIpcEvent(obj.event, obj.data)
                } catch (e) {
                }
            }
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
                                timestamp: items[i].timestamp || 0
                            })
                        }
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
                } catch(e) {}
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
        Behavior on opacity { PropertyAnimation { duration: 300; easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1] } }
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: Qt.rgba(base.r, base.g, base.b, 0.65) }
            GradientStop { position: 0.25; color: Qt.rgba(base.r, base.g, base.b, 0.35) }
            GradientStop { position: 1.0; color: "transparent" }
        }
        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blurMax: 10
            blur: 0.7
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

        property int collapsedH: osdActive ? s(68) : s(36)
        property int expandedW: Math.min(s(680), Screen.width - s(32))
        property int expandedH: {
            if (notifActive)
                return s(88)
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
        scale: hovered && !expanded ? 1.025 : 1.0
        opacity: launcherActive ? 0.0 : 1.0
        transform: [
            Translate { id: swipeTranslate },
            Translate { id: popDownTranslate; y: 0 }
        ]

        NumberAnimation {
            id: snapBackAnim; target: swipeTranslate; property: "x"; to: 0
            duration: 250; easing.type: Easing.OutBack; easing.overshoot: 1.2
        }

        SequentialAnimation {
            id: popDownAnim
            PropertyAnimation { target: popDownTranslate; property: "y"; from: s(8); to: s(4); duration: 120; easing.type: Easing.OutCubic }
            PropertyAnimation { target: popDownTranslate; property: "y"; to: 0; duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1.0 }
        }

        Behavior on width { PropertyAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on height { PropertyAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on scale { PropertyAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1] } }
        Behavior on opacity { PropertyAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1] } }

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
            grabPermissions: PointerGesture.CanTakeOverFromItems
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
            radius: expanded ? s(26) : height / 2
            antialiasing: true
            opacity: (expanded || hovered) ? 1.0 : 0.85

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#000000"
                shadowBlur: 0.5
                shadowOpacity: 0.45
                shadowVerticalOffset: s(6)
                blurEnabled: hovered && !expanded
                blurMax: 12
                blur: 0.5
            }
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: Qt.rgba(base.r, base.g, base.b, 0.82) }
                GradientStop { position: 1.0; color: Qt.rgba(base.r, base.g, base.b, 0.95) }
            }
            border.width: notifActive ? 2 : 1
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
                    return Qt.rgba(mauve.r, mauve.g, mauve.b, 0.4)
                return Qt.rgba(text.r, text.g, text.b, 0.06)
            }
            Behavior on radius { PropertyAnimation { duration: 150; easing.type: Easing.OutCubic } }
            Behavior on opacity { PropertyAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1] } }
            Behavior on border.width { PropertyAnimation { duration: 80; easing.type: Easing.OutCubic } }
            Behavior on border.color { enabled: islandWindow.visible; ColorAnimation { duration: 100 } }
        }

        Item {
            id: collapsedContent
            anchors.fill: parent
            clip: true
            visible: showCollapsed
            enabled: showCollapsed
            opacity: showCollapsed ? 1.0 : 0.0
            Behavior on opacity { PropertyAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1] } }

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
                    active: expanded
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
                    Behavior on opacity { NumberAnimation { duration: isCurrent ? 220 : 100; easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1] } }
                    Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1] } }
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
                Behavior on opacity { PropertyAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1] } }
                Behavior on y { PropertyAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1] } }
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
        Behavior on opacity { PropertyAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1] } }
        Behavior on scale { PropertyAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1] } }

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

