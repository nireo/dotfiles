#!/usr/bin/env bash

# Keep tmux's chrome in sync with Kitty's active theme.
#
# With no arguments this retains the original light/dark detector.  --apply
# applies the Kitty palette to the current tmux server, and --watch keeps
# doing that whenever current-theme.conf changes.

set -u

THEME_FILE="${KITTY_THEME_FILE:-$HOME/.config/kitty/current-theme.conf}"

kitty_color() {
    local name="$1"
    awk -v name="$name" '
        $1 == name && $2 ~ /^#[[:xdigit:]]{3,6}$/ { print $2; exit }
    ' "$THEME_FILE" 2>/dev/null
}

valid_color() {
    [[ "$1" =~ ^#[[:xdigit:]]{6}$ ]]
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
    get_colors

    # Use the actual Kitty background rather than tmux's default palette.  The
    # foreground/accent/border colors come directly from the active theme.
    tmux set-option -g status-style "bg=$BACKGROUND,fg=$FOREGROUND"
    tmux set-option -g status-right '#[fg='"$ACCENT"']#(b="$(git -C "#{pane_current_path}" rev-parse --abbrev-ref HEAD 2>/dev/null)"; [ -n "$b" ] || exit; printf "%%s" "$b"; [ -n "$(git -C "#{pane_current_path}" status --porcelain 2>/dev/null)" ] && printf " (c)")#[default] #[fg='"$ACCENT"']▍#[default] #[fg='"$FOREGROUND"',bold]#S #{?client_prefix,#[fg='"$ACCENT"']⌃B ,}#[default]'
    tmux set-option -g window-status-style "fg=$MUTED,bg=$BACKGROUND"
    tmux set-option -g window-status-current-style "fg=$ACCENT,bg=$BACKGROUND,bold"
    tmux set-option -g window-status-format " #[fg=$MUTED]#I/#W#[default] "
    tmux set-option -g window-status-current-format " #[fg=$ACCENT]#I#[fg=$MUTED]:#[fg=$FOREGROUND]#W#[fg=$ACCENT]#{?window_zoomed_flag,⤢,}*#[default] "
    tmux set-option -g pane-border-style "fg=$MUTED"
    tmux set-option -g pane-active-border-style "fg=$ACCENT,bold"
    tmux set-option -g message-style "fg=$BACKGROUND,bg=$SELECTION"
    tmux set-option -g message-command-style "fg=$BACKGROUND,bg=$SELECTION"
    tmux refresh-client -S 2>/dev/null || true
}

if [[ "${1:-}" == "--apply" ]]; then
    apply_theme
    exit 0
fi

if [[ "${1:-}" == "--watch" ]]; then
    # This process is started once per tmux server by .tmux.conf.  Polling a
    # small theme file avoids requiring fswatch/inotify and costs negligible
    # work while tmux is running.
    last_signature=""
    while tmux list-sessions >/dev/null 2>&1; do
        signature="$(cksum "$THEME_FILE" 2>/dev/null || printf 'missing')"
        if [[ "$signature" != "$last_signature" ]]; then
            apply_theme
            last_signature="$signature"
        fi
        sleep 2
    done
    exit 0
fi

# Original light/dark detection API.
get_colors

HEX="${BACKGROUND#\#}"
if [[ "$HEX" =~ ^[[:xdigit:]]{6}$ ]]; then
    R=$((16#${HEX:0:2}))
    G=$((16#${HEX:2:2}))
    B=$((16#${HEX:4:2}))
    LUMA=$(( (R * 299 + G * 587 + B * 114) / 1000 ))

    if (( LUMA > 140 )); then
        echo "light"
        exit 0
    fi
fi

echo "dark"
