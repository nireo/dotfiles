#!/bin/sh
# This file echos a string that will be processed and displayed on the spectrwm bar.
# Any spectrwm bar_format character sequences will be expanded.

# Text markup sequences
BOLD="+@fn=1;+@fg=1;"
REGULAR="+@fn=0;+@fg=0;"

# Echo an icon representing default sink volume from wireplumber. 
volume () {
  vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%.0f%\n", $2*100}')
  echo -e "Vol ${BOLD}${vol}${REGULAR}"
}

# Echo the amount of memory currently being used.
memory () {
  mem=$(free -m | awk '/^Mem:/{print $3}')
  echo "Mem ${BOLD}${mem}MiB${REGULAR}"
}

storage () {
    # Get used storage percentage for root partition
    used_percent=$(df -h / | awk 'NR==2 {print $5}')
    # Get used and total in human readable format
    used_total=$(df -h / | awk 'NR==2 {print $3"/"$2}')
    echo "Storage ${BOLD}${used_total} (${used_percent})${REGULAR}"
}

# Update the bar utilities every five seconds.
while :; do
  # Display username and window manager workspace info on left.
  left="+|L󱄅 ${BOLD}${USER}@$(hostname)${REGULAR}  Space ${BOLD}+L${REGULAR} Stack ${BOLD}+S${REGULAR}"

  # Display date and time in the center.
  center="+|C$(date +"%a %b %d %H:%M")"

  # Display utilities from this script on the right.
  right="+|R$(memory)  $(storage)  $(volume)"

  echo "${left}${center}${right}"
  sleep 5
done
