#!/usr/bin/env bash
echo "[$(date)] Called with: $*" >>/tmp/qs_launch_debug.log
echo "[$(date)] PWD: $(pwd)" >>/tmp/qs_launch_debug.log
echo "[$(date)] DISPLAY: ${DISPLAY:-unset}" >>/tmp/qs_launch_debug.log
echo "[$(date)] WAYLAND_DISPLAY: ${WAYLAND_DISPLAY:-unset}" >>/tmp/qs_launch_debug.log
nohup "$@" >/dev/null 2>&1 &
echo "[$(date)] Launched PID: $!" >>/tmp/qs_launch_debug.log
