import QtQuick
import Quickshell

Item {
    id: root

    property string watchName: ""
    property string _target: "qs_" + watchName

    signal openRequested()
    signal closeRequested()
    signal toggleRequested()

    visible: false

    Connections {
        target: IpcBus
        function onInstruct(file, cmd) {
            if (file !== root._target) return
            if (cmd === "open") root.openRequested()
            else if (cmd === "close") root.closeRequested()
            else if (cmd === "toggle") root.toggleRequested()
        }
    }
}
