#!/bin/bash
# Toggle Do Not Disturb via dunstctl

dunstctl set-paused toggle
PAUSED=$(dunstctl is-paused)

if [[ "$PAUSED" == "true" ]]; then
    notify-send "Notifications" "Do Not Disturb enabled" 2>/dev/null || true
fi
