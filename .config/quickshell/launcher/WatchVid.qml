import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: root

    property bool open: false
    property bool _showing: false
    property string searchText: ""

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.anchors.top: true
    WlrLayershell.anchors.bottom: true
    WlrLayershell.anchors.left: true
    WlrLayershell.anchors.right: true

    focusable: true
    color: "transparent"
    visible: _showing

    MatugenColors { id: theme }

    Timer {
        id: hideTimer
        interval: 500
        onTriggered: root._showing = false
    }

    onOpenChanged: {
        if (open) {
            hideTimer.stop()
            root._showing = true
            root.searchText = ""
            searchInput.text = ""
            loadVideos()
            filterVideos("")
            Qt.callLater(function() { searchInput.forceActiveFocus() })
        } else {
            hideTimer.restart()
        }
    }

    IpcHandler {
        target: "watchvid"
        function toggle() { root.open = !root.open }
        function show() { root.open = true }
        function hide() { root.open = false }
    }
    IpcWatcher {
        watchName: "watchvid"
        onOpenRequested: root.open = true
        onCloseRequested: root.open = false
        onToggleRequested: root.open = !root.open
    }

    ListModel { id: m }
    ListModel { id: filteredModel }

    function filterVideos(query) {
        filteredModel.clear()
        let q = query.trim().toLowerCase()
        for (let i = 0; i < m.count; i++) {
            let item = m.get(i)
            if (!q || item.label.toLowerCase().indexOf(q) >= 0)
                filteredModel.append({ label: item.label, path: item.path })
        }
        list.currentIndex = 0
    }

    function loadVideos() {
        m.clear()
        m.append({ label: "Loading...", path: "" })
        listProc.running = false
        listProc.running = true
    }

    function selectItem(idx) {
        if (idx < 0 || idx >= filteredModel.count) return
        let item = filteredModel.get(idx)
        if (!item.path) return
        playProc.path = item.path
        playProc.running = false
        playProc.running = true
        root.open = false
    }

    function selectCurrentItem() {
        root.selectItem(list.currentIndex)
    }

    Process {
        id: listProc
        command: ["bash", "-c",
            "fd . \"$HOME/Videos\" \"$HOME/Downloads\" -e mkv -e mp4 -e webm 2>/dev/null | sort"]
        stdout: StdioCollector {
            onStreamFinished: {
                m.clear()
                let lines = this.text.trim().split("\n")
                for (let i = 0; i < lines.length; i++) {
                    let p = lines[i].trim()
                    if (p) {
                        let name = p.replace(/^.*\//, "")
                        m.append({ label: name, path: p })
                    }
                }
                if (m.count === 0)
                    m.append({ label: "No video files found", path: "" })
                root.filterVideos(root.searchText)
            }
        }
    }

    Process {
        id: playProc
        property string path: ""
        command: ["systemd-run", "--user", "--quiet",
            "--property=CollectMode=inactive-or-failed",
            "mpv", "--no-terminal", playProc.path]
    }

    MenuCard {
        cardOpen: root.open
        onRequestClose: root.open = false
        cardWidth: 480
        cardHeight: Math.min(filteredModel.count, 5) * 54 + 130

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            spacing: 8

            Text {
                text: "Watch Video"
                color: theme.text
                font.pixelSize: 15; font.weight: Font.Bold
            }

            Item { Layout.fillWidth: true }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            radius: 14
            color: Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.5)
            border.width: searchInput.activeFocus || searchInput.text.length > 0 ? 2 : 1
            border.color: searchInput.activeFocus || searchInput.text.length > 0
                ? Qt.rgba(theme.mauve.r, theme.mauve.g, theme.mauve.b, 0.5)
                : Qt.rgba(theme.surface2.r, theme.surface2.g, theme.surface2.b, 0.15)

            Behavior on border.color { ColorAnimation { duration: 200 } }

            TextField {
                id: searchInput
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                color: theme.text
                placeholderText: "Search videos..."
                placeholderTextColor: Qt.rgba(theme.subtext0.r, theme.subtext0.g, theme.subtext0.b, 0.3)
                background: null
                font.pixelSize: 14
                verticalAlignment: TextInput.AlignVCenter

                onTextChanged: {
                    root.searchText = text
                    root.filterVideos(text)
                }

                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Up) {
                        list.decrementCurrentIndex()
                        Qt.callLater(function() { list.forceActiveFocus() })
                        event.accepted = true
                    } else if (event.key === Qt.Key_Down) {
                        list.incrementCurrentIndex()
                        Qt.callLater(function() { list.forceActiveFocus() })
                        event.accepted = true
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (list.count > 0 && list.currentIndex >= 0)
                            root.selectCurrentItem()
                        event.accepted = true
                    } else if (event.key === Qt.Key_Escape) {
                        root.open = false
                        text = ""
                        event.accepted = true
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 14
            color: "transparent"
            clip: true

            ListView {
                id: list
                anchors.fill: parent
                anchors.margins: 2
                model: filteredModel
                currentIndex: 0
                boundsBehavior: Flickable.StopAtBounds
                focus: root.open && !searchInput.activeFocus

                onCurrentIndexChanged: {
                    if (currentIndex >= 0)
                        positionViewAtIndex(currentIndex, ListView.Contain)
                }

                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Up) { decrementCurrentIndex(); event.accepted = true }
                    else if (event.key === Qt.Key_Down) { incrementCurrentIndex(); event.accepted = true }
                    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (currentIndex >= 0) root.selectCurrentItem()
                        event.accepted = true
                    } else if (event.key === Qt.Key_Escape) {
                        root.open = false
                        searchInput.text = ""
                        event.accepted = true
                    }
                }

                delegate: Item {
                    width: list.width
                    height: 54

                    Rectangle {
                        anchors.fill: parent
                        radius: 14
                        color: list.currentIndex === index ? Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.6) : "transparent"
                        border.width: list.currentIndex === index ? 1 : 0
                        border.color: Qt.rgba(theme.surface2.r, theme.surface2.g, theme.surface2.b, 0.3)

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            text: model.label
                            color: list.currentIndex === index ? theme.text : theme.subtext0
                            font.pixelSize: 14
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                list.currentIndex = index
                                root.selectItem(index)
                            }
                        }
                    }
                }
            }
        }
    }
}
