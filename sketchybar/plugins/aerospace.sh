#!/usr/bin/env bash

focused_workspace="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"
workspaces="$(aerospace list-workspaces --all)"
drawing=off

for workspace in $workspaces; do
  if [ "$workspace" = "$1" ]; then
    drawing=on
    break
  fi
done

if [ "$1" = "$focused_workspace" ]; then
  sketchybar --set "$NAME" \
    drawing="$drawing" \
    background.drawing=on \
    background.color=0x55ffffff \
    background.border_color=0x99ffffff \
    background.border_width=1 \
    background.corner_radius=8 \
    background.height=30 \
    label.padding_left=12 \
    label.padding_right=12 \
    label.color=0xffffffff
else
  sketchybar --set "$NAME" \
    drawing="$drawing" \
    background.drawing=off \
    background.border_width=0 \
    background.corner_radius=5 \
    background.height=25 \
    label.padding_left=8 \
    label.padding_right=8 \
    label.color=0xffa0a0a0
fi
