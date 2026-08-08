import QtQuick
import QtQuick.Layouts
import "../WindowRegistry.js" as Registry

Item {
    id: root
    property var island

    Item {
        anchors.fill: parent
        anchors.margins: island.s(20)
        anchors.bottomMargin: island.s(44)

        Rectangle {
            anchors.fill: parent
            radius: island.s(16)
            color: Qt.rgba(island.base.r, island.base.g, island.base.b, 0.5)
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: island.s(8)

            // ── Header: title | DND toggle | clear ──────────────
            RowLayout {
                Layout.fillWidth: true; spacing: island.s(6)

                Text {
                    text: "NOTIFICATIONS"
                    font.family: island.monoFont; font.pixelSize: island.s(11); font.weight: Font.Black; font.letterSpacing: 1.5
                    color: island.mauve; Layout.fillWidth: true
                }

                Rectangle {
                    height: island.s(22); width: dndLabel.implicitWidth + island.s(16); radius: island.s(11)
                    color: island.dndEnabled
                        ? Qt.rgba(island.mauve.r, island.mauve.g, island.mauve.b, 0.22)
                        : (dndMouse.containsMouse
                            ? Qt.rgba(island.surface1.r, island.surface1.g, island.surface1.b, 0.7)
                            : Qt.rgba(island.surface0.r, island.surface0.g, island.surface0.b, 0.5))
                    border.width: 1
                    border.color: island.dndEnabled
                        ? Qt.rgba(island.mauve.r, island.mauve.g, island.mauve.b, 0.5)
                        : Qt.rgba(island.text.r, island.text.g, island.text.b, 0.08)
                    Behavior on color { ColorAnimation { duration: 180 } }
                    Behavior on border.color { ColorAnimation { duration: 180 } }
                    Text {
                        id: dndLabel; anchors.centerIn: parent
                        text: island.dndEnabled ? "󰂛  DND" : "󰂚  DND"
                        font.family: island.nerdFont; font.pixelSize: island.s(11)
                        color: island.dndEnabled ? island.mauve : island.subtext0
                        Behavior on color { ColorAnimation { duration: 180 } }
                    }
                    MouseArea {
                        id: dndMouse; anchors.fill: parent; hoverEnabled: true
                        onClicked: {
                            island.dndEnabled = !island.dndEnabled
                            island.exec("mkdir -p ~/.cache && echo '" + (island.dndEnabled ? "1" : "0") + "' > ~/.cache/qs_dnd")
                        }
                    }
                }

                Rectangle {
                    visible: island.notifHistory.count > 0
                    height: island.s(22); width: clearAllLabel.implicitWidth + island.s(14); radius: island.s(11)
                    color: clearAllMouse.containsMouse
                        ? Qt.rgba(island.surface1.r, island.surface1.g, island.surface1.b, 0.8)
                        : Qt.rgba(island.surface0.r, island.surface0.g, island.surface0.b, 0.5)
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Text { id: clearAllLabel; anchors.centerIn: parent; text: "Clear"; font.family: island.monoFont; font.pixelSize: island.s(10); color: island.subtext0 }
                    MouseArea {
                        id: clearAllMouse; anchors.fill: parent; hoverEnabled: true
                        onClicked: { island.notifHistory.clear(); island.saveNotifHistory() }
                    }
                }
            }

            // ── Empty state ─────────────────────────────────────
            Item {
                Layout.fillWidth: true; Layout.fillHeight: true
                visible: island.notifHistory.count === 0
                ColumnLayout {
                    anchors.centerIn: parent; spacing: island.s(10)
                    Text { Layout.alignment: Qt.AlignHCenter; text: "󰂚"; font.family: island.nerdFont; font.pixelSize: island.s(40); color: island.surface2 }
                    Text { Layout.alignment: Qt.AlignHCenter; text: "No notifications"; font.family: island.monoFont; font.pixelSize: island.s(13); color: island.subtext0; opacity: 0.6 }
                }
            }

            // ── Grouped notification list ────────────────────────
            Flickable {
                Layout.fillWidth: true; Layout.fillHeight: true
                visible: island.notifHistory.count > 0
                clip: true
                contentHeight: groupedCol.height
                flickableDirection: Flickable.VerticalFlick

                ColumnLayout {
                    id: groupedCol
                    width: parent.width
                    spacing: island.s(4)

                    Repeater {
                        model: island.notifGroups

                        delegate: ColumnLayout {
                            required property var modelData
                            required property int index
                            spacing: island.s(3)
                            Layout.fillWidth: true

                            property bool isExpanded: island.expandedGroup === modelData.app
                            property color accentColor: island.appAccentColor(modelData.app)

                            // ── Group header ─────────────────────
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: island.s(36)
                                radius: island.s(10)
                                color: groupHeaderMouse.containsMouse
                                    ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.15)
                                    : Qt.rgba(island.surface0.r, island.surface0.g, island.surface0.b, 0.4)
                                border.width: 1
                                border.color: Qt.rgba(island.text.r, island.text.g, island.text.b, 0.06)
                                Behavior on color { ColorAnimation { duration: 120 } }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: island.s(10); anchors.rightMargin: island.s(10)
                                    spacing: island.s(8)

                                    // App icon
                                    Rectangle {
                                        width: island.s(24); height: island.s(24); radius: island.s(6); clip: true
                                        color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.12)
                                        Layout.alignment: Qt.AlignVCenter
                                        Image {
                                            anchors.fill: parent; anchors.margins: island.s(4)
                                            source: Registry.resolveIcon(modelData.icon || "")
                                            fillMode: Image.PreserveAspectFit; asynchronous: true
                                        }
                                        Text {
                                            anchors.centerIn: parent; text: "󰵙"
                                            font.family: island.nerdFont; font.pixelSize: island.s(12); color: accentColor
                                            visible: parent.children[0].status !== Image.Ready
                                        }
                                    }

                                    // App name
                                    Text {
                                        text: modelData.app
                                        font.family: island.monoFont; font.pixelSize: island.s(12); font.weight: Font.Bold
                                        color: island.text; Layout.fillWidth: true
                                    }

                                    // Count badge
                                    Rectangle {
                                        visible: modelData.count > 1
                                        width: countText.implicitWidth + island.s(10); height: island.s(18); radius: island.s(9)
                                        color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.2)
                                        Text {
                                            id: countText; anchors.centerIn: parent
                                            text: modelData.count
                                            font.family: island.monoFont; font.pixelSize: island.s(10); font.weight: Font.Black
                                            color: accentColor
                                        }
                                    }

                                    // Chevron
                                    Text {
                                        text: "󰅃"
                                        font.family: island.nerdFont; font.pixelSize: island.s(14)
                                        color: island.subtext0
                                        rotation: isExpanded ? 180 : 0
                                        Behavior on rotation { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                                    }
                                }

                                MouseArea {
                                    id: groupHeaderMouse; anchors.fill: parent; hoverEnabled: true
                                    onClicked: {
                                        if (isExpanded) island.expandedGroup = ""
                                        else island.expandedGroup = modelData.app
                                    }
                                }
                            }

                            // ── Expanded notifications ───────────
                            Repeater {
                                model: isExpanded ? modelData.items : []
                                delegate: Rectangle {
                                    required property var modelData
                                    required property int index
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: island.s(44)
                                    Layout.leftMargin: island.s(12)
                                    radius: island.s(10)
                                    color: Qt.rgba(island.surface0.r, island.surface0.g, island.surface0.b, 0.45)
                                    border.width: 1; border.color: Qt.rgba(island.text.r, island.text.g, island.text.b, 0.05)
                                    transform: Translate { id: notifDragOffset }
                                    opacity: 1.0 - Math.abs(notifDragOffset.x) / (width * 0.4)

                                    NumberAnimation {
                                        id: notifDragSpring; target: notifDragOffset; property: "x"
                                        duration: 300; easing.type: Easing.OutBack
                                    }

                                    property string timeAgo: {
                                        if (!modelData.timestamp) return ""
                                        let diff = Math.floor((Date.now() - modelData.timestamp) / 1000)
                                        if (diff < 60) return "now"
                                        if (diff < 3600) return Math.floor(diff / 60) + "m"
                                        if (diff < 86400) return Math.floor(diff / 3600) + "h"
                                        return Math.floor(diff / 86400) + "d"
                                    }

                                    DragHandler {
                                        id: notifRowDrag; target: null; margin: island.s(8)
                                        onTranslationChanged: notifDragOffset.x = notifRowDrag.translation.x
                                        onActiveChanged: {
                                            if (!active) {
                                                if (notifRowDrag.translation.x > parent.width * 0.4) {
                                                    for (let i = 0; i < island.notifHistory.count; i++) {
                                                        let n = island.notifHistory.get(i)
                                                        if (n.appName === modelData.appName && n.title === modelData.title && n.body === modelData.body && n.timestamp === modelData.timestamp) {
                                                            island.notifHistory.remove(i)
                                                            break
                                                        }
                                                    }
                                                    island.saveNotifHistory()
                                                } else {
                                                    notifDragSpring.start()
                                                }
                                            }
                                        }
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: island.s(8); anchors.rightMargin: island.s(8)
                                        spacing: island.s(6)

                                        Rectangle {
                                            width: island.s(3); Layout.fillHeight: true
                                            Layout.topMargin: island.s(10); Layout.bottomMargin: island.s(10)
                                            radius: island.s(2); color: accentColor; opacity: 0.6
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter; spacing: island.s(1)
                                            RowLayout {
                                                Layout.fillWidth: true; spacing: island.s(4)
                                                Text {
                                                    text: modelData.title || modelData.body || ""
                                                    font.family: island.monoFont; font.pixelSize: island.s(11); font.weight: Font.Bold
                                                    color: island.text; Layout.fillWidth: true; elide: Text.ElideRight
                                                }
                                                Text {
                                                    text: timeAgo
                                                    font.family: island.monoFont; font.pixelSize: island.s(8); font.weight: Font.Medium
                                                    color: island.subtext0; opacity: 0.5; visible: text !== ""
                                                    Layout.alignment: Qt.AlignVCenter
                                                }
                                            }
                                            Text {
                                                text: modelData.body || ""
                                                font.family: island.monoFont; font.pixelSize: island.s(9)
                                                color: island.subtext0; Layout.fillWidth: true; elide: Text.ElideRight; visible: text !== ""
                                            }
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: island.s(20); Layout.preferredHeight: island.s(20); radius: island.s(10)
                                            color: notifDismissMouse.containsMouse
                                                ? Qt.rgba(island.surface1.r, island.surface1.g, island.surface1.b, 0.8)
                                                : "transparent"
                                            Layout.alignment: Qt.AlignVCenter
                                            Behavior on color { ColorAnimation { duration: 120 } }
                                            Text { anchors.centerIn: parent; text: "󰅖"; font.family: island.nerdFont; font.pixelSize: island.s(10); color: island.subtext0 }
                                            MouseArea {
                                                id: notifDismissMouse; anchors.fill: parent; hoverEnabled: true
                                                onClicked: {
                                                    for (let i = 0; i < island.notifHistory.count; i++) {
                                                        let n = island.notifHistory.get(i)
                                                        if (n.appName === modelData.appName && n.title === modelData.title && n.body === modelData.body && n.timestamp === modelData.timestamp) {
                                                            island.notifHistory.remove(i)
                                                            break
                                                        }
                                                    }
                                                    island.saveNotifHistory()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
