import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtCore
import Quickshell
import Quickshell.Io
import "../"

Item {
    id: root
    property var island

    onVisibleChanged: if (visible) uptimeGlow.restart()

    Shortcut { sequence: "Escape"; onActivated: island.currentPage = "clock" }

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

    // ── Combined battery page watcher (system stats + battery — one process) ──
    Process {
        id: batteryPageWatcher
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
                    if (!root._sysBuf) root._sysBuf = []
                    root._sysBuf.push(data)
                    if (root._sysBuf.length < 5) return
                    let lines = root._sysBuf.splice(0)
                    if (lines.length >= 5) {
                        root.cpuUsage = parseInt(lines[0]) || 0
                        root.ramUsage = parseInt(lines[1]) || 0
                        root.diskUsage = parseInt(lines[2]) || 0
                        root.sysTemp = parseInt(lines[3]) || 0
                        let upMatch = lines[4].match(/(\d+)h\s*(\d+)m/)
                        if (upMatch) {
                            root.upHours = parseInt(upMatch[1]) || 0
                            root.upMins = parseInt(upMatch[2]) || 0
                        }
                    }
                    return
                }

                if (tag === "bout") {
                    try {
                        let d = JSON.parse(data)
                        if (d.percent !== undefined) root.batPct = d.percent
                        if (d.status !== undefined) root.batStatus = d.status
                        if (d.icon !== undefined) root.batIcon = d.icon
                    } catch (e) {}
                }
            }
        }
    }

    property bool orbitActive: root.visible
    NumberAnimation on globalOrbitAngle {
        from: 0; to: Math.PI * 2; duration: 180000; loops: Animation.Infinite; running: root.visible && orbitActive
    }

    // -------------------------------------------------------------------------
    // UI LAYOUT
    // -------------------------------------------------------------------------
    Item {
        anchors.fill: parent
        anchors.margins: island.s(28)
        anchors.bottomMargin: island.s(72)

        clip: true

        Rectangle {
            width: parent.width * 0.8; height: width; radius: width / 2
            x: (parent.width / 2 - width / 2) + Math.cos(root.globalOrbitAngle * 2) * island.s(150)
            y: (parent.height / 2 - height / 2) + Math.sin(root.globalOrbitAngle * 2) * island.s(100)
            opacity: 0.05
            color: island.mauve
        }

        Rectangle {
            width: parent.width * 0.9; height: width; radius: width / 2
            x: (parent.width / 2 - width / 2) + Math.sin(root.globalOrbitAngle * 1.5) * island.s(-150)
            y: (parent.height / 2 - height / 2) + Math.cos(root.globalOrbitAngle * 1.5) * island.s(-100)
            opacity: 0.03
            color: island.blue
        }

        // Top row: uptime + battery
        RowLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: island.s(6)

            // Uptime
            Row {
                spacing: island.s(6)
                Layout.alignment: Qt.AlignLeft

                Rectangle {
                    width: island.s(44); height: island.s(48); radius: island.s(10)
                    color: island.surface0; border.color: island.surface1; border.width: 1
                    Rectangle { anchors.fill: parent; radius: island.s(10); color: island.mauve; opacity: 0.05; }
                    Column {
                        anchors.centerIn: parent
                        Text {
                            text: root.upHours.toString().padStart(2, '0')
                            font.pixelSize: island.s(18); font.family: island.monoFont; font.weight: Font.Black
                            color: island.mauve; anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: "HR"; font.pixelSize: island.s(8); font.family: island.monoFont; font.weight: Font.Bold
                            color: island.subtext0; anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: ":"
                    font.pixelSize: island.s(22); font.family: island.monoFont; font.weight: Font.Black
                    color: island.mauve
                    opacity: uptimePulse
                                    property real uptimePulse: 1.0
                                    SequentialAnimation on uptimePulse {
                                        id: uptimeGlow
                                        loops: 3
                        NumberAnimation { to: 0.2; duration: 800; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutSine }
                    }
                }

                Rectangle {
                    width: island.s(44); height: island.s(48); radius: island.s(10)
                    color: island.surface0; border.color: island.surface1; border.width: 1
                    Rectangle { anchors.fill: parent; radius: island.s(10); color: island.blue; opacity: 0.05; }
                    Column {
                        anchors.centerIn: parent
                        Text {
                            text: root.upMins.toString().padStart(2, '0')
                            font.pixelSize: island.s(18); font.family: island.monoFont; font.weight: Font.Black
                            color: island.blue; anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: "MIN"; font.pixelSize: island.s(8); font.family: island.monoFont; font.weight: Font.Bold
                            color: island.subtext0; anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Battery status
            Row {
                spacing: island.s(6)
                Layout.alignment: Qt.AlignRight
                visible: !SharedConfig.isDesktop

                Rectangle {
                    width: batLayoutRow.implicitWidth + island.s(24); height: island.s(48); radius: island.s(12)
                    color: island.surface0; border.color: island.surface1; border.width: 1

                    Rectangle { anchors.fill: parent; radius: parent.radius; color: island.green; opacity: 0.06; }

                    Row {
                        id: batLayoutRow; anchors.centerIn: parent; spacing: island.s(8)
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.batIcon
                            font.family: island.nerdFont; font.pixelSize: island.s(20)
                            color: root.batCharging ? island.green : island.text
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.batPct + "%"
                            font.family: island.monoFont; font.pixelSize: island.s(15); font.weight: Font.Black
                            color: root.batCharging ? island.green : island.text
                        }
                    }
                }
            }
        }

        // Radar Rings
        Item {
            anchors.fill: parent
            Repeater {
                model: 3
                Rectangle {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: island.s(-30)
                    width: island.s(320) + (index * island.s(170))
                    height: width; radius: width / 2
                    color: "transparent"
                    border.color: island.blue
                    border.width: 1
                    opacity: 0.08 - (index * 0.025)
                }
            }
        }

        // ==========================================
        // SYSTEM RESOURCES GRID
        // ==========================================
        Grid {
            columns: 2
            spacing: island.s(20)
            anchors.centerIn: parent
            anchors.verticalCenterOffset: island.s(-25)

            // 1. CPU Orb
            ArcGauge {
                id: cpuOrb; width: island.s(130); height: island.s(130)
                value: root.cpuUsage
                colorFrom: island.blue; colorTo: island.sapphire
                trackColor: island.surface0
                ColumnLayout {
                    anchors.centerIn: parent; spacing: 0
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter; spacing: island.s(4)
                        Text { font.family: island.nerdFont; font.pixelSize: island.s(16); color: island.blue; text: "" }
                        Text { font.family: island.monoFont; font.weight: Font.Black; font.pixelSize: island.s(24); color: island.text; text: Math.round(cpuOrb.animVal) + "%" }
                    }
                    Text { Layout.alignment: Qt.AlignHCenter; font.family: island.monoFont; font.weight: Font.Bold; font.pixelSize: island.s(11); color: island.subtext0; text: "CPU LOAD" }
                }
            }

            // 2. RAM Orb
            ArcGauge {
                id: ramOrb; width: island.s(130); height: island.s(130)
                value: root.ramUsage
                colorFrom: island.mauve; colorTo: island.pink
                trackColor: island.surface0
                ColumnLayout {
                    anchors.centerIn: parent; spacing: 0
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter; spacing: island.s(4)
                        Text { font.family: island.nerdFont; font.pixelSize: island.s(16); color: island.mauve; text: "󰍛" }
                        Text { font.family: island.monoFont; font.weight: Font.Black; font.pixelSize: island.s(24); color: island.text; text: Math.round(ramOrb.animVal) + "%" }
                    }
                    Text { Layout.alignment: Qt.AlignHCenter; font.family: island.monoFont; font.weight: Font.Bold; font.pixelSize: island.s(11); color: island.subtext0; text: "MEMORY" }
                }
            }

            // 3. DISK Orb
            ArcGauge {
                id: diskOrb; width: island.s(130); height: island.s(130)
                value: root.diskUsage
                colorFrom: island.peach; colorTo: island.yellow
                trackColor: island.surface0
                ColumnLayout {
                    anchors.centerIn: parent; spacing: 0
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter; spacing: island.s(4)
                        Text { font.family: island.nerdFont; font.pixelSize: island.s(16); color: island.peach; text: "󰋊" }
                        Text { font.family: island.monoFont; font.weight: Font.Black; font.pixelSize: island.s(24); color: island.text; text: Math.round(diskOrb.animVal) + "%" }
                    }
                    Text { Layout.alignment: Qt.AlignHCenter; font.family: island.monoFont; font.weight: Font.Bold; font.pixelSize: island.s(11); color: island.subtext0; text: "STORAGE" }
                }
            }

            // 4. TEMP Orb
            ArcGauge {
                id: tempOrb; width: island.s(130); height: island.s(130)
                value: root.sysTemp
                colorFrom: island.red; colorTo: island.maroon
                trackColor: island.surface0
                ColumnLayout {
                    anchors.centerIn: parent; spacing: 0
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter; spacing: island.s(4)
                        Text { font.family: island.nerdFont; font.pixelSize: island.s(16); color: island.red; text: "" }
                        Text { font.family: island.monoFont; font.weight: Font.Black; font.pixelSize: island.s(24); color: island.text; text: Math.round(tempOrb.animVal) + "°" }
                    }
                    Text { Layout.alignment: Qt.AlignHCenter; font.family: island.monoFont; font.weight: Font.Bold; font.pixelSize: island.s(11); color: island.subtext0; text: "SYSTEM TEMP" }
                }
            }
        }
    }
}
