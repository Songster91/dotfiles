#!/bin/bash
# Check for Arch Linux updates (pacman + AUR via paru/yay)

COUNT=0
AUR_COUNT=0

# Sync db quietly
checkupdates_out=$(checkupdates 2>/dev/null)
COUNT=$(printf '%s' "$checkupdates_out" | grep -c '.' 2>/dev/null || echo 0)

# AUR updates (paru or yay)
if command -v paru &>/dev/null; then
    AUR_COUNT=$(paru -Qua 2>/dev/null | grep -c '.' || echo 0)
elif command -v yay &>/dev/null; then
    AUR_COUNT=$(yay -Qua 2>/dev/null | grep -c '.' || echo 0)
fi

TOTAL=$(( COUNT + AUR_COUNT ))

if (( TOTAL == 0 )); then
    printf '{"text":"","tooltip":"System up to date","class":""}\n'
else
    tooltip="${COUNT} pacman + ${AUR_COUNT} AUR updates available"
    if (( TOTAL > 20 )); then
        class="outdated"
    else
        class="pending"
    fi
    printf '{"text":" %s","tooltip":"%s","class":"%s"}\n' "$TOTAL" "$tooltip" "$class"
fi
