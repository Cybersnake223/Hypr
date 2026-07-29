#!/usr/bin/env bash
# master_watcher.sh — Single process for all system monitoring
# Output format: "tag:data" per line
# Tags: kblaout, batout, audioout, micout, pkgout,
#       weatherout, forecastout, caffeineout, wifiout, btout
#
# Uses flock-based primary/secondary pattern:
# - Only the first instance (primary) runs actual watchers
# - Subsequent instances (secondaries) relay output from a shared file

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/battery_common.sh"

LOCKFILE=/tmp/qs_master_watcher.lock
OUTFILE=/tmp/qs_master_watcher_out

# ── Lock acquisition ─────────────────────────────────────────────────────────
exec 200<>"$LOCKFILE"
if ! flock -n 200; then
    until [ -f "$OUTFILE" ] 2>/dev/null; do sleep 1; done
    exec tail -n 0 -f "$OUTFILE"
fi

# ── Primary instance ─────────────────────────────────────────────────────────
rm -f "$OUTFILE"
trap 'rm -f "$LOCKFILE" "$OUTFILE"; kill 0' EXIT
touch "$OUTFILE"
exec > >(stdbuf -oL tee -a "$OUTFILE")

# ── 1. Keyboard — Hyprland socket, event-driven ──────────────────────────────
{
    layout=$(hyprctl devices -j 2>/dev/null | jq -r '(.keyboards[] | select(.main == true) | .active_keymap) // .keyboards[0].active_keymap // empty' | head -n1)
    [[ -z "$layout" || "$layout" == "null" ]] && layout="US"
    echo "kblaout:$(echo "${layout:0:2}" | tr '[:lower:]' '[:upper:]')"

    if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        while true; do
            socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock 2>/dev/null \
                | grep --line-buffered "activelayout>>" \
                | while IFS= read -r line; do
                    raw="${line#*activelayout>>}"
                    raw="${raw#*,}"
                    layout="${raw:0:2}"
                    [ -z "$layout" ] && layout="US"
                    echo "kblaout:$(echo "$layout" | tr '[:lower:]' '[:upper:]')"
                  done
            sleep 2
        done
    fi
} &

# ── 2. Audio — pactl subscribe, event-driven ─────────────────────────────────
{
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
        echo "audioout:$(jq -n -c \
            --arg volume "$(get_volume)" \
            --arg icon "$(get_volume_icon)" \
            --arg is_muted "$(is_muted)" \
            '{volume: $volume, icon: $icon, is_muted: $is_muted}')"
    }
    emit
    pactl subscribe 2>/dev/null \
        | grep --line-buffered -E "sink|server" \
        | while read -r _; do emit; done
} &

# ── 3. Mic — pactl subscribe, event-driven ───────────────────────────────────
{
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
        echo "micout:$(jq -n -c \
            --arg volume "$(get_mic_volume)" \
            --arg icon "$(get_mic_icon)" \
            --arg is_muted "$(is_mic_muted)" \
            '{volume: $volume, icon: $icon, is_muted: $is_muted}')"
    }
    emit
    pactl subscribe 2>/dev/null \
        | grep --line-buffered -E "source|server" \
        | while read -r _; do emit; done
} &

# ── 4. Caffeine — event-driven via inotifywait ─────────────────────────────────
{
    state=$(cat /tmp/qs_caffeine 2>/dev/null || echo 'off')
    echo "caffeineout:$state"
    touch /tmp/qs_caffeine 2>/dev/null
    inotifywait -m -e close_write,moved_to /tmp/qs_caffeine 2>/dev/null \
        | while read -r _; do
            state=$(cat /tmp/qs_caffeine 2>/dev/null || echo 'off')
            echo "caffeineout:$state"
          done
} &

# ── 5. Polling watchers — combined loop ──────────────────────────────────────
# Battery (60s), Pkg (30min+1800s), Weather (300s), WiFi (120s), BT (60s)
{
    next_bat=0
    next_pkg=300
    next_wth=30
    next_wifi=15
    next_bt=20

    emit_bat() {
        echo "batout:$(jq -n -c \
            --arg percent "$(get_battery_percent)" \
            --arg status "$(get_battery_status)" \
            --arg icon "$(get_battery_icon)" \
            '{percent: $percent, status: $status, icon: $icon}')"
    }
    emit_pkg() {
        local out=$($HOME/.config/quickshell/dynamic/scripts/pkg_updates.sh 2>/dev/null)
        [ -z "$out" ] && out='{"count":0,"packages":[]}'
        echo "pkgout:$out"
    }
    emit_weather() {
        local out=$($HOME/.config/quickshell/dynamic/modules/calendar/weather.sh --island 2>/dev/null)
        if [ -n "$out" ] && [ "$(echo "$out" | cut -f1)" != "{}" ]; then
            echo "weatherout:$out"
        fi
    }
    emit_forecast() {
        if [ -f "$HOME/.cache/quickshell/weather/weather.json" ]; then
            local f=$(cat "$HOME/.cache/quickshell/weather/weather.json" | jq -c -r '.forecast[1:5] | map({day, icon, max})' 2>/dev/null)
            [ -n "$f" ] && echo "forecastout:$f"
        fi
    }
    emit_wifi() {
        local raw=$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi list --rescan no 2>/dev/null | grep '^yes' | head -1)
        if [ -n "$raw" ]; then
            local ssid=$(echo "$raw" | awk -F: '{print $2}')
            local signal=$(echo "$raw" | awk -F: '{print $3}')
            echo "wifiout:$(jq -n -c --arg s "$ssid" --argjson sig "${signal:-0}" '{ssid: $s, signal: $sig}')"
        else
            echo "wifiout:$(jq -n -c '{ssid: "", signal: 0}')"
        fi
    }
    emit_bt() {
        local json=$($HOME/.config/quickshell/dynamic/scripts/bt_all.sh 2>/dev/null | jq -c . 2>/dev/null)
        echo "btout:$json"
    }

    while true; do
        sleep 1
        ((next_bat--)); ((next_pkg--)); ((next_wth--)); ((next_wifi--)); ((next_bt--))

        if ((next_bat <= 0)); then emit_bat; next_bat=60; fi
        if ((next_pkg <= 0)); then emit_pkg; next_pkg=1800; fi
        if ((next_wth <= 0)); then emit_weather; emit_forecast; next_wth=300; fi
        if ((next_wifi <= 0)); then emit_wifi; next_wifi=120; fi
        if ((next_bt <= 0)); then emit_bt; next_bt=60; fi
    done
} &

while true; do wait; done
