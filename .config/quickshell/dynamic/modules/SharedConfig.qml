pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: config

    property real uiScale: 1.0
    property var themeColors: ({})

    readonly property string monoFont: "JetBrains Mono"
    readonly property string nerdFont: "Iosevka Nerd Font"
    readonly property string nerdPropoFont: "JetBrainsMono Nerd Font Propo"

    MatugenColors {
        id: _mocha
        colorOverrides: config.themeColors
    }

    readonly property alias mocha: _mocha

    // ── Shared visual tokens (flat/minimal consistency) ──
    readonly property color hairline:       Qt.rgba(mocha.text.r, mocha.text.g, mocha.text.b, 0.10)
    readonly property color hairlineStrong: Qt.rgba(mocha.text.r, mocha.text.g, mocha.text.b, 0.16)
    readonly property color pillBg:         Qt.rgba(mocha.base.r, mocha.base.g, mocha.base.b, 0.75)
    readonly property color pillBgHover:    Qt.rgba(mocha.surface1.r, mocha.surface1.g, mocha.surface1.b, 0.5)
    readonly property color pillBgIdle:     Qt.rgba(mocha.surface1.r, mocha.surface1.g, mocha.surface1.b, 0.35)
    readonly property color surface2Soft:   Qt.rgba(mocha.surface2.r, mocha.surface2.g, mocha.surface2.b, 0.9)
    readonly property color overlay0Soft:   Qt.rgba(mocha.overlay0.r, mocha.overlay0.g, mocha.overlay0.b, 0.9)
    readonly property color surface0Soft:   Qt.rgba(mocha.surface0.r, mocha.surface0.g, mocha.surface0.b, 0.4)

    readonly property color glassBg: Qt.rgba(mocha.base.r, mocha.base.g, mocha.base.b, 0.55)
    readonly property color glassBorder: Qt.rgba(mocha.text.r, mocha.text.g, mocha.text.b, 0.06)
    readonly property color accentPulse: Qt.rgba(mocha.mauve.r, mocha.mauve.g, mocha.mauve.b, 0.12)

    property bool isDesktop: false

    Process {
        id: chassisDetector
        running: true
        command: ["bash", "-c", "if ls /sys/class/power_supply/BAT* 1> /dev/null 2>&1; then echo 'laptop'; else echo 'desktop'; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                config.isDesktop = (this.text.trim() === "desktop");
            }
        }
    }

    Process {
        id: settingsManager
        command: ["bash", "-c",
            "if [ ! -f ~/.config/hypr/settings.json ]; then exit 0; fi; " +
            "cat ~/.config/hypr/settings.json 2>/dev/null; " +
            "inotifywait -m -e modify,close_write ~/.config/hypr/settings.json 2>/dev/null | " +
            "while read -r _; do cat ~/.config/hypr/settings.json 2>/dev/null; done"
        ]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                let text = line.trim();
                if (text === "" || text === "{}") return;
                try {
                    let parsed = JSON.parse(text);
                    if (parsed.uiScale !== undefined && config.uiScale !== parsed.uiScale) {
                        config.uiScale = parsed.uiScale;
                    }
                } catch (e) {}
            }
        }
    }

    // ── Theme color: initial load at startup ──
    Process {
        id: themeColorReader
        running: true
        command: ["cat", Quickshell.env("HOME") + "/.config/hypr/scripts/quickshell/qs_colors.json"]
        stdout: StdioCollector {
            onStreamFinished: {
                let txt = this.text.trim()
                if (txt !== "" && txt !== "{}") {
                    try {
                        let c = JSON.parse(txt)
                        let merged = Object.assign({}, config.themeColors)
                        for (var k in c) merged[k] = c[k]
                        config.themeColors = merged
                    } catch (e) {}
                }
            }
        }
    }

    // ── Theme color file watcher (event-driven, reads file on change) ──
    Process {
        id: themeColorWatcher
        running: true
        command: ["bash", "-c",
            "inotifywait -qq -e close_write,moved_to " +
            Quickshell.env("HOME") + "/.config/hypr/scripts/quickshell 2>/dev/null " +
            "--include qs_colors.json; " +
            "cat " + Quickshell.env("HOME") + "/.config/hypr/scripts/quickshell/qs_colors.json"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let txt = this.text.trim()
                if (txt !== "" && txt !== "{}") {
                    try {
                        let c = JSON.parse(txt)
                        let merged = Object.assign({}, config.themeColors)
                        for (var k in c) merged[k] = c[k]
                        config.themeColors = merged
                    } catch (e) {}
                }
            }
        }
    }
}