#!/usr/bin/env bash
set -e

echo "==> Neovim stack + dotfiles"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"

export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$HOME/.local/share/fnm:$HOME/.cargo/bin:$PATH"

echo "==> Base packages"
if command -v pacman >/dev/null 2>&1; then
  sudo pacman -Syu --needed \
    neovim git curl unzip tar gzip make gcc \
    ripgrep fd fzf tree-sitter-cli \
    nodejs npm rustup stylua lua-language-server bash-language-server marksman \
    python python-pip python-ruff go
  rustup default stable || true
elif command -v apt >/dev/null 2>&1; then
  sudo apt update
  sudo apt install -y \
    git curl unzip tar gzip build-essential cmake ninja-build gettext \
    ripgrep fd-find fzf tree-sitter-cli \
    nodejs npm cargo rustc \
    python3 python3-pip python3-venv golang-go

  for pkg in python3-ruff ruff lua-language-server bash-language-server marksman stylua; do
    sudo apt install -y "$pkg" || true
  done
else
  echo "Unknown system. Install Neovim, git, ripgrep, fd, fzf, Node, Rust, and Python manually."
fi

echo "==> Debian command aliases"
mkdir -p "$HOME/.local/bin"
if command -v fdfind >/dev/null 2>&1; then
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

echo "==> npm global prefix"
mkdir -p "$HOME/.npm-global"
npm config set prefix "$HOME/.npm-global" || true
export PATH="$HOME/.npm-global/bin:$PATH"

echo "==> TypeScript and formatting tools"
if command -v npm >/dev/null 2>&1; then
  npm install -g typescript typescript-language-server prettier prettier_d_slim vscode-langservers-extracted || true
fi

echo "==> Rust toolchain"
if command -v rustup >/dev/null 2>&1; then
  rustup default stable || true
  rustup component add rustfmt || true
fi

echo "==> Go tools"
if command -v go >/dev/null 2>&1; then
  go install golang.org/x/tools/cmd/goimports@latest || true
fi

echo "==> Neovim latest stable for Debian when needed"
if command -v apt >/dev/null 2>&1; then
  need_build=0
  if ! command -v nvim >/dev/null 2>&1; then
    need_build=1
  elif ! nvim --version | head -n 1 | grep -Eq 'NVIM v0\.(1[2-9]|[2-9][0-9])'; then
    need_build=1
  fi

  if [[ "$need_build" -eq 1 ]]; then
    rm -rf /tmp/neovim
    git clone --depth 1 --branch stable https://github.com/neovim/neovim /tmp/neovim
    (
      cd /tmp/neovim
      make CMAKE_BUILD_TYPE=Release
      sudo make install
    )
    rm -rf /tmp/neovim
  fi
fi

echo "==> Stow nvim"
for path in "$HOME/.config/nvim"; do
  if [[ -e "$path" && ! -L "$path" ]]; then
    backup="$path.bak.$(date +%Y%m%d%H%M%S)"
    echo "Backing up $path -> $backup"
    mv "$path" "$backup"
  fi
done

stow -R -d "$DOTFILES_DIR" -t "$HOME" nvim

echo "==> Verify"
nvim --headless "+Lazy! sync" +qa || true
nvim --headless "+checkhealth vim.lsp" +qa || true

echo
echo "==> Done."
echo "Run: nvim"
