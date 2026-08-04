import QtQuick
import QtQuick.Layouts

Item {
    property var island

    property int preferredWidth: {
        if (island.osdType === "layout" || island.osdType === "capslock" || island.osdType === "numlock") return island.s(160)
        return island.s(120)
    }

    anchors.centerIn: parent
    width: preferredWidth
    height: island.s(48)

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
        spacing: island.s(6)

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: island.s(8)

            // Circular progress ring
            Item {
                width: island.s(44)
                height: island.s(44)
                anchors.verticalCenter: parent.verticalCenter

                Canvas {
                    id: ringCanvas
                    anchors.fill: parent
                    antialiasing: true
                    property bool isVolume: island.osdType === "volume"
                    onPaint: {
                        let ctx = getContext("2d")
                        ctx.reset()
                        let c = width / 2
                        let r = c - island.s(3)
                        let lineW = island.s(4)
                        let v = Math.max(0, Math.min(1, (parseInt(island.osdValue) || 0) / 100))

                        ctx.lineWidth = lineW
                        ctx.lineCap = "round"
                        ctx.strokeStyle = Qt.rgba(island.surface1.r, island.surface1.g, island.surface1.b, 0.35).toString()
                        ctx.beginPath()
                        ctx.arc(c, c, r, 0, Math.PI * 2)
                        ctx.stroke()

                        if (v > 0) {
                            let g = ctx.createLinearGradient(0, 0, width, height)
                            if (ringCanvas.isVolume) {
                                g.addColorStop(0, island.blue.toString())
                                g.addColorStop(1, island.mauve.toString())
                            } else {
                                g.addColorStop(0, island.peach.toString())
                                g.addColorStop(1, island.mocha.yellow.toString())
                            }
                            ctx.strokeStyle = g
                            ctx.beginPath()
                            ctx.arc(c, c, r, -Math.PI / 2, -Math.PI / 2 + v * Math.PI * 2)
                            ctx.stroke()
                        }
                    }
                    Connections {
                        target: island
                        function onOsdValueChanged() { ringCanvas.requestPaint() }
                        function onOsdTypeChanged() { ringCanvas.requestPaint() }
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: island.s(26)
                    height: island.s(26)
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
                    font.family: island.nerdFont; font.pixelSize: island.s(15)
                    color: island.osdType === "volume" ? island.blue : island.peach
                }

                // Muted badge (ring bottom-right corner)
                Text {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: -island.s(1)
                    text: "󰝛"
                    font.family: island.nerdFont; font.pixelSize: island.s(11)
                    color: island.red
                    opacity: island.osdMuted ? 1.0 : 0.0
                    Behavior on opacity { PropertyAnimation { duration: 120 } }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: (parseInt(island.osdValue) || 0) + "%"
                font.family: island.monoFont; font.pixelSize: island.s(15); font.weight: Font.Black
                color: island.osdType === "volume" ? island.blue : island.peach
            }
        }
    }
}
