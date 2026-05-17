#!/bin/bash
# Native battery status notification

BAT=$(ls /sys/class/power_supply/ | grep -i 'bat' | head -1)
[[ -z "$BAT" ]] && echo "No battery found" && exit 1

CAP=$(cat "/sys/class/power_supply/${BAT}/capacity" 2>/dev/null || echo "?")
STATUS=$(cat "/sys/class/power_supply/${BAT}/status" 2>/dev/null || echo "Unknown")

# Try to get power draw (μW → W)
POWER_FILE="/sys/class/power_supply/${BAT}/power_now"
if [[ -f "$POWER_FILE" ]]; then
    POWER_UW=$(cat "$POWER_FILE")
    POWER=$(awk "BEGIN { printf \"%.1f\", $POWER_UW / 1000000 }")W
else
    POWER="N/A"
fi

printf 'Battery: %s%%\nStatus: %s\nPower: %s\n' "$CAP" "$STATUS" "$POWER"
