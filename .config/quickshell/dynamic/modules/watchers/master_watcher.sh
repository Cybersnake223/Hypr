#!/usr/bin/env bash
# master_watcher.sh — Single process for all system monitoring
# Replaces topbar_combined.sh + island_combined.sh
# Output format: "tag:data" per line (same convention as before)
#
# TopBar filters for: kblaout, batout, audioout, micout, pkgout
# DynamicIsland filters for: weatherout, forecastout, caffeineout, wifiout, btout

# --- Shared helpers ---
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/battery_common.sh"

# --- All watchers run as background subshores ---

# ── 1. Keyboard — Hyprland socket, event-driven ──────────────────────────────
{
    # Initial read
    layout=$(hyprctl devices -j 2>/dev/null | jq -r '(.keyboards[] | select(.main == true) | .active_keymap) // .keyboards[0].active_keymap // empty' | head -n1)
    [[ -z "$layout" || "$layout" == "null" ]] && layout="US"
    echo "${layout:0:2}" | tr '[:lower:]' '[:upper:]'

    # Event loop — parse activelayout>> directly from socket
    if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock 2>/dev/null \
            | grep --line-buffered "activelayout>>" \
            | while IFS= read -r line; do
                raw="${line#*activelayout>>}"
                raw="${raw#*,}"
                layout="${raw:0:2}"
                [ -z "$layout" ] && layout="US"
                echo "$layout" | tr '[:lower:]' '[:upper:]'
              done
    fi
} | while IFS= read -r line; do echo "kblaout:$line"; done &

# ── 2. Battery — poll every 60s ──────────────────────────────────────────────
(
    emit() {
        jq -n -c \
            --arg percent "$(get_battery_percent)" \
            --arg status "$(get_battery_status)" \
            --arg icon "$(get_battery_icon)" \
            '{percent: $percent, status: $status, icon: $icon}'
    }
    emit
    while true; do
        sleep 60
        emit
    done
) | while IFS= read -r line; do echo "batout:$line"; done &

# ── 3. Audio — pactl subscribe, event-driven ─────────────────────────────────
(
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
) | while IFS= read -r line; do echo "audioout:$line"; done &

# ── 4. Mic — pactl subscribe, event-driven ───────────────────────────────────
(
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
) | while IFS= read -r line; do echo "micout:$line"; done &

# ── 5. Package updates — poll every 30 min ────────────────────────────────────
(
    emit_pkg() {
        local out=$($HOME/.config/quickshell/dynamic/scripts/pkg_updates.sh 2>/dev/null)
        [ -z "$out" ] && out='{"count":0,"packages":[]}'
        echo "$out"
    }
    sleep 300; emit_pkg
    while true; do
        sleep 1800
        emit_pkg
    done
) | while IFS= read -r line; do echo "pkgout:$line"; done &

# ── 6. Weather — poll every 5 min ─────────────────────────────────────────────
(
    emit_weather() {
        local out=$($HOME/.config/quickshell/dynamic/modules/calendar/weather.sh --island 2>/dev/null)
        if [ -n "$out" ] && [ "$(echo "$out" | cut -f1)" != "{}" ]; then
            echo "$out"
        fi
    }
    emit_forecast() {
        if [ -f "$HOME/.cache/quickshell/weather/weather.json" ]; then
            local f=$(cat "$HOME/.cache/quickshell/weather/weather.json" | jq -c -r '.forecast[1:5] | map({day, icon, max})' 2>/dev/null)
            [ -n "$f" ] && echo "$f"
        fi
    }
    sleep 30; emit_weather
    emit_forecast
    while true; do
        sleep 300
        emit_weather
        emit_forecast
    done
) | while IFS= read -r line; do
    # First line is weather data, subsequent lines are forecast
    # We detect by checking if it starts with { (JSON object) or [ (JSON array)
    if [[ "$line" == \[* ]]; then
        echo "forecastout:$line"
    else
        echo "weatherout:$line"
    fi
done &

# ── 7. Caffeine — event-driven via inotifywait ─────────────────────────────────
(
    state=$(cat /tmp/qs_caffeine 2>/dev/null || echo 'off')
    echo "$state"
    touch /tmp/qs_caffeine 2>/dev/null
    inotifywait -m -e close_write,moved_to /tmp/qs_caffeine 2>/dev/null \
        | while read -r _; do
            state=$(cat /tmp/qs_caffeine 2>/dev/null || echo 'off')
            echo "$state"
          done
) | while IFS= read -r line; do echo "caffeineout:$line"; done &

# ── 8. WiFi — poll every 120s ─────────────────────────────────────────────────
(
    emit_wifi() {
        local raw=$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi list --rescan no 2>/dev/null | grep '^yes' | head -1)
        if [ -n "$raw" ]; then
            local ssid=$(echo "$raw" | awk -F: '{print $2}')
            local signal=$(echo "$raw" | awk -F: '{print $3}')
            jq -n -c --arg s "$ssid" --argjson sig "${signal:-0}" '{ssid: $s, signal: $sig}'
        else
            jq -n -c '{ssid: "", signal: 0}'
        fi
    }
    sleep 15; emit_wifi
    while true; do
        sleep 120
        emit_wifi
    done
) | while IFS= read -r line; do echo "wifiout:$line"; done &

# ── 9. Bluetooth — poll every 60s ─────────────────────────────────────────────
(
    emit_bt() {
        local json=$($HOME/.config/quickshell/dynamic/scripts/bt_all.sh 2>/dev/null | jq -c . 2>/dev/null)
        echo "$json"
    }
    sleep 20; emit_bt
    while true; do
        sleep 60
        emit_bt
    done
) | while IFS= read -r line; do echo "btout:$line"; done &

wait
