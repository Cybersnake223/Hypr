import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../"

// Reusable arc gauge orb with hover aura and animated value.
// Place center content (icon, value, label) inside as child items.
Item {
    id: root

    property real value: 0
    property color colorFrom: "#0000ff"
    property color colorTo: "#00ffff"
    property color trackColor: Qt.rgba(0.3, 0.3, 0.35, 0.2)

    default property alias contentItem: contentContainer.data

    property real animVal: value
    Behavior on animVal {
        NumberAnimation {
            duration: 1200
            easing.type: Easing.OutQuint
            onRunningChanged: if (!running) canvas.requestPaint()
        }
    }
    Component.onCompleted: canvas.requestPaint()
    onValueChanged: animVal = value

    // Aura glow
    Rectangle {
        id: aura
        anchors.centerIn: parent
        width: parent.width + (mouseArea.containsMouse ? parent.width * 0.18 : parent.width * 0.03)
        height: width; radius: width / 2
        color: root.colorFrom
        opacity: mouseArea.containsMouse ? 0.35 : 0.08
        Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }
        Behavior on opacity { NumberAnimation { duration: 300 } }
    }

    // Gauge arc
    Canvas {
        id: canvas; anchors.fill: parent; rotation: 180
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.4
            shadowOpacity: 0.25
            shadowVerticalOffset: 1
        }
        onPaint: {
            var ctx = getContext("2d"); ctx.clearRect(0, 0, width, height);
            var cX = width/2; var cY = height/2; var rad = (width/2)-width*0.06;
            var eA = (Math.min(100, Math.max(0, root.animVal)) / 100) * 2 * Math.PI;
            ctx.lineCap = "round"; ctx.lineWidth = width*0.06;
            ctx.beginPath(); ctx.arc(cX, cY, rad, 0, 2*Math.PI);
            ctx.strokeStyle = root.trackColor.toString(); ctx.stroke();
            var grad = ctx.createLinearGradient(0, height, width, 0);
            grad.addColorStop(0, root.colorFrom.toString());
            grad.addColorStop(1, root.colorTo.toString());
            ctx.lineWidth = width*0.1;
            ctx.beginPath(); ctx.arc(cX, cY, rad, 0, eA);
            ctx.strokeStyle = grad; ctx.stroke();
        }
    }

    // Center content
    Item {
        id: contentContainer
        anchors.centerIn: parent
        width: parent.width * 0.8
        height: parent.height * 0.8
    }

    // Hover scale
    scale: mouseArea.containsMouse ? 1.05 : 1.0
    Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
}