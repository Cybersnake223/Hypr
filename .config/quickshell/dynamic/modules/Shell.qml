import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    Main { id: mainRoot }
    TopBar {}
    DynamicIsland { id: islandRoot }
    ClipboardViewer { id: clipboardRoot }

    Process {
        id: shellIpcWatcher
        running: true
        command: ["bash", "-c",
            "stdbuf -oL inotifywait -m -e close_write,moved_to /tmp/ 2>/dev/null " +
            "--include 'qs_(widget_state|clipboard|launcher_state|island_dismiss|island_dnd|osd|island_toggle|island_clear_notifs|island_notifs_panel|island_calendar|island_notif)$' | " +
            "while read -r dir action file; do " +
            "  case \"$file\" in " +
            "    qs_widget_state) " +
            "      v=$(cat /tmp/qs_widget_state 2>/dev/null); rm -f /tmp/qs_widget_state; " +
            "      printf '{\"event\":\"QS_WIDGET\",\"data\":\"%s\"}\\n' \"$v\" ;; " +
            "    qs_clipboard) " +
            "      v=$(cat /tmp/qs_clipboard 2>/dev/null); rm -f /tmp/qs_clipboard; " +
            "      printf '{\"event\":\"QS_CLIPBOARD\",\"data\":\"%s\"}\\n' \"$v\" ;; " +
            "    qs_launcher_state) " +
            "      v=$(cat /tmp/qs_launcher_state 2>/dev/null); " +
            "      printf '{\"event\":\"QS_LAUNCHER\",\"data\":\"%s\"}\\n' \"$v\" ;; " +
            "    qs_island_dismiss) " +
            "      rm -f /tmp/qs_island_dismiss; " +
            "      printf '{\"event\":\"QS_DISMISS\",\"data\":\"\"}\\n' ;; " +
            "    qs_island_dnd) " +
            "      v=$(cat /tmp/qs_island_dnd 2>/dev/null); rm -f /tmp/qs_island_dnd; " +
            "      printf '{\"event\":\"QS_DND\",\"data\":\"%s\"}\\n' \"$v\" ;; " +
            "    qs_osd) " +
            "      v=$(cat /tmp/qs_osd 2>/dev/null); " +
            "      printf '{\"event\":\"QS_OSD\",\"data\":\"%s\"}\\n' \"$v\" ;; " +
            "    qs_island_toggle) " +
            "      v=$(cat /tmp/qs_island_toggle 2>/dev/null); rm -f /tmp/qs_island_toggle; " +
            "      printf '{\"event\":\"QS_TOGGLE\",\"data\":\"%s\"}\\n' \"$v\" ;; " +
            "    qs_island_clear_notifs) " +
            "      rm -f /tmp/qs_island_clear_notifs; " +
            "      printf '{\"event\":\"QS_CLEAR\",\"data\":\"\"}\\n' ;; " +
            "    qs_island_notifs_panel) " +
            "      rm -f /tmp/qs_island_notifs_panel; " +
            "      printf '{\"event\":\"QS_NOTIFS_PANEL\",\"data\":\"\"}\\n' ;; " +
            "    qs_island_calendar) " +
            "      rm -f /tmp/qs_island_calendar; " +
            "      printf '{\"event\":\"QS_CALENDAR\",\"data\":\"\"}\\n' ;; " +
            "    qs_island_notif) " +
            "      if [ -f /tmp/qs_island_notif ]; then " +
            "        while IFS= read -r j; do " +
            "          [ -n \"$j\" ] && printf '{\"event\":\"QS_NOTIF\",\"data\":%s}\\n' \"$j\"; " +
            "        done < <(jq -c '.' /tmp/qs_island_notif 2>/dev/null); " +
            "        rm -f /tmp/qs_island_notif; " +
            "      fi ;; " +
            "  esac; " +
            "done"
        ]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                if (!line || line.trim() === "") return
                try {
                    let trimmed = line.trim()
                    if (trimmed.length === 0 || (trimmed[0] !== '{' && trimmed[0] !== '[')) return
                    let obj = JSON.parse(trimmed)
                    dispatchIpc(obj.event, obj.data)
                } catch (e) {}  /* non-JSON output from watcher */
            }
        }
        onExited: running = true
    }

    function dispatchIpc(event, data) {
        if (event === "QS_WIDGET") {
            let rawCmd = (data || "").trim()
            if (rawCmd === "") return
            let cmd = rawCmd.split(":")[0]
            if (cmd === "close")
                mainRoot.switchWidget("hidden")
            else if (cmd !== "") {
                if (cmd === mainRoot.currentActive)
                    mainRoot.switchWidget("hidden")
                else
                    mainRoot.switchWidget(cmd)
            }
            return
        }
        if (event === "QS_CLIPBOARD") {
            let cmd = (data || "").trim()
            if (cmd === "open") clipboardRoot.open = true
            else if (cmd === "close") clipboardRoot.open = false
            else if (cmd === "toggle") clipboardRoot.open = !clipboardRoot.open
            return
        }
        islandRoot.handleIpcEvent(event, data)
    }
}
