import QtQuick
import QtQuick.Layouts

Item {
    property var island
    property int preferredWidth: {
        if (island.notifActive && island.notifData) {
            let txt = island.notifData.title || island.notifData.body || island.notifData.appName || ""
            let len = Math.min(18, txt.length)
            return Math.min(Math.max(island.s(300), island.s(200) + len * island.s(7)), Screen.width - island.s(32))
        }
        return island.s(340)
    }

    anchors.fill: parent

    // ── LEFT: WiFi + Bluetooth (far left edge) ──────────────
    Row {
        anchors.left: parent.left
        anchors.leftMargin: island.s(14)
        anchors.verticalCenter: parent.verticalCenter
        spacing: island.s(16)

        Text {
            text: ""
            visible: island.wifiSignal > 0
            font.family: island.nerdFont
            font.pixelSize: island.s(18)
            color: island.blue
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: "󰂯"
            visible: island.bluetoothOn
            font.family: island.nerdFont
            font.pixelSize: island.s(18)
            color: island.blue
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // ── RIGHT: Weather ──────────────────────────────────────
    Row {
        anchors.right: parent.right
        anchors.rightMargin: island.s(14)
        anchors.verticalCenter: parent.verticalCenter
        spacing: island.s(6)
        visible: island.weatherLoaded && island.weatherIcon !== "" && island.weatherTemp !== ""

        Text {
            text: island.weatherIcon
            font.family: island.nerdFont
            font.pixelSize: island.s(16)
            color: island.weatherHex || island.mauve
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: island.weatherTemp
            font.family: island.monoFont
            font.pixelSize: island.s(13)
            font.weight: Font.Black
            color: island.text
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // ── CENTER: Notification preview ──────────────────────────
    Row {
        anchors.centerIn: parent
        spacing: island.s(10)
        visible: island.notifActive && island.notifData

        Rectangle {
            width: island.s(28); height: island.s(28); radius: island.s(8); clip: true
            color: Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.15)
            anchors.verticalCenter: parent.verticalCenter
            Image {
                id: collNotifIcon; anchors.fill: parent; anchors.margins: island.s(5)
                source: {
                    let ic = island.notifData ? (island.notifData.icon || "") : ""
                    if (ic === "") return ""
                    if (ic.startsWith("/") || ic.startsWith("file://") || ic.startsWith("http")) return ic
                    return "image://theme/" + ic
                }
                fillMode: Image.PreserveAspectFit; asynchronous: true
            }
            Text {
                visible: collNotifIcon.status !== Image.Ready
                anchors.centerIn: parent; text: "󰵙"
                font.family: island.nerdFont; font.pixelSize: island.s(14); color: island.peach
            }
        }

        ColumnLayout {
            spacing: -2; anchors.verticalCenter: parent.verticalCenter
            Text {
                text: island.notifData ? (island.notifData.appName || "System") : ""
                font.family: island.monoFont; font.pixelSize: island.s(10); font.weight: Font.Medium
                color: island.peach; elide: Text.ElideRight; Layout.maximumWidth: island.s(200)
            }
            Text {
                text: island.notifData ? (island.notifData.title || island.notifData.body || "") : ""
                font.family: island.monoFont; font.pixelSize: island.s(13); font.weight: Font.Black
                color: island.text; elide: Text.ElideRight; Layout.maximumWidth: island.s(200)
            }
        }
    }

    // ── CENTER: Time / Date ──────────────────────────────────
    RowLayout {
        anchors.centerIn: parent
        spacing: island.s(10)
        visible: !island.notifActive

        ColumnLayout {
            spacing: -2
            Layout.alignment: Qt.AlignVCenter

            RowLayout {
                spacing: island.s(2)
                Layout.alignment: Qt.AlignHCenter

                Text {
                    text: island.timeStr
                    font.family: island.monoFont
                    font.pixelSize: island.s(19)
                    font.weight: Font.Black
                    color: island.mauve
                }

                Text {
                    text: ":" + island.timeStrSec.split(":")[2]
                    font.family: island.monoFont
                    font.pixelSize: island.s(19)
                    font.weight: Font.Black
                    color: island.mauve
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            Text {
                text: island.dateStr || ""
                font.family: island.monoFont
                font.pixelSize: island.s(13)
                font.weight: Font.Bold
                color: island.subtext0
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
