#!/bin/sh
# This script is executed at the start of each multiuser session.

### Set wallpaper
# feh --bg-fill ~/.wallpaper/archlinux_1.jpg

### Set screen layout ###
# ~/.screenlayout/layout.sh &

# Picom compositor
picom -b &

# Auth with polkit-kde-agent:
/usr/lib/polkit-kde-authentication-agent-1 &

# Desktop notifications
mako &

# Network Applet
nm-applet --indicator &

# # GTK3 applications take a long time to start
# systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK &
# hash dbus-update-activation-environment 2>/dev/null && \
#      dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK &
