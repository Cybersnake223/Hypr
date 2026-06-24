import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

Item {
    id: root

    property bool cardOpen: false
    property real cardWidth: 520
    property real cardHeight: 400

    anchors.centerIn: parent
    width: cardWidth
    height: cardHeight
    scale: cardOpen ? 1.0 : 0.85
    opacity: cardOpen ? 1.0 : 0.0

    Behavior on scale {
        NumberAnimation { duration: 450; easing.type: Easing.OutBack }
    }
    Behavior on opacity {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }

    clip: true

    transform: Translate {
        id: slideT
        y: cardOpen ? 0 : -80
        Behavior on y {
            NumberAnimation { duration: 450; easing.type: Easing.OutBack }
        }
    }

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Qt.rgba(0, 0, 0, 0.5)
        shadowBlur: 0.3
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 8
        shadowOpacity: 0.3
    }

    Rectangle {
        id: gradientBorder
        anchors.fill: parent
        radius: 24
        gradient: Gradient {
            GradientStop { position: 0.0; color: theme.mauve }
            GradientStop { position: 0.33; color: theme.tertiaryContainer }
            GradientStop { position: 0.66; color: Qt.rgba(theme.mauve.r, theme.mauve.g, theme.mauve.b, 0.6) }
            GradientStop { position: 1.0; color: theme.tertiaryContainer }
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 3
        radius: 21
        color: Qt.rgba(theme.base.r, theme.base.g, theme.base.b, 0.85)

        ColumnLayout {
            id: contentLayout
            anchors.fill: parent
            anchors.margins: 16
            spacing: 6
        }
    }

    default property alias content: contentLayout.data
}
