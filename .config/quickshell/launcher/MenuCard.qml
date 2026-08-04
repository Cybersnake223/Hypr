import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

Item {
    id: root

    property bool cardOpen: false
    property real cardWidth: 520
    property real cardHeight: 400

    signal requestClose()

    anchors.fill: parent
    clip: false

    // ─── Backdrop dim ────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, root.cardOpen ? 0.55 : 0)
        Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1] } }
        visible: color.a > 0.001

        MouseArea { anchors.fill: parent; onClicked: root.requestClose() }
    }

    // ─── Card ────────────────────────────────────────────────────────────────
    Item {
        id: card
        anchors.centerIn: parent
        width: cardWidth
        height: cardHeight
        scale: root.cardOpen ? 1.0 : 0.95
        opacity: root.cardOpen ? 1.0 : 0.0

        // Stretch-and-spring (Dynamic Island style)
        property real stretchY: 1.0
        transform: Scale { yScale: card.stretchY }

        SequentialAnimation {
            id: stretchAnim
            running: root.cardOpen
            PropertyAnimation { target: card; property: "stretchY"; from: 1.0; to: 1.06; duration: 100; easing.type: Easing.OutQuad }
            PropertyAnimation { target: card; property: "stretchY"; to: 1.0; duration: 180; easing.type: Easing.OutBack; easing.overshoot: 1.1 }
            onRunningChanged: if (!running) card.stretchY = 1.0
        }

        Behavior on scale {
            NumberAnimation { duration: root.cardOpen ? 350 : 120; easing.type: root.cardOpen ? Easing.OutBack : Easing.OutCubic; easing.overshoot: root.cardOpen ? 1.15 : 1.0 }
        }
        Behavior on opacity {
            NumberAnimation { duration: root.cardOpen ? 200 : 80; easing.type: root.cardOpen ? Easing.OutCubic : Easing.InCubic }
        }
        Behavior on width {
            NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.05 }
        }
        Behavior on height {
            NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.05 }
        }

        Rectangle {
            anchors.fill: parent
            // Radius morph: starts larger, settles to 24
            radius: root.cardOpen ? 24 : 36
            Behavior on radius { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            color: Qt.rgba(theme.base.r, theme.base.g, theme.base.b, 0.75)
            border.width: 1
            border.color: Qt.rgba(theme.surface2.r, theme.surface2.g, theme.surface2.b, 0.35)

            layer.enabled: root.cardOpen
            layer.effect: MultiEffect {
                id: cardEffect
                shadowEnabled: true
                shadowColor: "#000000"
                shadowBlur: 6.0
                shadowOpacity: 0.15
                shadowVerticalOffset: 2
                blurEnabled: false
            }

            // Top light-catch hairline (glass edge)
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: "transparent"
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.3; color: "transparent" }
                    GradientStop { position: 0.5; color: Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.22) }
                    GradientStop { position: 0.7; color: "transparent" }
                }
            }

            ColumnLayout {
                id: contentLayout
                anchors.fill: parent
                anchors.margins: 16
                spacing: 6
            }
        }
    }

    default property alias content: contentLayout.data
}
