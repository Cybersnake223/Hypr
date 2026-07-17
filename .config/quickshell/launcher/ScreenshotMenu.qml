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

    Timer {
        id: hideTimer
        interval: 500
        onTriggered: root._showing = false
    }

    onOpenChanged: {
        if (open) {
            hideTimer.stop()
            root._showing = true
            menuList.currentIndex = 0
            Qt.callLater(function() { menuList.forceActiveFocus() })
        } else {
            hideTimer.restart()
        }
    }

    ListModel {
        id: menuModel
    }

    Component.onCompleted: {
        menuModel.append({ label: "Capture screen", action: "screen" })
        menuModel.append({ label: "Capture area", action: "area" })
        menuModel.append({ label: "Capture window", action: "window" })
        menuModel.append({ label: "Capture in 5s", action: "5" })
        menuModel.append({ label: "Capture in 10s", action: "10" })
    }

    function selectItem(idx) {
        if (idx < 0 || idx >= menuModel.count)
            return

        let item = menuModel.get(idx)
        root.open = false
        screenshotProc.mode = item.action
        screenshotProc.running = false
        screenshotProc.running = true
    }

    function selectCurrentItem() {
        root.selectItem(menuList.currentIndex)
    }

    Process {
        id: screenshotProc
        property string mode: ""
        command: ["bash", "-c",
            "SAVE_DIR=\"${HOME}/Pictures/Screenshots\"; mkdir -p \"$SAVE_DIR\"; " +
            "FILE=\"$SAVE_DIR/$(date +'%Y-%m-%d_%H-%M-%S').png\"; " +
            "case " + JSON.stringify(screenshotProc.mode) + " in " +
            "screen) sleep 0.2; grim - | tee \"$FILE\" | wl-copy ;; " +
            "area) geo=$(slurp) || exit 0; grim -g \"$geo\" - | tee \"$FILE\" | wl-copy ;; " +
            "window) " +
            "while IFS=': ' read -r key rest; do " +
            "case \"$key\" in at) set -- $rest; x=$1; y=$2 ;; size) set -- $rest; w=$1; h=$2 ;; esac; " +
            "done < <(hyprctl activewindow); " +
            "grim -g \"${x},${y} ${w}x${h}\" - | tee \"$FILE\" | wl-copy ;; " +
            "5|10) " +
            "sec=" + JSON.stringify(screenshotProc.mode) + "; " +
            "while (( sec > 0 )); do notify-send -t 900 \"Screenshot in\" \"$sec s remaining\"; sleep 1; ((sec--)); done; " +
            "sleep 0.2; grim - | tee \"$FILE\" | wl-copy ;; " +
            "esac; notify-send \"Screenshot saved\" \"$FILE\""
        ]
    }

    IpcHandler {
        target: "screenshot"

        function toggle(): void { root.open = !root.open }
        function show(): void { root.open = true }
        function hide(): void { root.open = false }
    }
    IpcWatcher {
        watchName: "screenshot"
        onOpenRequested: root.open = true
        onCloseRequested: root.open = false
        onToggleRequested: root.open = !root.open
    }


    MenuCard {
        cardOpen: root.open
        onRequestClose: root.open = false
        cardWidth: 400
        cardHeight: menuModel.count * 54 + 90

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            spacing: 8

            Text {
                text: "Screenshot"
                color: theme.text
                font.pixelSize: 16
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
                    width: menuList.width
                    height: 54
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

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: model.label
                        color: menuList.currentIndex === index ? theme.text : theme.subtext0
                        font.pixelSize: 13
                        elide: Text.ElideRight
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
