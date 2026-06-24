import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property color base:     "#1e1e2e"
  property color text:     "#cdd6f4"
  property color subtext0: "#a6adc8"
  property color surface0: "#313244"
  property color surface1: "#45475a"
  property color surface2: "#585b70"
  property color mauve:    "#cba6f7"
  property color tertiaryContainer: "#b4befe"

  Process {
    id: reader
    command: ["bash", "-c",
      "inotifywait -qq -e close_write,moved_to --include 'colors\\.json$' \"$HOME/.local/state/quickshell/generated/\" 2>/dev/null; " +
      "cat \"$HOME/.local/state/quickshell/generated/colors.json\""]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        let txt = this.text.trim()
        if (!txt) return
        try {
          let c = JSON.parse(txt)
          let md3 = c.md3 || {}

          if (md3.surface)               root.base     = md3.surface
          if (md3.on_surface)            root.text     = md3.on_surface
          if (md3.on_surface_variant)    root.subtext0 = md3.on_surface_variant
          if (md3.surface_container)     root.surface0 = md3.surface_container
          if (md3.surface_container_high)   root.surface1 = md3.surface_container_high
          if (md3.surface_container_highest) root.surface2 = md3.surface_container_highest
          if (md3.primary)               root.mauve    = md3.primary
          if (md3.tertiary_container)    root.tertiaryContainer = md3.tertiary_container
        } catch (e) {}

        // re-watch immediately (inotify is one-shot)
        reader.running = false
        Qt.callLater(function() { reader.running = true })
      }
    }
  }

}
