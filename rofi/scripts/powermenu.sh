#!/bin/bash

# Rofi Power Menu moderno
# Dependências: rofi, systemctl

chosen=$(echo -e "⏻ Desligar\n Reiniciar\n⏸ Suspender\n📱 Hibernar\n🚪 Logout\n🔒 Lock" | rofi -dmenu -p "Power Menu" -theme-str 'window {width: 25%;}')

case "$chosen" in
  "⏻ Desligar") systemctl poweroff ;;
  " Reiniciar") systemctl reboot ;;
  "⏸ Suspender") systemctl suspend ;;
  "📱 Hibernar") systemctl hibernate ;;
  "🚪 Logout") 
    if pgrep -x "i3" > /dev/null; then
      i3-msg exit
    elif pgrep -x "sway" > /dev/null; then
      swaymsg exit
    elif pgrep -x "hyprland" > /dev/null; then
      hyprctl dispatch exit
    else
      pkill -KILL -u $USER
    fi
  ;;
  "🔒 Lock")
    if command -v i3lock &> /dev/null; then
      i3lock -c 000000
    elif command -v swaylock &> /dev/null; then
      swaylock -c 000000
    fi
  ;;
esac
