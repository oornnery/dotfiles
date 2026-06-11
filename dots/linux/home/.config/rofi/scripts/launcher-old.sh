#!/bin/bash

# Rofi App Launcher moderno com busca inteligente
# Suporte para aplicativos desktop e comandos

# Combinação de apps .desktop e comandos comuns
(
  # Apps desktop
  find /usr/share/applications ~/.local/share/applications -name "*.desktop" 2>/dev/null | \
  while read desktop; do
    name=$(grep -m 1 "^Name=" "$desktop" | cut -d= -f2)
    exec=$(grep -m 1 "^Exec=" "$desktop" | cut -d= -f2 | sed 's/%[a-zA-Z]//g')
    icon=$(grep -m 1 "^Icon=" "$desktop" | cut -d= -f2)
    
    # Filtrar aplicativos ocultos
    if ! grep -q "NoDisplay=true" "$desktop"; then
      echo "$name|$exec|$icon"
    fi
  done
  
  # Comandos úteis para desenvolvimento Python
  echo "Terminal|alacritty|terminal"
  echo "File Manager|thunar|folder"
  echo "Python REPL|python3|python"
  echo "Python Web Server|python3 -m http.server|python"
  echo "Jupyter Notebook|jupyter notebook|python"
  echo "VS Code|code|vscode"
  echo "Neovim|nvim|nvim"
  
) | rofi -dmenu -i -p "Launch" -theme-str 'window {width: 40%; height: 60%;}' -format 's' | \
while IFS='|' read -r name exec icon; do
  if [ -n "$exec" ]; then
    # Executar em background
    nohup $exec > /dev/null 2>&1 &
  fi
done
