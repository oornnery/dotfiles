#!/usr/bin/env bash
# arch/shell.sh — zsh, tmux, neovim + modern CLI replacements.
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

shell::base() {
  log::step "Installing shell packages."
  pacman_install \
    zsh tmux neovim \
    fastfetch btop htop \
    tree \
    ripgrep fd fzf \
    jq yq \
    bat eza zoxide \
    lazygit \
    yazi
  # Terminal emulators — skip in WSL (need WSLg).
  if [[ ${IS_WSL:-0} -eq 0 ]] && [[ ${IS_VM:-0} -eq 0 ]]; then
    pacman_install ghostty alacritty
  fi
}

shell::modern_cli() {
  log::step "Installing modern CLI replacements."
  pacman_install \
    github-cli atuin mise direnv tealdeer \
    procs dust duf sd xh bottom \
    gping doggo tokei glab
  PROMPTS_APPLIED+=("modern CLI tools")
}

# Oh My Zsh + plugins — runs as user via scripts/zsh.sh.
shell::oh_my_zsh() {
  id "$USER_NAME" >/dev/null 2>&1 || return 0
  local zsh_script="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}/scripts/zsh.sh"
  if [[ ! -f "$zsh_script" ]]; then
    log::warn "scripts/zsh.sh missing; skipping Oh My Zsh."
    return 0
  fi
  log::step "Installing Oh My Zsh + plugins as $USER_NAME."
  run as_user bash "$zsh_script"
}

shell::run() {
  shell::base
}
