#!/usr/bin/env bash
set -euo pipefail

echo "==> Herdr stack + plugins"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

has() { command -v "$1" >/dev/null 2>&1; }

echo "==> Install herdr (>= 0.7.5 for reviewr)"
if has herdr; then
  version="$(herdr --version 2>/dev/null | awk '{print $2}' || true)"
  echo "herdr already installed: ${version:-unknown}"
elif has pacman; then
  sudo pacman -S --needed --noconfirm herdr-bin || paru -S --needed herdr-bin
elif has apt; then
  mkdir -p "$HOME/.local/bin"
  curl -fsSL "https://github.com/herdrdev/herdr/releases/latest/download/herdr-linux-$(uname -m)" -o "$HOME/.local/bin/herdr"
  chmod +x "$HOME/.local/bin/herdr"
else
  echo "Unknown system. Install herdr manually: https://herdr.dev"
fi

echo "==> Plugin prerequisites"
if has pacman; then
  sudo pacman -S --needed --noconfirm fzf zoxide || true
elif has apt; then
  sudo apt install -y fzf zoxide || true
fi
has bun || echo "WARNING: bun not found (needed by tab-smart-rename, sessionizer, window-title-sync)"
has gh || echo "WARNING: gh not found (needed by reviewr PR tab, ghzinga)"
has cargo && has ghzinga || echo "INFO: ghzinga binary not installed, installing via cargo..."
if has cargo && ! has ghzinga; then
  cargo install ghzinga || true
fi

echo "==> Stow herdr config"
if [ -f "$HOME/.config/herdr/config.toml" ] && [ ! -L "$HOME/.config/herdr/config.toml" ]; then
  stamp="$(date +%Y%m%d-%H%M%S)"
  mv "$HOME/.config/herdr/config.toml" "$HOME/.config/herdr/config.toml.bak.$stamp"
  echo "backup: ~/.config/herdr/config.toml -> config.toml.bak.$stamp"
fi
stow -R -d "$DOTFILES_DIR" -t "$HOME" herdr

echo "==> Install plugins"
PLUGINS=(
  persiyanov/herdr-reviewr
  nicosuave/memex
  osolmaz/ghzinga/plugins/herdr
  thanhdat77/herdr-navigator
  yuk1ty/herdr-spreader
  iurysza/herdr-tab-smart-rename
  andrewchng/herdr-sessionizer
  rjyo/herdr-window-title-sync
)

has herdr || { echo "ERROR: herdr missing, cannot install plugins"; exit 1; }

installed="$(herdr plugin list 2>/dev/null || true)"
for plugin in "${PLUGINS[@]}"; do
  id="${plugin#*/}"
  id="${id%%/*}"
  if printf '%s' "$installed" | grep -q "$id"; then
    echo "skip (already installed): $plugin"
    continue
  fi
  echo "install: $plugin"
  herdr plugin install "$plugin" --yes || echo "FAILED: $plugin"
done

echo
echo "==> Done."
echo "Verify with: herdr plugin list"
