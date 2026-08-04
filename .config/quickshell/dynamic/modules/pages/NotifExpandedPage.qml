import QtQuick
import QtQuick.Layouts
import "../WindowRegistry.js" as Registry

Item {
    id: root
    property var island

    Item {
        id: contentWrap
        anchors.fill: parent
        anchors.margins: island.s(14)

        transform: Translate {
            y: island.notifActive ? 0 : island.s(-8)
            Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutBack; easing.overshoot: 1.15 } }
        }

        property real iconOpacity: 0.0
        property real iconScale: 0.7
        property real dotOpacity: 0.0
        property real appNameOpacity: 0.0
        property real titleOpacity: 0.0
        property real bodyOpacity: 0.0
        property real dismissOpacity: 0.0
        property real dismissScale: 0.6

        SequentialAnimation {
            id: notifEntryAnim
            onRunningChanged: {
                if (running) notifExitAnim.stop()
            }
            running: island.notifActive
            ParallelAnimation {
                NumberAnimation { target: contentWrap; property: "iconOpacity"; to: 1.0; duration: 150; easing.type: Easing.OutCubic }
                NumberAnimation { target: contentWrap; property: "iconScale"; to: 1.0; duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
            }
            PauseAnimation { duration: 50 }
            ParallelAnimation {
                NumberAnimation { target: contentWrap; property: "dotOpacity"; to: 1.0; duration: 150; easing.type: Easing.OutCubic }
                NumberAnimation { target: contentWrap; property: "appNameOpacity"; to: 1.0; duration: 150; easing.type: Easing.OutCubic }
            }
            PauseAnimation { duration: 50 }
            NumberAnimation { target: contentWrap; property: "titleOpacity"; to: 1.0; duration: 150; easing.type: Easing.OutCubic }
            PauseAnimation { duration: 50 }
            NumberAnimation { target: contentWrap; property: "bodyOpacity"; to: 1.0; duration: 150; easing.type: Easing.OutCubic }
            PauseAnimation { duration: 50 }
            ParallelAnimation {
                NumberAnimation { target: contentWrap; property: "dismissOpacity"; to: 1.0; duration: 150; easing.type: Easing.OutCubic }
                NumberAnimation { target: contentWrap; property: "dismissScale"; to: 1.0; duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
            }
        }

        SequentialAnimation {
            id: notifExitAnim
            onRunningChanged: {
                if (running) notifEntryAnim.stop()
            }
            running: !island.notifActive
            ParallelAnimation {
                NumberAnimation { target: contentWrap; property: "iconOpacity"; to: 0.0; duration: 100; easing.type: Easing.InCubic }
                NumberAnimation { target: contentWrap; property: "dotOpacity"; to: 0.0; duration: 100; easing.type: Easing.InCubic }
                NumberAnimation { target: contentWrap; property: "appNameOpacity"; to: 0.0; duration: 100; easing.type: Easing.InCubic }
                NumberAnimation { target: contentWrap; property: "titleOpacity"; to: 0.0; duration: 100; easing.type: Easing.InCubic }
                NumberAnimation { target: contentWrap; property: "bodyOpacity"; to: 0.0; duration: 100; easing.type: Easing.InCubic }
                NumberAnimation { target: contentWrap; property: "dismissOpacity"; to: 0.0; duration: 100; easing.type: Easing.InCubic }
                NumberAnimation { target: contentWrap; property: "iconScale"; to: 0.7; duration: 100; easing.type: Easing.InCubic }
                NumberAnimation { target: contentWrap; property: "dismissScale"; to: 0.6; duration: 100; easing.type: Easing.InCubic }
            }
        }

        RowLayout {
            anchors.fill: parent
            spacing: island.s(14)

            // Stacked older notification pills
            Column {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                spacing: island.s(4)
                visible: island.pendingNotifs.length > 1

                Repeater {
                    model: island.pendingNotifs.length > 1 ? island.pendingNotifs.slice(0, -1).reverse().slice(0, 2) : []
                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        width: parent.width
                        height: island.s(28)
                        radius: island.s(10)
                        color: Qt.rgba(island.surface0.r, island.surface0.g, island.surface0.b, 0.45)
                        border.width: 1
                        border.color: Qt.rgba(island.text.r, island.text.g, island.text.b, 0.06)
                        opacity: 0.6 - index * 0.15
                        scale: 0.92 - index * 0.03
                        transformOrigin: Item.TopLeft

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: island.s(8); anchors.rightMargin: island.s(8)
                            spacing: island.s(6)

                            Rectangle {
                                width: island.s(18); height: island.s(18); radius: island.s(5); clip: true
                                color: Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.12)
                                Layout.alignment: Qt.AlignVCenter
                                Image {
                                    anchors.fill: parent; anchors.margins: island.s(3)
                                    source: Registry.resolveIcon(modelData.icon || "")
                                    fillMode: Image.PreserveAspectFit; asynchronous: true
                                }
                            }

                            Text {
                                text: (modelData.appName || "System") + "  " + (modelData.title || modelData.body || "")
                                font.family: island.monoFont; font.pixelSize: island.s(10); font.weight: Font.Medium
                                color: island.subtext0; elide: Text.ElideRight; Layout.fillWidth: true
                            }
                        }
                    }
                }
            }

            // Accent bar
            Rectangle {
                Layout.preferredWidth: island.s(3); Layout.fillHeight: true; radius: island.s(2)
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.9) }
                    GradientStop { position: 1.0; color: Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.3) }
                }
                opacity: island.notifActive ? (island.notifPulse * 0.9 + 0.1) : 0.0
                Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
            }

            // App icon
            Rectangle {
                Layout.preferredWidth: island.s(40); Layout.preferredHeight: island.s(40); Layout.alignment: Qt.AlignVCenter
                radius: island.s(10)
                color: Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.12)
                border.width: 1; border.color: Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.25)
                opacity: contentWrap.iconOpacity
                scale: contentWrap.iconScale
                Image {
                    id: notifIconImg; anchors.fill: parent; anchors.margins: island.s(5)
                    source: Registry.resolveIcon(island.notifData ? (island.notifData.icon || "") : "")
                    fillMode: Image.PreserveAspectFit; asynchronous: true
                }
                Text {
                    anchors.centerIn: parent; text: "󰵙"
                    font.family: island.nerdFont; font.pixelSize: island.s(20); color: island.peach
                    visible: notifIconImg.status !== Image.Ready
                }
            }

            // Text content
            ColumnLayout {
                Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter; spacing: island.s(3)
                RowLayout {
                    Layout.fillWidth: true; spacing: island.s(6)
                    Rectangle {
                        width: island.s(6); height: island.s(6); radius: island.s(3)
                        color: island.peach; opacity: contentWrap.dotOpacity; Layout.alignment: Qt.AlignVCenter
                    }
                    Text {
                        text: island.notifData ? (island.notifData.appName || "System") : ""
                        font.family: island.monoFont; font.pixelSize: island.s(11); font.weight: Font.Medium
                        color: island.peach; elide: Text.ElideRight; Layout.fillWidth: true
                        opacity: contentWrap.appNameOpacity
                    }
                }
                Text {
                    text: island.notifData ? (island.notifData.title || "") : ""
                    font.family: island.monoFont; font.pixelSize: island.s(14); font.weight: Font.Black
                    color: island.text; wrapMode: Text.Wrap; maximumLineCount: 2; elide: Text.ElideRight; Layout.fillWidth: true
                    opacity: contentWrap.titleOpacity
                }
                Text {
                    text: island.notifData ? (island.notifData.body || "") : ""
                    font.family: island.monoFont; font.pixelSize: island.s(11)
                    color: island.subtext0; wrapMode: Text.Wrap; maximumLineCount: 2; elide: Text.ElideRight
                    Layout.fillWidth: true; visible: text !== ""
                    opacity: contentWrap.bodyOpacity
                }
            }

            // Dismiss button
            Rectangle {
                Layout.preferredWidth: island.s(22); Layout.preferredHeight: island.s(22); Layout.alignment: Qt.AlignTop
                radius: island.s(11)
                color: notifDismissMouse.containsMouse
                    ? Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.2)
                    : Qt.rgba(island.surface0.r, island.surface0.g, island.surface0.b, 0.5)
                border.width: 1
                border.color: Qt.rgba(island.peach.r, island.peach.g, island.peach.b, notifDismissMouse.containsMouse ? 0.5 : 0.15)
                Behavior on color { ColorAnimation { duration: 180 } }
                opacity: contentWrap.dismissOpacity
                scale: contentWrap.dismissScale
                Text { anchors.centerIn: parent; text: "󰅖"; font.family: island.nerdFont; font.pixelSize: island.s(11); color: island.subtext0 }
                MouseArea {
                    id: notifDismissMouse; anchors.fill: parent; hoverEnabled: true
                    onClicked: { island.dismissNotif(); mouse.accepted = true }
                }
            }
        }
    }
}
