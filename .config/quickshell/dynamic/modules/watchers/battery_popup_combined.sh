#!/usr/bin/env bash
# Combined battery popup watcher: system stats + battery, all in one process.
# Tags each output so BatteryPopup's SplitParser can route it.

tag() { while IFS= read -r line; do echo "$1:$line"; done; }

# CPU: read /proc/stat twice with 100ms gap for delta calculation
_get_cpu() {
    local t1=$(awk '/^cpu / {for(i=2;i<=NF;i++) t+=$i; print t}' /proc/stat)
    local i1=$(awk '/^cpu / {print $5}' /proc/stat)
    sleep 0.1
    local t2=$(awk '/^cpu / {for(i=2;i<=NF;i++) t+=$i; print t}' /proc/stat)
    local i2=$(awk '/^cpu / {print $5}' /proc/stat)
    local td=$(( t2 - t1 ))
    local id=$(( i2 - i1 ))
    [ "$td" -eq 0 ] && echo 0 || echo $(( (td - id) * 100 / td ))
}

# ── System stats (every 10s) ──────────────────────────────────────────────────
(
    emit_sys() {
        local cpu=$(_get_cpu)
        local ram=$(free -m | awk '/Mem:/ {print int($3/$2 * 100)}' || echo '0')
        local disk=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%' || echo '0')
        local temp=""
        temp=$(sensors 2>/dev/null | grep -m 1 -E 'Package id 0|Tctl|Tdie|edge|temp1' | grep -oE '\+[0-9]+\.[0-9]+' | head -n 1 | tr -d '+' | cut -d. -f1)
        [ -z "$temp" ] && temp=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n 1 | awk '{print int($1/1000)}')
        temp=${temp:-0}
        local uptime=$(awk '{print int($1/3600)"h "int(($1%3600)/60)"m"}' /proc/uptime 2>/dev/null || echo '0h 0m')
        # Emit all on one line, newline-separated for SplitParser
        echo "sysout:$cpu"
        echo "sysout:$ram"
        echo "sysout:$disk"
        echo "sysout:$temp"
        echo "sysout:$uptime"
    }
    emit_sys
    while true; do
        sleep 15
        emit_sys
    done
) &

# ── Battery (every 15s) ───────────────────────────────────────────────────────
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
    emit_bat() {
        jq -n -c \
            --arg percent "$(get_battery_percent)" \
            --arg status "$(get_battery_status)" \
            --arg icon "$(get_battery_icon)" \
            '{percent: $percent, status: $status, icon: $icon}'
    }
    echo "bout:$(emit_bat)"
    while true; do
        sleep 15
        echo "bout:$(emit_bat)"
    done
) &

wait