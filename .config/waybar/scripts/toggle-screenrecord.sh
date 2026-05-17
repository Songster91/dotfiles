#!/bin/bash
# Toggle wf-recorder screen recording

PIDFILE="/tmp/wf-recorder.pid"
OUTDIR="$HOME/Videos/Recordings"
mkdir -p "$OUTDIR"

if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    kill -SIGINT "$(cat "$PIDFILE")"
    rm -f "$PIDFILE"
    notify-send "Screen Recording" "Recording saved to $OUTDIR"
else
    OUTFILE="$OUTDIR/$(date +%Y-%m-%d_%H-%M-%S).mp4"
    wf-recorder -f "$OUTFILE" &
    echo $! > "$PIDFILE"
    notify-send "Screen Recording" "Recording started → $OUTFILE"
fi
