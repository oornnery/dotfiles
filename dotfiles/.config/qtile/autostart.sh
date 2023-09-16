#!/bin/sh
# This script is executed at the start of each multiuser session.

### Set wallpaper
feh --bg-fill ~/.wallpaper/archlinux_1.jpg

### Set screen layout ###
~/.screenlayout/layout.sh &

### AUTOSTART PROGRAMS ###
lxsession &
picom -b &
nm-applet &
