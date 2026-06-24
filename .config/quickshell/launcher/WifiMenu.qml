import QtQuick
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
    visible: _showing

    MatugenColors {
        id: theme
    }

    property bool open: false
    property bool _showing: false
    property string currentPage: "main"
    property string selectedSsid: ""
    property string wifiState: ""
    property int scanSpinner: 0
    property bool isScanning: false

    Timer {
        id: hideTimer
        interval: 500
        onTriggered: root._showing = false
    }

    Timer {
        id: spinnerTimer
        interval: 100
        running: root.isScanning
        repeat: true
        onTriggered: root.scanSpinner = (root.scanSpinner + 1) % 12
    }

    onOpenChanged: {
        if (open) {
            hideTimer.stop()
            root._showing = true
            loadMainMenu()
        } else {
            hideTimer.restart()
        }
    }

    ListModel {
        id: menuModel
    }

    function focusCurrentView() {
        if (!root.open)
            return

        if (currentPage === "password")
            Qt.callLater(function() { passwordInput.forceActiveFocus() })
        else
            Qt.callLater(function() { menuList.forceActiveFocus() })
    }

    function appendRow(label, action, arg, signal) {
        menuModel.append({
            label: label,
            action: action,
            arg: arg,
            signal: signal || -1
        })
    }

    function loadMainMenu() {
        currentPage = "main"
        menuModel.clear()
        appendRow("Connect to Network", "scan", "")
        appendRow("Quick Switch", "quickswitch", "")
        appendRow("Manage Saved Connections", "manage", "")
        appendRow("Disconnected", "", "")
        appendRow("Turn Wi-Fi Off", "toggle", "")
        nmcliState.running = false
        nmcliState.running = true
        currentStatus.running = false
        currentStatus.running = true
        menuList.currentIndex = 0
        focusCurrentView()
    }

    function scanNetworks() {
        currentPage = "scan"
        menuModel.clear()
        root.isScanning = true
        appendRow("Scanning", "", "")
        scanProc.running = false
        scanProc.running = true
        menuList.currentIndex = 0
        focusCurrentView()
    }

    function showQuickSwitch() {
        currentPage = "quickswitch"
        menuModel.clear()
        appendRow("Loading...", "", "")
        quickSwitchProc.running = false
        quickSwitchProc.running = true
        menuList.currentIndex = 0
        focusCurrentView()
    }

    function showManageConnections() {
        currentPage = "manage"
        menuModel.clear()
        appendRow("Loading...", "", "")
        manageListProc.running = false
        manageListProc.running = true
        menuList.currentIndex = 0
        focusCurrentView()
    }

    function toggleWifi() {
        toggleWifiProc.running = false
        toggleWifiProc.running = true
    }

    function connectToSsid(ssid, password) {
        if (password === undefined)
            password = ""

        connectProc.ssid = ssid
        connectProc.password = password
        connectProc.running = false
        connectProc.running = true
    }

    function forgetSsid(ssid) {
        forgetProc.ssid = ssid
        forgetProc.running = false
        forgetProc.running = true
    }

    function disconnectSsid(ssid) {
        disconnectProc.ssid = ssid
        disconnectProc.running = false
        disconnectProc.running = true
    }

    function handleAction(action, arg) {
        if (action === "scan")
            scanNetworks()
        else if (action === "quickswitch")
            showQuickSwitch()
        else if (action === "manage")
            showManageConnections()
        else if (action === "toggle")
            toggleWifi()
        else if (action === "connect")
            showPasswordPrompt(arg)
        else if (action === "connect_saved")
            connectToSsid(arg)
        else if (action === "forget")
            forgetSsid(arg)
        else if (action === "disconnect")
            disconnectSsid(arg)
    }

    function showPasswordPrompt(ssid) {
        currentPage = "password"
        selectedSsid = ssid
        passwordInput.text = ""
        focusCurrentView()
    }

    function submitPassword() {
        connectToSsid(selectedSsid, passwordInput.text)
        passwordInput.text = ""
    }

    function selectCurrentItem() {
        if (currentPage === "password") {
            submitPassword()
            return
        }

        if (menuList.currentIndex < 0 || menuList.currentIndex >= menuModel.count)
            return

        let item = menuModel.get(menuList.currentIndex)
        if (!item || !item.action)
            return

        handleAction(item.action, item.arg)
    }

    Process {
        id: nmcliState
        command: ["bash", "-c", "nmcli -t radio wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiState = this.text.trim()

                if (menuModel.count > 4) {
                    if (root.wifiState === "enabled")
                        menuModel.setProperty(4, "label", "Turn Wi-Fi Off")
                    else
                        menuModel.setProperty(4, "label", "Turn Wi-Fi On")
                }
            }
        }
    }

    Process {
        id: currentStatus
        command: ["bash", "-c",
            "s=$(nmcli -t -f IN-USE,SSID device wifi list 2>/dev/null | awk -F: '$1 == \"*\" {print $2; exit}'); " +
            "[ -n \"$s\" ] && echo \"$s\" || true"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let line = this.text.trim()

                if (menuModel.count > 3) {
                    if (line)
                        menuModel.setProperty(3, "label", "Connected: " + line)
                    else
                        menuModel.setProperty(3, "label", "Disconnected")
                }
            }
        }
    }

    Process {
        id: scanProc
        command: ["bash", "-c",
            "nmcli device wifi rescan 2>/dev/null; " +
            "nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list 2>/dev/null | " +
            "awk -F: '!seen[$2]++ && $2 != \"\" {printf \"%s|%s|%s|%s\\n\", $1, $2, $3, $4}'"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                root.isScanning = false
                menuModel.clear()

                let text = this.text ? this.text.trim() : ""
                let lines = text ? text.split("\n") : []

                for (let i = 0; i < lines.length; i++) {
                    let p = lines[i].split("|")
                    if (p.length >= 2 && p[1]) {
                        let ssid = p[1]
                        let signal = parseInt(p[2]) || 0
                        let sec = p[3] || ""

                        let label = ssid + (sec ? " [" + sec + "]" : "")
                        appendRow(label, "connect", ssid, signal)
                    }
                }

                if (menuModel.count === 0)
                    appendRow("No networks found", "scan", "")

                appendRow("Rescan", "scan", "")
                menuList.currentIndex = 0
                focusCurrentView()
            }
        }
    }

    Process {
        id: connectProc
        property string ssid: ""
        property string password: ""
        command: ["bash", "-c",
            "r=$(nmcli device wifi connect " + JSON.stringify(connectProc.ssid) +
            (connectProc.password ? " password " + JSON.stringify(connectProc.password) : "") +
            " 2>&1) && notify-send -a Wi-Fi \"Wi-Fi\" \"$r\" || notify-send -a Wi-Fi \"Wi-Fi\" \"$r\""
        ]
    }

    Process {
        id: disconnectProc
        property string ssid: ""
        command: ["bash", "-c",
            "nmcli connection down " + JSON.stringify(disconnectProc.ssid) + " 2>&1 | xargs -r notify-send -a Wi-Fi \"Wi-Fi\""
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                loadMainMenu()
            }
        }
    }

    Process {
        id: forgetProc
        property string ssid: ""
        command: ["bash", "-c",
            "nmcli connection delete " + JSON.stringify(forgetProc.ssid) + " 2>&1 | xargs -r notify-send -a Wi-Fi \"Wi-Fi\""
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                loadMainMenu()
            }
        }
    }

    Process {
        id: quickSwitchProc
        command: ["bash", "-c",
            "nmcli -t -f NAME,TYPE connection show 2>/dev/null | awk -F: '$2 ~ /wireless|wifi/ {print $1}' | sort -u"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                menuModel.clear()

                let text = this.text ? this.text.trim() : ""
                let lines = text ? text.split("\n") : []

                for (let i = 0; i < lines.length; i++) {
                    if (lines[i])
                        appendRow(lines[i], "connect_saved", lines[i])
                }

                if (menuModel.count === 0)
                    appendRow("No saved connections", "", "")

                menuList.currentIndex = menuModel.count > 0 ? 0 : -1
                focusCurrentView()
            }
        }
    }

    Process {
        id: manageListProc
        command: ["bash", "-c",
            "nmcli -t -f NAME,TYPE connection show 2>/dev/null | awk -F: '$2 ~ /wireless|wifi/ {print $1}' | sort -u"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                menuModel.clear()

                let text = this.text ? this.text.trim() : ""
                let lines = text ? text.split("\n") : []

                for (let i = 0; i < lines.length; i++) {
                    if (lines[i]) {
                        appendRow(lines[i] + " Connect", "connect_saved", lines[i])
                        appendRow(lines[i] + " Disconnect", "disconnect", lines[i])
                        appendRow(lines[i] + " Forget", "forget", lines[i])
                    }
                }

                if (menuModel.count === 0)
                    appendRow("No saved connections", "", "")

                menuList.currentIndex = menuModel.count > 0 ? 0 : -1
                focusCurrentView()
            }
        }
    }

    Process {
        id: toggleWifiProc
        command: ["bash", "-c",
            "state=$(nmcli radio wifi); " +
            "if [ \"$state\" = \"enabled\" ]; then nmcli radio wifi off; else nmcli radio wifi on; fi"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                loadMainMenu()
            }
        }
    }

    IpcHandler {
        target: "wifi"

        function toggle(): void { root.open = !root.open }
        function show(): void { root.open = true }
        function hide(): void { root.open = false }
    }
