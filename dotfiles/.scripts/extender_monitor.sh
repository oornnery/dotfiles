#!/bin/bash

# Verificando monitores ativos.
#

# Import .config/dotfiles/config
source ~/.config/dotfiles/config

mon_primary=$monitor_primary
mon_left=$monitor_left
monitors=($(xrandr -q | grep " connected" | awk -F " connected" '{print $1}'))

for mon in "${monitors[@]}"; do
	echo "Set monitor $mon"
	if [ "$mon" == "$mon_primary" ]; then
		xrandr --output $mon --auto --primary --right-of $mon_left
	else
		xrandr --output $mon --auto
	fi
done

#xrandr --output LVDS1 --auto --pos 0x0 --output VGA1 --auto --primary --pos 1366x0

