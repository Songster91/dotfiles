#!/bin/bash
# Timezone selector using walker

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

TZ=""
if command -v walker &>/dev/null; then
    TZ=$(timedatectl list-timezones | \
        WAYLAND_DISPLAY="$WAYLAND_DISPLAY" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
        walker --dmenu --placeholder "Select Timezone" 2>/dev/null)
elif command -v wofi &>/dev/null; then
    TZ=$(timedatectl list-timezones | \
        WAYLAND_DISPLAY="$WAYLAND_DISPLAY" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
        wofi --dmenu -p "Select Timezone" 2>/dev/null)
elif command -v rofi &>/dev/null; then
    TZ=$(timedatectl list-timezones | rofi -dmenu -p "Select Timezone" 2>/dev/null)
fi

[[ -z "$TZ" ]] && exit 0

if command -v pkexec &>/dev/null; then
    pkexec timedatectl set-timezone "$TZ"
else
    notify-send "Timezone" "Run: sudo timedatectl set-timezone $TZ"
fi
