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
    visible: showing

    MatugenColors {
        id: theme
    }

    property bool open: false
    property bool showing: false

    Timer {
        id: hideTimer
        interval: 500
        onTriggered: root.showing = false
    }

    onOpenChanged: {
        if (open) {
            hideTimer.stop()
            root.showing = true
            loadClipboard()
            Qt.callLater(() => list.forceActiveFocus())
        } else {
            hideTimer.restart()
        }
    }

    ListModel {
        id: m
    }

    function loadClipboard() {
        m.clear()
        m.append({ label: "Loading...", clipIndex: -1 })
        listProc.running = false
        listProc.running = true
    }

    function selectItem(idx) {
        if (idx < 0 || idx >= m.count)
            return

        let item = m.get(idx)
        if (item.clipIndex < 0)
            return

        copyProc.clipIndex = item.clipIndex
        copyProc.running = false
        copyProc.running = true
        root.open = false
    }

    function selectCurrentItem() {
        root.selectItem(list.currentIndex)
    }

    Process {
        id: listProc
        command: ["bash", "-c", "cliphist list 2>/dev/null | head -50 || true"]
        stdout: StdioCollector {
            onStreamFinished: {
                m.clear()

                let text = this.text ? this.text.trim() : ""
                let lines = text ? text.split("\n") : []

                for (let i = 0; i < lines.length; i++) {
                    let line = lines[i].trim()
                    if (!line)
                        continue

                    let tab = line.indexOf("\t")
                    if (tab < 0)
                        continue

                    let clipIdx = parseInt(line.substring(0, tab))
                    let content = line.substring(tab + 1).trim()

                    if (content.length > 80)
                        content = content.substring(0, 77) + "..."

                    m.append({
                        label: content,
                        clipIndex: clipIdx
                    })
                }

                if (m.count === 0) {
                    m.append({
                        label: "Clipboard is empty",
                        clipIndex: -1
                    })
                }

                list.currentIndex = 0
                Qt.callLater(() => list.forceActiveFocus())
            }
        }
    }

    Process {
        id: copyProc
        property int clipIndex: -1
        command: [
            "bash",
            "-c",
            "cliphist decode " + copyProc.clipIndex + " | wl-copy && notify-send 'Clipboard' 'Copied item " + copyProc.clipIndex + "'"
        ]
    }

    IpcHandler {
        target: "clipboard"

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
        watchName: "clipboard"
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
        cardHeight: Math.min(m.count, 8) * 48 + 80

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            spacing: 8

            Text {
                text: "Clipboard"
                color: theme.text
                font.pixelSize: 15
                font.weight: Font.Bold
            }

            Item {
                Layout.fillWidth: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            clip: true

            ListView {
                id: list
                anchors.fill: parent
                anchors.margins: 2
                model: m
                currentIndex: 0
                focus: true
                boundsBehavior: Flickable.StopAtBounds

                Keys.enabled: root.open
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
                        root.open = false
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
                    width: list.width
                    height: 44
                    radius: 10

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

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: model.label
                        color: list.currentIndex === index ? theme.text : theme.subtext0
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    Rectangle {
                        id: copiedFlash
                        anchors.fill: parent
                        radius: parent.radius
                        color: Qt.rgba(theme.mauve.r, theme.mauve.g, theme.mauve.b, 0.15)
                        opacity: 0
                        visible: opacity > 0

                        Text {
                            anchors.centerIn: parent
                            text: "Copied!"
                            color: theme.mauve
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }

                        NumberAnimation on opacity {
                            id: copiedAnim
                            from: 1; to: 0; duration: 600
                            easing.type: Easing.OutCubic
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
                            copiedFlash.opacity = 1
                            copiedAnim.restart()
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
    }
}
