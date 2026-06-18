#!/bin/bash
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_FILE="$HOME/.cache/current_wallpaper"

# Pick a random wallpaper
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)

# Random transition
TRANSITIONS=(any wave wipe grow outer fade left right top bottom center)
TRANSITION=${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}

# Set with random transition
awww img "$WALLPAPER" --transition-type "$TRANSITION" --transition-duration 1

# Save for next boot
echo "$WALLPAPER" > "$CACHE_FILE"
