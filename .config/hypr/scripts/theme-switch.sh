#!/bin/bash
THEME_STATE_FILE="$HOME/.cache/current_theme"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

THEMES=(mocha nord gruvbox dracula)

CURRENT=$(cat "$THEME_STATE_FILE" 2>/dev/null || echo "mocha")

CURRENT_INDEX=0
for i in "${!THEMES[@]}"; do
    if [ "${THEMES[$i]}" == "$CURRENT" ]; then
        CURRENT_INDEX=$i
        break
    fi
done

NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#THEMES[@]} ))
NEXT_THEME="${THEMES[$NEXT_INDEX]}"

apply_theme() {
    local theme=$1
    case "$theme" in
        mocha)
            GTK_THEME="catppuccin-mocha-mauve-standard+default"
            CURSOR_THEME="catppuccin-mocha-mauve-cursors"
            ;;
        nord)
            GTK_THEME="Colloid-Dark-Nord"
            CURSOR_THEME="Nordzy-cursors"
            ;;
        gruvbox)
            GTK_THEME="Colloid-Dark-Gruvbox"
            CURSOR_THEME="Bibata-Modern-Classic-Gruvbox"
            ;;
        dracula)
            GTK_THEME="Dracula"
            CURSOR_THEME="catppuccin-mocha-mauve-cursors"
            ;;
    esac

    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
    gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME"
    gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
    ln -sf "$HOME/.config/waybar/style-$theme.css" "$HOME/.config/waybar/style.css"

    sed -i "s/gtk-theme-name=.*/gtk-theme-name=$GTK_THEME/" "$HOME/.config/gtk-3.0/settings.ini"
    sed -i "s/gtk-cursor-theme-name=.*/gtk-cursor-theme-name=$CURSOR_THEME/" "$HOME/.config/gtk-3.0/settings.ini"
    sed -i "s/gtk-theme-name=.*/gtk-theme-name=$GTK_THEME/" "$HOME/.config/gtk-4.0/settings.ini"
    sed -i "s/gtk-cursor-theme-name=.*/gtk-cursor-theme-name=$CURSOR_THEME/" "$HOME/.config/gtk-4.0/settings.ini"

    hyprctl setcursor "$CURSOR_THEME" 24

    THEME_WALLPAPER_DIR="$WALLPAPER_DIR/$theme"
    if [ -d "$THEME_WALLPAPER_DIR" ] && [ "$(ls -A "$THEME_WALLPAPER_DIR" 2>/dev/null)" ]; then
        WALLPAPER=$(find "$THEME_WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)
    else
        WALLPAPER=$(find "$WALLPAPER_DIR/mocha" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)
    fi

    awww img "$WALLPAPER" --transition-type grow --transition-pos center --transition-duration 1
    echo "$WALLPAPER" > "$HOME/.cache/current_wallpaper"

    echo "$theme" > "$THEME_STATE_FILE"

    pkill waybar
    sleep 0.5
    uwsm-app -- waybar &
    notify-send "Theme Switched" "Now using: $theme" -t 2000
}

apply_theme "$NEXT_THEME"
