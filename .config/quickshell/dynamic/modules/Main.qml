import QtQuick
import QtQuick.Window
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications

PanelWindow {
    id: masterWindow

    color: "transparent"

    WlrLayershell.namespace: "qs-master"
    WlrLayershell.layer: WlrLayer.Overlay

    exclusionMode: ExclusionMode.Ignore
    focusable: true

    width: Screen.width
    height: Screen.height

    visible: isVisible

    mask: Region {
        item: topBarHole
        intersection: Intersection.Xor
    }

    Item {
        id: topBarHole
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 65
    }

    MouseArea {
        id: clickCatcher
        anchors.fill: parent
        enabled: masterWindow.isVisible
        focus: true
        onClicked: switchWidget("hidden")
        Keys.onEscapePressed: {
            switchWidget("hidden");
            event.accepted = true;
        }
    }

    Component.onCompleted: {
        Quickshell.execDetached(["bash", "-c", 'printf "%s\n" "$1" > /tmp/qs_active_widget', "qs_widget", currentActive]);
    }

    property string currentActive: "hidden"
    property bool isVisible: false

    // =========================================================
    // --- DAEMON: NOTIFICATION HANDLING
    // =========================================================
    NotificationServer {
        id: globalNotificationServer
        bodySupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: n => {
            console.log("Notification:", n.appName, "-", n.summary);

            let iconUrl = "";
            if (n.image && n.image.source && n.image.source.toString() !== "") {
                iconUrl = n.image.source.toString();
            } else if (n.appIcon !== "") {
                iconUrl = n.appIcon;
            }

            Quickshell.execDetached(["bash", "-c", 'printf "%s\n" "$1" >> /tmp/qs_island_notif', "qs_notif_sender", JSON.stringify({
                    appName: n.appName !== "" ? n.appName : "System",
                    title: n.summary !== "" ? n.summary : "No Title",
                    body: n.body !== "" ? n.body : "",
                    icon: iconUrl
                })]);
        }
    }

    // =========================================================

    onIsVisibleChanged: {
        if (isVisible)
            masterWindow.requestActivate();
    }

    function switchWidget(newWidget) {
        Quickshell.execDetached(["bash", "-c", 'printf "%s\n" "$1" > /tmp/qs_active_widget', "qs_widget", newWidget]);

        if (newWidget === "hidden") {
            masterWindow.currentActive = "hidden";
            masterWindow.isVisible = false;
        } else {
            masterWindow.currentActive = newWidget;
            masterWindow.isVisible = true;
        }
    }

    // =========================================================
    // --- IPC: WIDGET SWITCHING (handled by Shell.qml watcher) ---
}
