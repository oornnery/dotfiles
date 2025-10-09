#!/bin/bash

# Script de manutenção e limpeza dos dotfiles
# Remove symlinks antigos, atualiza configurações, etc.

set -e

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Limpar symlinks quebrados
clean_broken_symlinks() {
    log "Limpando symlinks quebrados..."
    
    # Verificar home
    find ~ -maxdepth 2 -type l ! -exec test -e {} \; -print 2>/dev/null | while read broken_link; do
        if [[ "$broken_link" =~ dotfiles ]]; then
            warn "Removendo symlink quebrado: $broken_link"
            rm -f "$broken_link"
        fi
    done
    
    # Verificar .config
    find ~/.config -maxdepth 2 -type l ! -exec test -e {} \; -print 2>/dev/null | while read broken_link; do
        if [[ "$broken_link" =~ dotfiles ]]; then
            warn "Removendo symlink quebrado: $broken_link"
            rm -f "$broken_link"
        fi
    done
    
    # Verificar .local/bin
    find ~/.local/bin -maxdepth 1 -type l ! -exec test -e {} \; -print 2>/dev/null | while read broken_link; do
        if [[ "$broken_link" =~ dotfiles ]]; then
            warn "Removendo symlink quebrado: $broken_link"
            rm -f "$broken_link"
        fi
    done
}

# Atualizar permissões
update_permissions() {
    log "Atualizando permissões dos scripts..."
    
    find . -name "*.sh" -type f -exec chmod +x {} \;
    find home/scripts -type f -exec chmod +x {} \; 2>/dev/null || true
    find rofi/scripts -type f -exec chmod +x {} \; 2>/dev/null || true
    find wm/*/scripts -type f -exec chmod +x {} \; 2>/dev/null || true
    find shells/*/scripts -type f -exec chmod +x {} \; 2>/dev/null || true
}

# Backup de configurações atuais
backup_configs() {
    local backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    log "Criando backup em: $backup_dir"
    
    # Backup de arquivos importantes
    [[ -f ~/.zshrc ]] && cp ~/.zshrc "$backup_dir/"
    [[ -f ~/.bashrc ]] && cp ~/.bashrc "$backup_dir/"
    [[ -d ~/.config/i3 ]] && cp -r ~/.config/i3 "$backup_dir/"
    [[ -d ~/.config/rofi ]] && cp -r ~/.config/rofi "$backup_dir/"
    [[ -d ~/.config/sway ]] && cp -r ~/.config/sway "$backup_dir/"
    [[ -d ~/.config/hypr ]] && cp -r ~/.config/hypr "$backup_dir/"
    
    log "Backup concluído: $backup_dir"
}

# Verificar integridade dos dotfiles
check_integrity() {
    log "Verificando integridade dos dotfiles..."
    
    local issues=0
    
    # Verificar estrutura básica
    for dir in setup wm shells home rofi utils; do
        if [[ ! -d "$dir" ]]; then
            error "Diretório obrigatório ausente: $dir"
            ((issues++))
        fi
    done
    
    # Verificar scripts importantes
    for script in install.sh rofi/scripts/powermenu.sh; do
        if [[ ! -f "$script" ]]; then
            error "Script importante ausente: $script"
            ((issues++))
        fi
    done
    
    # Verificar permissões
    for script in $(find . -name "*.sh" -type f); do
        if [[ ! -x "$script" ]]; then
            warn "Script sem permissão de execução: $script"
            ((issues++))
        fi
    done
    
    if [[ $issues -eq 0 ]]; then
        log "✅ Integridade verificada - tudo OK!"
    else
        warn "⚠️  Encontrados $issues problemas"
    fi
    
    return $issues
}

# Atualizar plugins ZSH
update_zsh_plugins() {
    log "Atualizando plugins ZSH..."
    
    if [[ -d ~/.oh-my-zsh ]]; then
        cd ~/.oh-my-zsh && git pull
        cd - > /dev/null
        log "Oh-My-Zsh atualizado"
    fi
    
    # Atualizar plugins específicos
    if [[ -d shells/zsh/plugins ]]; then
        cd shells/zsh/plugins
        for plugin_dir in */; do
            if [[ -d "$plugin_dir/.git" ]]; then
                log "Atualizando plugin: $plugin_dir"
                cd "$plugin_dir" && git pull && cd ..
            fi
        done
        cd - > /dev/null
    fi
}

# Limpar arquivos temporários
clean_temp_files() {
    log "Limpando arquivos temporários..."
    
    # Remover backups antigos (mais de 30 dias)
    find ~/.dotfiles-backup-* -maxdepth 0 -type d -mtime +30 -exec rm -rf {} \; 2>/dev/null || true
    
    # Limpar cache de compilação Python
    find . -name "__pycache__" -type d -exec rm -rf {} \; 2>/dev/null || true
    find . -name "*.pyc" -type f -delete 2>/dev/null || true
    
    # Limpar logs antigos
    find . -name "*.log" -type f -mtime +7 -delete 2>/dev/null || true
}

# Menu principal
main() {
    echo -e "${GREEN}"
    echo "┌─────────────────────────────────────┐"
    echo "│      Dotfiles Maintenance          │"
    echo "│    Cleanup & Update Tools          │"
    echo "└─────────────────────────────────────┘"
    echo -e "${NC}"
    
    echo "Escolha uma opção:"
    echo "1) Limpeza completa (symlinks + temp files)"
    echo "2) Backup de configurações atuais"
    echo "3) Atualizar permissões"
    echo "4) Verificar integridade"
    echo "5) Atualizar plugins ZSH"
    echo "6) Executar tudo"
    echo "0) Sair"
    
    read -p "Opção: " choice
    
    case $choice in
        1)
            clean_broken_symlinks
            clean_temp_files
            ;;
        2)
            backup_configs
            ;;
        3)
            update_permissions
            ;;
        4)
            check_integrity
            ;;
        5)
            update_zsh_plugins
            ;;
        6)
            backup_configs
            clean_broken_symlinks
            update_permissions
            clean_temp_files
            check_integrity
            update_zsh_plugins
            log "🎉 Manutenção completa finalizada!"
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

# Verificar se está no diretório correto
if [[ ! -f "README.md" ]] || [[ ! -d "setup" ]]; then
    error "Execute este script no diretório raiz dos dotfiles!"
    exit 1
fi

main
