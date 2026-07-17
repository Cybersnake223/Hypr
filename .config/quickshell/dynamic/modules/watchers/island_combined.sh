#!/usr/bin/env bash
# Combined island watcher: weather, pkg updates, caffeine, wifi, bt — all in one process.
# Each output line is prefixed with a tag so DynamicIsland's SplitParser can route it.
# Multi-line JSON outputs (like bt_all.sh) are buffered first, then emitted as one tagged line.

# Single-line emitter
etag() { echo "$1:$2"; }

# ── Weather (every 5 min) ────────────────────────────────────────────────────
(
    emit_weather() {
        # Single combined call: --island refreshes the cache once (if stale) and
        # emits all 12 fields (incl. current hourly icon/temp) in one jq pass.
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
    emit_weather
    emit_forecast
    while true; do
        sleep 300
        emit_weather
        emit_forecast
    done
) &

# ── Package updates (every 30 min) ────────────────────────────────────────────
(
    emit_pkg() {
        local out=$($HOME/.config/quickshell/dynamic/scripts/pkg_updates.sh 2>/dev/null)
        echo "pkgout:$out"
    }
    emit_pkg
    while true; do
        sleep 1800
        emit_pkg
    done
) &

# ── Caffeine (every 30s) ──────────────────────────────────────────────────────
(
    emit_caffeine() {
        local state=$(cat /tmp/qs_caffeine 2>/dev/null || echo 'off')
        echo "caffeineout:$state"
    }
    emit_caffeine
    while true; do
        sleep 30
        emit_caffeine
    done
) &

# ── WiFi (every 30s) — emit as single JSON ───────────────────────────────────
(
    emit_wifi() {
        local raw=$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi list 2>/dev/null | grep '^yes' | head -1)
        if [ -n "$raw" ]; then
            local ssid=$(echo "$raw" | awk -F: '{print $2}')
            local signal=$(echo "$raw" | awk -F: '{print $3}')
            jq -n -c --arg s "$ssid" --argjson sig "${signal:-0}" '{ssid: $s, signal: $sig}'
        else
            jq -n -c '{ssid: "", signal: 0}'
        fi
    }
    emit_wifi
    while true; do
        sleep 30
        emit_wifi
    done
) | while IFS= read -r line; do echo "wifiout:$line"; done &

# ── Bluetooth (every 30s) ────────────────────────────────────────────────────
# Compact multi-line JSON to one line, then emit as single tagged line.
(
    emit_bt() {
        local json=$($HOME/.config/quickshell/dynamic/scripts/bt_all.sh 2>/dev/null | jq -c . 2>/dev/null)
        echo "btout:$json"
    }
    emit_bt
    while true; do
        sleep 30
        emit_bt
    done
) &

wait
