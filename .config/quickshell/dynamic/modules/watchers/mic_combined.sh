#!/usr/bin/env bash
get_mic_volume() {
    local vol=""
    if command -v wpctl &> /dev/null; then
        vol=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | awk '{print int($2*100)}')
    fi
    if [[ -z "$vol" ]] && command -v pamixer &> /dev/null; then
        vol=$(pamixer --default-source --get-volume 2>/dev/null)
    fi
    echo "${vol:-0}"
}

is_mic_muted() {
    if command -v wpctl &> /dev/null; then
        wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q "MUTED" && echo "true" || echo "false"
    elif command -v pamixer &> /dev/null; then
        pamixer --default-source --get-mute 2>/dev/null | grep -q "true" && echo "true" || echo "false"
    else
        echo "false"
    fi
}

get_mic_icon() {
    local muted=$(is_mic_muted)
    if [ "$muted" = "true" ]; then echo "󰍭"
    else echo "󰍬"; fi
}

emit() {
    jq -n -c \
        --arg volume "$(get_mic_volume)" \
        --arg icon "$(get_mic_icon)" \
        --arg is_muted "$(is_mic_muted)" \
        '{volume: $volume, icon: $icon, is_muted: $is_muted}'
}

emit

pactl subscribe 2>/dev/null \
    | grep --line-buffered -E "source|server" \
    | while read -r _; do emit; done
