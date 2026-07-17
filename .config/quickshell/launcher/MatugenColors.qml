import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property color base: "#1e1e2e"
    property color mantle: "#181825"
    property color crust: "#11111b"
    property color text: "#cdd6f4"
    property color subtext0: "#a6adc8"
    property color subtext1: "#bac2de"
    property color surface0: "#313244"
    property color surface1: "#45475a"
    property color surface2: "#585b70"
    property color overlay0: "#6c7086"
    property color overlay1: "#7f849c"
    property color overlay2: "#9399b2"
    property color blue: "#89b4fa"
    property color sapphire: "#74c7ec"
    property color peach: "#fab387"
    property color green: "#a6e3a1"
    property color red: "#f38ba8"
    property color mauve: "#cba6f7"
    property color pink: "#f5c2e7"
    property color yellow: "#f9e2af"
    property color maroon: "#eba0ac"
    property color teal: "#94e2d5"
    property color tertiaryContainer: "#b4befe"

    property string rawJson: ""

    Process {
        id: themeReader
        command: ["cat", Quickshell.env("HOME") + "/.config/hypr/scripts/quickshell/qs_colors.json"]
        stdout: StdioCollector {
            onStreamFinished: {
                let txt = this.text.trim();
                if (txt !== "" && txt !== root.rawJson) {
                    root.rawJson = txt;
                    try {
                        let c = JSON.parse(txt);
                        if (c.base) root.base = c.base;
                        if (c.mantle) root.mantle = c.mantle;
                        if (c.crust) root.crust = c.crust;
                        if (c.text) root.text = c.text;
                        if (c.subtext0) root.subtext0 = c.subtext0;
                        if (c.subtext1) root.subtext1 = c.subtext1;
                        if (c.surface0) root.surface0 = c.surface0;
                        if (c.surface1) root.surface1 = c.surface1;
                        if (c.surface2) root.surface2 = c.surface2;
                        if (c.overlay0) root.overlay0 = c.overlay0;
                        if (c.overlay1) root.overlay1 = c.overlay1;
                        if (c.overlay2) root.overlay2 = c.overlay2;
                        if (c.blue) root.blue = c.blue;
                        if (c.sapphire) root.sapphire = c.sapphire;
                        if (c.peach) root.peach = c.peach;
                        if (c.green) root.green = c.green;
                        if (c.red) root.red = c.red;
                        if (c.mauve) root.mauve = c.mauve;
                        if (c.pink) root.pink = c.pink;
                        if (c.yellow) root.yellow = c.yellow;
                        if (c.maroon) root.maroon = c.maroon;
                        if (c.teal) root.teal = c.teal;
                        if (c.teal) root.tertiaryContainer = c.teal;
                    } catch(e) {}
                }
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: themeReader.running = true
    }
}
