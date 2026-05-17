#!/bin/bash
# Power menu using walker (dmenu mode), falls back to wofi/rofi

fix_wayland_env() {
    if [[ -z "$WAYLAND_DISPLAY" ]]; then
        local runtime="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
        local sock; sock=$(ls "$runtime"/wayland-* 2>/dev/null | grep -v '\.lock' | head -1)
        [[ -n "$sock" ]] && export WAYLAND_DISPLAY="$(basename "$sock")" || export WAYLAND_DISPLAY="wayland-1"
    fi
    export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"
}

fix_wayland_env

OPTIONS="󰤁  Lock
  Suspend
󰑓  Reboot
󰐥  Shutdown
  Cancel"

CHOICE=""
if command -v walker &>/dev/null; then
    CHOICE=$(printf '%s' "$OPTIONS" | \
        WAYLAND_DISPLAY="$WAYLAND_DISPLAY" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
        walker --dmenu --placeholder "Power..." 2>/dev/null)
elif command -v wofi &>/dev/null; then
    CHOICE=$(printf '%s' "$OPTIONS" | \
        WAYLAND_DISPLAY="$WAYLAND_DISPLAY" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
        wofi --dmenu -p "Power" 2>/dev/null)
elif command -v rofi &>/dev/null; then
    CHOICE=$(printf '%s' "$OPTIONS" | rofi -dmenu -p "Power" 2>/dev/null)
fi

case "$CHOICE" in
    *Lock*)     loginctl lock-session ;;
    *Suspend*)  systemctl suspend ;;
    *Reboot*)   systemctl reboot ;;
    *Shutdown*) systemctl poweroff ;;
esac
