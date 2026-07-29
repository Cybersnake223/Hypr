#!/usr/bin/env bash
ACTION="${1:-toggle}"
STEP="${2:-5}"

case "$ACTION" in
    up)
        MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -c "MUTED")
        [ "${MUTED:-0}" -gt 0 ] && wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
        wpctl set-volume @DEFAULT_AUDIO_SINK@ ${STEP}%+
        ;;
    down)   wpctl set-volume @DEFAULT_AUDIO_SINK@ ${STEP}%- ;;
    mute)   wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    mic)    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle ;;
esac

VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}')
MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -c "MUTED")
MUTED=${MUTED:-0}
if [ "$MUTED" -gt 0 ]; then
    echo "volume|${VOL:-0}|muted" > /tmp/qs_osd
else
    echo "volume|${VOL:-0}" > /tmp/qs_osd
fi
