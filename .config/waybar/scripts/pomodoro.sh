#!/bin/bash
# Pomodoro timer for Waybar
# Left click:   start / pause / resume
# Right click:  reset (logs partial session)
# Middle click: open pomodoro.conf in terminal editor

CONFIG_FILE="$HOME/.config/waybar/pomodoro.conf"
STATE_FILE="/tmp/waybar-pomodoro-state"
LOG_FILE="$HOME/.local/share/pomodoro-log.json"

# ── Create default config if missing ──────────────────────────
if [[ ! -f "$CONFIG_FILE" ]]; then
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cat > "$CONFIG_FILE" << 'EOF'
# ──────────────────────────────────────────────
#  Pomodoro Timer Config
#  Middle-click the timer in waybar to edit this.
#  Save and close — changes apply on next start.
# ──────────────────────────────────────────────

# Work session duration (minutes)
WORK_MINUTES=50

# Short break duration (minutes)
BREAK_MINUTES=10

# Long break duration (minutes)
LONG_BREAK_MINUTES=30

# Number of work sessions before a long break
SESSIONS_UNTIL_LONG=4

# Play a sound when a session ends (true/false)
SOUND_ENABLED=true
EOF
fi

# ── Load config ───────────────────────────────────────────────
source "$CONFIG_FILE"

WORK_TIME=$(( WORK_MINUTES * 60 ))
BREAK_TIME=$(( BREAK_MINUTES * 60 ))
LONG_BREAK_TIME=$(( LONG_BREAK_MINUTES * 60 ))

# ── Init state + log ──────────────────────────────────────────
[[ -f "$STATE_FILE" ]] || printf 'stopped:0:work:0:0:#general' > "$STATE_FILE"
if [[ ! -f "$LOG_FILE" ]]; then
    mkdir -p "$(dirname "$LOG_FILE")"
    printf '[]' > "$LOG_FILE"
fi

# ── Fix Wayland env (waybar strips these) ─────────────────────
# Find the real WAYLAND_DISPLAY socket dynamically
fix_wayland_env() {
    if [[ -z "$WAYLAND_DISPLAY" ]]; then
        local uid; uid=$(id -u)
        local runtime="${XDG_RUNTIME_DIR:-/run/user/$uid}"
        # Find the first wayland socket in the runtime dir
        local sock; sock=$(ls "$runtime"/wayland-* 2>/dev/null | grep -v '\.lock' | head -1)
        if [[ -n "$sock" ]]; then
            export WAYLAND_DISPLAY="$(basename "$sock")"
        else
            export WAYLAND_DISPLAY="wayland-1"
        fi
    fi
    export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"
}

# ── Helpers ───────────────────────────────────────────────────
read_state() {
    IFS=':' read -r STATUS REMAINING MODE ELAPSED SESSION_COUNT TAG < "$STATE_FILE"
    REMAINING=$(( ${REMAINING:-0} + 0 ))
    ELAPSED=$(( ${ELAPSED:-0} + 0 ))
    SESSION_COUNT=$(( ${SESSION_COUNT:-0} + 0 ))
    TAG="${TAG:-#general}"
    MODE="${MODE:-work}"
    STATUS="${STATUS:-stopped}"
}

write_state() {
    printf '%s:%s:%s:%s:%s:%s' "$1" "$2" "$3" "$4" "$5" "$6" > "$STATE_FILE"
}

play_sound() {
    [[ "$SOUND_ENABLED" == true ]] && \
        paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null &
}

fmt_time() {
    printf '%02d:%02d' $(( $1 / 60 )) $(( $1 % 60 ))
}

pnotify() {
    notify-send -a "Pomodoro" "$1" "$2" 2>/dev/null &
}

log_minutes() {
    local minutes=$1 tag=$2
    (( minutes <= 0 )) && return
    local ts; ts=$(date +%s)000
    local existing; existing=$(< "$LOG_FILE")
    if [[ "$existing" == "[]" ]]; then
        printf '[{"timestamp":%s,"minutes":%s,"tag":"%s"}]' \
            "$ts" "$minutes" "$tag" > "$LOG_FILE"
    else
        printf '%s]' \
            "${existing%?},{\"timestamp\":${ts},\"minutes\":${minutes},\"tag\":\"${tag}\"}" \
            > "$LOG_FILE"
    fi
}

# Launch a terminal with a command — works even when called from waybar
launch_terminal() {
    local cmd="$1"
    fix_wayland_env
    for term in alacritty kitty foot xterm; do
        if command -v "$term" &>/dev/null; then
            case "$term" in
                alacritty)
                    WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
                    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
                    DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
                    alacritty --class "floating,floating" -e bash -c "$cmd" &
                    ;;
                kitty)
                    WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
                    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
                    kitty --class floating -e bash -c "$cmd" &
                    ;;
                foot)
                    WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
                    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
                    foot --app-id floating -e bash -c "$cmd" &
                    ;;
                xterm)
                    DISPLAY="${DISPLAY:-:0}" xterm -e bash -c "$cmd" &
                    ;;
            esac
            return
        fi
    done
    # Last resort: open as text file
    xdg-open "$CONFIG_FILE" &
}

