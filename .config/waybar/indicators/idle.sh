#!/bin/bash
PIDFILE="/tmp/idle-inhibitor.pid"
if [[ -f "$PIDFILE" ]] && (kill -0 "$(cat "$PIDFILE")" 2>/dev/null || [[ "$(cat "$PIDFILE")" == "inhibited" ]]); then
    printf '{"text":"󰛐","tooltip":"Idle inhibited","class":"active"}\n'
else
    printf '{"text":"","tooltip":"","class":""}\n'
fi
