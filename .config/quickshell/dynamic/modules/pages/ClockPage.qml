import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects

Item {
    id: root
    property var island

    Item {
        anchors.fill: parent
        anchors.margins: island.s(28)
        anchors.bottomMargin: island.s(72)

        ColumnLayout {
            width: parent.width
            spacing: island.s(12)

            // ── Clock / Date ──────────────────────────────────
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: island.timeStrSec
                font.family: island.monoFont; font.pixelSize: island.s(50); font.weight: Font.Black
                color: island.mauve
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: island.dateStr
                font.family: island.monoFont; font.pixelSize: island.s(15); font.weight: Font.Medium
                color: island.subtext0
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: island.greetingStr
                visible: island.greetingStr !== ""
                font.family: island.monoFont; font.pixelSize: island.s(22); font.weight: Font.Black
                color: island.subtext0
                opacity: 0.65
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: island.s(8); Layout.bottomMargin: island.s(4)
                height: 1
                color: Qt.rgba(island.text.r, island.text.g, island.text.b, 0.08)
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: island.s(20)

                // WiFi
                RowLayout {
                    spacing: island.s(8)
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text: {
                            if (island.wifiSignal <= 0) return "󰤮";
                            if (island.wifiSignal < 25) return "󰤟";
                            if (island.wifiSignal < 50) return "󰤢";
                            if (island.wifiSignal < 75) return "󰤥";
                            return "󰤨";
                        }
                        font.family: island.nerdFont; font.pixelSize: island.s(24)
                        color: island.wifiSignal > 0 ? island.blue : island.overlay0
                    }
                    ColumnLayout {
                        spacing: island.s(1)
                        Text {
                            text: island.wifiSsid !== "" ? island.wifiSsid : "Disconnected"
                            font.family: island.monoFont; font.pixelSize: island.s(14); font.weight: Font.Bold
                            color: island.wifiSsid !== "" ? island.text : island.overlay0
                        }
                    }
                    Rectangle {
                        width: island.s(48); height: island.s(24); radius: island.s(12)
                        color: island.wifiSignal > 0 ? Qt.rgba(island.blue.r, island.blue.g, island.blue.b, 0.2) : island.surface0
                        border.color: island.wifiSignal > 0 ? island.blue : island.overlay0
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: island.wifiSignal > 0 ? "ON" : "OFF"
                            font.family: island.monoFont; font.pixelSize: island.s(10); font.weight: Font.Black
                            color: island.wifiSignal > 0 ? island.blue : island.overlay0
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: island.exec("nmcli radio wifi " + (island.wifiSignal > 0 ? "off" : "on"))
                        }
                    }
                }

                // Bluetooth
                RowLayout {
                    spacing: island.s(8)
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text: "󰂯"
                        font.family: island.nerdFont; font.pixelSize: island.s(24)
                        color: island.bluetoothOn ? island.blue : island.overlay0
                    }
                    ColumnLayout {
                        spacing: island.s(1)
                        Text {
                            text: island.bluetoothOn ? "On" : "Off"
                            font.family: island.monoFont; font.pixelSize: island.s(14); font.weight: Font.Bold
                            color: island.bluetoothOn ? island.text : island.overlay0
                        }
                        Text {
                            text: island.bluetoothDevices > 0 ? island.bluetoothDevices + " device" + (island.bluetoothDevices === 1 ? "" : "s") : ""
                            visible: island.bluetoothOn
                            font.family: island.monoFont; font.pixelSize: island.s(11)
                            color: island.subtext0
                        }
                    }
                    Rectangle {
                        width: island.s(48); height: island.s(24); radius: island.s(12)
                        color: island.bluetoothOn ? Qt.rgba(island.blue.r, island.blue.g, island.blue.b, 0.2) : island.surface0
                        border.color: island.bluetoothOn ? island.blue : island.overlay0
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: island.bluetoothOn ? "ON" : "OFF"
                            font.family: island.monoFont; font.pixelSize: island.s(10); font.weight: Font.Black
                            color: island.bluetoothOn ? island.blue : island.overlay0
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: island.exec("bluetoothctl power " + (island.bluetoothOn ? "off" : "on"))
                        }
                    }

                    // Connected device name on the right
                    Text {
                        text: island.btDeviceList.length > 0 ? "󰋋  " + island.btDeviceList[0].name : ""
                        visible: island.bluetoothOn && island.btDeviceList.length > 0
                        font.family: island.monoFont; font.pixelSize: island.s(12); font.weight: Font.Bold
                        color: island.text
                        Layout.leftMargin: island.s(8)
                    }
                }
            }

            // ── Quick actions ──────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(island.text.r, island.text.g, island.text.b, 0.08)
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: island.s(10)

                Rectangle {
                    width: island.s(36); height: island.s(28); radius: island.s(8)
                    color: island.dndEnabled
                        ? (dndMouse.containsMouse
                            ? Qt.rgba(island.mauve.r, island.mauve.g, island.mauve.b, 0.25)
                            : Qt.rgba(island.mauve.r, island.mauve.g, island.mauve.b, 0.15))
                        : (dndMouse.containsMouse
                            ? Qt.rgba(island.surface1.r, island.surface1.g, island.surface1.b, 0.6)
                            : island.surface0)
                    Behavior on color { ColorAnimation { duration: 180 } }
                    border.color: island.dndEnabled ? island.mauve : island.overlay0
                    border.width: 1
                    scale: dndMouse.containsMouse ? 1.08 : 1.0
                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                    Text {
                        anchors.centerIn: parent
                        text: island.dndEnabled ? "󰂛" : "󰂚"
                        font.family: island.nerdFont; font.pixelSize: island.s(16)
                        color: island.dndEnabled ? island.mauve : island.overlay0
                    }
                    MouseArea {
                        id: dndMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true
                        onClicked: {
                            island.dndEnabled = !island.dndEnabled
                            island.exec("mkdir -p ~/.cache && echo '" + (island.dndEnabled ? "1" : "0") + "' > ~/.cache/qs_dnd")
                        }
                    }
                }

                Rectangle {
                    width: island.s(36); height: island.s(28); radius: island.s(8)
                    color: island.caffeineEnabled
                        ? (caffeineMouse.containsMouse
                            ? Qt.rgba(island.green.r, island.green.g, island.green.b, 0.25)
                            : Qt.rgba(island.green.r, island.green.g, island.green.b, 0.15))
                        : (caffeineMouse.containsMouse
                            ? Qt.rgba(island.surface1.r, island.surface1.g, island.surface1.b, 0.6)
                            : island.surface0)
                    Behavior on color { ColorAnimation { duration: 180 } }
                    border.color: island.caffeineEnabled ? island.green : island.overlay0
                    border.width: 1
                    scale: caffeineMouse.containsMouse ? 1.08 : 1.0
                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.family: island.nerdFont; font.pixelSize: island.s(16)
                        color: island.caffeineEnabled ? island.green : island.overlay0
                    }
                    MouseArea {
                        id: caffeineMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true
                        onClicked: {
                            island.caffeineEnabled = !island.caffeineEnabled
                            island.exec("mkdir -p /tmp; echo '" + (island.caffeineEnabled ? "on" : "off") + "' > /tmp/qs_caffeine")
                            if (island.caffeineEnabled)
                                island.exec("systemd-inhibit --what=sleep:idle --who=qs-caffeine --why='Caffeine mode' sleep infinity &")
                            else
                                island.exec("pkill -f 'systemd-inhibit.*qs-caffeine' 2>/dev/null")
                        }
                    }
                }

                Rectangle {
                    width: island.s(36); height: island.s(28); radius: island.s(8)
                    color: island.currentPage === "calendar"
                        ? (calMouse.containsMouse
                            ? Qt.rgba(island.mauve.r, island.mauve.g, island.mauve.b, 0.25)
                            : Qt.rgba(island.mauve.r, island.mauve.g, island.mauve.b, 0.15))
                        : (calMouse.containsMouse
                            ? Qt.rgba(island.surface1.r, island.surface1.g, island.surface1.b, 0.6)
                            : island.surface0)
                    Behavior on color { ColorAnimation { duration: 180 } }
                    border.color: island.currentPage === "calendar" ? island.mauve : island.overlay0
                    border.width: 1
                    scale: calMouse.containsMouse ? 1.08 : 1.0
                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.family: island.nerdFont; font.pixelSize: island.s(16)
                        color: island.currentPage === "calendar" ? island.mauve : island.overlay0
                    }
                    MouseArea {
                        id: calMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true
                        onClicked: {
                            island.currentPage = "calendar"
                            island.expanded = true
                        }
                    }
                }

                Rectangle {
                    width: island.s(36); height: island.s(28); radius: island.s(8)
                    visible: island.availablePages.length > 1
                    color: notifMouse.containsMouse
                        ? Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.22)
                        : Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.12)
                    Behavior on color { ColorAnimation { duration: 180 } }
                    border.color: notifMouse.containsMouse
                        ? Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.5)
                        : Qt.rgba(island.peach.r, island.peach.g, island.peach.b, 0.3)
                    Behavior on border.color { ColorAnimation { duration: 180 } }
                    border.width: 1
                    scale: notifMouse.containsMouse ? 1.08 : 1.0
                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                    Text {
                        anchors.centerIn: parent
                        text: "󰎟"
                        font.family: island.nerdFont; font.pixelSize: island.s(16)
                        color: island.peach
                    }
                    MouseArea {
                        id: notifMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true
                        onClicked: {
                            island.currentPage = "notifs"
                            island.expanded = true
                        }
                    }
                    Rectangle {
                        anchors.top: parent.top; anchors.right: parent.right
                        anchors.topMargin: -3; anchors.rightMargin: -3
                        width: island.s(15); height: island.s(15); radius: island.s(7.5)
                        visible: island.notifHistory.count > 0
                        color: island.peach
                        Text {
                            anchors.centerIn: parent
                            text: island.notifHistory.count > 9 ? "9+" : island.notifHistory.count
                            font.family: island.monoFont; font.pixelSize: island.s(9); font.weight: Font.Black
                            color: island.base
                        }
                    }
                }
            }
        }
    }
}