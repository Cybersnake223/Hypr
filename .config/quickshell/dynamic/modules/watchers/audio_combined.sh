#!/usr/bin/env bash
get_volume() {
    local vol=""
    if command -v wpctl &> /dev/null; then
        vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print int($2*100)}')
    fi
    if [[ -z "$vol" ]] && command -v pamixer &> /dev/null; then
        vol=$(pamixer --get-volume 2>/dev/null)
    fi
    echo "${vol:-0}"
}

is_muted() {
    if command -v wpctl &> /dev/null; then
        wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep -q "MUTED" && echo "true" || echo "false"
    elif command -v pamixer &> /dev/null; then
        pamixer --get-mute 2>/dev/null | grep -q "true" && echo "true" || echo "false"
    else
        echo "false"
    fi
}

get_volume_icon() {
    local vol=$(get_volume)
    local muted=$(is_muted)
    if [ "$muted" = "true" ]; then echo "󰝟"
    elif [ "$vol" -ge 70 ]; then echo "󰕾"
    elif [ "$vol" -ge 30 ]; then echo "󰖀"
    elif [ "$vol" -gt 0 ]; then echo "󰕿"
    else echo "󰝟"; fi
}

emit() {
    jq -n -c \
        --arg volume "$(get_volume)" \
        --arg icon "$(get_volume_icon)" \
        --arg is_muted "$(is_muted)" \
        '{volume: $volume, icon: $icon, is_muted: $is_muted}'
}

emit

pactl subscribe 2>/dev/null \
    | grep --line-buffered -E "sink|server" \
    | while read -r _; do emit; done
