#!/bin/bash

set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

BASE_PACKAGES=(
    build-essential
    ninja-build
    cmake
    make
    gettext
    curl
    wget
    git
    gh
    htop
    btop
    tree
    python3
    python3-pip
    vim
    tmux
    zsh
    fzf
    ripgrep
    fd-find
    unzip
    eza
    bat
    stow
    nodejs
    npm
    golang
    rustc
    fastfetch
)

OH_MY_ZSH_PLUGINS=(
    "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions"
    "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting.git"
    "fzf-tab|https://github.com/Aloxaf/fzf-tab"
    "zsh-completions|https://github.com/zsh-users/zsh-completions"
)

STOW_MODULES=(tmux zsh bash nvim)

if [[ -t 1 ]]; then
    C_RESET="\033[0m"
    C_BOLD="\033[1m"
    C_DIM="\033[2m"
    C_BLUE="\033[34m"
    C_CYAN="\033[36m"
    C_GREEN="\033[32m"
    C_YELLOW="\033[33m"
    C_MAGENTA="\033[35m"
else
    C_RESET=""
    C_BOLD=""
    C_DIM=""
    C_BLUE=""
    C_CYAN=""
    C_GREEN=""
    C_YELLOW=""
    C_MAGENTA=""
fi

log_section() {
    echo -e "${C_BOLD}${C_BLUE}$1${C_RESET}"
}

log_info() {
    echo -e "${C_CYAN}ℹ${C_RESET} $1"
}

log_ok() {
    echo -e "${C_GREEN}✔${C_RESET} $1"
}

log_warn() {
    echo -e "${C_YELLOW}↷${C_RESET} $1"
}

has_command() {
    command -v "$1" >/dev/null 2>&1
}

ask_yes_no() {
    local prompt="$1"
    local answer
    printf "%b%s%b %b(y/n)%b " "$C_MAGENTA" "$prompt" "$C_RESET" "$C_DIM" "$C_RESET"
    read -r answer
    [[ "$answer" =~ ^[Yy]$ ]]
}

run_step() {
    local prompt="$1"
    local skip_message="$2"
    local step_function="$3"

    if ask_yes_no "$prompt"; then
        "$step_function"
    else
        log_warn "$skip_message"
    fi
}

install_packages() {
    if has_command nala; then
        log_info "Using nala package manager..."
        sudo nala install -y "$@"
    else
        log_warn "Nala not found; falling back to apt..."
        sudo apt install -y "$@"
    fi
}

update_system() {
    log_info "Updating package lists..."
    sudo apt update && sudo apt upgrade -y
    log_ok "System update step done."
}

install_nala() {
    log_info "Installing Nala..."
    sudo apt install nala -y
    log_ok "Nala step done."
}

install_base_packages() {
    log_info "Installing base packages..."
    install_packages "${BASE_PACKAGES[@]}"
    log_ok "Base package step done."
}

install_uv() {
    log_info "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    log_ok "uv step done."
}

install_pnpm() {
    log_info "Installing pnpm..."
    curl -fsSL https://get.pnpm.io/install.sh | sh
    log_ok "pnpm step done."
}

install_bun() {
    log_info "Installing bun..."
    curl -fsSL https://bun.sh/install | bash
    log_ok "bun step done."
}

install_oh_my_zsh() {
    log_info "Installing Oh My Zsh..."
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        log_ok "Oh My Zsh installed."
    else
        log_warn "Oh My Zsh already installed, skipping..."
    fi
}

clone_or_update_plugin() {
    local plugin_name="$1"
    local repo_url="$2"
    local plugin_dir="$3/$plugin_name"

    if [ -d "$plugin_dir/.git" ]; then
        log_info "Updating $plugin_name..."
        git -C "$plugin_dir" pull --ff-only
    else
        log_info "Cloning $plugin_name..."
        git clone "$repo_url" "$plugin_dir"
    fi
}

