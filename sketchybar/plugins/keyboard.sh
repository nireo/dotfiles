#!/bin/sh

layout="$(defaults read "$HOME/Library/Preferences/com.apple.HIToolbox.plist" AppleSelectedInputSources 2>/dev/null)"

case "$layout" in
  *Finnish*) label="fi" ;;
  *) label="us" ;;
esac

sketchybar --set "$NAME" label="$label"
