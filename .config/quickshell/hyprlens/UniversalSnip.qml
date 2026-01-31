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

    // --- 2. Action Logic ---
    Process { id: proc; onExited: Qt.quit() }

    function executeAction() {
        // Calculate Scale
        const scale = root.hyprlandMonitor.scale;
        const x = Math.round((selector.selectionX + root.hyprlandMonitor.x) * scale);
        const y = Math.round((selector.selectionY + root.hyprlandMonitor.y) * scale);
        const w = Math.round(selector.selectionWidth * scale);
        const h = Math.round(selector.selectionHeight * scale);

        // Ignore tiny accidental drags
        if (w < 10 || h < 10) return;

        root.visible = false; // Vanish immediately

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
                ctx.strokeStyle = "rgba(255, 255, 255, 0.8)";
                ctx.lineWidth = 1;
                ctx.setLineDash([4, 4]);
                ctx.beginPath();

                if (!mouseArea.pressed) {
                    // Hover Crosshair
                    ctx.moveTo(selector.mouseX, 0); ctx.lineTo(selector.mouseX, height);
                    ctx.moveTo(0, selector.mouseY); ctx.lineTo(width, selector.mouseY);
                } else {
                    // Selection Box
                    ctx.rect(selector.selectionX, selector.selectionY, selector.selectionWidth, selector.selectionHeight);
                }
                ctx.stroke();
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
                    var x = Math.min(selector.startPos.x, mouse.x)
                    var y = Math.min(selector.startPos.y, mouse.y)
                    var w = Math.abs(mouse.x - selector.startPos.x)
                    var h = Math.abs(mouse.y - selector.startPos.y)

                    selector.selectionX = x
                    selector.selectionY = y
                    selector.selectionWidth = w
                    selector.selectionHeight = h
                }
            }

            onReleased: root.executeAction()
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
                width: 90
                height: 36
                radius: 18
                color: root.currentMode === "ocr" ? "#3b8eea" : "transparent" // Blue if active

                Text {
                    anchors.centerIn: parent
                    text: "Text (OCR)"
                    color: "white"
                    font.bold: root.currentMode === "ocr"
                    font.pixelSize: 13
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
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
                width: 90
                height: 36
                radius: 18
                color: root.currentMode === "lens" ? "#3b8eea" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "Search"
                    color: "white"
                    font.bold: root.currentMode === "lens"
                    font.pixelSize: 13
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.currentMode = "lens"
                }
            }
        }
    }

    // --- 5. Escape Hatch ---
    Shortcut {
        sequence: "Escape"
        onActivated: () => {
            Quickshell.execDetached(["rm", root.fullScreenshotPath]);
            Qt.quit();
        }
    }
}
