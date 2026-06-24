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
    property bool confirmMode: false
    property string pendingAction: ""
    property string uptime: "..."
    property int confirmIndex: 0
    property int confirmCountdown: 5

    Timer {
        id: hideTimer
        interval: 500
        onTriggered: root._showing = false
    }

    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        running: confirmMode && root.confirmCountdown > 0
        onTriggered: {
            root.confirmCountdown--
            if (root.confirmCountdown <= 0)
                root.confirmYes()
        }
    }

    onOpenChanged: {
        if (open) {
            hideTimer.stop()
            root._showing = true
            confirmMode = false
            pendingAction = ""
            confirmIndex = 0
            confirmCountdown = 5
            list.currentIndex = 0
            Qt.callLater(function() { keyCatcher.forceActiveFocus() })
            uptimeProc.running = false
            uptimeProc.running = true
        } else {
            hideTimer.restart()
        }
    }

    ListModel {
        id: m
    }

    Component.onCompleted: {
        m.append({ label: "Shutdown", action: "shutdown" })
        m.append({ label: "Reboot", action: "reboot" })
        m.append({ label: "Lock", action: "lock" })
        m.append({ label: "Suspend", action: "suspend" })
        m.append({ label: "Log Out", action: "logout" })
    }

    function selectItem(idx) {
        if (idx < 0 || idx >= m.count)
            return

        let item = m.get(idx)

        if (item.action === "shutdown" || item.action === "reboot") {
            pendingAction = item.action
            confirmMode = true
            confirmIndex = 0
            confirmCountdown = 5
            Qt.callLater(function() { keyCatcher.forceActiveFocus() })
        } else {
            executeAction(item.action)
        }
    }

    function executeAction(action) {
        root.open = false
        powerProc.action = action
        powerProc.running = false
        powerProc.running = true
    }

    function confirmYes() {
        confirmMode = false
        executeAction(pendingAction)
    }

    function confirmNo() {
        confirmMode = false
        pendingAction = ""
        confirmIndex = 0
        Qt.callLater(function() { keyCatcher.forceActiveFocus() })
    }

    function selectCurrentItem() {
        if (confirmMode) {
            if (confirmIndex === 0)
                confirmYes()
            else
                confirmNo()
        } else {
            root.selectItem(list.currentIndex)
        }
    }

    Item {
        id: keyCatcher
        visible: true
        focus: true
        width: 0
        height: 0

        Keys.onUpPressed: function(ev) {
            if (!confirmMode)
                list.decrementCurrentIndex()
            ev.accepted = true
        }

        Keys.onDownPressed: function(ev) {
            if (!confirmMode)
                list.incrementCurrentIndex()
            ev.accepted = true
        }

        Keys.onLeftPressed: function(ev) {
            if (confirmMode) {
                confirmIndex = 0
                ev.accepted = true
            }
        }

        Keys.onRightPressed: function(ev) {
            if (confirmMode) {
                confirmIndex = 1
                ev.accepted = true
            }
        }

        Keys.onTabPressed: function(ev) {
            if (confirmMode) {
                confirmIndex = confirmIndex === 0 ? 1 : 0
                ev.accepted = true
            }
        }

        Keys.onReturnPressed: function(ev) {
            root.selectCurrentItem()
            ev.accepted = true
        }

        Keys.onEscapePressed: function(ev) {
            if (confirmMode)
                confirmNo()
            else
                root.open = false
            ev.accepted = true
        }
    }

    Process {
        id: uptimeProc
        command: ["bash", "-c", "uptime -p | sed 's/up //g'"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.uptime = this.text.trim()
            }
        }
    }

    Process {
        id: powerProc
        property string action: ""
        command: ["bash", "-c",
            "case " + JSON.stringify(powerProc.action) + " in " +
            "shutdown) systemctl poweroff ;; " +
            "reboot) systemctl reboot ;; " +
            "lock) hyprlock ;; " +
            "suspend) systemctl suspend ;; " +
            "logout) pkill hyprland ;; " +
            "esac"
        ]
    }

    IpcHandler {
        target: "powermenu"

        function toggle() {
            root.open = !root.open
        }

        function show() {
            root.open = true
        }

        function hide() {
            root.open = false
        }
    }
    IpcWatcher {
        watchName: "powermenu"
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
        cardWidth: 380
        cardHeight: confirmMode ? 140 : m.count * 54 + 90

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            spacing: 8

            Text {
                text: "Power Menu"
                color: theme.text
                font.pixelSize: 16
                font.weight: Font.Bold
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: root.uptime
                color: theme.subtext0
                font.pixelSize: 11
                opacity: 0.6
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            clip: true
            visible: !confirmMode

            ListView {
                id: list
                anchors.fill: parent
                anchors.margins: 2
                model: m
                currentIndex: 0
                boundsBehavior: Flickable.StopAtBounds

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
                    width: list.width
                    height: 50
                    radius: 12

                    color: list.currentIndex === index
                           ? Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.85)
                           : mouseArea.containsMouse
                             ? Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.25)
                             : "transparent"

                    Rectangle {
                        visible: list.currentIndex === index
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
                        visible: list.currentIndex === index
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
                        spacing: 12

                        Text {
                            text: model.label
                            color: list.currentIndex === index ? theme.text : theme.subtext0
                            font.pixelSize: 14
                            elide: Text.ElideRight
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: model.action === "shutdown" || model.action === "reboot" ? "\u203A" : ""
                            color: theme.subtext0
                            font.pixelSize: 16
                            opacity: 0.3
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
                            list.currentIndex = index
                            root.selectItem(index)
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
            visible: confirmMode
            Layout.fillWidth: true
            spacing: 12

            Text {
                Layout.fillWidth: true
                text: (pendingAction === "shutdown" ? "Shut down" : "Reboot") + " in " + root.confirmCountdown + "s"
                color: theme.text
                font.pixelSize: 15
                font.weight: Font.DemiBold
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    radius: 14
                    color: confirmIndex === 0
                           ? Qt.rgba(0.8, 0.2, 0.2, 0.30)
                           : Qt.rgba(0.8, 0.2, 0.2, 0.20)

                    Text {
                        anchors.centerIn: parent
                        text: "Yes"
                        color: "#ff6b6b"
                        font.pixelSize: 14
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.confirmYes()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    radius: 14
                    color: confirmIndex === 1
                           ? Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.72)
                           : Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.50)

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: theme.subtext0
                        font.pixelSize: 14
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.confirmNo()
                    }
                }
            }
        }
    }
}
