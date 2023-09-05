#!/bin/bash

# Get the current keyboard layout
current_layout=$(setxkbmap -print | awk -F"+" '/xkb_symbols/ {print $2}')

# Check the current layout and toggle it
if [ "$current_layout" = "fi" ]; then
    setxkbmap us
    echo "Switched to US keyboard layout."
else
    setxkbmap "fi"
    echo "Switched to Finnish keyboard layout."
fi
