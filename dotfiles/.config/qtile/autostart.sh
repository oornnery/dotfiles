#!/bin/sh
# This script is executed at the start of each multiuser session.

### Set wallpaper
# feh --bg-fill ~/.wallpaper/archlinux_1.jpg
feh $HOME/Wallpaper/Aesthetic2.png -F --bg-fill &

### Set screen layout ###
#~/.screenlayout/layout_edp_hdmi-a-0.sh &

num_monitors=$(xrandr --listmonitors | grep -oP "Monitors: \K\d+")

# Verifica o numero de monitores
if [ $num_monitors -eq 1]; then
  autorandr default
elif [ $num_monitors -eq 2 ]; then
  autorandr default_hdmi
else
  autorandr default
fi


# Picom compositor
picom -b &

# Auth with polkit-kde-agent:
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Desktop notifications
dunst &

# Network Applet
nm-applet --indicator &

# # GTK3 applications take a long time to start
# systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK &
# hash dbus-update-activation-environment 2>/dev/null && \
#      dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK &
