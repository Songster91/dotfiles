#!/bin/bash
# Weather script using wttr.in — no omarchy dep
# Usage: weather.sh [notify]

CACHE_FILE="/tmp/waybar-weather-cache"
CACHE_TTL=600   # seconds

fetch_weather() {
    # Auto-detect location via wttr.in (uses IP geolocation)
    local raw; raw=$(curl -sf --max-time 5 "https://wttr.in/?format=j1" 2>/dev/null) || return 1
    local temp desc icon feels

    temp=$(printf '%s' "$raw" | python3 -c "
import sys,json
d=json.load(sys.stdin)
c=d['current_condition'][0]
print(c.get('temp_C','?'))
" 2>/dev/null) || temp="?"

    desc=$(printf '%s' "$raw" | python3 -c "
import sys,json
d=json.load(sys.stdin)
c=d['current_condition'][0]
print(c['weatherDesc'][0]['value'])
" 2>/dev/null) || desc="Unknown"

    feels=$(printf '%s' "$raw" | python3 -c "
import sys,json
d=json.load(sys.stdin)
c=d['current_condition'][0]
print(c.get('FeelsLikeC','?'))
" 2>/dev/null) || feels="?"

    # Pick icon based on description
    case "${desc,,}" in
        *sunny*|*clear*)       icon="" ;;
        *partly*cloud*)        icon="⛅" ;;
        *cloud*|*overcast*)    icon="☁" ;;
        *rain*|*drizzle*)      icon="🌧" ;;
        *thunder*|*storm*)     icon="⛈" ;;
        *snow*|*blizzard*)     icon="❄" ;;
        *mist*|*fog*|*haze*)   icon="🌫" ;;
        *)                     icon="🌡" ;;
    esac

    local tooltip="${desc} | Feels like ${feels}°C"
    printf '{"text":"%s %s°C","tooltip":"%s","class":""}\n' "$icon" "$temp" "$tooltip"
    printf '%s\t%s\t%s\t%s\n' "$temp" "$desc" "$feels" "$icon" > "$CACHE_FILE"
}

if [[ "$1" == "notify" ]]; then
    if [[ -f "$CACHE_FILE" ]]; then
        IFS=$'\t' read -r temp desc feels icon < "$CACHE_FILE"
        notify-send -u low "🌤 Weather" "${icon} ${desc}\nTemp: ${temp}°C | Feels like: ${feels}°C"
    fi
    exit 0
fi

# Use cache if fresh
if [[ -f "$CACHE_FILE" ]] && (( $(date +%s) - $(stat -c %Y "$CACHE_FILE") < CACHE_TTL )); then
    IFS=$'\t' read -r temp desc feels icon < "$CACHE_FILE"
    printf '{"text":"%s %s°C","tooltip":"%s | Feels like %s°C","class":""}\n' \
        "$icon" "$temp" "$desc" "$feels"
    exit 0
fi

result=$(fetch_weather) || printf '{"text":"","tooltip":"Weather unavailable","class":"unavailable"}'
[[ -n "$result" ]] && printf '%s' "$result"
