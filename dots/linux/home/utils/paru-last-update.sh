#!/bin/bash

# Monitor last update paru -Qum | egrep -vc "^$"
# Inpired by https://github.com/polybar/polybar-scripts/blob/master/polybar-scripts/updates-aurhelper/updates-aurhelper.sh


if ! updates=$(paru -Qum 2> /dev/null | wc -l); then
    update=0
fi

if [ "$updates" -gt 0 ]; then
    echo "󰚰 $updates"
    notify-send "Paru new updates 󰚰 $updates"
else
    echo ""
fi