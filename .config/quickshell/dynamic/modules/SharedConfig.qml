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

    readonly property var animEaseOut: [0.16, 1, 0.3, 1]

    // ── Shared visual tokens (flat/minimal consistency) ──
    readonly property color hairline:       Qt.rgba(mocha.text.r, mocha.text.g, mocha.text.b, 0.10)
    readonly property color pillBg:         Qt.rgba(mocha.base.r, mocha.base.g, mocha.base.b, 0.55)
    readonly property color pillBgHover:    Qt.rgba(mocha.surface1.r, mocha.surface1.g, mocha.surface1.b, 0.5)
    readonly property color pillBgIdle:     Qt.rgba(mocha.surface1.r, mocha.surface1.g, mocha.surface1.b, 0.35)
    readonly property color surface2Soft:   Qt.rgba(mocha.surface2.r, mocha.surface2.g, mocha.surface2.b, 0.9)
    readonly property color overlay0Soft:   Qt.rgba(mocha.overlay0.r, mocha.overlay0.g, mocha.overlay0.b, 0.9)
    readonly property color surface0Soft:   Qt.rgba(mocha.surface0.r, mocha.surface0.g, mocha.surface0.b, 0.4)

    readonly property color glassBg: Qt.rgba(mocha.base.r, mocha.base.g, mocha.base.b, 0.55)
    readonly property color glassBorder: Qt.rgba(mocha.text.r, mocha.text.g, mocha.text.b, 0.06)
    readonly property color accentPulse: Qt.rgba(mocha.mauve.r, mocha.mauve.g, mocha.mauve.b, 0.12)

    property bool isDesktop: false

    // ══════════════════════════════════════════════════════════════════════════
    // MASTER WATCHER DATA — populated by sharedWatcher below
    // Shared between TopBar, DynamicIsland, and their children
    // ══════════════════════════════════════════════════════════════════════════
    property string kbLayout: "us"
    property string batPercent: "100%"
    property string batIcon: "󰁹"
    property string batStatus: "Unknown"
    property string volPercent: "0"
    property string volIcon: "󰝟"
    property bool volMuted: false
    property string micPercent: "0"
    property string micIcon: "󰍬"
    property bool micMuted: false
    property int pkgUpdates: 0
    property string weatherIcon: ""
    property string weatherTemp: "--°"
    property string weatherHex: "#cdd6f4"
    property bool weatherLoaded: false
    property bool caffeineEnabled: false
    property string wifiSsid: ""
    property int wifiSignal: 0
    property bool bluetoothOn: false
    property int bluetoothDevices: 0
    property var btDeviceList: []

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
                } catch (e) { console.warn(e) }
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
                    } catch (e) { console.warn(e) }
                }
            }
        }
    }

    // ── Theme color file watcher (exit-on-event pattern, matches wsWatcher) ──
    Process {
        id: themeColorWatcher
        running: true
        command: ["bash", "-c",
            "inotifywait -qq -e close_write,moved_to " +
            Quickshell.env("HOME") + "/.config/hypr/scripts/quickshell/qs_colors.json 2>/dev/null"
        ]
        onExited: {
            themeColorReader.running = true;
            running = true;
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    // MASTER SYSTEM WATCHER — single process shared by TopBar + DynamicIsland
    // Tags routed: kblaout, batout, audioout, micout, pkgout,
    //              weatherout, caffeineout, wifiout, btout
    // ══════════════════════════════════════════════════════════════════════════
    Process {
        id: sharedWatcher
        running: true
        command: ["bash", "-c", "~/.config/quickshell/dynamic/modules/watchers/master_watcher.sh"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                let txt = line.trim()
                if (txt === "" || txt === "{}") return
                let colonIdx = txt.indexOf(":")
                if (colonIdx < 0) return
                let tag = txt.substring(0, colonIdx)
                let data = txt.substring(colonIdx + 1)

                // ── Keyboard (plain text) ──
                if (tag === "kblaout") {
                    if (data !== "") config.kbLayout = data
                    return
                }

                // ── JSON-based tags (bat, audio, mic, pkg, wifi, bt) ──
                if (data.length > 0 && (data[0] === '{' || data[0] === '[')) {
                    try {
                        let obj = JSON.parse(data)
                        if (tag === "batout") {
                            let newPct = (obj.percent || "100").toString() + "%"
                            if (config.batPercent !== newPct) config.batPercent = newPct
                            if (config.batIcon !== obj.icon) config.batIcon = obj.icon || "󰁹"
                            if (config.batStatus !== obj.status) config.batStatus = obj.status || "Unknown"
                        } else if (tag === "audioout") {
                            if (config.volPercent !== obj.volume) config.volPercent = obj.volume || "0"
                            if (config.volIcon !== obj.icon) config.volIcon = obj.icon || "󰝟"
                            config.volMuted = obj.is_muted === "true"
                        } else if (tag === "micout") {
                            if (config.micPercent !== obj.volume) config.micPercent = obj.volume || "0"
                            if (config.micIcon !== obj.icon) config.micIcon = obj.icon || "󰍬"
                            config.micMuted = obj.is_muted === "true"
                        } else if (tag === "pkgout") {
                            config.pkgUpdates = obj.count || 0
                        } else if (tag === "wifiout") {
                            config.wifiSsid = obj.ssid || ""
                            config.wifiSignal = obj.signal || 0
                        } else if (tag === "btout") {
                            config.bluetoothOn = (obj.powered === "yes")
                            config.bluetoothDevices = obj.count || 0
                            config.btDeviceList = obj.devices || []
                        }
                    } catch (e) { /* skip parse errors */ }
                    return
                }

                // ── Weather (tab-separated TSV, not JSON) ──
                if (tag === "weatherout") {
                    let parts = data.split("\t")
                    if (parts.length >= 10) {
                        config.weatherLoaded = true
                        let unit = parts[9] || "°C"
                        let curIcon = parts[10] || ""
                        let curTemp = parts[11] || ""
                        config.weatherIcon = curIcon !== "" ? curIcon : (parts[0] || "")
                        config.weatherTemp = curTemp !== "" ? curTemp : (parts[2] ? parts[2] + unit : "--°")
                        config.weatherHex = parts[8]
                    }
                    return
                }

                // ── Caffeine (plain text) ──
                if (tag === "caffeineout") {
                    config.caffeineEnabled = (data.trim() === "on")
                    return
                }
            }
        }
        onExited: running = true
    }
}
