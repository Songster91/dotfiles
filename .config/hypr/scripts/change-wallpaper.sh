#!/bin/bash
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Pick a random wallpaper
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)

# 1. Preload the new one FIRST (loads into memory)
hyprctl hyprpaper preload "$WALLPAPER"

# 2. Set it (now instant, already in memory)
hyprctl hyprpaper wallpaper ",$WALLPAPER"

# 3. Unload ALL others AFTER switching (cleanup)
hyprctl hyprpaper unload all
