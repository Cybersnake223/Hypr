import QtQuick

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

    property var colorOverrides: null
    onColorOverridesChanged: {
        if (colorOverrides) {
            for (var k in colorOverrides) {
                if (k in root) root[k] = colorOverrides[k];
            }
        }
    }
}
