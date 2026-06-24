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
    property string selectedDevice: ""
    property string btState: ""
    property bool isScanning: false
    property int scanSpinner: 0

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

    function appendRow(label, action, arg) {
        menuModel.append({
            label: label,
            action: action,
            arg: arg
        })
      }

    function loadMainMenu() {
        currentPage = "main"
        menuModel.clear()
        appendRow("Scan for devices", "scan", "")
        appendRow("Quick Switch", "quickswitch", "")
        appendRow("Manage paired devices", "manage", "")
        appendRow("Disconnected", "", "")
        appendRow("Turn Bluetooth Off", "toggle", "")
        btStateProc.running = false
        btStateProc.running = true
        currentStatusProc.running = false
        currentStatusProc.running = true
        menuList.currentIndex = 0
        focusCurrentView()
    }

    function scanDevices() {
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

    function showManageDevices() {
        currentPage = "manage"
        menuModel.clear()
        appendRow("Loading...", "", "")
        manageListProc.running = false
        manageListProc.running = true
        menuList.currentIndex = 0
        focusCurrentView()
    }

    function toggleBluetooth() {
        toggleBtProc.running = false
        toggleBtProc.running = true
    }

    function connectToDevice(mac) {
        connectProc.mac = mac
        connectProc.running = false
        connectProc.running = true
    }

    function disconnectDevice(mac) {
        disconnectProc.mac = mac
        disconnectProc.running = false
        disconnectProc.running = true
    }

    function pairDevice(mac) {
        pairProc.mac = mac
        pairProc.running = false
        pairProc.running = true
    }

    function removeDevice(mac) {
        removeProc.mac = mac
        removeProc.running = false
        removeProc.running = true
    }

    function handleAction(action, arg) {
        if (action === "scan")
            scanDevices()
        else if (action === "quickswitch")
            showQuickSwitch()
        else if (action === "manage")
            showManageDevices()
        else if (action === "toggle")
            toggleBluetooth()
        else if (action === "connect")
            connectToDevice(arg)
        else if (action === "disconnect")
            disconnectDevice(arg)
        else if (action === "pair")
            pairDevice(arg)
        else if (action === "remove")
            removeDevice(arg)
    }

    function selectCurrentItem() {
        if (menuList.currentIndex < 0 || menuList.currentIndex >= menuModel.count)
            return

        let item = menuModel.get(menuList.currentIndex)
        if (!item || !item.action)
            return

        handleAction(item.action, item.arg)
    }

    Process {
        id: btStateProc
        command: ["bash", "-c",
            "s=$(bluetoothctl show 2>/dev/null | grep -o 'Powered: \\(yes\\|no\\)' | awk '{print $2}'); " +
            "[ \"$s\" = \"yes\" ] && echo on || echo off"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                root.btState = this.text.trim()
                if (menuModel.count > 4) {
                    if (root.btState === "on")
                        menuModel.setProperty(4, "label", "Turn Bluetooth Off")
                    else
                        menuModel.setProperty(4, "label", "Turn Bluetooth On")
                }
            }
        }
    }

    Process {
        id: currentStatusProc
        command: ["bash", "-c",
            "devices=$(bluetoothctl devices Connected 2>/dev/null | awk '{$1=\"\"; $2=\"\"; print substr($0,3)}' | paste -sd, -); " +
            "echo \"${devices:-}\""
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
            "bluetoothctl --timeout 3 scan on 2>/dev/null >/dev/null; " +
            "bluetoothctl devices 2>/dev/null | awk '{for(i=3;i<=NF;i++) printf \"%s%s\", (i>3?OFS:\"\"), $i; print \"|\" $2}' | sort -u"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                root.isScanning = false
                menuModel.clear()

                let text = this.text ? this.text.trim() : ""
                let lines = text ? text.split("\n") : []

                let seen = new Set()
                for (let i = 0; i < lines.length; i++) {
                    let p = lines[i].split("|")
                    if (p.length >= 2 && p[1]) {
                        let name = p[0].trim()
                        let mac = p[1].trim()
                        if (!name || name === "" || name.startsWith("Device"))
                            name = mac
                        if (seen.has(mac))
                            continue
                        seen.add(mac)
                        appendRow(name, "connect", mac)
                    }
                }

                if (menuModel.count === 0)
                    appendRow("No devices found", "", "")

                appendRow("Rescan", "scan", "")
                menuList.currentIndex = 0
                focusCurrentView()
            }
        }
    }

    Process {
        id: connectProc
        property string mac: ""
        command: ["bash", "-c",
            "r=$(bluetoothctl connect " + JSON.stringify(connectProc.mac) + " 2>&1) && " +
            "notify-send -a Bluetooth \"Bluetooth\" \"Connected\" || " +
            "notify-send -a Bluetooth \"Bluetooth\" \"Connection failed\""
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                loadMainMenu()
            }
        }
    }

    Process {
        id: disconnectProc
        property string mac: ""
        command: ["bash", "-c",
            "bluetoothctl disconnect " + JSON.stringify(disconnectProc.mac) + " 2>&1 | xargs -r notify-send -a Bluetooth \"Bluetooth\""
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                loadMainMenu()
            }
        }
    }

    Process {
        id: pairProc
        property string mac: ""
        command: ["bash", "-c",
            "r=$(bluetoothctl pair " + JSON.stringify(pairProc.mac) + " 2>&1) && " +
            "notify-send -a Bluetooth \"Bluetooth\" \"Paired successfully\" || " +
            "notify-send -a Bluetooth \"Bluetooth\" \"Pairing failed\""
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                loadMainMenu()
            }
        }
    }

    Process {
        id: removeProc
        property string mac: ""
        command: ["bash", "-c",
            "bluetoothctl remove " + JSON.stringify(removeProc.mac) + " 2>&1 | xargs -r notify-send -a Bluetooth \"Bluetooth\""
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
            "bluetoothctl devices 2>/dev/null | awk '{for(i=3;i<=NF;i++) printf \"%s%s\", (i>3?OFS:\"\"), $i; print \"|\" $2}' | sort -u"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                menuModel.clear()

                let text = this.text ? this.text.trim() : ""
                let lines = text ? text.split("\n") : []

                for (let i = 0; i < lines.length; i++) {
                    let p = lines[i].split("|")
                    if (p.length >= 2 && p[1]) {
                        let name = p[0].trim()
                        let mac = p[1].trim()
                        if (!name || name === "" || name.startsWith("Device"))
                            name = mac
                        appendRow(name, "connect", mac)
                    }
                }

                if (menuModel.count === 0)
                    appendRow("No paired devices", "", "")

                menuList.currentIndex = menuModel.count > 0 ? 0 : -1
                focusCurrentView()
            }
        }
    }

    Process {
        id: manageListProc
        command: ["bash", "-c",
            "bluetoothctl devices 2>/dev/null | awk '{for(i=3;i<=NF;i++) printf \"%s%s\", (i>3?OFS:\"\"), $i; print \"|\" $2}' | sort -u"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                menuModel.clear()

                let text = this.text ? this.text.trim() : ""
                let lines = text ? text.split("\n") : []

                for (let i = 0; i < lines.length; i++) {
                    let p = lines[i].split("|")
                    if (p.length >= 2 && p[1]) {
                        let name = p[0].trim()
                        let mac = p[1].trim()
                        if (!name || name === "" || name.startsWith("Device"))
                            name = mac
                        appendRow(name + " Connect", "connect", mac)
                        appendRow(name + " Disconnect", "disconnect", mac)
                        appendRow(name + " Forget", "remove", mac)
                    }
                }

                if (menuModel.count === 0)
                    appendRow("No paired devices", "", "")

                menuList.currentIndex = menuModel.count > 0 ? 0 : -1
                focusCurrentView()
            }
        }
    }

    Process {
        id: toggleBtProc
        command: ["bash", "-c",
            "state=$(bluetoothctl show 2>/dev/null | grep -o 'Powered: \\(yes\\|no\\)' | awk '{print $2}'); " +
            "if [ \"$state\" = \"yes\" ]; then bluetoothctl power off; else bluetoothctl power on; fi"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                loadMainMenu()
            }
        }
    }

    IpcHandler {
        target: "bluetooth"

        function toggle(): void { root.open = !root.open }
        function show(): void { root.open = true }
        function hide(): void { root.open = false }
    }
    IpcWatcher {
        watchName: "bluetooth"
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
                text: "Bluetooth"
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

            ListView {
                id: menuList
                anchors.fill: parent
                anchors.margins: 2
                model: menuModel
                currentIndex: 0
                boundsBehavior: Flickable.StopAtBounds
                focus: root.open

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
    }
}
