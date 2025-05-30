#!/bin/bash

# Rofi App Launcher moderno com busca inteligente
# Suporte para aplicativos desktop e comandos de desenvolvimento

# Auto-detectar terminal preferido
detect_terminal() {
    for term in alacritty kitty gnome-terminal xfce4-terminal konsole xterm; do
        if command -v "$term" &> /dev/null; then
            echo "$term"
            return
        fi
    done
    echo "xterm"  # fallback
}

# Auto-detectar file manager
detect_filemanager() {
    for fm in thunar nautilus dolphin pcmanfm nemo caja; do
        if command -v "$fm" &> /dev/null; then
            echo "$fm"
            return
        fi
    done
    echo "xdg-open"  # fallback
}

TERMINAL=$(detect_terminal)
FILEMANAGER=$(detect_filemanager)

# Combinação de apps .desktop e comandos comuns
(
  # Apps desktop
  find /usr/share/applications ~/.local/share/applications -name "*.desktop" 2>/dev/null | \
  while read desktop; do
    name=$(grep -m 1 "^Name=" "$desktop" | cut -d= -f2)
    exec=$(grep -m 1 "^Exec=" "$desktop" | cut -d= -f2 | sed 's/%[a-zA-Z]//g')
    icon=$(grep -m 1 "^Icon=" "$desktop" | cut -d= -f2)
    
    # Filtrar aplicativos ocultos
    if ! grep -q "NoDisplay=true" "$desktop" && ! grep -q "OnlyShowIn=" "$desktop"; then
      echo "$name|$exec|$icon"
    fi
  done
  
  # Comandos úteis para desenvolvimento
  echo "🖥️ Terminal|$TERMINAL|terminal"
  echo "📁 File Manager|$FILEMANAGER|folder" 
  echo "🐍 Python REPL|$TERMINAL -e python3|python"
  echo "🌐 Python Web Server|$TERMINAL -e 'python3 -m http.server 8000'|python"
  echo "📓 Jupyter Notebook|jupyter notebook|jupyter"
  echo "💻 VS Code|code|vscode"
  echo "⚡ Neovim|$TERMINAL -e nvim|nvim"
  echo "🔧 Htop|$TERMINAL -e htop|htop"
  echo "🗃️ Docker PS|$TERMINAL -e 'docker ps'|docker"
  echo "📊 System Monitor|$TERMINAL -e 'watch -n 1 free -h'|system"
  
) | sort | rofi -dmenu -i -p "🚀 Launch Application" \
    -theme-str 'window {width: 50%; height: 70%;}' \
    -theme-str 'listview {lines: 15;}' \
    -format 's' | \
while IFS='|' read -r name exec icon; do
  if [ -n "$exec" ]; then
    # Executar em background, suprimindo output
    nohup bash -c "$exec" > /dev/null 2>&1 &
    # Notificar o usuário
    if command -v notify-send &> /dev/null; then
        notify-send "Launched" "$name" -t 2000
    fi
  fi
done