ask_tag() {
    fix_wayland_env
    local tags="#study
#webdev
#yarn
#textile
#reading
#project
#personal
#practice
#assignment
#other"
    local tag=""
    if command -v walker &>/dev/null; then
        tag=$(printf '%s' "$tags" | \
              WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
              XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
              walker --dmenu --placeholder "What are you working on?" 2>/dev/null)
    elif command -v wofi &>/dev/null; then
        tag=$(printf '%s' "$tags" | \
              WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
              XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
              wofi --dmenu -p "What are you working on?" 2>/dev/null)
    elif command -v rofi &>/dev/null; then
        tag=$(printf '%s' "$tags" | rofi -dmenu -p "What are you working on?" 2>/dev/null)
    fi
    [[ -z "$tag" ]] && tag="#general"
    [[ "$tag" != \#* ]] && tag="#${tag}"
    printf '%s' "$tag"
}

# ── Commands ──────────────────────────────────────────────────
case "$1" in

    config)
        EDITOR_CMD="nano"
        for ed in micro nvim vim nano vi; do
            command -v "$ed" &>/dev/null && EDITOR_CMD="$ed" && break
        done
        launch_terminal "$EDITOR_CMD '$CONFIG_FILE'; echo; echo 'Done. Press enter to close.'; read _"
        ;;

    toggle)
        read_state
        case "$STATUS" in
            stopped)
                if [[ "$MODE" == "work" ]]; then
                    TAG=$(ask_tag)
                    pnotify "Pomodoro Started" "Tag: ${TAG}  ·  ${WORK_MINUTES}m"
                    write_state "running" "$WORK_TIME" "work" "0" "$SESSION_COUNT" "$TAG"
                elif [[ "$MODE" == "break" ]]; then
                    pnotify "Break Started" "${BREAK_MINUTES}m short break"
                    write_state "running" "$BREAK_TIME" "break" "0" "$SESSION_COUNT" "$TAG"
                else
                    pnotify "Long Break Started" "${LONG_BREAK_MINUTES}m — relax!"
                    write_state "running" "$LONG_BREAK_TIME" "long_break" "0" "$SESSION_COUNT" "$TAG"
                fi
                ;;
            running)
                pnotify "Paused" "$(fmt_time "$REMAINING") remaining [${TAG}]"
                write_state "paused" "$REMAINING" "$MODE" "$ELAPSED" "$SESSION_COUNT" "$TAG"
                ;;
            paused)
                pnotify "Resumed" "[${TAG}]"
                write_state "running" "$REMAINING" "$MODE" "$ELAPSED" "$SESSION_COUNT" "$TAG"
                ;;
        esac
        ;;

    reset)
        read_state
        if [[ "$MODE" == "work" ]] && (( ELAPSED > 0 )); then
            mins=$(( ELAPSED / 60 ))
            (( mins > 0 )) && log_minutes "$mins" "$TAG"
        fi
        pnotify "Reset" "Timer cleared."
        write_state "stopped" "0" "work" "0" "$SESSION_COUNT" "#general"
        ;;

    status|*)
        read_state

        if [[ "$STATUS" == "running" ]]; then
            REMAINING=$(( REMAINING - 1 ))
            ELAPSED=$(( ELAPSED + 1 ))

            if (( REMAINING <= 0 )); then
                play_sound
                if [[ "$MODE" == "work" ]]; then
                    log_minutes "$WORK_MINUTES" "$TAG"
                    SESSION_COUNT=$(( SESSION_COUNT + 1 ))
                    if (( SESSION_COUNT % SESSIONS_UNTIL_LONG == 0 )); then
                        pnotify "Long Break! 🎉" "${LONG_BREAK_MINUTES}m — you earned it [${TAG}]"
                        write_state "running" "$LONG_BREAK_TIME" "long_break" "0" "$SESSION_COUNT" "$TAG"
                    else
                        pnotify "Break Time ☕" "${BREAK_MINUTES}m break [${TAG}]"
                        write_state "running" "$BREAK_TIME" "break" "0" "$SESSION_COUNT" "$TAG"
                    fi
                else
                    pnotify "Break Over!" "Click to start next session."
                    write_state "stopped" "0" "work" "0" "$SESSION_COUNT" "#general"
                fi
            else
                write_state "running" "$REMAINING" "$MODE" "$ELAPSED" "$SESSION_COUNT" "$TAG"
            fi
        fi

        read_state

        if [[ "$STATUS" == "stopped" ]]; then
            [[ "$MODE" == "work" ]] && icon="󰔟" || icon="󰾩"
            text="Ready"
            css_class="stopped"
        elif [[ "$STATUS" == "paused" ]]; then
            icon="󰏤"
            text="$(fmt_time "$REMAINING")"
            css_class="paused"
        else
            [[ "$MODE" == "work" ]] && icon="󰔟" || icon="󰾩"
            text="$(fmt_time "$REMAINING")"
            css_class="running-${MODE}"
        fi

        printf '{"text":"%s %s","class":"%s","tooltip":"Tag: %s | Session #%s | Work: %sm Break: %sm"}\n' \
            "$icon" "$text" "$css_class" "$TAG" "$SESSION_COUNT" "$WORK_MINUTES" "$BREAK_MINUTES"
        ;;
esac