install_oh_my_zsh_plugins() {
    log_info "Installing Oh My Zsh plugins..."
    local zsh_custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    local plugins_dir="$zsh_custom_dir/plugins"
    local plugin_entry plugin_name repo_url

    mkdir -p "$plugins_dir"

    for plugin_entry in "${OH_MY_ZSH_PLUGINS[@]}"; do
        plugin_name="${plugin_entry%%|*}"
        repo_url="${plugin_entry#*|}"
        clone_or_update_plugin "$plugin_name" "$repo_url" "$plugins_dir"
    done

    log_ok "Oh My Zsh plugins step done."
}

install_neovim_from_source() {
    log_info "Installing Neovim..."
    if [ -d /tmp/neovim/.git ]; then
        log_warn "Neovim repo exists in /tmp/neovim, updating..."
        git -C /tmp/neovim fetch --all --tags
    else
        git clone https://github.com/neovim/neovim /tmp/neovim
    fi
    cd /tmp/neovim
    git fetch origin stable
    git checkout -B stable origin/stable
    git reset --hard origin/stable
    make CMAKE_BUILD_TYPE=Release
    sudo make install
    cd "$DOTFILES_ROOT"
    rm -rf /tmp/neovim
    log_ok "Neovim install step done."
}

# # Settings debian testing repository to get the last version of neovim
# echo "Setting debian testing repository..."
# sudo cp /etc/apt/sources.list /etc/apt/sources.list.stable.backup
# sudo sed -i 's/bookworm/trixie/g' /etc/apt/sources.list
# sudo apt update
# sudo apt upgrade -y
# sudo apt install neovim -y

# # recovering sources.list
# sudo mv /etc/apt/sources.list.stable.backup /etc/apt/sources.list

configure_git() {
    log_info "Setting Git global config..."

    read -r -p "Enter your Git user name: " git_user_name
    git config --global user.name "$git_user_name"

    read -r -p "Enter your Git user email: " git_user_email
    git config --global user.email "$git_user_email"

    if ask_yes_no "Do you want to set up GitHub CLI now?"; then
        gh auth login
    fi
    log_ok "Git configuration step done."
}

ask_install() {
    local dotfile=$1
    if ask_yes_no "Do you want to install $dotfile dotfiles?"; then
        stow -v -d "$DOTFILES_ROOT" -t "$HOME" "$dotfile"
        log_ok "$dotfile dotfiles applied."
    else
        log_warn "Skipping $dotfile dotfiles."
    fi
}

run_stow_session() {
    log_info "Settings dotfiles with stow..."
    local module
    for module in "${STOW_MODULES[@]}"; do
        ask_install "$module"
    done
    log_ok "Stow session finished."
}

run_bootstrap_sessions() {
    run_step "Run system update/upgrade?" "Skipping system update/upgrade." update_system
    run_step "Install/ensure Nala?" "Skipping Nala installation." install_nala
    run_step "Install base packages (dev tools, shell tools, runtimes)?" "Skipping base package installation." install_base_packages
    run_step "Install uv?" "Skipping uv installation." install_uv
    run_step "Install pnpm?" "Skipping pnpm installation." install_pnpm
    run_step "Install bun?" "Skipping bun installation." install_bun
    run_step "Install/ensure Oh My Zsh?" "Skipping Oh My Zsh installation." install_oh_my_zsh
    run_step "Install/update Oh My Zsh plugins?" "Skipping Oh My Zsh plugins." install_oh_my_zsh_plugins
    run_step "Build and install Neovim from source?" "Skipping Neovim source install." install_neovim_from_source
    run_step "Configure Git global user/email and optional GitHub CLI login?" "Skipping Git/GitHub configuration." configure_git
    run_step "Run dotfiles stow session?" "Skipping dotfiles stow session." run_stow_session
}

log_section "=== Debian bootstrap (interactive sessions) ==="
run_bootstrap_sessions

log_section "Bootstrap finished."

