#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# CONSTANTS & ARGUMENTS
# -----------------------------------------------------------------------------
QS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

IPC_FILE="/tmp/qs_widget_state"

ACTION="$1"
TARGET="$2"
SUBTARGET="$3"

# -----------------------------------------------------------------------------
# FAST PATH: WORKSPACE SWITCHING
# -----------------------------------------------------------------------------
if [[ "$ACTION" =~ ^[0-9]+$ ]]; then
    WORKSPACE_NUM="$ACTION"
    echo "close" > "$IPC_FILE"
    
    CMD="workspace $WORKSPACE_NUM"
    [[ "$2" == "move" ]] && CMD="movetoworkspace $WORKSPACE_NUM"
    hyprctl --batch "dispatch $CMD" >/dev/null 2>&1
    exit 0
fi



# -----------------------------------------------------------------------------
# ZOMBIE WATCHDOG
# -----------------------------------------------------------------------------
MAIN_QML_PATH="$HOME/.config/quickshell/dynamic/modules/Main.qml"
BAR_QML_PATH="$HOME/.config/quickshell/dynamic/modules/TopBar.qml"
ISLAND_QML_PATH="$HOME/.config/quickshell/dynamic/modules/DynamicIsland.qml"
CLIPBOARD_QML_PATH="$HOME/.config/quickshell/dynamic/modules/ClipboardViewer.qml"

if ! pgrep -f "quickshell.*Main\.qml" >/dev/null; then
    quickshell -p "$MAIN_QML_PATH" >/dev/null 2>&1 &
    disown
fi

if ! pgrep -f "quickshell.*TopBar\.qml" >/dev/null; then
    quickshell -p "$BAR_QML_PATH" >/dev/null 2>&1 &
    disown
fi

if ! pgrep -f "quickshell.*DynamicIsland\.qml" >/dev/null; then
    quickshell -p "$ISLAND_QML_PATH" >/dev/null 2>&1 &
    disown
fi

if ! pgrep -f "quickshell.*ClipboardViewer\.qml" >/dev/null; then
    quickshell -p "$CLIPBOARD_QML_PATH" >/dev/null 2>&1 &
    disown
fi


# -----------------------------------------------------------------------------
# IPC ROUTING
# -----------------------------------------------------------------------------
if [[ "$ACTION" == "close" ]]; then
    echo "close" > "$IPC_FILE"
    exit 0
fi

if [[ "$ACTION" == "open" || "$ACTION" == "toggle" ]]; then
    if [[ "$TARGET" == "clipboard" ]]; then
        echo "toggle" > /tmp/qs_clipboard
        exit 0
    fi

    if [[ "$TARGET" == "caffeine" ]]; then
        CURRENT_CAFF=$(cat /tmp/qs_caffeine 2>/dev/null || echo "off")
        if [[ "$CURRENT_CAFF" == "on" ]]; then
            echo "off" > /tmp/qs_caffeine
            pkill -f "systemd-inhibit.*qs-caffeine" 2>/dev/null
        else
            echo "on" > /tmp/qs_caffeine
            systemd-inhibit --what=sleep:idle --who=qs-caffeine --why='Caffeine mode' sleep infinity &
        fi
        exit 0
    fi

    echo "$TARGET" > "$IPC_FILE"
    exit 0
fi
