import QtQuick
import QtQuick.Layouts

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
        Behavior on color { ColorAnimation { duration: 380 } }
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

        Behavior on scale {
            NumberAnimation { duration: 400; easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1] }
        }
        Behavior on opacity {
            NumberAnimation { duration: 220 }
        }
        Behavior on width {
            NumberAnimation { duration: 400; easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1] }
        }
        Behavior on height {
            NumberAnimation { duration: 400; easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1] }
        }

        Rectangle {
            anchors.fill: parent
            radius: 24
            color: Qt.rgba(theme.base.r, theme.base.g, theme.base.b, 0.97)
            border.width: 1
            border.color: Qt.rgba(theme.surface2.r, theme.surface2.g, theme.surface2.b, 0.35)

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
