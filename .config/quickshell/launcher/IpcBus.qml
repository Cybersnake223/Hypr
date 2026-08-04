pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    signal instruct(string file, string cmd)

    Process {
        running: true
        command: ["bash", "-c",
            "stdbuf -oL inotifywait -m -e close_write,moved_to /tmp/ 2>/dev/null " +
            "--include 'qs_(launcher|emoji|powermenu|scriptedit|screenshot|bluetooth|wifi|watchvid|editconf)$' | " +
            "while read -r dir action file; do " +
            "  v=$(cat /tmp/$file 2>/dev/null); rm -f /tmp/$file; " +
            "  printf '%s:%s\\n' \"$file\" \"$v\"; " +
            "done"
        ]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                if (!line || line.trim() === "") return
                let trimmed = line.trim()
                let i = trimmed.indexOf(":")
                if (i < 0) return
                let file = trimmed.substring(0, i)
                let cmd = trimmed.substring(i + 1)
                root.instruct(file, cmd)
            }
        }
        onExited: running = true
    }
}
