#!/bin/bash
PIDFILE="/tmp/wf-recorder.pid"
if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    printf '{"text":"","tooltip":"Recording in progress","class":"active"}\n'
else
    printf '{"text":"","tooltip":"","class":""}\n'
fi
