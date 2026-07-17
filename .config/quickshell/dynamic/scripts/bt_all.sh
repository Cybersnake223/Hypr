#!/bin/bash
# Quickshell helper: Bluetooth status + device list as JSON
power=$(bluetoothctl show 2>/dev/null | grep 'Powered:' | awk '{print $2}')
devices=$(bluetoothctl devices Connected 2>/dev/null | jq -Rs 'split("\n") | map(select(length > 0)) | [.[] | capture("Device (?<mac>[^ ]+) (?<name>.*)")]')
jq -n --arg power "$power" --argjson devices "$devices" '{powered: $power, count: ($devices | length), devices: $devices}'
