import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls
import QtCore
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import "../"

Item {
    id: window
    property real globalUiScale: 1.0
    property var themeColors: null

    onVisibleChanged: if (visible) uptimeGlow.restart()

    // --- Responsive Scaling Logic ---
    Scaler {
        id: scaler
        // Uses the physical screen width so the popup scales synchronously with the TopBar
        uiScale: globalUiScale
        currentWidth: Screen.width
    }
    
    // Helper function scoped to the root Item for easy access in deeply nested elements and Canvases
    function s(val) { 
        return scaler.s(val); 
    }

    // -------------------------------------------------------------------------
    // COLORS (Dynamic Matugen Palette)
    // -------------------------------------------------------------------------
    readonly property var _theme: SharedConfig.mocha
    readonly property color base: _theme.base
    readonly property color mantle: _theme.mantle
    readonly property color crust: _theme.crust
    readonly property color text: _theme.text
    readonly property color subtext0: _theme.subtext0
    readonly property color overlay0: _theme.overlay0
    readonly property color overlay1: _theme.overlay1
    readonly property color surface0: _theme.surface0
    readonly property color surface1: _theme.surface1
    readonly property color surface2: _theme.surface2
    
    readonly property color mauve: _theme.mauve
    readonly property color pink: _theme.pink
    readonly property color red: _theme.red
    readonly property color maroon: _theme.maroon
    readonly property color peach: _theme.peach
    readonly property color yellow: _theme.yellow
    readonly property color green: _theme.green
    readonly property color teal: _theme.teal
    readonly property color sapphire: _theme.sapphire
    readonly property color blue: _theme.blue

    // -------------------------------------------------------------------------
    // CACHE (Eliminates startup delay visually)
    // -------------------------------------------------------------------------
    Settings {
        id: widgetCache
        category: "SystemMonitorCache"
        property int cpuUsage: 0
        property int ramUsage: 0
        property int diskUsage: 0
        property int sysTemp: 0
        property int upHours: 0
        property int upMins: 0
    }

    // -------------------------------------------------------------------------
    // STATE & POLLING
    // -------------------------------------------------------------------------
    property int cpuUsage: 0
    property int ramUsage: 0
    property int diskUsage: 0
    property int sysTemp: 0

    property int upHours: 0
    property int upMins: 0

    property string batPct: "100"
    property string batStatus: "Full"
    property string batIcon: "󰁹"
    readonly property bool batCharging: batStatus === "Charging" || batStatus === "Full"

    // Ambient Blobs - Static for Desktop version
    readonly property color ambientPrimary: window.mauve
    readonly property color ambientSecondary: window.blue

    // ── Combined battery popup watcher (system stats + battery — one process) ──
    Process {
        id: batteryPopupWatcher
        running: true
        command: ["bash", "-c", "~/.config/quickshell/dynamic/modules/watchers/battery_popup_combined.sh"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                let txt = line.trim()
                if (txt === "") return
                let colonIdx = txt.indexOf(":")
                if (colonIdx < 0) return
                let tag = txt.substring(0, colonIdx)
                let data = txt.substring(colonIdx + 1)

                if (tag === "sysout") {
                    // 5 newline-separated values: cpu, ram, disk, temp, uptime
                    // Accumulate into a queue; emit once we have all 5
                    if (!window._sysBuf) window._sysBuf = []
                    window._sysBuf.push(data)
                    if (window._sysBuf.length < 5) return
                    let lines = window._sysBuf.splice(0)
                    if (lines.length >= 5) {
                        window.cpuUsage = parseInt(lines[0]) || 0
                        window.ramUsage = parseInt(lines[1]) || 0
                        window.diskUsage = parseInt(lines[2]) || 0
                        window.sysTemp = parseInt(lines[3]) || 0
                        let upMatch = lines[4].match(/(\d+)h\s*(\d+)m/)
                        if (upMatch) {
                            window.upHours = parseInt(upMatch[1]) || 0
                            window.upMins = parseInt(upMatch[2]) || 0
                        }
                    }
                    return
                }

                if (tag === "bout") {
                    try {
                        let d = JSON.parse(data)
                        if (d.percent !== undefined) window.batPct = d.percent
                        if (d.status !== undefined) window.batStatus = d.status
                        if (d.icon !== undefined) window.batIcon = d.icon
                    } catch (e) {}
                }
            }
        }
    }

    // Removed: sysPoller, batPoller, and both Timer restarters (merged above)
    // The combined watcher handles 10s sys + 15s battery internally

    property bool orbitActive: window.visible
    NumberAnimation on globalOrbitAngle {
        from: 0; to: Math.PI * 2; duration: 180000; loops: Animation.Infinite; running: window.visible && orbitActive
    }

    // --- ENHANCED STARTUP ANIMATION STATES ---
    property real introMain: 0
    property real introTop: 0
    property real introCore: 0


    ParallelAnimation {
        running: true
        NumberAnimation { target: window; property: "introMain"; from: 0; to: 1.0; duration: 800; easing.type: Easing.OutQuart }
        SequentialAnimation {
            PauseAnimation { duration: 100 }
            NumberAnimation { target: window; property: "introTop"; from: 0; to: 1.0; duration: 800; easing.type: Easing.OutBack; easing.overshoot: 1.0 }
        }
        SequentialAnimation {
            PauseAnimation { duration: 250 }
            NumberAnimation { target: window; property: "introCore"; from: 0; to: 1.0; duration: 900; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
        }

    }

    ParallelAnimation {
        id: exitAnim
        NumberAnimation { target: window; property: "introMain"; to: 0; duration: 400; easing.type: Easing.InQuart }
        NumberAnimation { target: window; property: "introTop"; to: 0; duration: 300; easing.type: Easing.InQuart }
        NumberAnimation { target: window; property: "introCore"; to: 0; duration: 350; easing.type: Easing.InQuart }

    }

    // -------------------------------------------------------------------------
    // UI LAYOUT
    // -------------------------------------------------------------------------
    Item {
        anchors.fill: parent
        scale: 0.92 + (0.08 * introMain)
        opacity: introMain
        transform: Translate { y: window.s(10) * (1 - introMain) }

        // Outer Border
    Rectangle {
        anchors.fill: parent
        anchors.margins: window.s(16)
        radius: window.s(20)
        color: window.base
        border.color: window.surface1 
        border.width: 1
        clip: true

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#000000"
            shadowBlur: 0.5
            shadowOpacity: 0.5
            shadowVerticalOffset: window.s(8)
            blurEnabled: false
        }

            // Rotating Background Blobs
            Rectangle {
                width: parent.width * 0.8; height: width; radius: width / 2
                x: (parent.width / 2 - width / 2) + Math.cos(window.globalOrbitAngle * 2) * window.s(150)
                y: (parent.height / 2 - height / 2) + Math.sin(window.globalOrbitAngle * 2) * window.s(100)
                opacity: 0.08
                color: window.ambientPrimary
            }
            
            Rectangle {
                width: parent.width * 0.9; height: width; radius: width / 2
                x: (parent.width / 2 - width / 2) + Math.sin(window.globalOrbitAngle * 1.5) * window.s(-150)
                y: (parent.height / 2 - height / 2) + Math.cos(window.globalOrbitAngle * 1.5) * window.s(-100)
                opacity: 0.06
                color: window.ambientSecondary
            }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // Notification center moved to Dynamic Island (navigation arrows inside the island)
                // --- REMOVED: LEFT SIDE NOTIFICATION CENTER ---

                // ==========================================
                // RIGHT SIDE: SYSTEM RESOURCES CORE
                // ==========================================
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // Radar Rings
                    Item {
                        id: radarItem
                        anchors.fill: parent
                        
                        Repeater {
                            model: 3
                            Rectangle {
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: window.s(-30)
                                width: window.s(320) + (index * window.s(170))
                                height: width
                                radius: width / 2
                                color: "transparent"
                                border.color: window.ambientSecondary
                                border.width: 1
                                opacity: 0.06 - (index * 0.02)
                            }
                        }
                    }

                    // ==========================================
                    // TOP: UPTIME COMPONENT
                    // ==========================================
                    Row {
                        id: uptimeRow
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: window.s(25)
                        spacing: window.s(6)
                        z: 10
                        
                        transform: Translate { y: window.s(-20) * (1.0 - introTop) }
                        opacity: introTop
                        
                        // Hours Box
                        Rectangle {
                            width: window.s(44); height: window.s(48); radius: window.s(10)
                            color: window.surface0; border.color: window.surface1; border.width: 1
                            
                            Rectangle { anchors.fill: parent; radius: window.s(10); color: window.ambientPrimary; opacity: 0.05; }
                            Column {
                                anchors.centerIn: parent
                                Text { 
                                    text: window.upHours.toString().padStart(2, '0')
                                    font.pixelSize: window.s(18); font.family: SharedConfig.monoFont; font.weight: Font.Black
                                    color: window.ambientPrimary
                                    anchors.horizontalCenter: parent.horizontalCenter 
                                }
                                Text { 
                                    text: "HR"; font.pixelSize: window.s(8); font.family: SharedConfig.monoFont; font.weight: Font.Bold
                                    color: window.subtext0; anchors.horizontalCenter: parent.horizontalCenter 
                                }
                            }
                        }

                        // Pulsing Colon
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: ":"
                            font.pixelSize: window.s(22); font.family: SharedConfig.monoFont; font.weight: Font.Black
                            color: window.ambientPrimary
                            
                            opacity: uptimePulse
                            property real uptimePulse: 1.0
                            SequentialAnimation on uptimePulse {
                                id: uptimeGlow
                                loops: 3
                                NumberAnimation { to: 0.2; duration: 800; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutSine }
                            }
                        }

                        // Mins Box
                        Rectangle {
                            width: window.s(44); height: window.s(48); radius: window.s(10)
                            color: window.surface0; border.color: window.surface1; border.width: 1
                            
                            Rectangle { anchors.fill: parent; radius: window.s(10); color: window.ambientSecondary; opacity: 0.05; }
                            Column {
                                anchors.centerIn: parent
                                Text { 
                                    text: window.upMins.toString().padStart(2, '0')
                                    font.pixelSize: window.s(18); font.family: SharedConfig.monoFont; font.weight: Font.Black
                                    color: window.ambientSecondary
                                    anchors.horizontalCenter: parent.horizontalCenter 
                                }
                                Text { 
                                    text: "MIN"; font.pixelSize: window.s(8); font.family: SharedConfig.monoFont; font.weight: Font.Bold
                                    color: window.subtext0; anchors.horizontalCenter: parent.horizontalCenter 
                                }
                            }
                        }
                    }



                    // Battery status pill (charging pulse parity with TopBar / Lock)
                    Row {
                        id: batRow
                        anchors.top: parent.top; anchors.right: parent.right; anchors.margins: window.s(25)
                        spacing: window.s(6)
                        z: 10
                        visible: !SharedConfig.isDesktop

                        transform: Translate { y: window.s(-20) * (1.0 - introTop) }
                        opacity: introTop

                        Rectangle {
                            width: batLayoutRow.implicitWidth + window.s(24); height: window.s(48); radius: window.s(12)
                            color: window.surface0; border.color: window.surface1; border.width: 1

                            Rectangle { anchors.fill: parent; radius: parent.radius; color: window.green; opacity: 0.06; }

                            Rectangle {
                                anchors.fill: parent; radius: parent.radius
                                opacity: window.batCharging ? chargePulse : 0.0
                                property real chargePulse: 1.0
                                SequentialAnimation on chargePulse {
                                    loops: Animation.Infinite; running: window.batCharging
                                    PauseAnimation { duration: 1200 }
                                    NumberAnimation { from: 1.0; to: 0.5; duration: 150; easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1] }
                                    PauseAnimation { duration: 600 }
                                    NumberAnimation { from: 0.5; to: 1.0; duration: 150; easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1] }
                                }
                                Behavior on opacity { NumberAnimation { duration: 300 } }
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: Qt.rgba(window.green.r, window.green.g, window.green.b, 0.20) }
                                    GradientStop { position: 1.0; color: Qt.rgba(window.green.r, window.green.g, window.green.b, 0.06) }
                                }
                            }

                            Row {
                                id: batLayoutRow; anchors.centerIn: parent; spacing: window.s(8)
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: window.batIcon
                                    font.family: SharedConfig.nerdFont; font.pixelSize: window.s(20)
                                    color: window.batCharging ? window.green : window.text
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: window.batPct + "%"
                                    font.family: SharedConfig.monoFont; font.pixelSize: window.s(15); font.weight: Font.Black
                                    color: window.batCharging ? window.green : window.text
                                }
                            }
                        }
                    }

                    // ==========================================
                    // BIG SYSTEM RESOURCES GRID (DESKTOP)
                    // ==========================================
                    Grid {
                        id: sysGrid
                        columns: 2
                        spacing: window.s(25)
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: window.s(-55) 
                        z: 1

                        opacity: introCore
                        transform: Translate { y: window.s(25) * (1 - introCore) }
                        scale: 0.9 + (0.1 * introCore)

                        // 1. CPU Orb
                        ArcGauge {
                            id: cpuOrb; width: window.s(145); height: window.s(145)
                            value: window.cpuUsage
                            colorFrom: window.blue; colorTo: window.sapphire
                            trackColor: window.surface0
                            ColumnLayout {
                                anchors.centerIn: parent; spacing: 0
                                RowLayout {
                                    Layout.alignment: Qt.AlignHCenter; spacing: window.s(4)
                                    Text { font.family: SharedConfig.nerdFont; font.pixelSize: window.s(18); color: window.blue; text: "" }
                                    Text { font.family: SharedConfig.monoFont; font.weight: Font.Black; font.pixelSize: window.s(28); color: window.text; text: Math.round(cpuOrb.animVal) + "%" }
                                }
                                Text { Layout.alignment: Qt.AlignHCenter; font.family: SharedConfig.monoFont; font.weight: Font.Bold; font.pixelSize: window.s(12); color: window.subtext0; text: "CPU LOAD" }
                            }
                        }

                        // 2. RAM Orb
                        ArcGauge {
                            id: ramOrb; width: window.s(145); height: window.s(145)
                            value: window.ramUsage
                            colorFrom: window.mauve; colorTo: window.pink
                            trackColor: window.surface0
                            ColumnLayout {
                                anchors.centerIn: parent; spacing: 0
                                RowLayout {
                                    Layout.alignment: Qt.AlignHCenter; spacing: window.s(4)
                                    Text { font.family: SharedConfig.nerdFont; font.pixelSize: window.s(18); color: window.mauve; text: "󰍛" }
                                    Text { font.family: SharedConfig.monoFont; font.weight: Font.Black; font.pixelSize: window.s(28); color: window.text; text: Math.round(ramOrb.animVal) + "%" }
                                }
                                Text { Layout.alignment: Qt.AlignHCenter; font.family: SharedConfig.monoFont; font.weight: Font.Bold; font.pixelSize: window.s(12); color: window.subtext0; text: "MEMORY" }
                            }
                        }

                        // 3. DISK Orb
                        ArcGauge {
                            id: diskOrb; width: window.s(145); height: window.s(145)
                            value: window.diskUsage
                            colorFrom: window.peach; colorTo: window.yellow
                            trackColor: window.surface0
                            ColumnLayout {
                                anchors.centerIn: parent; spacing: 0
                                RowLayout {
                                    Layout.alignment: Qt.AlignHCenter; spacing: window.s(4)
                                    Text { font.family: SharedConfig.nerdFont; font.pixelSize: window.s(18); color: window.peach; text: "󰋊" }
                                    Text { font.family: SharedConfig.monoFont; font.weight: Font.Black; font.pixelSize: window.s(28); color: window.text; text: Math.round(diskOrb.animVal) + "%" }
                                }
                                Text { Layout.alignment: Qt.AlignHCenter; font.family: SharedConfig.monoFont; font.weight: Font.Bold; font.pixelSize: window.s(12); color: window.subtext0; text: "STORAGE" }
                            }
                        }

                        // 4. TEMP Orb
                        ArcGauge {
                            id: tempOrb; width: window.s(145); height: window.s(145)
                            value: window.sysTemp
                            colorFrom: window.red; colorTo: window.maroon
                            trackColor: window.surface0
                            ColumnLayout {
                                anchors.centerIn: parent; spacing: 0
                                RowLayout {
                                    Layout.alignment: Qt.AlignHCenter; spacing: window.s(4)
                                    Text { font.family: SharedConfig.nerdFont; font.pixelSize: window.s(18); color: window.red; text: "" }
                                    Text { font.family: SharedConfig.monoFont; font.weight: Font.Black; font.pixelSize: window.s(28); color: window.text; text: Math.round(tempOrb.animVal) + "°" }
                                }
                                Text { Layout.alignment: Qt.AlignHCenter; font.family: SharedConfig.monoFont; font.weight: Font.Bold; font.pixelSize: window.s(12); color: window.subtext0; text: "SYSTEM TEMP" }
                            }
                        }
                    }


                }
            }
        }
    }
}
