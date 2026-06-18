#!/bin/bash
CACHE_FILE="$HOME/.cache/current_wallpaper"
FALLBACK="$HOME/Pictures/Wallpapers/wallpaperflare.com_wallpaper.jpg"

# Wait for daemon to be ready
while ! awww query; do
    sleep 0.1
done

if [ -f "$CACHE_FILE" ]; then
    awww img "$(cat $CACHE_FILE)" --transition-type fade --transition-duration 1
else
    awww img "$FALLBACK" --transition-type fade --transition-duration 1
fi
