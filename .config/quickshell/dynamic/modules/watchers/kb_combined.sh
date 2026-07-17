#!/usr/bin/env bash
fetch_layout() {
    local layout
    layout=$(hyprctl devices -j 2>/dev/null | jq -r '(.keyboards[] | select(.main == true) | .active_keymap) // .keyboards[0].active_keymap // empty' | head -n1)
    [[ -z "$layout" || "$layout" == "null" ]] && layout="US"
    echo "${layout:0:2}" | tr '[:lower:]' '[:upper:]'
}

fetch_layout

if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock 2>/dev/null \
        | grep --line-buffered "activelayout>>" \
        | while read -r _; do fetch_layout; done
fi
