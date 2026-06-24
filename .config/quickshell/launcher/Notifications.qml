import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import Quickshell.Io

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.exclusiveZone: 0
    WlrLayershell.anchors.top: true
    WlrLayershell.anchors.right: true

    exclusionMode: ExclusionMode.Ignore
    focusable: false
    color: "transparent"

    visible: activePopups.count > 0
    implicitWidth: activePopups.count > 0 ? 392 : 1
    implicitHeight: activePopups.count > 0 ? popupColumn.implicitHeight + 16 : 1

    MatugenColors {
        id: theme
    }

    ListModel {
        id: activePopups
    }

    property int popupCounter: 0
    property int popupTimeout: 5000
    property int maxPopups: 5

    function removePopup(uid, animated) {
        if (animated === false) {
            for (let i = 0; i < activePopups.count; i++) {
                if (activePopups.get(i).uid === uid) {
                    activePopups.remove(i)
                    return
                }
            }
        }
        for (let i = 0; i < activePopups.count; i++) {
            if (activePopups.get(i).uid === uid) {
                activePopups.setProperty(i, "dismissing", true)
                dismissTimer.uid = uid
                dismissTimer.restart()
                return
            }
        }
    }

    Timer {
        id: dismissTimer
        property int uid: -1
        interval: 300
        onTriggered: {
            for (let i = 0; i < activePopups.count; i++) {
                if (activePopups.get(i).uid === uid) {
                    activePopups.remove(i)
                    return
                }
            }
        }
    }

    function dismissAll() {
        activePopups.clear()
    }

    function normalizeIconSource(path) {
        if (!path || path === "")
            return ""

        if (path.startsWith("file://")
                || path.startsWith("image://")
                || path.startsWith("http://")
                || path.startsWith("https://")) {
            return path
        }

        if (path.startsWith("/"))
            return "file://" + path

        return path
    }

    IpcHandler {
        target: "notifications"

        function dismissAll() {
            root.dismissAll()
        }
    }

    NotificationServer {
        id: notifServer

        bodySupported: true
        actionsSupported: false
        imageSupported: true

        onNotification: n => {
            let iconUrl = ""

            if (n.image && n.image.source && n.image.source.toString() !== "")
                iconUrl = n.image.source.toString()
            else if (n.appIcon && n.appIcon !== "")
                iconUrl = n.appIcon

            root.popupCounter++

            activePopups.append({
                uid: root.popupCounter,
                appName: n.appName !== "" ? n.appName : "System",
                summary: n.summary !== "" ? n.summary : "No Title",
                body: n.body !== "" ? n.body : "",
                iconSource: root.normalizeIconSource(iconUrl),
                dismissing: false,
                dragX: 0
            })

            while (activePopups.count > root.maxPopups)
                activePopups.remove(0)
        }
    }

    ColumnLayout {
        id: popupColumn
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 12
        spacing: 8

        Repeater {
            model: activePopups

            delegate: Rectangle {
                id: notifCard

                required property int uid
                required property string appName
                required property string summary
                required property string body
                required property string iconSource
                required property bool dismissing
                required property real dragX

                Layout.preferredWidth: 380
                Layout.preferredHeight: contentLayout.implicitHeight + 24 + 3

                radius: 16
                color: Qt.rgba(theme.base.r, theme.base.g, theme.base.b, 0.85)
                border.width: 3
                border.color: Qt.rgba(theme.tertiaryContainer.r, theme.tertiaryContainer.g, theme.tertiaryContainer.b, 0.4)
                clip: true

                opacity: 0
                scale: 0.92
                property real notifSlide: -20
                property real elapsed: 0

                transform: Translate {
                    x: notifCard.dragX
                    y: notifCard.notifSlide
                }

                Behavior on opacity {
                    NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                }
                Behavior on scale {
                    NumberAnimation { duration: 260; easing.type: Easing.OutBack }
                }
                Behavior on notifSlide {
                    NumberAnimation { duration: 260; easing.type: Easing.OutBack }
                }

                Component.onCompleted: {
                    opacity = 1
                    scale = 1
                    notifSlide = 0
                    autoDismiss.restart()
                }

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: Qt.rgba(0, 0, 0, 0.5)
                    shadowBlur: 0.6
                    shadowHorizontalOffset: 0
                    shadowVerticalOffset: 4
                    shadowOpacity: 0.6
                }

                Timer {
                    id: autoDismiss
                    interval: root.popupTimeout
                    repeat: false
                    onTriggered: {
                        notifCard.elapsed = root.popupTimeout
                        root.removePopup(notifCard.uid)
                    }
                }

                Timer {
                    interval: 50
                    repeat: true
                    running: !notifCard.dismissing
                    onTriggered: {
                        notifCard.elapsed = Math.min(notifCard.elapsed + 50, root.popupTimeout)
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(theme.mauve.r, theme.mauve.g, theme.mauve.b, 0.04) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                Rectangle {
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                    height: parent.height * 0.4
                    radius: 16
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.08) }
                        GradientStop { position: 0.6; color: "transparent" }
                    }
                }
                Canvas {
                    id: borderCanvas
                    anchors.fill: parent
                    contextType: "2d"

                    property real progress: 1 - (notifCard.elapsed / root.popupTimeout)
                    onProgressChanged: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)

                        var lw = 3, r = 14
                        var x = lw / 2, y = lw / 2
                        var w = width - lw, h = height - lw

                        ctx.lineWidth = lw
                        ctx.lineCap = "round"

                        var p = Math.max(0, Math.min(1, progress))
                        if (p <= 0) return

                        var perimeter = 2 * (w + h) - 8 * r + 2 * Math.PI * r

                        // Background track
                        ctx.beginPath()
                        ctx.moveTo(x + r, y)
                        ctx.lineTo(x + w - r, y)
                        ctx.arcTo(x + w, y, x + w, y + r, r)
                        ctx.lineTo(x + w, y + h - r)
                        ctx.arcTo(x + w, y + h, x + w - r, y + h, r)
                        ctx.lineTo(x + r, y + h)
                        ctx.arcTo(x, y + h, x, y + h - r, r)
                        ctx.lineTo(x, y + r)
                        ctx.arcTo(x, y, x + r, y, r)
                        ctx.closePath()
                        ctx.globalAlpha = 0.12
                        ctx.strokeStyle = theme.mauve.toString()
                        ctx.stroke()
                        ctx.globalAlpha = 1.0

                        // Progress arc
                        var drawLen = Math.max(0.01, perimeter * p)
                        ctx.beginPath()
                        ctx.moveTo(x + r, y)
                        ctx.lineTo(x + w - r, y)
                        ctx.arcTo(x + w, y, x + w, y + r, r)
                        ctx.lineTo(x + w, y + h - r)
                        ctx.arcTo(x + w, y + h, x + w - r, y + h, r)
                        ctx.lineTo(x + r, y + h)
                        ctx.arcTo(x, y + h, x, y + h - r, r)
                        ctx.lineTo(x, y + r)
                        ctx.arcTo(x, y, x + r, y, r)
                        ctx.closePath()
                        ctx.setLineDash([drawLen, perimeter])
                        ctx.lineDashOffset = -perimeter * 0.25
                        ctx.strokeStyle = theme.mauve.toString()
                        ctx.stroke()
                    }
                }


                // Slide-out state
                states: State {
                    name: "dismissing"; when: notifCard.dismissing
                    PropertyChanges { target: notifCard; opacity: 0; scale: 0.85; notifSlide: 40 }
                }
                transitions: Transition {
                    to: "dismissing"
                    NumberAnimation { properties: "opacity,scale,notifSlide"; duration: 250; easing.type: Easing.OutCubic }
                }

                RowLayout {
                    id: contentLayout
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Item {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        Layout.alignment: Qt.AlignTop

                        Image {
                            id: notifIcon
                            anchors.fill: parent
                            source: notifCard.iconSource
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true; smooth: true
                            visible: status === Image.Ready
                        }

                        Rectangle {
                            anchors.fill: parent; radius: 10
                            visible: notifIcon.status !== Image.Ready
                            color: Qt.rgba(theme.surface1.r, theme.surface1.g, theme.surface1.b, 0.6)

                            Text {
                                anchors.centerIn: parent
                                text: notifCard.appName.length > 0 ? notifCard.appName.charAt(0).toUpperCase() : "?"
                                font.pixelSize: 16; font.weight: Font.Black; color: theme.subtext0
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: notifCard.appName
                            color: theme.text; font.pixelSize: 12; font.weight: Font.Bold; elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: notifCard.summary
                            color: theme.text; font.pixelSize: 13; font.weight: Font.DemiBold; elide: Text.ElideRight
                            visible: text !== ""
                        }
                        Text {
                            Layout.fillWidth: true
                            text: notifCard.body
                            color: theme.subtext0; font.pixelSize: 12
                            wrapMode: Text.WordWrap; maximumLineCount: 2; elide: Text.ElideRight
                            visible: text !== ""
                        }
                    }

                    Item {
                        Layout.preferredWidth: 24; Layout.preferredHeight: 24; Layout.alignment: Qt.AlignTop

                        Text {
                            anchors.centerIn: parent
                            text: "\u2716"; color: theme.subtext0; font.pixelSize: 12
                            opacity: closeArea.containsMouse ? 0.9 : 0.45
                        }

                        MouseArea {
                            id: closeArea
                            anchors.fill: parent; hoverEnabled: true
                            onEntered: autoDismiss.stop()
                            onExited: autoDismiss.restart()
                            onClicked: root.removePopup(notifCard.uid)
                        }
                    }
                }

                // Swipe to dismiss
                property real swipeStartX: 0
                property bool swiping: false

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    hoverEnabled: true
                    onEntered: autoDismiss.stop()
                    onExited: { if (!notifCard.swiping) autoDismiss.restart() }
                    onClicked: root.removePopup(notifCard.uid)

                    onPressed: { notifCard.swipeStartX = mouseX; notifCard.swiping = true }
                    onPositionChanged: {
                        let dx = mouseX - notifCard.swipeStartX
                        if (dx > 0) dx = 0
                        notifCard.dragX = dx
                        notifCard.opacity = 1 - Math.min(Math.abs(dx) / 380, 0.5)
                        notifCard.scale = 0.95 + 0.05 * (1 - Math.min(Math.abs(dx) / 380, 1))
                    }
                    onReleased: {
                        notifCard.swiping = false
                        if (Math.abs(notifCard.dragX) > 100) {
                            root.removePopup(notifCard.uid)
                        } else {
                            notifCard.dragX = 0
                            notifCard.opacity = 1
                            notifCard.scale = 1
                            autoDismiss.restart()
                        }
                    }
                }
            }
        }
    }
}
