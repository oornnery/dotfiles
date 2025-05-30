#!/bin/bash

# XFCE Configuration Script
# Aplica configurações personalizadas para XFCE

set -e

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Verificar se XFCE está rodando
if [ "$XDG_CURRENT_DESKTOP" != "XFCE" ]; then
    warn "XFCE desktop não detectado. Pulando configuração do XFCE."
    exit 0
fi

log "Configurando desktop XFCE..."

# Configurações do painel
log "Configurando painel XFCE..."
xfconf-query -c xfce4-panel -p /panels/panel-1/position -s "p=6;x=0;y=0"
xfconf-query -c xfce4-panel -p /panels/panel-1/length -s 100
xfconf-query -c xfce4-panel -p /panels/panel-1/size -s 28
xfconf-query -c xfce4-panel -p /panels/panel-1/mode -s 0

# Configurações da área de trabalho
log "Configurando área de trabalho..."
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s "$HOME/.local/share/backgrounds/wallpaper.jpg"
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/image-style -s 5

# Configurações do window manager
log "Configurando gerenciador de janelas..."
xfconf-query -c xfwm4 -p /general/theme -s "Adwaita-dark"
xfconf-query -c xfwm4 -p /general/title_font -s "Cantarell Bold 9"
xfconf-query -c xfwm4 -p /general/workspace_count -s 4

# Atalhos de teclado
log "Configurando atalhos de teclado..."
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Primary><Alt>t" -s "exo-open --launch TerminalEmulator"
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>r" -s "rofi -show drun"
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>l" -s "xflock4"

# Configurações de energia
log "Configurando gerenciamento de energia..."
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -s 10
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-sleep -s 20
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-off -s 30

# Configurações do terminal
log "Configurando terminal..."
if [ -f ~/.config/xfce4/terminal/terminalrc ]; then
    sed -i 's/ColorForeground=.*/ColorForeground=#ffffff/' ~/.config/xfce4/terminal/terminalrc
    sed -i 's/ColorBackground=.*/ColorBackground=#1e1e1e/' ~/.config/xfce4/terminal/terminalrc
    sed -i 's/FontName=.*/FontName=Source Code Pro 10/' ~/.config/xfce4/terminal/terminalrc
fi

log "Configuração do XFCE concluída!"
log "Pode ser necessário fazer logout/login para aplicar todas as mudanças."
