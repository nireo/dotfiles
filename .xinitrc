if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# portion the screen corrently
sh /home/eemil/.screenlayout/preset.sh &

# dwm bar configuration
sh /home/eemil/projects/dwm-bar/dwm_bar.sh &

# set wallpaper
feh --bg-scale ~/pictures/wallpapers/1594786252519.jpg &

# fix the jetbrains ides
export _JAVA_AWT_WM_NONREPARENTING=1

# Change caps to an additional control key
setxkbmap -option "caps:ctrl_modifier" &

exec dwm

