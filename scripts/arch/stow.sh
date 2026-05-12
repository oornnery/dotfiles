#!/usr/bin/env bash
# arch/stow.sh — link dotfiles from ~/dotfiles/<pkg>/ into $HOME via GNU stow.
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

stow::run() {
  id "$USER_NAME" >/dev/null 2>&1 || { log::warn "User $USER_NAME doesn't exist; skipping stow."; return 0; }
  command -v stow >/dev/null 2>&1 \
    || { log::warn "stow not installed (should be in core.sh); skipping."; return 0; }

  local user_home dotfiles_dir
  user_home="$(getent passwd "$USER_NAME" | cut -d: -f6)"
  dotfiles_dir="$user_home/dotfiles"

  if [[ ! -d "$dotfiles_dir" ]]; then
    log::warn "$dotfiles_dir not found — clone the dotfiles repo there first."
    return 0
  fi

  log::step "Stowing dotfiles from $dotfiles_dir."

  # Base packages — always tried.
  local -a packages=(bash zsh tmux nvim git editor fabric system)

  # Hyprland config — only if hyprland installed.
  pkg_installed hyprland && packages+=(hyprland)

  # WSL package — only inside WSL.
  [[ ${IS_WSL:-0} -eq 1 ]] && packages+=(wsl)

  local pkg
  for pkg in "${packages[@]}"; do
    if [[ ! -d "$dotfiles_dir/$pkg" ]]; then
      log::info "Skipping '$pkg' (not in repo)."
      continue
    fi
    log::info "Stowing '$pkg'."
    run as_user stow -d "$dotfiles_dir" -t "$user_home" -R "$pkg" \
      || log::warn "stow failed for '$pkg' (file conflict? rm or back up the existing one)."
  done
  PROMPTS_APPLIED+=("stow dotfiles")
}
