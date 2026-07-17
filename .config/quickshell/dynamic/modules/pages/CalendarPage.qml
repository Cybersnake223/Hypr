import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io

Item {
    id: root
    property var island

    Shortcut { sequence: "Escape"; onActivated: island.currentPage = "clock" }
    Shortcut { sequence: "Left"; onActivated: prevMonth() }
    Shortcut { sequence: "Right"; onActivated: nextMonth() }

    property int cYear: new Date().getFullYear()
    property int cMonth: new Date().getMonth()
    property int todayDate: new Date().getDate()
    property int todayMonth: new Date().getMonth()
    property int todayYear: new Date().getFullYear()

    property var monthNames: ["January","February","March","April","May","June","July","August","September","October","November","December"]
    property var dayHeaders: ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]

    function daysInMonth(y, m) { return new Date(y, m + 1, 0).getDate() }
    function firstDow(y, m) { return new Date(y, m, 1).getDay() }

    function prevMonth() {
        if (calGrid) calGrid.x = island.s(30)
        if (cMonth === 0) { cMonth = 11; cYear-- }
        else cMonth--
    }
    function nextMonth() {
        if (calGrid) calGrid.x = -island.s(30)
        if (cMonth === 11) { cMonth = 0; cYear++ }
        else cMonth++
    }

    property var days: []
    function buildCalendar() {
        var d = []
        var dim = daysInMonth(cYear, cMonth)
        var fdow = firstDow(cYear, cMonth)
        for (var i = 0; i < fdow; i++)
            d.push({ num: 0, isToday: false })
        for (var j = 1; j <= dim; j++)
            d.push({ num: j, isToday: (j === todayDate && cMonth === todayMonth && cYear === todayYear) })
        while (d.length % 7 !== 0)
            d.push({ num: 0, isToday: false })
        days = d
    }

    onCMonthChanged: buildCalendar()
    onCYearChanged: buildCalendar()
    Component.onCompleted: buildCalendar()

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            var n = new Date()
            todayDate = n.getDate()
            todayMonth = n.getMonth()
            todayYear = n.getFullYear()
            buildCalendar()
        }
    }

    property var forecastData: []

    // Current hourly weather (mirrors the fixed --current-* logic in weather.sh):
    // the hourly array is chronological but wraps past midnight (last entry is the
    // next day's early-morning slot), so we exclude that wrap slot unless "now"
    // actually falls before the first slot of the day.
    function curWeather() {
        if (!forecastData || forecastData.length === 0) return {}
        let h = forecastData[0].hourly
        if (!h || h.length === 0) return {}
        let now = Qt.formatDateTime(new Date(), "HH:mm")
        let first = h[0].time
        let slot
        if (now < first) {
            slot = h[h.length - 1]
        } else {
            let cand = h.slice(0, -1).filter(s => s.time <= now)
            slot = cand.length > 0 ? cand[cand.length - 1] : h[0]
        }
        return { icon: slot.icon, temp: slot.temp, unit: forecastData[0].unit }
    }

    property bool weatherLoaded: false
    property bool weatherError: false
    property int weatherRetryCount: 0
    readonly property int weatherMaxRetries: 3

    Process {
        id: weatherReader
        running: true
        command: ["bash", "-c", "cat ~/.cache/quickshell/weather/weather.json 2>/dev/null || echo '{}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let t = this.text.trim()
                if (t && t !== "{}") {
                    try {
                        let d = JSON.parse(t)
                        if (d.forecast && d.forecast.length > 0) {
                            forecastData = d.forecast
                            weatherLoaded = true
                            weatherError = false
                            weatherRetryCount = 0
                            return
                        }
                    } catch (e) {}
                }
                weatherError = true
                if (weatherRetryCount < weatherMaxRetries)
                    weatherRetryTimer.restart()
            }
        }
    }

    Timer {
        id: weatherRetryTimer
        interval: 10000
        repeat: false
        onTriggered: {
            weatherRetryCount++
            weatherReader.running = true
        }
    }

    Process {
        id: weatherWatcher
        running: true
        command: ["bash", "-c",
            "while [ ! -f ~/.cache/quickshell/weather/weather.json ]; do sleep 1; done; " +
            "inotifywait -m -e modify -e close_write -e moved_to ~/.cache/quickshell/weather/weather.json 2>/dev/null | " +
            "while read -r _; do cat ~/.cache/quickshell/weather/weather.json 2>/dev/null; done"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let t = this.text.trim()
                if (t && t !== "{}") {
                    try {
                        let d = JSON.parse(t)
                        if (d.forecast && d.forecast.length > 0) {
                            forecastData = d.forecast
                            weatherLoaded = true
                            weatherError = false
                        }
                    } catch (e) {}
                }
            }
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: island.s(20)
        anchors.bottomMargin: island.s(72)

        Rectangle {
            anchors.fill: parent
            radius: island.s(16)
            color: Qt.rgba(island.base.r, island.base.g, island.base.b, 0.5)
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blurMax: 16
                blur: 0.7
            }
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // ── Left pane: Calendar ──────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
                radius: island.s(16)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: island.s(4)
                    spacing: island.s(8)

                    // Calendar header: prev | Month Year | next
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: island.s(6)

                        Rectangle {
                            Layout.preferredWidth: island.s(26)
                            Layout.preferredHeight: island.s(26)
                            radius: island.s(13)
                            color: prevMouse.containsMouse ? Qt.rgba(island.mauve.r, island.mauve.g, island.mauve.b, 0.2) : "transparent"
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Text {
                                anchors.centerIn: parent
                                text: "󰁍"
                                font.family: island.nerdFont; font.pixelSize: island.s(15)
                                color: prevMouse.containsMouse ? island.mauve : island.subtext0
                            }
                            MouseArea {
                                id: prevMouse; anchors.fill: parent; hoverEnabled: true; onClicked: prevMonth()
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: monthNames[cMonth] + " " + cYear
                            font.family: island.monoFont; font.pixelSize: island.s(17); font.weight: Font.Bold
                            color: island.mauve; horizontalAlignment: Text.AlignHCenter
                        }

                        Rectangle {
                            Layout.preferredWidth: island.s(26)
                            Layout.preferredHeight: island.s(26)
                            radius: island.s(13)
                            color: nextMouse.containsMouse ? Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.2) : "transparent"
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Text {
                                anchors.centerIn: parent
                                text: "󰁕"
                                font.family: island.nerdFont; font.pixelSize: island.s(15)
                                color: nextMouse.containsMouse ? island.peach : island.subtext0
                            }
                            MouseArea {
                                id: nextMouse; anchors.fill: parent; hoverEnabled: true; onClicked: nextMonth()
                            }
                        }
                    }

                    // "Today" badge
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: island.s(18)
                        visible: cMonth === todayMonth && cYear === todayYear
                        radius: island.s(9)
                        color: Qt.rgba(island.mauve.r, island.mauve.g, island.mauve.b, 0.08)
                        Text {
                            anchors.centerIn: parent
                            text: {
                                var d = new Date()
                                var days = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
                                return "Today: " + days[d.getDay()] + ", " + monthNames[d.getMonth()] + " " + d.getDate()
                            }
                            font.family: island.monoFont; font.pixelSize: island.s(10)
                            color: island.subtext0; opacity: 0.8
                        }
                    }

                    // Day headers
                    RowLayout {
                        Layout.fillWidth: true; spacing: 0
                        Repeater {
                            model: dayHeaders
                            delegate: Text {
                                required property int index
                                Layout.fillWidth: true
                                text: modelData
                                font.family: island.monoFont; font.pixelSize: island.s(11); font.weight: Font.Bold
                                color: index === 0 ? island.peach : (index === 6 ? island.mocha.sapphire : island.mocha.overlay0)
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true; height: 1
                        color: Qt.rgba(island.text.r, island.text.g, island.text.b, 0.08)
                    }

                    // Calendar grid
                    Item {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        clip: true

                        GridLayout {
                            id: calGrid
                            x: 0
                            Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                            anchors.fill: parent
                            columns: 7; columnSpacing: 0; rowSpacing: island.s(2)

                        Repeater {
                            model: days
                            delegate: Rectangle {
                                required property var modelData
                                property int dayNum: modelData.num
                                property bool isToday: modelData.isToday
                                property int colIndex: index % 7
                                property bool isWeekend: colIndex === 0 || colIndex === 6

                                Layout.fillWidth: true; Layout.preferredHeight: island.s(28)
                                radius: island.s(6)
                                color: {
                                    if (dayNum === 0) return "transparent"
                                    if (isToday) return island.mauve
                                    if (cellMouse.containsMouse) return Qt.rgba(island.mauve.r, island.mauve.g, island.mauve.b, 0.15)
                                    return "transparent"
                                }
                                Behavior on color { ColorAnimation { duration: 120 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: dayNum > 0 ? dayNum.toString() : ""
                                    font.family: island.monoFont; font.pixelSize: island.s(13)
                                    font.weight: isToday ? Font.Bold : Font.Medium
                                    color: {
                                        if (dayNum === 0) return "transparent"
                                        if (isToday) return island.base
                                        if (cellMouse.containsMouse) return island.mauve
                                        if (isWeekend) return colIndex === 0 ? island.peach : island.mocha.sapphire
                                        return island.subtext0
                                    }
                                }

                                Rectangle {
                                    visible: dayNum > 0 && isToday
                                    anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottomMargin: island.s(2)
                                    width: island.s(4); height: island.s(4); radius: island.s(2)
                                    color: island.base
                                }

                                Rectangle {
                                    visible: dayNum > 0 && !isToday && cellMouse.containsMouse
                                    anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottomMargin: island.s(2)
                                    width: island.s(4); height: island.s(4); radius: island.s(2)
                                    color: island.mauve
                                }

                                MouseArea {
                                    id: cellMouse; anchors.fill: parent; hoverEnabled: true
                                }
                            }
                        }
                        }
                    }
                }
            }

            // ── Vertical divider ──────────────────────────────────
            Rectangle {
                Layout.preferredWidth: 1; Layout.fillHeight: true
                Layout.topMargin: island.s(8); Layout.bottomMargin: island.s(8)
                Layout.leftMargin: island.s(8); Layout.rightMargin: island.s(8)
                color: Qt.rgba(island.text.r, island.text.g, island.text.b, 0.08)
            }

            // ── Right pane: Weather ──────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
                radius: island.s(16)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: island.s(4)
                    spacing: island.s(10)

                    // ── Loading / error state ────────────────────
                    Item {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        visible: !weatherLoaded

                        ColumnLayout {
                            anchors.centerIn: parent; spacing: island.s(8)
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "󰖔"
                                font.family: island.nerdFont; font.pixelSize: island.s(28)
                                color: weatherError
                                    ? Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.6)
                                    : Qt.rgba(island.surface2.r, island.surface2.g, island.surface2.b, 0.5)
                                RotationAnimation on rotation {
                                    from: 0; to: 360; duration: 3000; loops: Animation.Infinite; running: visible && !weatherError
                                }
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: weatherError ? "Weather unavailable" : "Fetching weather..."
                                font.family: island.monoFont; font.pixelSize: island.s(12)
                                color: island.mocha.overlay0
                            }
                        }
                    }

                    // ── Today's weather card ─────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: island.s(80)
                        visible: weatherLoaded && forecastData.length > 0
                        radius: island.s(14)
                        border.width: 1
                        border.color: Qt.rgba(island.blue.r, island.blue.g, island.blue.b, 0.08)
                        gradient: Gradient {
                            orientation: Gradient.Vertical
                            GradientStop { position: 0.0; color: Qt.rgba(island.surface0.r, island.surface0.g, island.surface0.b, 0.5) }
                            GradientStop { position: 1.0; color: Qt.rgba(island.surface0.r, island.surface0.g, island.surface0.b, 0.3) }
                        }

                        Item {
                            anchors.fill: parent; anchors.margins: island.s(16)

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: island.s(14)

                                Text {
                                    text: (function() { let c = curWeather(); return (c && c.icon) ? c.icon : ""; })()
                                    font.family: island.nerdFont; font.pixelSize: island.s(36)
                                    color: forecastData.length > 0 ? forecastData[0].hex : island.subtext0
                                }

                                ColumnLayout {
                                    spacing: island.s(2)
                                    Text {
                                        text: (function() { let c = curWeather(); return (c && c.temp) ? c.temp + c.unit : "--\u00b0C"; })()
                                        font.family: island.monoFont; font.pixelSize: island.s(28); font.weight: Font.Bold
                                        color: island.peach
                                    }
                                    Text {
                                        text: weatherLoaded && forecastData.length > 0
                                            ? (forecastData[0].desc || "") : "Weather data unavailable"
                                        font.family: island.monoFont; font.pixelSize: island.s(11)
                                        color: island.subtext0; elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                    }

                    // ── Detail chips ─────────────────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: island.s(6)
                        visible: weatherLoaded && forecastData.length > 0

                        Repeater {
                            model: weatherLoaded && forecastData.length > 0 ? [
                                { icon: "󰔄", value: forecastData[0].feels_like + forecastData[0].unit, color: island.subtext0 },
                                { icon: "󰖚", value: forecastData[0].pop + "%", color: island.blue },
                                { icon: "󰕝", value: forecastData[0].wind + " km/h", color: island.green },
                                { icon: "󰉐", value: forecastData[0].humidity + "%", color: island.mocha.sapphire }
                            ] : []

                            delegate: Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: island.s(48)
                                radius: island.s(10)
                                color: chipMouse.containsMouse
                                    ? Qt.rgba(modelData.color.r, modelData.color.g, modelData.color.b, 0.22)
                                    : Qt.rgba(modelData.color.r, modelData.color.g, modelData.color.b, 0.12)
                                Behavior on color { ColorAnimation { duration: 120 } }

                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: island.s(2)
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: modelData.icon
                                        font.family: island.nerdFont; font.pixelSize: island.s(13)
                                        color: modelData.color
                                    }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: modelData.value
                                        font.family: island.monoFont; font.pixelSize: island.s(11); font.weight: Font.Bold
                                        color: island.subtext0
                                    }
                                }

                                MouseArea {
                                    id: chipMouse; anchors.fill: parent; hoverEnabled: true
                                }
                            }
                        }
                    }

                    // ── Hourly forecast ─────────────────────────
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: island.s(4)
                        visible: weatherLoaded && forecastData.length > 0 && forecastData[0].hourly && forecastData[0].hourly.length > 0

                        Text {
                            text: "HOURLY"
                            font.family: island.monoFont; font.pixelSize: island.s(9); font.weight: Font.Bold; font.letterSpacing: 1.2
                            color: island.blue; opacity: 0.7
                        }

                        ListView {
                            Layout.fillWidth: true
                            Layout.preferredHeight: island.s(62)
                            orientation: ListView.Horizontal
                            spacing: island.s(5); clip: true
                            model: forecastData[0].hourly || []

                            delegate: Rectangle {
                                required property var modelData
                                width: island.s(50)
                                Layout.leftMargin: island.s(2)
                                Layout.rightMargin: island.s(2)
                                height: island.s(62)
                                radius: island.s(10)
                                color: hrMouse.containsMouse
                                    ? Qt.rgba(island.surface0.r, island.surface0.g, island.surface0.b, 0.5)
                                    : Qt.rgba(island.surface0.r, island.surface0.g, island.surface0.b, 0.3)
                                Behavior on color { ColorAnimation { duration: 120 } }

                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: island.s(3)
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: modelData.time
                                        font.family: island.monoFont; font.pixelSize: island.s(9)
                                        color: island.mocha.overlay0
                                    }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: modelData.icon || ""
                                        font.family: island.nerdFont; font.pixelSize: island.s(16)
                                        color: modelData.hex || island.subtext0
                                    }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: modelData.temp + (forecastData.length > 0 ? forecastData[0].unit : "\u00b0")
                                        font.family: island.monoFont; font.pixelSize: island.s(10); font.weight: Font.Bold
                                        color: island.peach
                                    }
                                }

                                MouseArea {
                                    id: hrMouse; anchors.fill: parent; hoverEnabled: true
                                }
                            }
                        }
                    }

                    // ── 3-day forecast ───────────────────────────
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: island.s(4)
                        visible: weatherLoaded && forecastData.length > 1

                        Text {
                            text: "FORECAST"
                            font.family: island.monoFont; font.pixelSize: island.s(9); font.weight: Font.Bold; font.letterSpacing: 1.2
                            color: island.peach; opacity: 0.7
                        }

                        Repeater {
                            model: forecastData.slice(1, 4)
                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: island.s(34)
                                radius: island.s(8)
                                color: fcMouse.containsMouse
                                    ? Qt.rgba(island.surface0.r, island.surface0.g, island.surface0.b, 0.4)
                                    : Qt.rgba(island.surface0.r, island.surface0.g, island.surface0.b, 0.2)
                                Behavior on color { ColorAnimation { duration: 120 } }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: island.s(10); anchors.rightMargin: island.s(10)
                                    spacing: island.s(6)

                                    Text {
                                        text: modelData.icon || ""
                                        font.family: island.nerdFont; font.pixelSize: island.s(14)
                                        color: modelData.hex || island.subtext0
                                    }

                                    Text {
                                        Layout.preferredWidth: island.s(28)
                                        text: modelData.day || ""
                                        font.family: island.monoFont; font.pixelSize: island.s(11); font.weight: Font.Bold
                                        color: island.subtext0
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.desc || ""
                                        font.family: island.monoFont; font.pixelSize: island.s(9)
                                        color: island.subtext0; elide: Text.ElideRight
                                    }

                                    Text {
                                        text: modelData.min + modelData.unit
                                        font.family: island.monoFont; font.pixelSize: island.s(10)
                                        color: island.mocha.sapphire
                                    }

                                    Rectangle {
                                        width: island.s(44); height: island.s(4)
                                        radius: island.s(2)
                                        color: Qt.rgba(island.surface1.r, island.surface1.g, island.surface1.b, 0.5)
                                        Rectangle {
                                            anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                                            width: parent.width * Math.min(Math.max((parseFloat(modelData.max) - parseFloat(modelData.min)) / 30, 0.1), 0.95)
                                            radius: island.s(2)
                                            gradient: Gradient {
                                                orientation: Gradient.Horizontal
                                                GradientStop { position: 0.0; color: island.mocha.sapphire }
                                                GradientStop { position: 0.5; color: island.blue }
                                                GradientStop { position: 1.0; color: island.peach }
                                            }
                                        }
                                    }

                                    Text {
                                        text: modelData.max + modelData.unit
                                        font.family: island.monoFont; font.pixelSize: island.s(10); font.weight: Font.Bold
                                        color: island.peach
                                    }
                                }

                                MouseArea {
                                    id: fcMouse; anchors.fill: parent; hoverEnabled: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
