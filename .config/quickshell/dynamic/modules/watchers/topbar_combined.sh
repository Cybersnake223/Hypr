#!/usr/bin/env bash
# Combined watcher for TopBar: keyboard, battery, audio, mic
# Runs all four in one process, prefixing each output line with its source tag.
# TopBar's SplitParser routes by prefix: kblaout:, batout:, audioout:, micout:

tag() { while IFS= read -r line; do echo "$1:$line"; done; }

# Keyboard — event-driven via Hyprland socket
{
    layout=$(hyprctl devices -j 2>/dev/null | jq -r '(.keyboards[] | select(.main == true) | .active_keymap) // .keyboards[0].active_keymap // empty' | head -n1)
    [[ -z "$layout" || "$layout" == "null" ]] && layout="US"
    echo "${layout:0:2}" | tr '[:lower:]' '[:upper:]'
} | tag "kblaout" &

kb_pid=$!

# Battery — poll every 60 s, emit JSON with batout: prefix
(
    get_battery_percent() { cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1 || echo "100"; }
    get_battery_status() { cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n1 || echo "Full"; }
    get_battery_icon() {
        local percent=$(get_battery_percent)
        local status=$(get_battery_status)
        if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
            if [ "$percent" -ge 90 ]; then echo "󰂅"
            elif [ "$percent" -ge 80 ]; then echo "󰂋"
            elif [ "$percent" -ge 60 ]; then echo "󰂊"
            elif [ "$percent" -ge 40 ]; then echo "󰢞"
            elif [ "$percent" -ge 20 ]; then echo "󰂆"
            else echo "󰢜"; fi
        else
            if [ "$percent" -ge 90 ]; then echo "󰁹"
            elif [ "$percent" -ge 80 ]; then echo "󰂂"
            elif [ "$percent" -ge 70 ]; then echo "󰂁"
            elif [ "$percent" -ge 60 ]; then echo "󰂀"
            elif [ "$percent" -ge 50 ]; then echo "󰁿"
            elif [ "$percent" -ge 40 ]; then echo "󰁾"
            elif [ "$percent" -ge 30 ]; then echo "󰁽"
            elif [ "$percent" -ge 20 ]; then echo "󰁼"
            elif [ "$percent" -ge 10 ]; then echo "󰁻"
            else echo "󰁺"; fi
        fi
    }
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
) | tag "batout" &

# Audio — pactl subscribe, event-driven
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
) | tag "audioout" &

# Mic — pactl subscribe, event-driven
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
) | tag "micout" &

# Keyboard Hyprland socket watcher (keep it alive alongside the initial read)
# The activelayout>> event already carries the new layout in its payload
# (format: activelayout>><keyboard>,<Layout Name>), so parse it directly
# instead of re-querying the full device tree via hyprctl on every switch.
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock 2>/dev/null \
        | grep --line-buffered "activelayout>>" \
        | while IFS= read -r line; do
            raw="${line#*activelayout>>}"
            raw="${raw#*,}"
            layout="${raw:0:2}"
            [ -z "$layout" ] && layout="US"
            echo "$layout" | tr '[:lower:]' '[:upper:]'
          done | tag "kblaout" &
fi

# Package updates — poll every 30 min
(
    emit_pkg() {
        local pkgs="[]"
        while IFS= read -r line; do
            [ -z "$line" ] && continue
            local name=$(awk '{print $1}' <<<"$line")
            local oldver=$(awk '{print $2}' <<<"$line")
            local newver=$(awk '{print $4}' <<<"$line")
            pkgs=$(jq -c --arg n "$name" --arg o "$oldver" --arg v "$newver" \
                '. + [{name: $n, oldver: $o, newver: $v}]' <<<"$pkgs" 2>/dev/null)
        done < <(timeout 15 checkupdates 2>/dev/null)
        local result=$(jq -n -c --argjson packages "$pkgs" '{count: ($packages | length), packages: $packages}')
        echo "pkgout:$result"
    }
    emit_pkg
    while true; do
        sleep 1800
        emit_pkg
    done
) &

wait