IpcWatcher {
        watchName: "wifi"
        onOpenRequested: root.open = true
        onCloseRequested: root.open = false
        onToggleRequested: root.open = !root.open
    }


    MouseArea {
        anchors.fill: parent
        onClicked: root.open = false
    }

    MenuCard {
        cardOpen: root.open
        cardWidth: 520
        cardHeight: Math.min(menuModel.count, 10) * 54 + 90

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            spacing: 8

            Text {
                text: "Wi-Fi"
                color: theme.text
                font.pixelSize: 16
                font.weight: Font.Bold
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                visible: currentPage !== "main"
                height: 28
                implicitWidth: 60
                radius: 8
                color: Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.5)

                Text {
                    anchors.centerIn: parent
                    text: "Back"
                    color: theme.mauve
                    font.pixelSize: 12
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: loadMainMenu()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            clip: true
            visible: currentPage !== "password"

            ListView {
                id: menuList
                anchors.fill: parent
                anchors.margins: 2
                model: menuModel
                currentIndex: 0
                boundsBehavior: Flickable.StopAtBounds
                focus: root.open && currentPage !== "password"

                Keys.onPressed: function(ev) {
                    if (ev.key === Qt.Key_Up) {
                        decrementCurrentIndex()
                        ev.accepted = true
                    } else if (ev.key === Qt.Key_Down) {
                        incrementCurrentIndex()
                        ev.accepted = true
                    } else if (ev.key === Qt.Key_Return || ev.key === Qt.Key_Enter) {
                        root.selectCurrentItem()
                        ev.accepted = true
                    } else if (ev.key === Qt.Key_Escape) {
                        if (currentPage === "main")
                            root.open = false
                        else
                            loadMainMenu()
                        ev.accepted = true
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
                }

                delegate: Rectangle {
                    width: menuList.width
                    height: 50
                    radius: 12

                    color: menuList.currentIndex === index
                           ? Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.85)
                           : mouseArea.containsMouse
                             ? Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.25)
                             : "transparent"

                    Rectangle {
                        visible: menuList.currentIndex === index
                        width: 3
                        height: parent.height * 0.5
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        radius: 2

                        gradient: Gradient {
                            GradientStop {
                                position: 0.0
                                color: theme.mauve
                            }
                            GradientStop {
                                position: 0.5
                                color: Qt.rgba(theme.mauve.r, theme.mauve.g, theme.mauve.b, 0.6)
                            }
                            GradientStop {
                                position: 1.0
                                color: theme.mauve
                            }
                        }
                    }

                    Rectangle {
                        visible: menuList.currentIndex === index
                        anchors.fill: parent
                        radius: parent.radius
                        color: "transparent"
                        border.width: 1
                        border.color: Qt.rgba(theme.mauve.r, theme.mauve.g, theme.mauve.b, 0.15)
                    }

                    RowLayout {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10

                        Text {
                            Layout.fillWidth: true
                            text: model.label + (root.isScanning && model.action === "" ? " " + ["⣾","⣽","⣻","⢿","⡿","⣟","⣯","⣷","⣾","⣽","⣻","⢿"][root.scanSpinner] : "")
                            color: menuList.currentIndex === index ? theme.text : theme.subtext0
                            font.pixelSize: 13
                            elide: Text.ElideRight
                        }

                        Item {
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 14
                            visible: model.signal >= 0

                            Row {
                                anchors.fill: parent
                                spacing: 3

                                Repeater {
                                    model: 5
                                    delegate: Rectangle {
                                        width: 9
                                        height: parent.height
                                        radius: 2
                                        color: {
                                            let barIdx = modelData
                                            let level = model.signal / 20
                                            if (barIdx > level) return Qt.rgba(theme.surface2.r, theme.surface2.g, theme.surface2.b, 0.3)
                                            if (level <= 1) return "#f38ba8"
                                            if (level <= 2) return "#fab387"
                                            return "#a6e3a1"
                                        }
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            ripple.x = mouseX - ripple.width / 2
                            ripple.y = mouseY - ripple.height / 2
                            ripple.scale = 0
                            ripple.opacity = 0.4
                            rippleAnim.restart()
                            menuList.currentIndex = index
                            if (model.action)
                                root.handleAction(model.action, model.arg)
                        }

                        Rectangle {
                            id: ripple
                            width: 8; height: 8
                            radius: 4
                            color: theme.mauve
                            opacity: 0

                            NumberAnimation {
                                id: rippleAnim
                                target: ripple
                                property: "scale"
                                from: 0; to: 8
                                duration: 400
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                target: ripple
                                property: "opacity"
                                from: 0.4; to: 0
                                duration: 400
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            visible: currentPage === "password"
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "Password for: " + root.selectedSsid
                color: theme.subtext0
                font.pixelSize: 13
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                radius: 14
                color: Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.5)
                border.width: passwordInput.activeFocus ? 2 : 1
                border.color: passwordInput.activeFocus
                              ? Qt.rgba(theme.mauve.r, theme.mauve.g, theme.mauve.b, 0.5)
                              : Qt.rgba(theme.surface2.r, theme.surface2.g, theme.surface2.b, 0.15)

                Behavior on border.color {
                    ColorAnimation {
                        duration: 200
                    }
                }

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    color: theme.text
                    font.pixelSize: 14
                    echoMode: TextInput.Password
                    verticalAlignment: TextInput.AlignVCenter
                    selectionColor: Qt.rgba(theme.mauve.r, theme.mauve.g, theme.mauve.b, 0.35)
                    onAccepted: root.submitPassword()

                    Keys.onEscapePressed: function(ev) {
                        loadMainMenu()
                        ev.accepted = true
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: 14
                color: Qt.rgba(theme.mauve.r, theme.mauve.g, theme.mauve.b, 0.15)

                Text {
                    anchors.centerIn: parent
                    text: "Connect"
                    color: theme.mauve
                    font.pixelSize: 14
                    font.weight: Font.Bold
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.submitPassword()
                }
            }
        }
    }
}
