import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import QtQuick.Effects

Variants {
    model: Quickshell.screens
    
    delegate: Component {
        PanelWindow {
            id: barWindow

            required property var modelData

            // Bind this specific bar instance to the dynamically assigned screen
            screen: modelData
            WlrLayershell.namespace: "qs-topbar"
            
            anchors {
                top: true
                left: true
                right: true
            }
            
            // --- Responsive Scaling Logic ---
            Scaler {
                id: scaler
                currentWidth: barWindow.width
                uiScale: barWindow.uiScale
            }

            property real uiScale: SharedConfig.uiScale

            readonly property var mocha: SharedConfig.mocha

            property real baseScale: scaler.baseScale
            
            // Helper function mapped to the external scaler
            function s(val) { 
                return scaler.s(val); 
            }

            property int barHeight: s(36)

            // THICKER BAR, MINIMAL MARGINS (Scaled)
            implicitHeight: barHeight
            margins { top: 0; bottom: s(6); left: s(2); right: s(2) }
            
            // exclusiveZone = height + top margin
            exclusiveZone: barHeight + s(2)
            color: "transparent"

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
                    GradientStop { position: 0.5; color: Qt.rgba(mocha.text.r, mocha.text.g, mocha.text.b, 0.22) }
                    GradientStop { position: 0.7; color: "transparent" }
                }
            }

            // Dynamic Matugen Palette (aliased to shared tokens for consistency)
            readonly property color base75: SharedConfig.pillBg
            readonly property color text05: SharedConfig.hairline
            readonly property color text08: SharedConfig.hairline
            readonly property color surface2_09: SharedConfig.surface2Soft
            readonly property color surface1_06: SharedConfig.pillBgHover
            readonly property color surface1_04: SharedConfig.pillBgIdle
            readonly property color overlay0_09: SharedConfig.overlay0Soft
            readonly property color surface0_04: SharedConfig.surface0Soft

            // Prevents repeaters (kkkkkkkkkkkTray) from flickering on data updates
            property bool fastPollerLoaded: false
            
            property bool isDataReady: fastPollerLoaded

            // Reveal the right cluster when data arrives (or after 1.5s fallback)
            Timer {
                running: !barWindow.fastPollerLoaded
                interval: 1500
                onTriggered: barWindow.fastPollerLoaded = true
            }
            Connections {
                target: SharedConfig
                enabled: !barWindow.fastPollerLoaded
                function onKbLayoutChanged() {
                    barWindow.fastPollerLoaded = true
                }
            }

            // Triggers layout animations immediately to feel fast
            property bool isStartupReady: false
            Component.onCompleted: barWindow.isStartupReady = true

    ListModel { id: workspacesModel }

            // Derived properties for UI logic
            property int batCap: parseInt(SharedConfig.batPercent) || 0
            property bool isCharging: SharedConfig.batStatus === "Charging" || SharedConfig.batStatus === "Full"
            
            property color batDynamicColor: {
                if (isCharging) return mocha.green;
                if (batCap <= 20) return mocha.red;
                return mocha.text;
            }
            readonly property color wsActiveColor: mocha.mauve

            // ==========================================
            // DATA FETCHING 
            // ==========================================

            // Workspaces --------------------------------
            Process {
                id: wsDaemon
                command: ["bash", "-c", "~/.config/quickshell/dynamic/scripts/workspaces.sh"]
                running: true
                onExited: running = true
            }

            Process {
                id: wsReader
                command: ["cat", "/tmp/qs_workspaces.json"]
                stdout: StdioCollector {
                    onStreamFinished: {
                        let txt = this.text.trim();
                        if (txt !== "") {
                            try { 
                                let newData = JSON.parse(txt);
                                if (workspacesModel.count !== newData.length) {
                                    workspacesModel.clear();
                                    for (let i = 0; i < newData.length; i++) {
                                        workspacesModel.append({ "wsId": newData[i].id.toString(), "wsState": newData[i].state });
                                    }
                                } else {
                                    for (let i = 0; i < newData.length; i++) {
                                        if (workspacesModel.get(i).wsState !== newData[i].state) {
                                            workspacesModel.setProperty(i, "wsState", newData[i].state);
                                        }
                                        if (workspacesModel.get(i).wsId !== newData[i].id.toString()) {
                                            workspacesModel.setProperty(i, "wsId", newData[i].id.toString());
                                        }
                                    }
                                }
                            } catch(e) { console.warn(e) }
                                    }
                                }
                            }
            }

            Process {
                id: wsWatcher
                running: true
                command: ["bash", "-c", "inotifywait -qq -e close_write,modify /tmp/qs_workspaces.json"]
                onExited: {
                    wsReader.running = true;
                    running = true;
                }
            }



            // ==========================================
            // UI LAYOUT
            // ==========================================
                // The real dynamic island is rendered by DynamicIsland.qml on the Overlay
                // layer. This invisible item only reserves horizontal space so the
                // left/right sections never overlap the real island.
                Item {
                    id: centerBox
                    anchors.centerIn: parent

                    height: barWindow.barHeight
                    width: Math.min(barWindow.s(260), Math.max(barWindow.s(120), Screen.width * 0.20))
                    Behavior on width { NumberAnimation { duration: 450; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }
                }

                // ---------------- LEFT ----------------
                RowLayout {
                    id: leftLayout
                    anchors.left: parent.left
                    anchors.right: centerBox.left  // Hard boundary to prevent overlaps
                    anchors.rightMargin: barWindow.s(6)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: barWindow.s(6)

                    // Staggered Main Transition
                    property bool showLayout: false
                    opacity: showLayout ? 1 : 0
                    transform: Translate {
                        x: leftLayout.showLayout ? 0 : barWindow.s(-30)
                        Behavior on x { NumberAnimation { duration: 600; easing.type: Easing.OutBack; easing.overshoot: 1.1 } }
                    }
                    
                    Timer {
                        running: barWindow.isStartupReady
                        interval: 10
                        onTriggered: leftLayout.showLayout = true
                    }

                    Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }

                    property int moduleHeight: barWindow.barHeight

                    // Workspaces 
                    Rectangle {
                        color: barWindow.base75
                        radius: barWindow.s(14); border.width: 1; border.color: barWindow.text05
                        Layout.preferredHeight: parent.moduleHeight
                        clip: true

                        

                        property real targetWidth: workspacesModel.count > 0 ? wsLayout.width + barWindow.s(20) : 0
                        Layout.preferredWidth: targetWidth
                        visible: targetWidth > 0
                        opacity: workspacesModel.count > 0 ? 1 : 0
                        
                        Behavior on opacity { NumberAnimation { duration: 300 } }

                        Row {
                            id: wsLayout
                            anchors.centerIn: parent
                            spacing: barWindow.s(6)
                            
                            Repeater {
                                model: workspacesModel
                                delegate: Rectangle {
                                    id: wsPill
                                    property bool isHovered: wsPillMouse.containsMouse
                                    
                                    property string stateLabel: model.wsState
                                    property string wsName: model.wsId
                                    
                                    property bool isEmpty: stateLabel === "empty"
                                    visible: !isEmpty
                                    property real targetWidth: isEmpty ? 0 : barWindow.s(28)
                                    width: targetWidth
                                    Behavior on targetWidth { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                                    
                                    height: barWindow.s(34); radius: barWindow.s(11)
                                    
                                    color: stateLabel === "active" 
                                            ? "transparent" 
                                            : (isHovered 
                                                ? barWindow.overlay0_09 
                                                : (stateLabel === "occupied" 
                                                    ? barWindow.surface2_09 
                                                    : "transparent"))

                                    scale: isHovered && stateLabel !== "active" ? 1.08 : 1.0
                                    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

                                    Rectangle {
                                        id: wsActiveFill
                                        anchors.centerIn: parent
                                        width: parent.width
                                        height: barWindow.s(28)
                                        radius: barWindow.s(9)
                                        visible: stateLabel === "active"
                                        clip: true
                                        gradient: Gradient {
                                            orientation: Gradient.Horizontal
                                            GradientStop { position: 0.0; color: barWindow.wsActiveColor; Behavior on color { enabled: barWindow.visible; ColorAnimation { duration: 300 } } }
                                            GradientStop { position: 1.0; color: Qt.lighter(barWindow.wsActiveColor, 1.3); Behavior on color { enabled: barWindow.visible; ColorAnimation { duration: 300 } } }
                                        }

                                        // Slow light-glint sweep
                                        Rectangle {
                                            id: wsSheen
                                            width: wsActiveFill.width * 0.45
                                            height: wsActiveFill.height * 2
                                            y: -wsActiveFill.height * 0.5
                                            rotation: 15
                                            color: "transparent"
                                            gradient: Gradient {
                                                GradientStop { position: 0.0; color: "transparent" }
                                                GradientStop { position: 0.5; color: Qt.rgba(barWindow.mocha.text.r, barWindow.mocha.text.g, barWindow.mocha.text.b, 0.30) }
                                                GradientStop { position: 1.0; color: "transparent" }
                                            }
                                            SequentialAnimation on x {
                                                running: wsActiveFill.visible
                                                loops: Animation.Infinite
                                                PauseAnimation { duration: 2200 }
                                                NumberAnimation { from: -width; to: wsActiveFill.width + width; duration: 800; easing.type: Easing.InOutQuad }
                                                PauseAnimation { duration: 2200 }
                                            }
                                        }
                                    }

                                    Behavior on color { enabled: barWindow.visible; ColorAnimation { duration: 250 } }

                                    Text {
                                        anchors.centerIn: parent
                                        text: wsName === "special" ? "󱂬" : wsName
                                        font.family: wsName === "special" ? SharedConfig.nerdFont : SharedConfig.monoFont
                                        font.pixelSize: wsName === "special" ? barWindow.s(14) : barWindow.s(12)
                                        font.weight: stateLabel === "active" ? Font.Black : (stateLabel === "occupied" ? Font.Bold : Font.Medium)
                                        
                                        color: wsName === "special"
                                            ? (stateLabel === "active" ? "#000000" : mocha.green)
                                            : (stateLabel === "active" 
                                                ? "#000000" 
                                                : (isHovered 
                                                    ? mocha.crust 
                                                    : (stateLabel === "occupied" ? mocha.text : mocha.overlay0)))
                                        
                                    Behavior on color { enabled: barWindow.visible; ColorAnimation { duration: 250 } }
                                    }
                                    MouseArea {
                                         id: wsPillMouse
                                         hoverEnabled: true
                                         anchors.fill: parent
                                         cursorShape: Qt.PointingHandCursor
                                         onClicked: {
                                            if (wsName === "special")
                                                Quickshell.execDetached(["bash", "-c", "hyprctl dispatch togglespecialworkspace magic"])
                                            else
                                                Quickshell.execDetached(["bash", "-c", "~/.config/hypr/scripts/qs_manager.sh " + wsName])
                                        }
                                    }
                                }
                            }
                        }
                    }            

                    // Upgradable Packages
                    Rectangle {
                        id: pkgPill
                        property bool isHovered: pkgPillMouse.containsMouse
                        property bool hasUpdates: SharedConfig.pkgUpdates > 0

                        color: barWindow.base75
                        radius: barWindow.s(14); border.width: 1; border.color: barWindow.text05
                        Layout.preferredHeight: parent.moduleHeight
                        clip: true

                        property real targetWidth: pkgLayout.width + barWindow.s(20)
                        Layout.preferredWidth: targetWidth
                        Behavior on targetWidth { NumberAnimation { duration: 400; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }

                        scale: isHovered ? 1.05 : 1.0
                        Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }

                        Row {
                            id: pkgLayout
                            anchors.centerIn: parent
                            spacing: barWindow.s(8)

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: pkgPill.hasUpdates ? "󰏔" : "󰸟"
                                font.family: SharedConfig.nerdFont
                                font.pixelSize: barWindow.s(16)
                                color: pkgPill.hasUpdates ? mocha.peach : mocha.green
                                Behavior on color { enabled: barWindow.visible; ColorAnimation { duration: 250 } }
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: pkgPill.hasUpdates ? SharedConfig.pkgUpdates.toString() : "0"
                                font.family: SharedConfig.monoFont
                                font.pixelSize: barWindow.s(13)
                                font.weight: Font.Black
                                color: pkgPill.hasUpdates ? mocha.text : mocha.overlay0
                                Behavior on color { enabled: barWindow.visible; ColorAnimation { duration: 250 } }
                            }
                        }

                        MouseArea { id: pkgPillMouse; anchors.fill: parent; hoverEnabled: true }
                    }

                    Item { Layout.fillWidth: true }

                }

                // ---------------- RIGHT ----------------
                RowLayout {
                    id: rightLayout
                    anchors.right: parent.right
                    anchors.left: centerBox.right // Hard boundary to prevent overlaps
                    anchors.leftMargin: barWindow.s(6)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: barWindow.s(6)

                    // Staggered Right Transition
                    property bool showLayout: false
                    opacity: showLayout ? 1 : 0
                    transform: Translate {
                        x: rightLayout.showLayout ? 0 : barWindow.s(30)
                        Behavior on x { NumberAnimation { duration: 600; easing.type: Easing.OutBack; easing.overshoot: 1.1 } }
                    }
                    
                    Timer {
                        running: barWindow.isStartupReady && barWindow.isDataReady
                        interval: 250
                        onTriggered: rightLayout.showLayout = true
                    }

                    Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }

                    // Dynamic Spacer to gently push the tray and system pills completely to the right edge
                    Item { Layout.fillWidth: true } 

                    // Dedicated System Tray Pill
                    Rectangle {
                        Layout.preferredHeight: barWindow.barHeight
                        radius: barWindow.s(14)
                        border.color: barWindow.text08
                        border.width: 1
                        color: barWindow.base75

                        

                        property real targetWidth: trayRepeater.count > 0 ? trayLayout.width + barWindow.s(20) : 0
                        Layout.preferredWidth: targetWidth
                        Behavior on targetWidth { NumberAnimation { duration: 400; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }
                        
                        visible: targetWidth > 0
                        opacity: targetWidth > 0 ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 300 } }

                        Row {
                            id: trayLayout
                            anchors.centerIn: parent
                            spacing: barWindow.s(10)

                            Repeater {
                                id: trayRepeater
                                model: SystemTray.items
                                delegate: Image {
                                    id: trayIcon
                                    source: modelData.icon || ""
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                    
                                    sourceSize: Qt.size(barWindow.s(18), barWindow.s(18))
                                    width: barWindow.s(18)
                                    height: barWindow.s(18)
                                    anchors.verticalCenter: parent.verticalCenter
                                    
                                    property bool isHovered: trayMouse.containsMouse
                                    opacity: isHovered ? 1.0 : 0.8
                                    scale: isHovered ? 1.15 : 1.0
                                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1.0 } }

                                    QsMenuAnchor {
                                        id: menuAnchor
                                        anchor.window: barWindow
                                        anchor.item: trayIcon
                                        anchor.edges: Edges.Bottom
                                        anchor.gravity: Edges.Bottom | Edges.Right
                                        menu: modelData.menu
                                    }

                                    MouseArea {
                                        id: trayMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                                        onClicked: mouse => {
                                            if (mouse.button === Qt.LeftButton) {
                                                modelData.activate();
                                            } else if (mouse.button === Qt.MiddleButton) {
                                                modelData.secondaryActivate();
                                            } else if (mouse.button === Qt.RightButton) {
                                                if (modelData.menu) {
                                                    menuAnchor.open();
                                                } else if (typeof modelData.contextMenu === "function") {
                                                    modelData.contextMenu(mouse.x, mouse.y);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // System Elements Pill
                    Rectangle {
                        Layout.preferredHeight: barWindow.barHeight
                        radius: barWindow.s(14)
                        border.color: barWindow.text08
                        border.width: 1
                        color: barWindow.base75
                        clip: true

                        

                        property real targetWidth: sysLayout.width + barWindow.s(20)
                        Layout.preferredWidth: targetWidth
                        Layout.maximumWidth: targetWidth

                        Row {
                            id: sysLayout
                            anchors.centerIn: parent
                            spacing: barWindow.s(8) 

                            property int pillHeight: barWindow.s(34)

                            // KB
                            Rectangle {
                                property bool isHovered: kbMouse.containsMouse
                                color: isHovered ? barWindow.surface1_06 : barWindow.surface1_04
                                radius: barWindow.s(12); height: sysLayout.pillHeight;
                                clip: true

                                property real targetWidth: kbLayoutRow.width + barWindow.s(20)
                                width: targetWidth
                                Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }
                                
                                scale: isHovered ? 1.05 : 1.0
                                Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }
                                Behavior on color { enabled: barWindow.visible; ColorAnimation { duration: 200 } }

                                Row { 
                                    id: kbLayoutRow; anchors.centerIn: parent; spacing: barWindow.s(8)
                                    Text { anchors.verticalCenter: parent.verticalCenter; text: "󰌌"; font.family: SharedConfig.nerdFont; font.pixelSize: barWindow.s(16); color: mocha.text }
                                    Text { anchors.verticalCenter: parent.verticalCenter; text: SharedConfig.kbLayout; font.family: SharedConfig.monoFont; font.pixelSize: barWindow.s(13); font.weight: Font.Black; color: mocha.text }
                                }
                            MouseArea { id: kbMouse; anchors.fill: parent; hoverEnabled: true; onClicked: Quickshell.execDetached(["hyprctl", "switchxkblayout", "main", "next"]) }
                        }

                        Rectangle { width: 1; height: sysLayout.pillHeight * 0.55; radius: 1; color: SharedConfig.hairline }

                        // Mic
                            Rectangle {
                                property bool isHovered: micMouse.containsMouse
                                color: isHovered ? barWindow.surface1_06 : barWindow.surface1_04
                                radius: barWindow.s(12); height: sysLayout.pillHeight;
                                clip: true

                                property real targetWidth: micLayoutRow.width + barWindow.s(20)
                                width: targetWidth
                                Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }

                                scale: isHovered ? 1.05 : 1.0
                                Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }
                                Behavior on color { enabled: barWindow.visible; ColorAnimation { duration: 200 } }

                                Row {
                                    id: micLayoutRow; anchors.centerIn: parent; spacing: barWindow.s(8)
                                    Text { anchors.verticalCenter: parent.verticalCenter; text: SharedConfig.micIcon; font.family: SharedConfig.nerdFont; font.pixelSize: barWindow.s(16); color: SharedConfig.micMuted ? mocha.red : mocha.text }
                                    Text { anchors.verticalCenter: parent.verticalCenter; text: SharedConfig.micPercent + "%"; font.family: SharedConfig.monoFont; font.pixelSize: barWindow.s(13); font.weight: Font.Black; color: SharedConfig.micMuted ? mocha.red : mocha.text }
                                }
                            MouseArea { id: micMouse; anchors.fill: parent; hoverEnabled: true; onClicked: Quickshell.execDetached(["bash", "-c", "~/.config/quickshell/dynamic/scripts/osd_volume.sh mic"]) }
                        }

                        Rectangle { width: 1; height: sysLayout.pillHeight * 0.55; radius: 1; color: SharedConfig.hairline }

                        // Volume
                            Rectangle {
                                property bool isHovered: volMouse.containsMouse
                                color: isHovered ? barWindow.surface1_06 : barWindow.surface1_04
                                radius: barWindow.s(12); height: sysLayout.pillHeight;
                                clip: true

                                property real targetWidth: volLayoutRow.width + barWindow.s(20)
                                width: targetWidth
                                Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }

                                scale: isHovered ? 1.05 : 1.0
                                Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }
                                Behavior on color { enabled: barWindow.visible; ColorAnimation { duration: 200 } }

                                Row {
                                    id: volLayoutRow; anchors.centerIn: parent; spacing: barWindow.s(8)
                                    Text { anchors.verticalCenter: parent.verticalCenter; text: SharedConfig.volIcon; font.family: SharedConfig.nerdFont; font.pixelSize: barWindow.s(16); color: SharedConfig.volMuted ? mocha.red : mocha.text }
                                    Text { anchors.verticalCenter: parent.verticalCenter; text: SharedConfig.volPercent + "%"; font.family: SharedConfig.monoFont; font.pixelSize: barWindow.s(13); font.weight: Font.Black; color: SharedConfig.volMuted ? mocha.red : mocha.text }
                                }
                            MouseArea { id: volMouse; anchors.fill: parent; hoverEnabled: true; onClicked: Quickshell.execDetached(["bash", "-c", "~/.config/quickshell/dynamic/scripts/osd_volume.sh mute"]) }
                        }

                        Rectangle { width: 1; height: sysLayout.pillHeight * 0.55; radius: 1; color: SharedConfig.hairline }

                            // Battery (or Power button for Desktop)
                            Rectangle {
                                property bool isHovered: batMouse.containsMouse
                                color: isHovered ? barWindow.surface1_06 : barWindow.surface0_04; 
                                radius: barWindow.s(12); height: barWindow.s(34);
                                clip: true

                                property real targetWidth: SharedConfig.isDesktop ? barWindow.s(20) : batLayoutRow.width + barWindow.s(20)
                                width: targetWidth
                                Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }

                                scale: isHovered ? 1.05 : 1.0
                                Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.Bezier; easing.bezierCurve: SharedConfig.animEaseOut } }
                                Behavior on color { enabled: barWindow.visible; ColorAnimation { duration: 200 } }

                                Row { 
                                    id: batLayoutRow; anchors.centerIn: parent; spacing: barWindow.s(8)
                                    Text { 
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: SharedConfig.isDesktop ? "" : SharedConfig.batIcon; 
                                        font.family: SharedConfig.nerdFont; font.pixelSize: SharedConfig.isDesktop ? barWindow.s(14) : barWindow.s(13); 
                                        color: barWindow.batDynamicColor
                                        Behavior on color { enabled: barWindow.visible; ColorAnimation { duration: 300 } }
                                    }
                                    Text { 
                                        anchors.verticalCenter: parent.verticalCenter
                                        visible: !SharedConfig.isDesktop
                                        text: SharedConfig.batPercent; font.family: SharedConfig.monoFont; font.pixelSize: barWindow.s(13); font.weight: Font.Black; 
                                        color: barWindow.batDynamicColor
                                        Behavior on color { enabled: barWindow.visible; ColorAnimation { duration: 300 } }
                                    }
                                }
                            MouseArea { id: batMouse; anchors.fill: parent; hoverEnabled: true }
                            }
                        }
                   } 
                }
            }
        }
    }
