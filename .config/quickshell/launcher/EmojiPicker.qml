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

  property bool open: false
  property bool _showing: false
  property real pulse: 0

  Timer {
    id: hideTimer
    interval: 500
    onTriggered: root._showing = false
  }

  onOpenChanged: {
    if (open) {
      if (allEmojiModel.count === 0)
        { emojiLoader.running = false; emojiLoader.running = true }
      hideTimer.stop()
      root._showing = true
      searchInput.text = ""
      filterEmoji("")
      Qt.callLater(function() { searchInput.forceActiveFocus() })
      pulseAnim.restart()
    } else {
      hideTimer.restart()
    }
  }

  NumberAnimation {
    id: pulseAnim
    target: root
    property: "pulse"
    from: 0
    to: 1
    duration: 3000
    loops: Animation.Infinite
    easing.type: Easing.InOutSine
  }

  ListModel { id: allEmojiModel }
  ListModel { id: filteredModel }

  function appendEmoji(char, name, keywords) {
    allEmojiModel.append({
      emojiChar: char,
      name: name,
      keywords: keywords,
      search: (name + " " + keywords).toLowerCase()
    })
  }

  Process {
    id: emojiLoader
    running: false
    command: ["bash", "-c",
      "cat \"" + Quickshell.env("HOME") + "/.config/quickshell/launcher/emoji.json\""]
    stdout: StdioCollector {
      onStreamFinished: {
        let txt = this.text.trim()
        if (!txt) return
        try {
          let list = JSON.parse(txt)
          for (let i = 0; i < list.length; i++) {
            let e = list[i]
            appendEmoji(e.char, e.name, e.keywords)
          }
        } catch (e) {}
        filterEmoji("")
      }
    }
  }
  function fuzzyScore(name, query) {
    let n = name.toLowerCase()
    let q = query.toLowerCase()
    if (n === q) return 4
    if (n.startsWith(q)) return 3
    if (n.includes(q)) return 2
    let qi = 0
    for (let i = 0; i < n.length && qi < q.length; i++)
      if (n[i] === q[qi]) qi++
    return qi === q.length ? 1 : 0
  }

  function filterEmoji(query) {
    filteredModel.clear()
    let q = query.trim().toLowerCase()

    if (!q) {
      for (let i = 0; i < allEmojiModel.count; i++) {
        let e = allEmojiModel.get(i)
        filteredModel.append({
          emojiChar: e.emojiChar,
          name: e.name,
          keywords: e.keywords
        })
      }
    } else {
      let scored = []
      for (let i = 0; i < allEmojiModel.count; i++) {
        let e = allEmojiModel.get(i)
        let score = fuzzyScore(e.name, q)
        if (e.search.indexOf(q) >= 0)
          score = Math.max(score, 2)
        if (score > 0)
          scored.push({ score: score, item: e })
      }

      scored.sort(function(a, b) {
        if (b.score !== a.score)
          return b.score - a.score
        return a.item.name.localeCompare(b.item.name)
      })

      for (let i = 0; i < scored.length; i++) {
        let e = scored[i].item
        filteredModel.append({
          emojiChar: e.emojiChar,
          name: e.name,
          keywords: e.keywords
        })
      }
    }

    emojiList.currentIndex = filteredModel.count > 0 ? 0 : -1
  }

  function copyEmoji(idx) {
    if (idx < 0 || idx >= filteredModel.count)
      return

    let item = filteredModel.get(idx)
    if (!item || !item.emojiChar)
      return

    copyProc.selectedEmoji = item.emojiChar
    copyProc.running = false
    copyProc.running = true
    root.open = false
  }

  Process {
    id: copyProc
    property string selectedEmoji: ""
    command: ["bash", "-c", "printf %s " + JSON.stringify(selectedEmoji) + " | wl-copy"]
  }

  IpcHandler {
    target: "emoji"
    function toggle(): void { root.open = !root.open }
    function show(): void { root.open = true }
    function hide(): void { root.open = false }
  }
  IpcWatcher {
    watchName: "emoji"
    onOpenRequested: root.open = true
    onCloseRequested: root.open = false
    onToggleRequested: root.open = !root.open
  }


  MenuCard {
    cardOpen: root.open
    onRequestClose: root.open = false
    cardWidth: 560
      cardHeight: Math.max(Math.min(filteredModel.count, 7) * 54 + 84, 200)

    Rectangle {
      Layout.fillWidth: true
      Layout.preferredHeight: 48
      radius: 14
      color: Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.5)
      border.width: searchInput.activeFocus || searchInput.text.length > 0 ? 2 : 1
      border.color: searchInput.activeFocus || searchInput.text.length > 0
        ? Qt.rgba(theme.mauve.r, theme.mauve.g, theme.mauve.b, 0.5 + root.pulse * 0.15)
        : Qt.rgba(theme.surface2.r, theme.surface2.g, theme.surface2.b, 0.15)
      Behavior on border.color { ColorAnimation { duration: 200 } }

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 10

        Text {
          text: "\u2315"
          color: searchInput.activeFocus || searchInput.text.length > 0
            ? Qt.rgba(theme.mauve.r, theme.mauve.g, theme.mauve.b, 0.8)
            : theme.subtext0
          font.pixelSize: 18
          opacity: searchInput.activeFocus || searchInput.text.length > 0 ? 0.9 : 0.5
          Behavior on color { ColorAnimation { duration: 200 } }
          Behavior on opacity { ColorAnimation { duration: 200 } }
        }

        TextField {
          id: searchInput
          Layout.fillWidth: true
          color: theme.text
          placeholderText: "Search emoji..."
          placeholderTextColor: Qt.rgba(theme.subtext0.r, theme.subtext0.g, theme.subtext0.b, 0.3)
          background: null
          font.pixelSize: 15
          verticalAlignment: TextInput.AlignVCenter

          onTextChanged: root.filterEmoji(text)

          Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Up) {
              emojiList.decrementCurrentIndex()
              event.accepted = true
            } else if (event.key === Qt.Key_Down) {
              emojiList.incrementCurrentIndex()
              event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              if (emojiList.count > 0 && emojiList.currentIndex >= 0)
                root.copyEmoji(emojiList.currentIndex)
              event.accepted = true
            } else if (event.key === Qt.Key_Escape) {
              root.open = false
              text = ""
              event.accepted = true
            }
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
        id: emojiList
        anchors.fill: parent
        anchors.margins: 2
        model: filteredModel
        currentIndex: 0
        boundsBehavior: Flickable.StopAtBounds

        onCurrentIndexChanged: {
          if (currentIndex >= 0)
            positionViewAtIndex(currentIndex, ListView.Contain)
        }

        add: Transition {
          NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 250; easing.type: Easing.OutCubic }
          NumberAnimation { property: "scale"; from: 0.95; to: 1; duration: 250; easing.type: Easing.OutBack }
        }

        delegate: Item {
          width: emojiList.width
          height: 54

          transform: Translate { id: itemSlide; x: -15 }

          ParallelAnimation {
            id: fadeInAnim
            running: true
            NumberAnimation { target: itemDelegate; property: "opacity"; from: 0; to: 1; duration: 300; easing.type: Easing.OutCubic }
            NumberAnimation { target: itemDelegate; property: "scale"; from: 0.95; to: 1; duration: 300; easing.type: Easing.OutBack }
            NumberAnimation { target: itemSlide; property: "x"; from: -15; to: 0; duration: 300; easing.type: Easing.OutCubic }
          }

          Rectangle {
            id: itemDelegate
            anchors.fill: parent
            radius: 12
            color: emojiList.currentIndex === index
              ? Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.85)
              : mouseArea.containsMouse
                ? Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.35)
                : "transparent"
            Rectangle {
              visible: emojiList.currentIndex === index
              width: 3
              height: parent.height * 0.55
              anchors { left: parent.left; verticalCenter: parent.verticalCenter }
              radius: 2
              gradient: Gradient {
                GradientStop { position: 0.0; color: theme.mauve }
                GradientStop { position: 0.5; color: Qt.rgba(theme.mauve.r, theme.mauve.g, theme.mauve.b, 0.6) }
                GradientStop { position: 1.0; color: theme.mauve }
              }
            }

            Rectangle {
              visible: emojiList.currentIndex === index
              anchors.fill: parent
              radius: parent.radius
              color: "transparent"
              border.width: 1
              border.color: Qt.rgba(theme.mauve.r, theme.mauve.g, theme.mauve.b, 0.2)
            }

            Row {
              anchors { left: parent.left; leftMargin: 14; right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
              spacing: 12

              Item {
                width: 40
                height: 40
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                  anchors.centerIn: parent
                  width: 36; height: 36; radius: 10
                  color: Qt.rgba(theme.mauve.r, theme.mauve.g, theme.mauve.b, 0)
                  scale: mouseArea.containsMouse ? 1.4 : 1.0
                  opacity: mouseArea.containsMouse ? 0.3 : 0.0
                  Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                  Behavior on opacity { NumberAnimation { duration: 200 } }
                }

                Rectangle {
                  width: 36; height: 36; radius: 10
                  color: Qt.rgba(theme.surface1.r, theme.surface1.g, theme.surface1.b, 0.45)
                  anchors.centerIn: parent
                  scale: mouseArea.containsMouse ? 1.2 : 1.0
                  Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

                  Text {
                    anchors.centerIn: parent
                    text: model.emojiChar
                    font.pixelSize: 20
                  }
                }
              }

              Column {
                width: parent.width - 40 - 12 - 14 - 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text {
                  width: parent.width
                  text: model.name
                  color: emojiList.currentIndex === index ? theme.text : theme.subtext0
                  font.pixelSize: 14
                  elide: Text.ElideRight
                }

                Text {
                  width: parent.width
                  text: model.keywords
                  color: Qt.rgba(theme.subtext0.r, theme.subtext0.g, theme.subtext0.b,
                                 emojiList.currentIndex === index ? 0.75 : 0.5)
                  font.pixelSize: 11
                  elide: Text.ElideRight
                }
              }
            }

            MouseArea {
              id: mouseArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor

              onClicked: {
                ripple.x = mouseX - ripple.width / 2
                ripple.y = mouseY - ripple.height / 2
                ripple.scale = 0
                ripple.opacity = 0.4
                rippleAnim.restart()
                emojiList.currentIndex = index
                root.copyEmoji(index)
              }

              Rectangle {
                id: ripple
                width: 8
                height: 8
                radius: 4
                color: theme.mauve
                opacity: 0

                NumberAnimation {
                  id: rippleAnim
                  target: ripple
                  property: "scale"
                  from: 0
                  to: 8
                  duration: 400
                  easing.type: Easing.OutCubic
                }

                NumberAnimation {
                  target: ripple
                  property: "opacity"
                  from: 0.4
                  to: 0
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
}
