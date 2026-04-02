# ~/.zshenv
# This file is sourced by every zsh instance.
# Keep it small and fast.
# Use it for environment variables that must always exist.

# Preferred editor
export EDITOR="nvim"
export VISUAL="nvim"

# Locale
export LANG="en_US.UTF-8"

# XDG base directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Local user binaries
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/.local/npm/bin"
  $path
)

# Bun
export BUN_INSTALL="$HOME/.bun"
path=(
  "$BUN_INSTALL/bin"
  $path
)

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
path=(
  "$PNPM_HOME"
  $path
)

# uv installer helper path
# The Astral installer may create this helper file.
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

export PATH
