#!/usr/bin/env bash

# Path to Kitty's current theme file
THEME_FILE="$HOME/.config/kitty/current-theme.conf"

if [ -f "$THEME_FILE" ]; then
    # Extract background hex color (ignoring leading whitespace and comments)
    BG=$(awk '/^[[:space:]]*background[[:space:]]/ {print $2}' "$THEME_FILE" | head -n 1)
fi

# Fallback to dark if background hex not found
BG=${BG:-"#000000"}

# Remove leading # if present
HEX=${BG#\#}

# Ensure valid 6 hex digits
if [[ ${#HEX} -eq 6 ]]; then
    R=$((16#${HEX:0:2}))
    G=$((16#${HEX:2:2}))
    B=$((16#${HEX:4:2}))
    
    # Calculate perceived luminance (0-255)
    LUMA=$(( (R * 299 + G * 587 + B * 114) / 1000 ))
    
    if [ "$LUMA" -gt 140 ]; then
        echo "light"
        exit 0
    fi
fi

echo "dark"
