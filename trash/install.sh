#!/bin/bash

# Script de instalação automática dos dotfiles
# Suporta: Arch Linux, Debian, NixOS, Windows (WSL)

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para logging
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detectar sistema operacional
detect_os() {
    if [[ -f /etc/arch-release ]]; then
        echo "arch"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/NIXOS ]]; then
        echo "nixos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Detectar window manager
detect_wm() {
    if pgrep -x "i3" > /dev/null; then
        echo "i3"
    elif pgrep -x "sway" > /dev/null; then
        echo "sway"
    elif pgrep -x "hyprland" > /dev/null; then
        echo "hyprland"
    elif pgrep -x "qtile" > /dev/null; then
        echo "qtile"
    elif [[ "$XDG_CURRENT_DESKTOP" == "GNOME" ]]; then
        echo "gnome"
    elif [[ "$XDG_CURRENT_DESKTOP" == "XFCE" ]]; then
        echo "xfce"
    else
        echo "unknown"
    fi
}

# Criar symlinks
create_symlinks() {
    local os=$1
    local wm=$2
    
    log "Criando symlinks para $os com $wm"
    
    # Configurações home
    mkdir -p ~/.config
    
    # Rofi (universal)
    if [[ -d "home/.config/rofi" ]]; then
        ln -sf "$(pwd)/home/.config/rofi" ~/.config/
        log "Rofi configurado"
    fi
    
    # Configurações específicas do WM
    case $wm in
        "i3")
            if [[ -d "wm/i3/i3" ]]; then
                ln -sf "$(pwd)/wm/i3/i3" ~/.config/
                log "i3 configurado"
            fi
            ;;
        "sway")
            if [[ -d "wm/sway/sway" ]]; then
                ln -sf "$(pwd)/wm/sway/sway" ~/.config/
                log "Sway configurado"
            fi
            ;;
        "hyprland")
            if [[ -d "wm/hyprland/hypr" ]]; then
                ln -sf "$(pwd)/wm/hyprland/hypr" ~/.config/
                log "Hyprland configurado"
            fi
            ;;
        "qtile")
            if [[ -d "wm/qtile/qtile" ]]; then
                ln -sf "$(pwd)/wm/qtile/qtile" ~/.config/
                log "Qtile configurado"
            fi
            ;;
    esac
    
    # ZSH
    if [[ -f "shells/zsh/.zshrc" ]]; then
        ln -sf "$(pwd)/shells/zsh/.zshrc" ~/.zshrc
        log "ZSH configurado"
    fi
    
    # Scripts úteis
    mkdir -p ~/.local/bin
    chmod +x home/scripts/*
    chmod +x rofi/scripts/*
    
    for script in home/scripts/*; do
        if [[ -f "$script" ]]; then
            ln -sf "$(pwd)/$script" ~/.local/bin/
        fi
    done
    
    for script in rofi/scripts/*; do
        if [[ -f "$script" ]]; then
            ln -sf "$(pwd)/$script" ~/.local/bin/
        fi
    done
    
    log "Scripts instalados em ~/.local/bin"
}

# Instalar pacotes
install_packages() {
    local os=$1
    
    case $os in
        "arch")
            if [[ -f "setup/linux/arch/install.sh" ]]; then
                log "Executando instalação para Arch Linux"
                cd setup/linux/arch && ./install.sh
                cd - > /dev/null
            fi
            ;;
        "debian")
            log "Setup para Debian disponível em setup/linux/debian/"
            ;;
        "nixos")
            if [[ -f "setup/linux/nixos/configuration.nix" ]]; then
                log "Configuração NixOS disponível em setup/linux/nixos/"
                warn "Execute: sudo cp setup/linux/nixos/configuration.nix /etc/nixos/"
                warn "Depois: sudo nixos-rebuild switch"
            fi
            ;;
    esac
}

# Menu principal
main() {
    echo -e "${BLUE}"
    echo "┌─────────────────────────────────────┐"
    echo "│        Dotfiles Installer          │"
    echo "│   Multi-OS & Multi-WM Support      │"
    echo "└─────────────────────────────────────┘"
    echo -e "${NC}"
    
    local os=$(detect_os)
    local wm=$(detect_wm)
    
    log "Sistema detectado: $os"
    log "Window Manager detectado: $wm"
    
    echo
    echo "Escolha uma opção:"
    echo "1) Instalação completa (pacotes + configs)"
    echo "2) Apenas configurações (symlinks)"
    echo "3) Apenas pacotes"
    echo "4) Setup ZSH com plugins"
    echo "5) Mostrar estrutura dos dotfiles"
    echo "0) Sair"
    
    read -p "Opção: " choice
    
    case $choice in
        1)
            install_packages $os
            create_symlinks $os $wm
            log "Instalação completa finalizada!"
            ;;
        2)
            create_symlinks $os $wm
            log "Configurações aplicadas!"
            ;;
        3)
            install_packages $os
            log "Pacotes instalados!"
            ;;
        4)
            if [[ -f "shells/zsh/scripts/zsh.sh" ]]; then
                cd shells/zsh/scripts && ./zsh.sh && ./zsh_plugins.sh
                cd - > /dev/null
                log "ZSH configurado com plugins!"
            fi
            ;;
        5)
            tree -L 2 --dirsfirst
            ;;
        0)
            log "Saindo..."
            exit 0
            ;;
        *)
            error "Opção inválida!"
            main
            ;;
    esac
}

# Verificações iniciais
if [[ ! -d "setup" ]] || [[ ! -d "wm" ]]; then
    error "Execute este script no diretório raiz dos dotfiles!"
    exit 1
fi

main
