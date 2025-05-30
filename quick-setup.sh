#!/bin/bash

# Dotfiles Quick Setup - Configuração rápida para desenvolvimento
# Execute este script para configurar rapidamente um ambiente de desenvolvimento

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_banner() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════╗"
    echo "║          Quick Dev Setup             ║"
    echo "║      Python Development Focus       ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
}

log() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[⚠]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

# Detectar sistema
detect_system() {
    if [ -f /etc/arch-release ]; then
        echo "arch"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/nixos/configuration.nix ]; then
        echo "nixos"
    else
        echo "unknown"
    fi
}

# Setup rápido para Python
setup_python_dev() {
    log "Configurando ambiente Python para desenvolvimento..."
    
    # Verificar se Python está instalado
    if ! command -v python3 &> /dev/null; then
        error "Python3 não está instalado!"
        exit 1
    fi
    
    # Instalar pipx se não existir
    if ! command -v pipx &> /dev/null; then
        log "Instalando pipx..."
        python3 -m pip install --user pipx
        python3 -m pipx ensurepath
    fi
    
    # Instalar ferramentas Python essenciais
    log "Instalando ferramentas Python essenciais..."
    tools=("poetry" "black" "flake8" "mypy" "pytest" "jupyter")
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log "Instalando $tool..."
            pipx install "$tool"
        else
            log "$tool já instalado"
        fi
    done
}

# Setup rápido de ZSH
setup_zsh() {
    log "Configurando ZSH..."
    
    if [ ! -f ~/.zshrc ]; then
        log "Criando symlink para .zshrc..."
        ln -sf "$(pwd)/shells/zsh/.zshrc" ~/.zshrc
    fi
    
    if [ ! -f ~/.zprofile ]; then
        log "Criando symlink para .zprofile..."
        ln -sf "$(pwd)/shells/zsh/.zprofile" ~/.zprofile
    fi
    
    # Instalar plugins ZSH se não existirem
    if [ ! -d ~/.zsh/plugins ]; then
        log "Configurando plugins ZSH..."
        mkdir -p ~/.zsh
        ln -sf "$(pwd)/shells/zsh/plugins" ~/.zsh/plugins
    fi
}

# Setup de configurações básicas
setup_basic_configs() {
    log "Configurando aplicações básicas..."
    
    # Neovim
    if [ ! -d ~/.config/nvim ]; then
        log "Configurando Neovim..."
        mkdir -p ~/.config
        ln -sf "$(pwd)/home/.config/nvim" ~/.config/nvim
    fi
    
    # Rofi (se instalado)
    if command -v rofi &> /dev/null && [ ! -d ~/.config/rofi ]; then
        log "Configurando Rofi..."
        ln -sf "$(pwd)/home/.config/rofi" ~/.config/rofi
    fi
    
    # Git config básico
    if [ ! -f ~/.gitconfig ]; then
        log "Configurando Git..."
        read -p "Seu nome para Git: " git_name
        read -p "Seu email para Git: " git_email
        
        git config --global user.name "$git_name"
        git config --global user.email "$git_email"
        git config --global init.defaultBranch main
        git config --global core.editor nvim
    fi
}

# Menu principal
main_menu() {
    print_banner
    
    echo "Escolha uma configuração rápida:"
    echo "1) Setup completo de desenvolvimento Python"
    echo "2) Apenas configurar ZSH + plugins"
    echo "3) Apenas configurações básicas (nvim, rofi, etc.)"
    echo "4) Setup Git"
    echo "5) Verificar sistema e dependências"
    echo "0) Sair"
    echo
    
    read -p "Opção [0-5]: " choice
    
    case $choice in
        1)
            setup_python_dev
            setup_zsh
            setup_basic_configs
            log "Setup completo concluído!"
        ;;
        2)
            setup_zsh
            log "ZSH configurado!"
        ;;
        3)
            setup_basic_configs
            log "Configurações básicas aplicadas!"
        ;;
        4)
            setup_basic_configs
            log "Git configurado!"
        ;;
        5)
            system=$(detect_system)
            log "Sistema detectado: $system"
            log "Python: $(python3 --version 2>/dev/null || echo 'Não instalado')"
            log "Git: $(git --version 2>/dev/null || echo 'Não instalado')"
            log "ZSH: $(zsh --version 2>/dev/null || echo 'Não instalado')"
            log "Neovim: $(nvim --version 2>/dev/null | head -1 || echo 'Não instalado')"
        ;;
        0)
            log "Saindo..."
            exit 0
        ;;
        *)
            error "Opção inválida!"
            main_menu
        ;;
    esac
}

# Verificar se estamos no diretório correto
if [ ! -f "install.sh" ] || [ ! -d "shells" ]; then
    error "Execute este script a partir do diretório raiz dos dotfiles!"
    exit 1
fi

main_menu
