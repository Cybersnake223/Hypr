#!/usr/bin/env bash
ACTION="${1:-up}"
STEP="${2:-5}"

case "$ACTION" in
    up)   brightnessctl set +${STEP}% 2>/dev/null ;;
    down) brightnessctl set ${STEP}%- 2>/dev/null ;;
esac

BRIGHT=$(brightnessctl -m 2>/dev/null | awk -F, '{gsub(/%/,"",$4); print int($4)}')
echo "brightness|${BRIGHT:-50}" > /tmp/qs_osd
