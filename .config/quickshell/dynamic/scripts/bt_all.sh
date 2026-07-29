#!/bin/bash
# Quickshell helper: Bluetooth status + device list as JSON
power=$(timeout 5 bluetoothctl show 2>/dev/null | grep 'Powered:' | awk '{print $2}')
devices=$(timeout 5 bluetoothctl devices Connected 2>/dev/null | jq -Rs 'split("\n") | map(select(length > 0)) | [.[] | capture("Device (?<mac>[^ ]+) (?<name>.*)")]')
if [ -z "$power" ]; then
    echo '{"powered":"no","count":0,"devices":[]}'
else
    jq -n --arg power "$power" --argjson devices "${devices:-[]}" '{powered: $power, count: ($devices | length), devices: $devices}'
fi
