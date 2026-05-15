import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

PanelWindow {
    id: root

    // --- Configuration ---
    property var targetScreen: Quickshell.screens[0]
    property var hyprlandMonitor: Hyprland.focusedMonitor

    property string fullScreenshotPath
    property string cropPath

    // Defaults to "ocr" (Text Copy)
    property string currentMode: "ocr"

    screen: targetScreen
    anchors { left: true; right: true; top: true; bottom: true }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    visible: false

    // --- 1. Background Freeze ---
    ScreencopyView {
        captureSource: root.targetScreen
        anchors.fill: parent
        z: -1
    }

    // Flash overlay for capture feedback
    Rectangle {
        id: flashOverlay
        anchors.fill: parent
        color: "white"
        opacity: 0
        z: 50
    }

    Component.onCompleted: {
        const timestamp = Date.now();
        root.fullScreenshotPath = Quickshell.cachePath("snip-full-" + timestamp + ".png");
        root.cropPath = Quickshell.cachePath("snip-crop-" + timestamp + ".png");

        Quickshell.execDetached(["grim", root.fullScreenshotPath]);
        showTimer.start();
    }

    Timer {
        id: showTimer
        interval: 50
        repeat: false
        onTriggered: root.visible = true
    }

    // Flash effect timer
    Timer {
        id: flashTimer
        interval: 80
        onTriggered: flashOverlay.opacity = 0
    }

    // --- 2. Action Logic ---
    Process { id: proc; onExited: Qt.quit() }

    function getMonitorForPoint(x, y) {
        // Find which monitor contains the center of the selection
        const centerX = x + selector.selectionWidth / 2
        const centerY = y + selector.selectionHeight / 2

        for (var i = 0; i < Hyprland.monitors.length; i++) {
            const mon = Hyprland.monitors[i]
            if (centerX >= mon.x && centerX < mon.x + mon.width &&
                centerY >= mon.y && centerY < mon.y + mon.height) {
                return mon
            }
        }
        // Fallback to focused monitor
        return root.hyprlandMonitor
    }

    function executeAction() {
        // Get monitor that contains the selection
        const mon = getMonitorForPoint(selector.selectionX, selector.selectionY)

        // Calculate Scale and coordinates using the correct monitor
        const scale = mon.scale
        const x = Math.round((selector.selectionX + mon.x) * scale)
        const y = Math.round((selector.selectionY + mon.y) * scale)
        const w = Math.round(selector.selectionWidth * scale)
        const h = Math.round(selector.selectionHeight * scale)

        // Ignore tiny accidental drags
        if (w < 10 || h < 10) return;

        root.visible = false; // Vanish immediately

        // Flash effect feedback
        flashOverlay.opacity = 0.3;
        flashTimer.start();

        var cmd = "";

        if (root.currentMode === "ocr") {
            // OCR Pipeline
            cmd = `magick "${root.fullScreenshotPath}" -crop ${w}x${h}+${x}+${y} - | tesseract - - -l eng | wl-copy && notify-send 'OCR Complete' 'Text copied to clipboard'`;
        } else {
            // Lens Pipeline
            cmd = `magick "${root.fullScreenshotPath}" -crop ${w}x${h}+${x}+${y} "${root.cropPath}" && imageLink=$(curl -sF files[]=@"${root.cropPath}" 'https://uguu.se/upload' | jq -r '.files[0].url') && xdg-open "https://lens.google.com/uploadbyurl?url=\${imageLink}"`;
        }

        // Cleanup
        cmd += ` && rm "${root.fullScreenshotPath}" "${root.cropPath}"`;

        proc.command = ["sh", "-c", cmd];
        proc.running = true;
    }

    // --- 3. Visual Selector Layer ---
    Item {
        id: selector
        anchors.fill: parent
        z: 1

        property real selectionX: 0
        property real selectionY: 0
        property real selectionWidth: 0
        property real selectionHeight: 0
        property point startPos
        property real mouseX: 0
        property real mouseY: 0

        // Force redraw when geometry changes
        onSelectionXChanged: guides.requestPaint()
        onSelectionYChanged: guides.requestPaint()
        onSelectionWidthChanged: guides.requestPaint()
        onSelectionHeightChanged: guides.requestPaint()
        onMouseXChanged: guides.requestPaint()
        onMouseYChanged: guides.requestPaint()

        // Dimming Background
        ShaderEffect {
            anchors.fill: parent
            property vector4d selectionRect: Qt.vector4d(selector.selectionX, selector.selectionY, selector.selectionWidth, selector.selectionHeight)
            property real dimOpacity: 0.5
            property vector2d screenSize: Qt.vector2d(selector.width, selector.height)
            property real borderRadius: 4.0
            property real outlineThickness: 1.0
            fragmentShader: Qt.resolvedUrl("dimming.frag.qsb")
        }

        // Crosshairs / Box
        Canvas {
            id: guides
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                if (!mouseArea.pressed) {
                    // Hover Crosshair - pulsing style
                    ctx.strokeStyle = "rgba(255, 255, 255, 0.7)";
                    ctx.lineWidth = 1;
                    ctx.setLineDash([4, 4]);
                    ctx.beginPath();
                    ctx.moveTo(selector.mouseX, 0); ctx.lineTo(selector.mouseX, height);
                    ctx.moveTo(0, selector.mouseY); ctx.lineTo(width, selector.mouseY);
                    ctx.stroke();
                } else {
                    // Selection Box - dashed guides
                    ctx.strokeStyle = "rgba(255, 255, 255, 0.8)";
                    ctx.lineWidth = 1;
                    ctx.setLineDash([4, 4]);
                    ctx.beginPath();
                    ctx.rect(selector.selectionX, selector.selectionY, selector.selectionWidth, selector.selectionHeight);
                    ctx.stroke();

                    // Corner brackets - blue accent
                    ctx.strokeStyle = "#3b8eea";
                    ctx.lineWidth = 2.5;
                    ctx.setLineDash([]);
                    var bracketSize = 16;
                    var x = selector.selectionX;
                    var y = selector.selectionY;
                    var w = selector.selectionWidth;
                    var h = selector.selectionHeight;

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

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.CrossCursor

            onPressed: (mouse) => {
                selector.startPos = Qt.point(mouse.x, mouse.y)
                selector.selectionX = mouse.x
                selector.selectionY = mouse.y
                selector.selectionWidth = 0
                selector.selectionHeight = 0
            }

            onPositionChanged: (mouse) => {
                selector.mouseX = mouse.x
                selector.mouseY = mouse.y

                if (pressed) {
                    selector.selectionX = Math.min(selector.startPos.x, mouse.x)
                    selector.selectionY = Math.min(selector.startPos.y, mouse.y)
                    selector.selectionWidth = Math.abs(mouse.x - selector.startPos.x)
                    selector.selectionHeight = Math.abs(mouse.y - selector.startPos.y)
                }
            }

            onReleased: root.executeAction()
        }

        // Live Dimension Readout
        Text {
            id: dimReadout
            visible: mouseArea.pressed && selector.selectionWidth > 20 && selector.selectionHeight > 20
            z: 5
            anchors.horizontalCenter: parent.horizontalCenter
            y: selector.selectionY + selector.selectionHeight + 10

            text: Math.round(selector.selectionWidth) + " × " + Math.round(selector.selectionHeight)
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

    // --- 4. Control Bar  ---
    Rectangle {
        id: controlBar
        z: 10 // Above the mouse area
        width: 200
        height: 44
        radius: 22 // Pill shape
        color: "#AA11111b" // Semi-transparent dark
        border.color: "#33ffffff"
        border.width: 1

        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 60
        }

        Row {
            anchors.centerIn: parent
            spacing: 8

            // OCR Button (Default)
            Rectangle {
                id: ocrBtn
                width: 90
                height: 36
                radius: 18
                color: root.currentMode === "ocr" ? "#3b8eea" : "transparent"
                border.color: root.currentMode === "ocr" ? "#3b8eea" : "#44ffffff"
                border.width: 1
                scale: ocrBtn.containsMouse ? 1.08 : 1.0
                Behavior on scale { NumberAnimation { duration: 150 } }
                Behavior on color { ColorAnimation { duration: 150 } }

                property bool containsMouse: false

                Text {
                    anchors.centerIn: parent
                    text: "Text (OCR)"
                    color: "white"
                    font.bold: root.currentMode === "ocr"
                    font.pixelSize: 13
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: ocrBtn.containsMouse = true
                    onExited: ocrBtn.containsMouse = false
                    onClicked: root.currentMode = "ocr"
                }
            }

            // Separator
            Rectangle {
                width: 1
                height: 16
                color: "#44ffffff"
                anchors.verticalCenter: parent.verticalCenter
            }

            // Lens Button
            Rectangle {
                id: lensBtn
                width: 90
                height: 36
                radius: 18
                color: root.currentMode === "lens" ? "#3b8eea" : "transparent"
                border.color: root.currentMode === "lens" ? "#3b8eea" : "#44ffffff"
                border.width: 1
                scale: lensBtn.containsMouse ? 1.08 : 1.0
                Behavior on scale { NumberAnimation { duration: 150 } }
                Behavior on color { ColorAnimation { duration: 150 } }

                property bool containsMouse: false

                Text {
                    anchors.centerIn: parent
                    text: "Search"
                    color: "white"
                    font.bold: root.currentMode === "lens"
                    font.pixelSize: 13
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: lensBtn.containsMouse = true
                    onExited: lensBtn.containsMouse = false
                    onClicked: root.currentMode = "lens"
                }
            }
        }
    }

    // --- 5. Keyboard Hints ---
    Rectangle {
        anchors {
            bottom: parent.bottom
            right: parent.right
            bottomMargin: 20
            rightMargin: 20
        }
        color: "#33ffffff"
        radius: 4
        implicitWidth: 34
        implicitHeight: 20

        Text {
            anchors.centerIn: parent
            text: "Esc"
            color: "#aaa"
            font.pixelSize: 11
            font.family: "JetBrains Mono, monospace"
        }
        opacity: 0.7
    }

    // --- 6. Escape Hatch ---
    Shortcut {
        sequence: "Escape"
        onActivated: () => {
            Quickshell.execDetached(["rm", root.fullScreenshotPath]);
            Qt.quit();
        }
    }
}
