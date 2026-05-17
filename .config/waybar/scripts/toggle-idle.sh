#!/bin/bash
# Toggle idle inhibition using wayland-idle-inhibitor or hypridle

PIDFILE="/tmp/idle-inhibitor.pid"

if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    kill "$(cat "$PIDFILE")"
    rm -f "$PIDFILE"
    notify-send "Idle" "Idle inhibitor disabled"
else
    if command -v wayland-idle-inhibitor &>/dev/null; then
        wayland-idle-inhibitor &
        echo $! > "$PIDFILE"
    elif command -v hypridle &>/dev/null; then
        # kill hypridle to prevent idle; restart to re-enable
        pkill hypridle
        echo "inhibited" > "$PIDFILE"
    fi
    notify-send "Idle" "Idle inhibitor enabled — screen won't sleep"
fi
