#!/bin/bash
# Quickshell helper: list connected Bluetooth devices as JSON
bluetoothctl devices Connected 2>/dev/null | jq -Rs 'split("\n") | map(select(length > 0)) | [.[] | capture("Device (?<mac>[^ ]+) (?<name>.*)")]' 2>/dev/null || echo '[]'
