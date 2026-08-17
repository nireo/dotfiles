#!/usr/bin/env bash

# Keep tmux's chrome in sync with Kitty's active theme.
#
# Kitty's dark-theme.auto.conf/light-theme.auto.conf files override the
# normal current-theme.conf include when the OS appearance changes, so tmux
# resolves those files from the same appearance setting before falling back
# to the configured include.  With no arguments this retains the original
# light/dark detector.  --apply applies the palette to the current tmux
# server, and --watch re-applies it when the config, theme file, or OS mode
# changes.

set -u

KITTY_CONF="${KITTY_CONF:-$HOME/.config/kitty/kitty.conf}"
# KITTY_THEME_FILE overrides the theme file directly for custom setups.
DIRECT_THEME="${KITTY_THEME_FILE:-}"
THEME_FILE=""
THEME_MODE=""

# Return the appearance Kitty uses for its automatic theme files.
detect_os_mode() {
    case "${KITTY_THEME_MODE:-}" in
        dark|light|no-preference)
            printf '%s\n' "$KITTY_THEME_MODE"
            return
            ;;
    esac

    if [[ "$(uname -s 2>/dev/null)" == "Darwin" ]] \
        && command -v defaults >/dev/null 2>&1; then
        if [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == "Dark" ]]; then
            printf '%s\n' "dark"
        else
            printf '%s\n' "light"
        fi
        return
    fi

    if command -v gsettings >/dev/null 2>&1; then
        local scheme
        scheme="$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || true)"
        case "$scheme" in
            *prefer-dark*) printf '%s\n' "dark"; return ;;
            *prefer-light*) printf '%s\n' "light"; return ;;
            *) printf '%s\n' "no-preference"; return ;;
        esac
    fi

    printf '%s\n' "unknown"
}

