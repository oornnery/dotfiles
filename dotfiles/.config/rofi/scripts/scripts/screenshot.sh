#!/bin/bash

# Options to be displayed
option0="󰲎"
option1="󰹑"
option2=""

# Options passed into variable
options="$option0\n$option1\n$option2\n"

# Chosen 
chosen="$(echo -e "$options" | rofi -lines 3 -dmenu -p "ScreenShot" -theme $HOME/.config/rofi/screenshot.rasi )"

case $chosen in
    $option0)
        flameshot gui;;
    $option1)
        flameshot full;;
    $option2)
        flameshot config;;
esac
