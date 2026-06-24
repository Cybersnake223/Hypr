import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
  id: root

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

  property bool open:     false
  property bool _showing: false
  property string searchText: ""

  Timer {
    id: hideTimer; interval: 500
    onTriggered: root._showing = false
  }

  onOpenChanged: {
    if (open) {
      hideTimer.stop()
      root._showing = true
      root.searchText = ""
      searchInput.text = ""
      loadScripts()
      filterApps("")
      Qt.callLater(function() { searchInput.forceActiveFocus() })
    } else {
      hideTimer.restart()
    }
  }

  ListModel { id: m }

  ListModel { id: filteredModel }

  function filterApps(query) {
    filteredModel.clear()
    let q = query.trim().toLowerCase()
    for (let i = 0; i < m.count; i++) {
      let item = m.get(i)
      if (!q || item.label.toLowerCase().indexOf(q) >= 0)
        filteredModel.append({ label: item.label, path: item.path })
    }
    list.currentIndex = 0
  }

  function loadScripts() {
    m.clear()
    m.append({ label: "Loading...", path: "" })
    listProc.running = false
    listProc.running = true
  }

  function selectItem(idx) {
    if (idx < 0 || idx >= filteredModel.count) return
    let item = filteredModel.get(idx)
    if (!item.path) return
    editProc.path = item.path
    editProc.running = false
    editProc.running = true
    root.open = false
  }

  function selectCurrentItem() {
    root.selectItem(list.currentIndex)
  }

  Item {
    id: keyCatcher
    visible: searchInput.activeFocus ? false : true
    focus: true
    width: 0; height: 0

    Keys.onUpPressed:     function(ev) { list.decrementCurrentIndex(); ev.accepted = true }
    Keys.onDownPressed:   function(ev) { list.incrementCurrentIndex(); ev.accepted = true }
    Keys.onReturnPressed: function(ev) { root.selectCurrentItem(); ev.accepted = true }
    Keys.onEscapePressed: function(ev) { root.open = false; ev.accepted = true }
  }

  Process {
    id: listProc
    command: ["bash", "-c",
      "dir=\"${SCRIPTS_DIR:-$HOME/.local/bin/scripts}\"; " +
      "[ -d \"$dir\" ] && fd . \"$dir\" -t f 2>/dev/null || find \"$dir\" -type f 2>/dev/null || true"]
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
          m.append({ label: "No scripts found", path: "" })
        root.filterApps(root.searchText)
      }
    }
  }

  Process {
    id: editProc
    property string path: ""
    command: ["bash", "-c", "kitty -e nvim " + JSON.stringify(editProc.path)]
  }

  IpcHandler {
    target: "scriptedit"
    function toggle(): void { root.open = !root.open }
    function show():    void { root.open = true }
    function hide():    void { root.open = false }
  }
  IpcWatcher {
    watchName: "scriptedit"
    onOpenRequested: root.open = true
    onCloseRequested: root.open = false
    onToggleRequested: root.open = !root.open
  }


  MouseArea { anchors.fill: parent; onClicked: root.open = false }

  MenuCard {
    cardOpen: root.open
    cardWidth: 480
    cardHeight: Math.min(filteredModel.count, 5) * 50 + 130

    RowLayout {
      Layout.fillWidth: true
      Layout.preferredHeight: 32
      spacing: 8

      Text {
        text: "Edit Script"
        color: theme.text
        font.pixelSize: 15; font.weight: Font.Bold
      }

      Item { Layout.fillWidth: true }
    }

    Rectangle {
      Layout.fillWidth: true
      Layout.preferredHeight: 38
      radius: 12
      color: Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.5)
      border.width: searchInput.activeFocus ? 2 : 1
      border.color: searchInput.activeFocus
        ? Qt.rgba(theme.mauve.r, theme.mauve.g, theme.mauve.b, 0.5)
        : Qt.rgba(theme.surface2.r, theme.surface2.g, theme.surface2.b, 0.15)
      Behavior on border.color { ColorAnimation { duration: 200 } }

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 8

        Text {
          text: "\u2315"
          color: searchInput.activeFocus ? Qt.rgba(theme.mauve.r, theme.mauve.g, theme.mauve.b, 0.7) : theme.subtext0
          font.pixelSize: 14
          opacity: 0.5
        }

        TextField {
          id: searchInput
          Layout.fillWidth: true
          color: theme.text
          placeholderText: "Search..."
          placeholderTextColor: Qt.rgba(theme.subtext0.r, theme.subtext0.g, theme.subtext0.b, 0.3)
          background: null
          font.pixelSize: 13
          verticalAlignment: TextInput.AlignVCenter

          onTextChanged: root.filterApps(text)

          Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Up) {
              list.decrementCurrentIndex(); event.accepted = true
            } else if (event.key === Qt.Key_Down) {
              list.incrementCurrentIndex(); event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              root.selectCurrentItem(); event.accepted = true
            } else if (event.key === Qt.Key_Escape) {
              root.open = false; event.accepted = true
            }
          }
        }
      }
    }

    Rectangle {
      Layout.fillWidth: true
      Layout.fillHeight: true
      color: "transparent"
      clip: true

      ListView {
        id: list
        anchors.fill: parent
        anchors.margins: 2
        model: filteredModel
        currentIndex: 0
        boundsBehavior: Flickable.StopAtBounds

        add: Transition {
          NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 250; easing.type: Easing.OutCubic }
        }

        delegate: Rectangle {
          width: list.width; height: 46
          radius: 12
          color: list.currentIndex === index
            ? Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.85)
            : mouseArea.containsMouse
              ? Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.25)
              : "transparent"
          Rectangle {
            visible: list.currentIndex === index
            width: 3; height: parent.height * 0.5
            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            radius: 2
            gradient: Gradient {
              GradientStop { position: 0.0; color: theme.mauve }
              GradientStop { position: 0.5; color: Qt.rgba(theme.mauve.r, theme.mauve.g, theme.mauve.b, 0.6) }
              GradientStop { position: 1.0; color: theme.mauve }
            }
          }

          Rectangle {
            visible: list.currentIndex === index
            anchors.fill: parent; radius: parent.radius; color: "transparent"
            border.width: 1
            border.color: Qt.rgba(theme.mauve.r, theme.mauve.g, theme.mauve.b, 0.15)
          }

          Text {
            anchors { left: parent.left; leftMargin: 16; right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
            text: model.label
            color: list.currentIndex === index ? theme.text : theme.subtext0
            font.pixelSize: 13
            elide: Text.ElideRight
          }

          MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
              ripple.x = mouseX - ripple.width / 2
              ripple.y = mouseY - ripple.height / 2
              ripple.scale = 0
              ripple.opacity = 0.4
              rippleAnim.restart()
              list.currentIndex = index
              root.selectItem(index)
            }

            Rectangle {
              id: ripple
              width: 8; height: 8
              radius: 4
              color: theme.mauve
              opacity: 0

              NumberAnimation {
                id: rippleAnim
                target: ripple
                property: "scale"
                from: 0; to: 8
                duration: 400
                easing.type: Easing.OutCubic
              }
              NumberAnimation {
                target: ripple
                property: "opacity"
                from: 0.4; to: 0
                duration: 400
                easing.type: Easing.OutCubic
              }
            }
          }
        }
      }
    }
  }
}
