import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: root

    property real uiScale: SharedConfig.uiScale

    readonly property var theme: SharedConfig.mocha

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.anchors.top:    true
    WlrLayershell.anchors.bottom: true
    WlrLayershell.anchors.left:   true
    WlrLayershell.anchors.right:  true

    color: "transparent"
    visible: _showing

    Scaler        { id: scaler; currentWidth: Screen.width; uiScale: root.uiScale }
    function s(v) { return scaler.s(v) }

    // ─── State ───────────────────────────────────────────────────────────────

    property bool open:     false
    property bool _showing: false

    Timer { id: hideTimer; interval: 600; onTriggered: root._showing = false }

    function setLauncherState(state) {
        Quickshell.execDetached(["bash", "-c", "echo " + state + " > /tmp/qs_launcher_state"])
    }

    Component.onCompleted: setLauncherState("0")

    onOpenChanged: {
        if (open) {
            hideTimer.stop()
            _showing = true
            setLauncherState("1")
            searchInput.text = ""
            clipProc.running = false; clipProc.running = true
            Qt.callLater(function() { searchInput.forceActiveFocus() })
        } else {
            hideTimer.restart()
            setLauncherState("0")
        }
    }

    // ─── Clipboard data ───────────────────────────────────────────────────────

    ListModel { id: allItems }
    ListModel { id: filteredItems }

    function filterItems(query) {
        filteredItems.clear()
        let q = query.toLowerCase().trim()
        for (let i = 0; i < allItems.count; i++) {
            let item = allItems.get(i)
            if (!q || item.preview.toLowerCase().includes(q))
                filteredItems.append({ id: item.id, preview: item.preview, isBinary: item.isBinary })
        }
        list.currentIndex = 0
    }

    function copyItem(idx) {
        if (idx < 0 || idx >= filteredItems.count) return
        let item = filteredItems.get(idx)
        copyProc.itemId = item.id
        copyProc.running = false; copyProc.running = true
        open = false
    }

    // Load clipboard history
    Process {
        id: clipProc
        command: ["bash", "-c", "cliphist list | head -50"]
        stdout: StdioCollector {
            onStreamFinished: {
                allItems.clear()
                let lines = this.text.trim().split("\n")
                for (let i = 0; i < lines.length; i++) {
                    let tab = lines[i].indexOf("\t")
                    if (tab < 0) continue
                    let id      = lines[i].substring(0, tab)
                    let preview = lines[i].substring(tab + 1).trim()
                    if (!preview) continue
                    let isBinary = preview.startsWith("[[")
                    // For binary: extract dimensions if available
                    let label = isBinary
                        ? (preview.match(/\[\[.*?(\d+x\d+)/) ? "[ image " + preview.match(/(\d+x\d+)/)[1] + " ]" : "[ image ]")
                        : preview
                    allItems.append({ id, preview: label, isBinary })
                }
                filterItems(searchInput.text)
            }
        }
    }

    // Copy to clipboard
    Process {
        id: copyProc
        property string itemId: ""
        command: ["bash", "-c",
            "cliphist list | awk -v id=" + JSON.stringify(copyProc.itemId) +
            " -F'\\t' '$1==id' | cliphist decode | wl-copy"
        ]
    }

    // ─── IPC ──────────────────────────────────────────────────────────────────

    Process {
        id: ipcWatcher; running: true
        command: ["bash", "-c",
            "stdbuf -oL inotifywait -m -e close_write,moved_to /tmp/ --include 'qs_clipboard$' 2>/dev/null | " +
            "while read dir action file; do " +
            "  v=$(cat /tmp/qs_clipboard 2>/dev/null); rm -f /tmp/qs_clipboard; " +
            "  printf '%s\\n' \"$v\"; " +
            "done"
        ]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (line) => {
                let cmd = (line || "").trim()
                if      (cmd === "open")   root.open = true
                else if (cmd === "close")  root.open = false
                else if (cmd === "toggle") root.open = !root.open
            }
        }
    }

    // ─── UI ───────────────────────────────────────────────────────────────────

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.55)
        opacity: root.open ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 380 } }
        visible: opacity > 0.001
        MouseArea { anchors.fill: parent; onClicked: root.open = false }
    }

    Rectangle {
        id: card

        property int openH: s(70) + Math.min(list.count, 9) * s(54)

        width:  root.open ? s(660) : s(230)
        height: root.open ? openH  : s(40)
        radius: root.open ? s(24)  : s(20)

        x: Math.round((parent.width  - width)  / 2)
        y: root.open ? Math.round((parent.height - openH) / 2) : s(8)

        Behavior on width  { NumberAnimation { duration: 400; easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1] } }
        Behavior on height { NumberAnimation { duration: 400; easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1] } }
        Behavior on radius { NumberAnimation { duration: 300; easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1] } }
        Behavior on y      { NumberAnimation { duration: 400; easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1] } }

        opacity: root.open ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 220 } }

        color: Qt.rgba(theme.base.r, theme.base.g, theme.base.b, 0.97)

        Rectangle {
            anchors.fill: parent; radius: parent.radius; color: "transparent"
            border.width: 1; border.color: Qt.rgba(theme.surface2.r, theme.surface2.g, theme.surface2.b, 0.35)
        }

        Text {
            anchors.centerIn: card
            text: "󰅍"
            font.family: SharedConfig.nerdFont; font.pixelSize: s(18)
            color: Qt.rgba(theme.subtext0.r, theme.subtext0.g, theme.subtext0.b, 0.5)
            opacity: root.open ? 0 : 1
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        Item {
            anchors { fill: parent; margins: s(16); topMargin: s(14) }
            opacity: root.open ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180 } }
            clip: true

            Column {
                width: parent.width
                spacing: 0

                // ── Search ───────────────────────────────────────────────────
                Row {
                    width: parent.width; height: s(40)
                    spacing: s(10)

                    Text {
                        text: "󰅍"; font.family: SharedConfig.nerdFont; font.pixelSize: s(20)
                        color: theme.subtext0; anchors.verticalCenter: parent.verticalCenter
                    }

                    Item {
                        width: parent.width - s(30) - s(10); height: parent.height

                        Text {
                            visible: searchInput.text.length === 0
                            text: "Search clipboard..."
                            font.family: SharedConfig.monoFont; font.pixelSize: s(15)
                            color: Qt.rgba(theme.subtext0.r, theme.subtext0.g, theme.subtext0.b, 0.4)
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        TextInput {
                            id: searchInput
                            anchors.fill: parent
                            font.family: SharedConfig.monoFont; font.pixelSize: s(15); font.weight: Font.Bold
                            color: theme.text
                            verticalAlignment: TextInput.AlignVCenter
                            selectionColor: Qt.rgba(theme.teal.r, theme.teal.g, theme.teal.b, 0.35)

                            onTextChanged: root.filterItems(text)

                            Keys.onUpPressed:     function(e) { list.decrementCurrentIndex(); e.accepted = true }
                            Keys.onDownPressed:   function(e) { list.incrementCurrentIndex(); e.accepted = true }
                            Keys.onReturnPressed: function(e) { root.copyItem(list.currentIndex); e.accepted = true }
                            Keys.onEscapePressed: function(e) { root.open = false; e.accepted = true }
                        }
                    }
                }

                Rectangle {
                    width: parent.width; height: 1
                    color: Qt.rgba(theme.surface2.r, theme.surface2.g, theme.surface2.b, 0.35)
                }

                // ── Items ────────────────────────────────────────────────────
                ListView {
                    id: list
                    width: parent.width
                    height: Math.min(filteredItems.count, 9) * s(54)
                    clip: true
                    model: filteredItems
                    currentIndex: 0
                    boundsBehavior: Flickable.StopAtBounds
                    Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.Bezier; easing.bezierCurve: [0.16, 1, 0.3, 1] } }
                    onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                    delegate: Rectangle {
                        width: list.width; height: s(54)
                        radius: s(12)
                        color: list.currentIndex === index
                            ? Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.85)
                            : (rowHover.containsMouse
                                ? Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.4)
                                : "transparent")
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Row {
                            anchors { left: parent.left; right: parent.right; margins: s(12); verticalCenter: parent.verticalCenter }
                            spacing: s(10)

                            // Type badge
                            Rectangle {
                                width: s(28); height: s(28); radius: s(8)
                                anchors.verticalCenter: parent.verticalCenter
                                color: model.isBinary
                                    ? Qt.rgba(theme.mauve.r, theme.mauve.g, theme.mauve.b, 0.15)
                                    : Qt.rgba(theme.teal.r,  theme.teal.g,  theme.teal.b,  0.12)

                                Text {
                                    anchors.centerIn: parent
                                    text: model.isBinary ? "󰋩" : "󰉿"
                                    font.family: SharedConfig.nerdFont; font.pixelSize: s(14)
                                    color: model.isBinary ? theme.mauve : theme.teal
                                }
                            }

                            Text {
                                width: parent.width - s(28) - s(10)
                                anchors.verticalCenter: parent.verticalCenter
                                text: model.preview
                                font.family: SharedConfig.monoFont
                                font.pixelSize: s(13); font.weight: model.isBinary ? Font.Normal : Font.Medium
                                color: list.currentIndex === index
                                    ? theme.text
                                    : (model.isBinary ? theme.subtext0 : Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.8))
                                elide: Text.ElideRight
                                Behavior on color { ColorAnimation { duration: 100 } }
                            }
                        }

                        MouseArea {
                            id: rowHover; anchors.fill: parent; hoverEnabled: true
                            onClicked: root.copyItem(index)
                            onContainsMouseChanged: if (containsMouse) list.currentIndex = index
                        }
                    }
                }
            }
        }
    }
}
