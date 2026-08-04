import QtQuick
import QtQuick.Layouts
import Quickshell
import "../WindowRegistry.js" as Registry

Row {
    property var island
    property int preferredWidth: {
        let max = Screen.width - island.s(32)
        let n = island.notifHistory.count > 0 ? island.notifHistory.get(0)
              : (island.notifActive ? island.notifData : null)
        let txt = n ? (n.title || n.body || n.appName || "") : ""
        let len = Math.min(18, txt.length)
        let base = Math.min(Math.max(island.s(280), island.s(200) + len * island.s(7)), max)
        if (island.pendingNotifs.length > 1) base += island.s(24)
        return base
    }
    spacing: island.s(8)

    // Notif icon
    Rectangle {
        width: island.s(28); height: island.s(28); radius: island.s(8); clip: true
        color: Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.15)
        anchors.verticalCenter: parent.verticalCenter
        Image {
            id: notifIcon; anchors.fill: parent; anchors.margins: island.s(5)
            source: Registry.resolveIcon(island.notifHistory.count > 0 ? (island.notifHistory.get(0).icon || "")
                       : (island.notifData ? (island.notifData.icon || "") : ""))
            fillMode: Image.PreserveAspectFit; asynchronous: true
        }
        Text {
            visible: notifIcon.status !== Image.Ready
            anchors.centerIn: parent; text: "󰵙"
            font.family: island.nerdFont; font.pixelSize: island.s(14); color: island.peach
        }
    }

    // App name + title
    ColumnLayout {
        spacing: -2; anchors.verticalCenter: parent.verticalCenter
        Text {
            text: {
                let n = island.notifHistory.count > 0 ? island.notifHistory.get(0)
                      : (island.notifActive ? island.notifData : null)
                return n ? (n.appName || "System") : "System"
            }
            font.family: island.monoFont; font.pixelSize: island.s(10); font.weight: Font.Medium
            color: island.peach; elide: Text.ElideRight; Layout.maximumWidth: island.s(160)
        }
        Text {
            text: {
                let n = island.notifHistory.count > 0 ? island.notifHistory.get(0)
                      : (island.notifActive ? island.notifData : null)
                return n ? (n.title || n.body || "") : ""
            }
            font.family: island.monoFont; font.pixelSize: island.s(13); font.weight: Font.Black
            color: island.text; elide: Text.ElideRight; Layout.maximumWidth: island.s(160)
        }
    }

    // Stacked count badge
    Rectangle {
        visible: island.pendingNotifs.length > 1
        width: island.s(18); height: island.s(18); radius: island.s(9)
        color: Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.85)
        anchors.verticalCenter: parent.verticalCenter
        Text {
            anchors.centerIn: parent
            text: island.pendingNotifs.length.toString()
            font.family: island.monoFont; font.pixelSize: island.s(10); font.weight: Font.Black
            color: island.base
        }
    }
}
