import QtQuick
import QtQuick.Layouts

Item {
    property var island

    property int preferredWidth: {
        if (island.osdType === "layout" || island.osdType === "capslock" || island.osdType === "numlock") return island.s(160)
        return island.s(200)
    }

    anchors.centerIn: parent
    width: preferredWidth
    height: island.s(64)

    // Keyboard layout / Caps / Num Lock
    Row {
        visible: island.osdType === "layout" || island.osdType === "capslock" || island.osdType === "numlock"
        anchors.centerIn: parent
        spacing: island.s(8)

        Text {
            text: {
                if (island.osdType === "capslock") return "󰘴"
                if (island.osdType === "numlock") return ""
                return "⌨"
            }
            font.family: island.osdType === "layout" ? island.monoFont : island.nerdFont
            font.pixelSize: island.s(20)
            color: island.osdType === "layout" ? island.teal : (island.osdValue === "ON" ? island.peach : island.subtext0)
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: island.osdType === "layout" ? island.osdValue : (island.osdType === "capslock" ? "CAPS " : "NUM ") + island.osdValue
            font.family: island.monoFont; font.pixelSize: island.s(18); font.weight: Font.Black
            color: island.osdType === "layout" ? island.teal : (island.osdValue === "ON" ? island.peach : island.subtext0)
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Volume / Brightness
    Column {
        visible: island.osdType === "volume" || island.osdType === "brightness"
        anchors.centerIn: parent
        spacing: island.s(8)

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: island.s(8)

            Item {
                width: island.s(28)
                height: island.s(28)
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors.centerIn: parent
                    width: island.s(36)
                    height: island.s(36)
                    radius: width / 2
                    color: island.osdType === "volume" ? island.blue : island.peach
                    opacity: {
                        let v = parseInt(island.osdValue) || 0
                        return (v === 0 || v === 100) ? 0.2 : 0.0
                    }
                    scale: {
                        let v = parseInt(island.osdValue) || 0
                        return (v === 0 || v === 100) ? 1.3 : 0.8
                    }
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                }

                Text {
                    anchors.centerIn: parent
                    text: {
                        if (island.osdType === "volume") {
                            let v = parseInt(island.osdValue) || 0
                            if (v === 0) return "󰖁"
                            if (v < 40) return "󰖀"
                            return "󰕾"
                        }
                        let b = parseInt(island.osdValue) || 0
                        if (b < 30) return "󰃞"
                        if (b < 70) return "󰃟"
                        return "󰃠"
                    }
                    font.family: island.nerdFont; font.pixelSize: island.s(20)
                    color: island.osdType === "volume" ? island.blue : island.peach
                }
            }
            Text {
                text: (parseInt(island.osdValue) || 0) + "%"
                font.family: island.monoFont; font.pixelSize: island.s(18); font.weight: Font.Black
                color: island.osdType === "volume" ? island.blue : island.peach
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: "󰝛"
                font.family: island.nerdFont; font.pixelSize: island.s(14)
                color: island.red
                anchors.verticalCenter: parent.verticalCenter
                opacity: island.osdMuted ? 1.0 : 0.0
                Behavior on opacity { PropertyAnimation { duration: 120 } }
            }
        }

        Rectangle {
            width: island.s(160); height: island.s(5); radius: island.s(3)
            anchors.horizontalCenter: parent.horizontalCenter
            color: Qt.rgba(island.surface1.r, island.surface1.g, island.surface1.b, 0.35)

            Rectangle {
                anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                width: parent.width * Math.max(0, Math.min(1, (parseInt(island.osdValue) || 0) / 100))
                radius: parent.radius
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: island.osdType === "volume" ? island.blue  : island.peach }
                    GradientStop { position: 1.0; color: island.osdType === "volume" ? island.mauve : island.yellow }
                }
                Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
            }
        }
    }
}
