import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property var island

    Item {
        anchors.fill: parent
        anchors.margins: island.s(14)

        transform: Translate {
            y: island.notifActive ? 0 : island.s(-8)
            Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1] } }
        }

        RowLayout {
            anchors.fill: parent
            spacing: island.s(14)

            // Accent bar
            Rectangle {
                Layout.preferredWidth: island.s(3); Layout.fillHeight: true; radius: island.s(2)
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.9) }
                    GradientStop { position: 1.0; color: Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.3) }
                }
                opacity: island.notifPulse * 0.9 + 0.1
            }

            // App icon
            Rectangle {
                Layout.preferredWidth: island.s(40); Layout.preferredHeight: island.s(40); Layout.alignment: Qt.AlignVCenter
                radius: island.s(10)
                color: Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.12)
                border.width: 1; border.color: Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.25)
                Image {
                    id: notifIconImg; anchors.fill: parent; anchors.margins: island.s(5)
                    source: {
                        let ic = island.notifData ? (island.notifData.icon || "") : ""
                        if (ic === "") return ""
                        if (ic.startsWith("/") || ic.startsWith("file://") || ic.startsWith("http")) return ic
                        return "image://theme/" + ic
                    }
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
                        color: island.peach; opacity: island.notifPulse; Layout.alignment: Qt.AlignVCenter
                    }
                    Text {
                        text: island.notifData ? (island.notifData.appName || "System") : ""
                        font.family: island.monoFont; font.pixelSize: island.s(11); font.weight: Font.Medium
                        color: island.peach; opacity: 0.85; elide: Text.ElideRight; Layout.fillWidth: true
                    }
                }
                Text {
                    text: island.notifData ? (island.notifData.title || "") : ""
                    font.family: island.monoFont; font.pixelSize: island.s(14); font.weight: Font.Black
                    color: island.text; wrapMode: Text.Wrap; maximumLineCount: 2; elide: Text.ElideRight; Layout.fillWidth: true
                }
                Text {
                    text: island.notifData ? (island.notifData.body || "") : ""
                    font.family: island.monoFont; font.pixelSize: island.s(11)
                    color: island.subtext0; wrapMode: Text.Wrap; maximumLineCount: 2; elide: Text.ElideRight
                    Layout.fillWidth: true; visible: text !== ""
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
                Text { anchors.centerIn: parent; text: "󰅖"; font.family: island.nerdFont; font.pixelSize: island.s(11); color: island.subtext0 }
                MouseArea {
                    id: notifDismissMouse; anchors.fill: parent; hoverEnabled: true
                    onClicked: { island.dismissNotif(); mouse.accepted = true }
                }
            }
        }
    }
}
