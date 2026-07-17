import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.anchors.top: true
    WlrLayershell.anchors.bottom: true
    WlrLayershell.anchors.left: true
    WlrLayershell.anchors.right: true

    focusable: true
    color: "transparent"
    visible: showing

    MatugenColors {
        id: theme
    }

    property bool open: false
    property bool showing: false
    property bool appsLoaded: false
    property bool appsLoading: false
    property real pulse: 0
    property string pendingSearchText: ""
    property int refreshSerial: 0
    property int activeRefreshSerial: 0
    readonly property int refreshDebounceMs: 120

    function fuzzyScore(name, query) {
        let n = (name || "").toLowerCase()
        let q = (query || "").toLowerCase()

        if (!q)
            return 1
        if (n === q)
            return 4
        if (n.startsWith(q))
            return 3
        if (n.includes(q))
            return 2

        let qi = 0
        for (let i = 0; i < n.length && qi < q.length; ++i) {
            if (n[i] === q[qi])
                ++qi
        }

        return qi === q.length ? 1 : 0
    }

    function appendFilteredApp(app) {
        filteredModel.append({
            name: app.name,
            exec: app.exec,
            icon: app.icon,
            desktop: app.desktop,
            terminal: app.terminal
        })
    }

    function filterApps(query) {
        filteredModel.clear()

        let q = (query || "").trim()
        if (!q) {
            for (let i = 0; i < allAppsModel.count; ++i)
                appendFilteredApp(allAppsModel.get(i))
        } else {
            let scored = []
            for (let i = 0; i < allAppsModel.count; ++i) {
                let app = allAppsModel.get(i)
                let score = fuzzyScore(app.name, q)
                if (score > 0)
                    scored.push({ score: score, app: app })
            }

            scored.sort(function(a, b) {
                return b.score - a.score || a.app.name.localeCompare(b.app.name)
            })

            for (let i = 0; i < scored.length; ++i)
                appendFilteredApp(scored[i].app)
        }

        appList.currentIndex = filteredModel.count > 0 ? 0 : -1
    }

    function cleanExec(execCommand) {
        let cmd = (execCommand || "").trim()
        if (!cmd)
            return ""

        cmd = cmd.replace(/%[uUfFdDnNickvm]/g, "")
        cmd = cmd.replace(/@@[^ ]*/g, "")
        cmd = cmd.replace(/--file-forwarding/g, "")
        cmd = cmd.replace(/\s+/g, " ").trim()

        return cmd
    }

    function launchApp(index) {
        if (index < 0 || index >= filteredModel.count)
            return

        let app = filteredModel.get(index)
        if (!app || !app.exec)
            return

        let cmd = cleanExec(app.exec)
        if (!cmd)
            return

        if (app.terminal)
            cmd = "kitty -e " + cmd

        launchProc.running = false
        launchProc.launchCmd = cmd
        Qt.callLater(function() {
            launchProc.running = true
            root.open = false
        })
    }

    function requestAppsRefresh() {
        pendingSearchText = searchInput.text
        refreshSerial += 1
        refreshDebounce.restart()
    }

    function startAppsRefresh() {
        if (appsLoading) {
            appsProc.running = false
            appsLoading = false
        }

        activeRefreshSerial = refreshSerial
        appsLoading = true
        appsProc.running = false
        appsProc.running = true
    }

    function parseAppsOutput(output) {
        let parsed = []
        let text = output ? output.trim() : ""
        let lines = text ? text.split("\n") : []

        for (let i = 0; i < lines.length; ++i) {
            if (!lines[i])
                continue

            let parts = lines[i].split("\t")
            if (parts.length < 2 || !parts[0])
                continue

            parsed.push({
                name: parts[0],
                exec: parts[1],
                icon: parts[2] || "",
                desktop: parts[3] || "",
                terminal: parts[4] === "true"
            })
        }

        allAppsModel.clear()
        for (let i = 0; i < parsed.length; ++i)
            allAppsModel.append(parsed[i])

        appsLoaded = true
        appsLoading = false
        filterApps(pendingSearchText)

        if (root.open) {
            Qt.callLater(function() {
                searchInput.forceActiveFocus()
            })
        }
    }

    onOpenChanged: {
        if (open) {
            hideTimer.stop()
            showing = true
            searchInput.text = ""
            pendingSearchText = ""
            pulseAnim.restart()
            requestAppsRefresh()
        } else {
            hideTimer.restart()
        }
    }

    Timer {
        id: hideTimer
        interval: 500
        onTriggered: root.showing = false
    }

    Timer {
        id: refreshDebounce
        interval: root.refreshDebounceMs
        repeat: false
        onTriggered: root.startAppsRefresh()
    }

    NumberAnimation {
        id: pulseAnim
        target: root
        property: "pulse"
        from: 0
        to: 1
        duration: 3000
        loops: Animation.Infinite
        easing.type: Easing.InOutSine
    }

    ListModel {
        id: allAppsModel
    }

    ListModel {
        id: filteredModel
    }

    Process {
        id: appsProc
        command: ["bash", "-c", "bash \"" + Quickshell.env("HOME") + "/.config/quickshell/launcher/get_apps.sh\""]
        running: false

        stdout: StdioCollector {
            onStreamFinished: root.parseAppsOutput(this.text)
        }
    }

    Process {
        id: launchProc
        property string launchCmd: ""
        command: ["sh", "-c", launchCmd]
        running: false
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.open = !root.open
        }

        function show(): void {
            root.open = true
        }

        function hide(): void {
            root.open = false
        }

        function refresh(): void {
            root.requestAppsRefresh()
        }
    }

    IpcWatcher {
        watchName: "launcher"
        onOpenRequested: root.open = true
        onCloseRequested: root.open = false
        onToggleRequested: root.open = !root.open
    }

    MenuCard {
        cardOpen: root.open
        onRequestClose: root.open = false
        cardWidth: 560
            cardHeight: Math.max(Math.min(filteredModel.count, 5) * 54 + 84, 200)

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                radius: 14
                color: Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.5)
                border.width: searchInput.activeFocus || searchInput.text.length > 0 ? 2 : 1
                border.color: searchInput.activeFocus || searchInput.text.length > 0
                              ? Qt.rgba(theme.mauve.r, theme.mauve.g, theme.mauve.b, 0.5 + root.pulse * 0.15)
                              : Qt.rgba(theme.surface2.r, theme.surface2.g, theme.surface2.b, 0.15)

                Behavior on border.color {
                    ColorAnimation {
                        duration: 200
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 10

                    Text {
                        text: "\u2315"
                        color: searchInput.activeFocus || searchInput.text.length > 0
                               ? Qt.rgba(theme.mauve.r, theme.mauve.g, theme.mauve.b, 0.8)
                               : theme.subtext0
                        font.pixelSize: 18
                        opacity: searchInput.activeFocus || searchInput.text.length > 0 ? 0.9 : 0.5

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }

                        Behavior on opacity {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                    }

                    TextField {
                        id: searchInput
                        Layout.fillWidth: true
                        color: theme.text
                        placeholderText: "Search applications..."
                        placeholderTextColor: Qt.rgba(theme.subtext0.r, theme.subtext0.g, theme.subtext0.b, 0.3)
                        background: null
                        font.pixelSize: 15
                        verticalAlignment: TextInput.AlignVCenter

                        onTextChanged: {
                            root.pendingSearchText = text
                            root.filterApps(text)
                        }

                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_Up) {
                                appList.decrementCurrentIndex()
                                Qt.callLater(function() {
                                    appList.forceActiveFocus()
                                })
                                event.accepted = true
                            } else if (event.key === Qt.Key_Down) {
                                appList.incrementCurrentIndex()
                                Qt.callLater(function() {
                                    appList.forceActiveFocus()
                                })
                                event.accepted = true
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (appList.count > 0 && appList.currentIndex >= 0)
                                    launchApp(appList.currentIndex)
                                event.accepted = true
                            } else if (event.key === Qt.Key_Escape) {
                                root.open = false
                                text = ""
                                event.accepted = true
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 14
                color: "transparent"
                clip: true

                ListView {
                    id: appList
                    anchors.fill: parent
                    anchors.margins: 2
                    model: filteredModel
                    currentIndex: 0
                    boundsBehavior: Flickable.StopAtBounds
                    focus: root.open && !searchInput.activeFocus

                    onCurrentIndexChanged: {
                        if (currentIndex >= 0)
                            positionViewAtIndex(currentIndex, ListView.Contain)
                    }

                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Up) {
                            decrementCurrentIndex()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Down) {
                            incrementCurrentIndex()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (currentIndex >= 0)
                                launchApp(currentIndex)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Escape) {
                            root.open = false
                            searchInput.text = ""
                            event.accepted = true
                        }
                    }

                    add: Transition {
                        NumberAnimation {
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 250
                            easing.type: Easing.OutCubic
                        }

                        NumberAnimation {
                            property: "scale"
                            from: 0.95
                            to: 1
                            duration: 250
                            easing.type: Easing.OutBack
                        }
                    }

                    delegate: Item {
                        width: appList.width
                        height: 54

                        transform: Translate {
                            id: itemSlide
                            x: -15
                        }

                        Rectangle {
                            id: itemDelegate
                            anchors.fill: parent
                            radius: 12
                            color: appList.currentIndex === index
                                   ? Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.85)
                                   : mouseArea.containsMouse
                                     ? Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.35)
                                     : "transparent"
                            opacity: 1
                            scale: 1

                            Rectangle {
                                visible: appList.currentIndex === index
                                width: 3
                                height: parent.height * 0.55
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                radius: 2

                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: theme.mauve }
                                    GradientStop { position: 0.5; color: Qt.rgba(theme.mauve.r, theme.mauve.g, theme.mauve.b, 0.6) }
                                    GradientStop { position: 1.0; color: theme.mauve }
                                }
                            }

                            Rectangle {
                                visible: appList.currentIndex === index
                                anchors.fill: parent
                                radius: parent.radius
                                color: "transparent"
                                border.width: 1
                                border.color: Qt.rgba(theme.mauve.r, theme.mauve.g, theme.mauve.b, 0.2)
                            }

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 14
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 12

                                Text {
                                    width: parent.width - 14 - 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: model.name
                                    color: appList.currentIndex === index ? theme.text : theme.subtext0
                                    font.pixelSize: 14
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    ripple.x = mouseX - ripple.width / 2
                                    ripple.y = mouseY - ripple.height / 2
                                    ripple.scale = 0
                                    ripple.opacity = 0.4
                                    rippleAnim.restart()
                                    appList.currentIndex = index
                                    launchApp(index)
                                }
                            }

                            Rectangle {
                                id: ripple
                                width: 8
                                height: 8
                                radius: 4
                                color: theme.mauve
                                opacity: 0
                            }
                        }

                        ParallelAnimation {
                            id: fadeInAnim
                            running: true

                            NumberAnimation {
                                target: itemDelegate
                                property: "opacity"
                                from: 0
                                to: 1
                                duration: 300
                                easing.type: Easing.OutCubic
                            }

                            NumberAnimation {
                                target: itemDelegate
                                property: "scale"
                                from: 0.95
                                to: 1
                                duration: 300
                                easing.type: Easing.OutBack
                            }

                            NumberAnimation {
                                target: itemSlide
                                property: "x"
                                from: -15
                                to: 0
                                duration: 300
                                easing.type: Easing.OutCubic
                            }
                        }

                        ParallelAnimation {
                            id: rippleAnim

                            NumberAnimation {
                                target: ripple
                                property: "scale"
                                from: 0
                                to: 8
                                duration: 400
                                easing.type: Easing.OutCubic
                            }

                            NumberAnimation {
                                target: ripple
                                property: "opacity"
                                from: 0.4
                                to: 0
                                duration: 400
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }
        }
    }