resolve_theme() {
    if [[ -n "$DIRECT_THEME" ]]; then
        THEME_FILE="$DIRECT_THEME"
        THEME_MODE="direct"
        return
    fi

    local config_dir="$(dirname "$KITTY_CONF")"
    local mode="$(detect_os_mode)"
    local candidates=()
    case "$mode" in
        dark) candidates=("dark-theme.auto.conf") ;;
        light) candidates=("light-theme.auto.conf") ;;
        no-preference) candidates=("no-preference-theme.auto.conf") ;;
    esac

    for candidate in "${candidates[@]}"; do
        if [[ -f "$config_dir/$candidate" ]]; then
            THEME_FILE="$config_dir/$candidate"
            THEME_MODE="$mode"
            return
        fi
    done

    local inc=""
    if [[ -f "$KITTY_CONF" ]]; then
        # Prefer the include inside the theme block, then any include.
        inc="$(awk '/^# BEGIN_KITTY_THEME/{in_block=1} in_block && /^include[[:space:]]+/{print $2; exit} /^# END_KITTY_THEME/{exit}' "$KITTY_CONF" 2>/dev/null)"
        [[ -n "$inc" ]] || inc="$(awk '/^include[[:space:]]+/{inc=$2} END{print inc}' "$KITTY_CONF" 2>/dev/null)"
    fi
    if [[ -n "$inc" ]]; then
        if [[ "$inc" == /* ]]; then
            THEME_FILE="$inc"
        else
            THEME_FILE="$config_dir/$inc"
        fi
    else
        THEME_FILE="$config_dir/current-theme.conf"
    fi
    THEME_MODE="static"
}

kitty_color() {
    local name="$1"
    awk -v name="$name" '
        $1 == name && $2 ~ /^#[[:xdigit:]]{3,6}$/ { print $2; exit }
    ' "$THEME_FILE" 2>/dev/null
}

valid_color() {
    [[ "$1" =~ ^#[[:xdigit:]]{6}$ ]]
}

color_luma() {
    local hex="${1#\#}"
    if [[ ! "$hex" =~ ^[[:xdigit:]]{6}$ ]]; then
        printf '%s\n' 0
        return
    fi
    printf '%s\n' "$(( ((16#${hex:0:2}) * 299 + (16#${hex:2:2}) * 587 + (16#${hex:4:2}) * 114) / 1000 ))"
}

# Mix two colors; weight is 0-100, the share of the first color.
blend() {
    local a="$1" b="$2" weight="$3"
    local ar=$((16#${a:1:2})) ag=$((16#${a:3:2})) ab=$((16#${a:5:2}))
    local br=$((16#${b:1:2})) bg=$((16#${b:3:2})) bb=$((16#${b:5:2}))
    printf '#%02x%02x%02x' \
        "$(( (ar * weight + br * (100 - weight)) / 100 ))" \
        "$(( (ag * weight + bg * (100 - weight)) / 100 ))" \
        "$(( (ab * weight + bb * (100 - weight)) / 100 ))"
}

get_colors() {
    BACKGROUND="$(kitty_color background)"
    FOREGROUND="$(kitty_color foreground)"
    ACCENT="$(kitty_color cursor)"
    MUTED="$(kitty_color color8)"
    SELECTION="$(kitty_color selection_background)"

    # Themes are allowed to omit cursor/selection colors.  Prefer colors from
    # the theme itself, with conservative fallbacks for incomplete themes.
    valid_color "$BACKGROUND" || BACKGROUND="#000000"
    valid_color "$FOREGROUND" || FOREGROUND="#ffffff"
    valid_color "$ACCENT" || ACCENT="$(kitty_color color4)"
    valid_color "$ACCENT" || ACCENT="$FOREGROUND"
    valid_color "$MUTED" || MUTED="$FOREGROUND"
    valid_color "$SELECTION" || SELECTION="$MUTED"
}

apply_theme() {
    resolve_theme
    get_colors

    # Use the actual Kitty background rather than tmux's default palette.  The
    # foreground/accent/border colors come directly from the active theme.
    tmux set-option -g status-style "bg=$BACKGROUND,fg=$FOREGROUND"
    tmux set-option -g status-right '#[fg='"$ACCENT"']#(b="$(git -C "#{pane_current_path}" rev-parse --abbrev-ref HEAD 2>/dev/null)"; [ -n "$b" ] || exit; printf "%%s" "$b"; [ -n "$(git -C "#{pane_current_path}" status --porcelain 2>/dev/null)" ] && printf " (c)")#[default] #[fg='"$ACCENT"']▍#[default] #[fg='"$FOREGROUND"',bold]#S #{?client_prefix,#[fg='"$ACCENT"']⌃B ,}#[default]'
    tmux set-option -g window-status-style "fg=$MUTED,bg=$BACKGROUND"
    tmux set-option -g window-status-current-style "fg=$ACCENT,bg=$BACKGROUND,bold"
    tmux set-option -g window-status-format " #[fg=$MUTED]#I/#W#[default] "
    tmux set-option -g window-status-current-format " #[fg=$ACCENT]#I#[fg=$MUTED]:#[fg=$FOREGROUND]#W#[fg=$ACCENT]#{?window_zoomed_flag,⤢,}*#[default] "
    # Pane borders stay quiet: the inactive border is dimmed well below the
    # muted palette, and the active one is a dim accent without bold so it
    # reads as a subtle highlight rather than a glow.  Tweak the blend
    # weights to taste: higher = closer to the raw MUTED/ACCENT color.
    BORDER_DIM="$(blend "$MUTED" "$BACKGROUND" 50)"
    BORDER_ACTIVE="$(blend "$ACCENT" "$BACKGROUND" 60)"
    tmux set-option -g pane-border-style "fg=$BORDER_DIM"
    tmux set-option -g pane-active-border-style "fg=$BORDER_ACTIVE"
    # tmux confirmation prompts use message-style/message-command-style.
    # Pick whichever of the theme's foreground/background colors contrasts
    # with the selection color instead of assuming every theme uses a light
    # selection.
    BACKGROUND_LUMA="$(color_luma "$BACKGROUND")"
    FOREGROUND_LUMA="$(color_luma "$FOREGROUND")"
    SELECTION_LUMA="$(color_luma "$SELECTION")"
    if (( SELECTION_LUMA > 140 )); then
        if (( BACKGROUND_LUMA < FOREGROUND_LUMA )); then
            MESSAGE_FOREGROUND="$BACKGROUND"
        else
            MESSAGE_FOREGROUND="$FOREGROUND"
        fi
    elif (( BACKGROUND_LUMA > FOREGROUND_LUMA )); then
        MESSAGE_FOREGROUND="$BACKGROUND"
    else
        MESSAGE_FOREGROUND="$FOREGROUND"
    fi
    tmux set-option -g message-style "fg=$MESSAGE_FOREGROUND,bg=$SELECTION"
    tmux set-option -g message-command-style "fg=$MESSAGE_FOREGROUND,bg=$SELECTION"
    tmux refresh-client -S 2>/dev/null || true
}

if [[ "${1:-}" == "--apply" ]]; then
    apply_theme
    exit 0
fi

if [[ "${1:-}" == "--watch" ]]; then
    # Started by .tmux.conf; replaces any previous watcher (e.g. after
    # Prefix-r).  Polling avoids requiring fswatch/inotify and costs
    # negligible work while tmux is running.
    WATCH_PIDFILE="/tmp/kitty-theme-watch.pid"
    if [[ -f "$WATCH_PIDFILE" ]]; then
        old_pid="$(cat "$WATCH_PIDFILE" 2>/dev/null)"
        if [[ "$old_pid" =~ ^[0-9]+$ ]] \
            && ps -p "$old_pid" -o command= 2>/dev/null | grep -q "tmux-theme-detect.sh --watch"; then
            kill "$old_pid" 2>/dev/null || true
        fi
    fi
    printf '%s\n' "$$" > "$WATCH_PIDFILE"
    trap 'rm -f "$WATCH_PIDFILE"' EXIT

    last_signature=""
    while tmux list-sessions >/dev/null 2>&1; do
        resolve_theme
        signature="$(printf '%s\n' "$THEME_MODE" "$THEME_FILE"; cksum "$KITTY_CONF" 2>/dev/null || printf 'missing\n'; cksum "$THEME_FILE" 2>/dev/null || printf 'missing\n')"
        if [[ "$signature" != "$last_signature" ]]; then
            apply_theme
            last_signature="$signature"
        fi
        sleep 2
    done
    exit 0
fi

# Original light/dark detection API.
resolve_theme
get_colors

if (( $(color_luma "$BACKGROUND") > 140 )); then
    echo "light"
    exit 0
fi

echo "dark"
