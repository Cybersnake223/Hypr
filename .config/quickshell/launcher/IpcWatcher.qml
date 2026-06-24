import Quickshell
import Quickshell.Io

Process {
    id: root

    property string watchName: ""

    running: watchName !== ""

    command: ["bash", "-c",
        "inotifywait -qq -e close_write,moved_to --include 'qs_" + watchName + "$' /tmp/ 2>/dev/null; " +
        "[ -f /tmp/qs_" + watchName + " ] && cat /tmp/qs_" + watchName + " && rm -f /tmp/qs_" + watchName
    ]

    signal openRequested()
    signal closeRequested()
    signal toggleRequested()

    stdout: StdioCollector {
        onStreamFinished: {
            let cmd = this.text.trim()
            if (cmd === "open") root.openRequested()
            else if (cmd === "close") root.closeRequested()
            else if (cmd === "toggle") root.toggleRequested()
            root.running = false
            Qt.callLater(function() { root.running = true })
        }
    }
}
