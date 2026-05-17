#!/bin/bash

TOUCHPAD="synps/2-synaptics-touchpad"
STATE_FILE="/tmp/touchpad_state"

# Read current state from file (default: enabled)
if [ ! -f "$STATE_FILE" ]; then
    echo "enabled" > "$STATE_FILE"
fi

CURRENT=$(cat "$STATE_FILE")

if [ "$CURRENT" = "enabled" ]; then
    hyprctl keyword "device[$TOUCHPAD]:enabled" "false"
    echo "disabled" > "$STATE_FILE"
    notify-send "Touchpad" "Disabled 🚫"
else
    hyprctl keyword "device[$TOUCHPAD]:enabled" "true"
    echo "enabled" > "$STATE_FILE"
    notify-send "Touchpad" "Enabled ✅"
fi
