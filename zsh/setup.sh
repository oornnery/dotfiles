#!/usr/bin/env bash
set -e

echo "==> Zsh stack + dotfiles"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"

# PATH for current session
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$HOME/.local/share/fnm:$HOME/.atuin/bin:$HOME/.cargo/bin:$PATH"

has() { command -v "$1" >/dev/null 2>&1; }

install_optional_pacman() {
  for pkg in "$@"; do
    if pacman -Si "$pkg" >/dev/null 2>&1; then
      sudo pacman -S --needed --noconfirm "$pkg" || true
    else
      echo "Skipping missing pacman package: $pkg"
    fi
  done
}

install_optional_apt() {
  for pkg in "$@"; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
      sudo apt install -y "$pkg" || true
    else
      echo "Skipping missing apt package: $pkg"
    fi
  done
}

echo "==> Base packages"
if has pacman; then
  sudo pacman -Syu --needed --noconfirm \
    zsh git curl wget ca-certificates unzip tar stow fzf ripgrep fd base-devel

  echo "==> Optional packages"
  install_optional_pacman \
    zoxide direnv bat eza starship fastfetch duf bottom procs xh \
    lazygit lazydocker zellij fnm atuin mise
elif has apt; then
  sudo apt update
  sudo apt install -y \
    zsh git curl wget ca-certificates unzip tar stow fzf ripgrep fd-find build-essential

  echo "==> Optional packages"
  install_optional_apt \
    zoxide direnv bat eza starship fastfetch duf bottom procs xh \
    lazygit lazydocker zellij fnm atuin mise
else
  echo "Unknown system. Install zsh git curl stow fzf manually."
fi

echo "==> Antigen"
mkdir -p "$HOME/.antigen"
if [ ! -f "$HOME/.antigen/antigen.zsh" ]; then
  if [ -f "$DOTFILES_DIR/antigen.zsh" ]; then
    cp "$DOTFILES_DIR/antigen.zsh" "$HOME/.antigen/antigen.zsh"
  else
    curl -fsSL https://git.io/antigen -o "$HOME/.antigen/antigen.zsh"
  fi
fi

echo "==> Starship"
if ! has starship; then
  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin" || true
fi

echo "==> fnm"
if ! has fnm; then
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell || true
  export PATH="$HOME/.local/share/fnm:$PATH"
fi

echo "==> atuin"
if ! has atuin; then
  curl -fsSL https://setup.atuin.sh | bash || true
  export PATH="$HOME/.atuin/bin:$PATH"
fi

echo "==> mise"
if ! has mise; then
  curl -fsSL https://mise.run | sh || true
fi

if [ "${DOTFILES_ZSH_CARGO_TOOLS:-0}" = "1" ]; then
  echo "==> Rust/Cargo"
  if ! has cargo; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y || true
    export PATH="$HOME/.cargo/bin:$PATH"
  fi

  echo "==> Optional cargo tools"
  has eza || cargo install --locked eza || true
  has bat || cargo install --locked bat || true
  has zellij || cargo install --locked zellij || true
  has btm || cargo install --locked bottom || true
  has procs || cargo install --locked procs || true
  has xh || cargo install --locked xh || true
  has pay-respects || cargo install --locked pay-respects || true
fi

echo "==> Backing up existing zsh files"
stamp="$(date +%Y%m%d-%H%M%S)"
for rel in .zshrc .zshenv .zprofile .zlogin .zsh_functions; do
  target="$HOME/$rel"
  [ -e "$target" ] || [ -L "$target" ] || continue

  if [ -L "$target" ]; then
    resolved="$(readlink -f "$target" 2>/dev/null || true)"
    case "$resolved" in
      "$DOTFILES_DIR/zsh/"*) continue ;;
    esac
  fi

  mv "$target" "$target.bak.$stamp"
  echo "backup: $target -> $target.bak.$stamp"
done

echo "==> Stow zsh"
stow -R -d "$DOTFILES_DIR" -t "$HOME" zsh

echo "==> Cleaning zsh completion cache"
rm -f "$HOME"/.zcompdump* 2>/dev/null || true
rm -f "$HOME/.cache/zsh"/.zcompdump* 2>/dev/null || true
rm -f "$HOME/.antigen"/.zcompdump* 2>/dev/null || true
rm -f "$HOME/.antigen"/*.zwc 2>/dev/null || true
cache_dir="$HOME/.antigen/bundles/robbyrussell/oh-my-zsh/cache"
rm -f "$cache_dir"/.zcompdump* "$cache_dir"/*.zwc 2>/dev/null || true

if [ -L /usr/share/zsh/vendor-completions/_docker ] && [ ! -e /usr/share/zsh/vendor-completions/_docker ]; then
  echo "Broken completion symlink detected: /usr/share/zsh/vendor-completions/_docker"
  echo "If compinit still complains, run: sudo rm -f /usr/share/zsh/vendor-completions/_docker"
fi

echo "==> Verify"
zsh -n "$HOME/.zshenv" "$HOME/.zshrc"
zsh -ic 'print -P "%F{green}zsh ok%f"' || true

if [ "${SHELL:-}" != "$(command -v zsh 2>/dev/null || true)" ]; then
  echo
  echo "Login shell is not zsh. To change it:"
  echo "  chsh -s $(command -v zsh)"
fi

echo
echo "==> Done."
echo
echo "Now run:"
echo "  exec zsh"
echo
echo "Optional flags:"
echo "  DOTFILES_ZSH_CARGO_TOOLS=1 ./zsh/setup.sh"
