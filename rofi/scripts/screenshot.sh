#!/bin/bash

# Script moderno para captura de tela com rofi
# Suporta múltiplas opções e preview

screenshot_dir="$HOME/Pictures/Screenshots"
mkdir -p "$screenshot_dir"

options="🖼️ Tela Inteira\n📐 Seleção\n🪟 Janela Ativa\n⏱️ Timer 5s\n🎬 Gravação (10s)"

chosen=$(echo -e "$options" | rofi -dmenu -p "Screenshot" -theme-str 'window {width: 30%;}')

timestamp=$(date +%Y%m%d_%H%M%S)
filename="screenshot_${timestamp}.png"
filepath="$screenshot_dir/$filename"

case "$chosen" in
  "🖼️ Tela Inteira")
    if command -v grim &> /dev/null; then
      grim "$filepath"
    else
      scrot "$filepath"
    fi
    ;;
  "📐 Seleção")
    if command -v grim &> /dev/null && command -v slurp &> /dev/null; then
      grim -g "$(slurp)" "$filepath"
    else
      scrot -s "$filepath"
    fi
    ;;
  "🪟 Janela Ativa")
    if command -v grim &> /dev/null; then
      grim -g "$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')" "$filepath"
    else
      scrot -u "$filepath"
    fi
    ;;
  "⏱️ Timer 5s")
    sleep 5
    if command -v grim &> /dev/null; then
      grim "$filepath"
    else
      scrot "$filepath"
    fi
    ;;
  "🎬 Gravação (10s)")
    if command -v wf-recorder &> /dev/null; then
      timeout 10 wf-recorder -f "${screenshot_dir}/recording_${timestamp}.mp4"
    elif command -v ffmpeg &> /dev/null; then
      ffmpeg -f x11grab -s 1920x1080 -i :0.0 -t 10 "${screenshot_dir}/recording_${timestamp}.mp4"
    fi
    ;;
esac

# Notificação e cópia para clipboard
if [ -f "$filepath" ]; then
  notify-send "Screenshot" "Salvo em: $filename"
  if command -v wl-copy &> /dev/null; then
    wl-copy < "$filepath"
  elif command -v xclip &> /dev/null; then
    xclip -selection clipboard -t image/png -i "$filepath"
  fi
fi
