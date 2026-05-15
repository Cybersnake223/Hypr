import QtQuick
import QtQuick.Animations
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    property var targetScreen: Quickshell.screens[0]
    property alias contentItem: root.contentItem

    screen: targetScreen

    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    // Fade in animation
    opacity: 0
    NumberAnimation on opacity {
        to: 1
        duration: 200
        easing.type: Easing.OutCubic
    }

    ScreencopyView {
        captureSource: root.targetScreen
        anchors.fill: parent
        z: -1
    }

    // Vignette overlay
    Rectangle {
        anchors.fill: parent
        z: 1
        gradient: RadialGradient {
            center: Qt.point(0.5, 0.5)
            radius: 0.8
            focalRadius: 0.3
            GradientStop { position: 0; color: "transparent" }
            GradientStop { position: 0.7; color: "transparent" }
            GradientStop { position: 1; color: "#99000000" }
        }
    }
}