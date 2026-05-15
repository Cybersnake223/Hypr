import QtQuick

Item {
    id: root

    signal regionSelected(real x, real y, real width, real height)

    // Shader properties
    property real dimOpacity: 0.6
    property real borderRadius: 10.0
    property real outlineThickness: 2.0
    property url fragmentShader: Qt.resolvedUrl("dimming.frag.qsb")

    property point startPos

    // Selection Box Geometry
    property real selectionX: 0
    property real selectionY: 0
    property real selectionWidth: 0
    property real selectionHeight: 0

    property real targetX: 0
    property real targetY: 0
    property real targetWidth: 0
    property real targetHeight: 0

    // Mouse Tracking for Crosshair
    property real mouseX: 0
    property real mouseY: 0

    // Animations
    Behavior on selectionX { SpringAnimation { spring: 4; damping: 0.4 } }
    Behavior on selectionY { SpringAnimation { spring: 4; damping: 0.4 } }
    Behavior on selectionHeight { SpringAnimation { spring: 4; damping: 0.4 } }
    Behavior on selectionWidth { SpringAnimation { spring: 4; damping: 0.4 } }

    // Redraw guides when anything moves
    onSelectionXChanged: guides.requestPaint()
    onSelectionYChanged: guides.requestPaint()
    onSelectionWidthChanged: guides.requestPaint()
    onSelectionHeightChanged: guides.requestPaint()
    onMouseXChanged: guides.requestPaint()
    onMouseYChanged: guides.requestPaint()

    // 1. Dimming Background
    ShaderEffect {
        anchors.fill: parent
        z: 0
        property vector4d selectionRect: Qt.vector4d(root.selectionX, root.selectionY, root.selectionWidth, root.selectionHeight)
        property real dimOpacity: root.dimOpacity
        property vector2d screenSize: Qt.vector2d(root.width, root.height)
        property real borderRadius: root.borderRadius
        property real outlineThickness: root.outlineThickness
        fragmentShader: root.fragmentShader
    }

    // 3. Alignment Guides (Canvas)
    Canvas {
        id: guides
        anchors.fill: parent
        z: 2

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            // Crosshair / Selection styling
            ctx.strokeStyle = "rgba(255, 255, 255, 0.9)";
            ctx.lineWidth = 1.5;
            ctx.setLineDash([5, 5]);

            if (!mouseArea.pressed) {
                // MODE 1: Crosshair at mouse cursor (Before clicking)
                // Vertical
                ctx.beginPath();
                ctx.moveTo(root.mouseX, 0);
                ctx.lineTo(root.mouseX, root.height);
                // Horizontal
                ctx.moveTo(0, root.mouseY);
                ctx.lineTo(root.width, root.mouseY);
                ctx.stroke();
            } else {
                // MODE 2: Guides around the selection box (While dragging)
                ctx.beginPath();
                // Vertical Left & Right
                ctx.moveTo(root.selectionX, 0);
                ctx.lineTo(root.selectionX, root.height);
                ctx.moveTo(root.selectionX + root.selectionWidth, 0);
                ctx.lineTo(root.selectionX + root.selectionWidth, root.height);
                // Horizontal Top & Bottom
                ctx.moveTo(0, root.selectionY);
                ctx.lineTo(root.width, root.selectionY);
                ctx.moveTo(0, root.selectionY + root.selectionHeight);
                ctx.lineTo(root.width, root.selectionY + root.selectionHeight);
                ctx.stroke();

                // Corner brackets
                ctx.strokeStyle = "#3b8eea";
                ctx.lineWidth = 2.5;
                ctx.setLineDash([]);
                var bracketSize = 16;
                var x = root.selectionX;
                var y = root.selectionY;
                var w = root.selectionWidth;
                var h = root.selectionHeight;

                // Top-left
                ctx.beginPath();
                ctx.moveTo(x, y + bracketSize);
                ctx.lineTo(x, y);
                ctx.lineTo(x + bracketSize, y);
                ctx.stroke();

                // Top-right
                ctx.beginPath();
                ctx.moveTo(x + w - bracketSize, y);
                ctx.lineTo(x + w, y);
                ctx.lineTo(x + w, y + bracketSize);
                ctx.stroke();

                // Bottom-left
                ctx.beginPath();
                ctx.moveTo(x, y + h - bracketSize);
                ctx.lineTo(x, y + h);
                ctx.lineTo(x + bracketSize, y + h);
                ctx.stroke();

                // Bottom-right
                ctx.beginPath();
                ctx.moveTo(x + w - bracketSize, y + h);
                ctx.lineTo(x + w, y + h);
                ctx.lineTo(x + w, y + h - bracketSize);
                ctx.stroke();
            }
        }
    }

    // 3. Mouse Interaction
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        z: 3
        hoverEnabled: true // <--- Critical for tracking before click

        Timer {
            id: updateTimer
            interval: 16
            repeat: true
            running: mouseArea.pressed
            onTriggered: {
                root.selectionX = root.targetX
                root.selectionY = root.targetY
                root.selectionWidth = root.targetWidth
                root.selectionHeight = root.targetHeight
            }
        }

        onPressed: (mouse) => {
            root.startPos = Qt.point(mouse.x, mouse.y)
            root.targetX = mouse.x
            root.targetY = mouse.y
            root.targetWidth = 0
            root.targetHeight = 0
            guides.requestPaint() // Force redraw to switch modes
        }

        onPositionChanged: (mouse) => {
            // Always update global mouse trackers for the crosshair
            root.mouseX = mouse.x
            root.mouseY = mouse.y

            if (pressed) {
                const x = Math.min(root.startPos.x, mouse.x)
                const y = Math.min(root.startPos.y, mouse.y)
                const width = Math.abs(mouse.x - root.startPos.x)
                const height = Math.abs(mouse.y - root.startPos.y)

                root.targetX = x
                root.targetY = y
                root.targetWidth = width
                root.targetHeight = height
            }
        }

        onReleased: {
            root.regionSelected(
                Math.round(root.selectionX),
                                Math.round(root.selectionY),
                                Math.round(root.selectionWidth),
                                Math.round(root.selectionHeight)
            )
        }
    }

    // 4. Live Dimension Readout
    Text {
        id: dimensionLabel
        visible: mouseArea.pressed && root.selectionWidth > 20 && root.selectionHeight > 20
        z: 10
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.selectionY + root.selectionHeight + 12

        text: Math.round(root.selectionWidth) + " × " + Math.round(root.selectionHeight)
        color: "#ffffff"
        styleColor: "#000000"
        style: Text.Outline
        font.pixelSize: 13
        font.family: "JetBrains Mono, monospace"
        font.bold: true
        opacity: 0.95
        Behavior on opacity { NumberAnimation { duration: 100 } }
    }
}
