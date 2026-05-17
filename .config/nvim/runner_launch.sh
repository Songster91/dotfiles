#!/bin/bash
FNAME="$1"
CMD="$2"

# Get screen dimensions
SCREEN_W=$(hyprctl monitors -j | python3 -c "
import sys,json; m=json.load(sys.stdin)[0]
print(int(m['width']/m.get('scale',1)))")
SCREEN_H=$(hyprctl monitors -j | python3 -c "
import sys,json; m=json.load(sys.stdin)[0]
print(int(m['height']/m.get('scale',1)))")

WIN_W=$(( SCREEN_W * 30 / 100 ))
WIN_X=$(( SCREEN_W - WIN_W ))

# Launch alacritty
alacritty --title "Runner: $FNAME" -e bash -c "
clear
printf '\033[1;36m  Running: $FNAME\033[0m\n'
printf '\033[0;90m  Ctrl+C to stop  |  Enter to close\033[0m\n'
printf '\033[0;90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m\n'
$CMD
EXIT_CODE=\$?
printf '\033[0;90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m\n'
if [ \$EXIT_CODE -eq 0 ]; then
  printf '\033[1;32m  ✓  Done  (exit 0)\033[0m\n'
else
  printf '\033[1;31m  ✗  Error — exit code: '\$EXIT_CODE'\033[0m\n'
fi
printf '\n'
read -p \$'\033[0;90mPress Enter to close...\033[0m'
" &

# Poll until window appears
ADDR=""
for i in $(seq 1 30); do
  sleep 0.1
  ADDR=$(hyprctl clients -j | python3 -c "
import sys,json
for c in reversed(json.load(sys.stdin)):
    if 'Runner:' in c.get('title',''):
        print(c['address']); break
" 2>/dev/null)
  [ -n "$ADDR" ] && break
done

if [ -n "$ADDR" ]; then
  hyprctl dispatch togglefloating address:"$ADDR"
  hyprctl dispatch resizewindowpixel exact "$WIN_W" "$SCREEN_H",address:"$ADDR"
  hyprctl dispatch movewindowpixel exact "$WIN_X" 0,address:"$ADDR"
fi
