#if [ -d /etc/X11/xinit/xinitrc.d ]; then
#  for f in /etc/X11/xinit/xinitrc.d/*; do
#    [ -x "$f" ] && . "$f"
#  done
#  unset f
#fi

# portion the screen corrently
sh /home/lain/.screenlayout/preset.sh

# set wallpaper
# feh --bg-scale ~/media/wallpapers/1602417424949.jpg

# fix the jetbrains ides
export _JAVA_AWT_WM_NONREPARENTING=1

# Change caps to an additional control key
setxkbmap -option "caps:ctrl_modifier" &

# Load different visual settings for xorg.
xrdb ~/.Xresources &

# start the status bar
# dwmblocks &
# picom -b

xset r rate 400 33

exec i3
# exec startlxqt
