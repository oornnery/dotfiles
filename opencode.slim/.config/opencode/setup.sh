#!/usr/bin/env bash
set -e

echo "==> OpenCode stack simples + fnm/Node 22"

# PATH da sessão atual
export PATH="$HOME/.opencode/bin:$HOME/.bun/bin:$HOME/.cargo/bin:$HOME/.local/share/fnm:$HOME/.npm-global/bin:$PATH"

echo "==> Pacotes base"
if command -v pacman >/dev/null 2>&1; then
  sudo pacman -Syu --needed git curl wget unzip tar base-devel stow rustup jq ripgrep fd fzf
  rustup default stable || true
elif command -v apt >/dev/null 2>&1; then
  sudo apt update
  sudo apt install -y git curl wget unzip tar build-essential stow jq ripgrep fzf
else
  echo "Sistema não reconhecido. Instale git curl unzip rust/cargo manualmente."
fi

echo "==> fnm + Node 22"
if ! command -v fnm >/dev/null 2>&1; then
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
  export PATH="$HOME/.local/share/fnm:$PATH"
fi

# carrega fnm na sessão atual
eval "$(fnm env --shell bash)"

# instala e força Node 22 para evitar erro com better-sqlite3/Cavemem no Node 26
fnm install 22
fnm default 22
fnm use 22

echo "Node atual: $(node -v)"
echo "NPM atual: $(npm -v)"

echo "==> npm global sem sudo"
mkdir -p "$HOME/.npm-global"
npm config set prefix "$HOME/.npm-global"
export PATH="$HOME/.npm-global/bin:$PATH"

echo "==> Bun"
if ! command -v bun >/dev/null 2>&1; then
  curl -fsSL https://bun.sh/install | bash
  export PATH="$HOME/.bun/bin:$PATH"
fi

echo "==> Rust/Cargo"
if ! command -v cargo >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  export PATH="$HOME/.cargo/bin:$PATH"
fi

echo "==> OpenCode"
if ! command -v opencode >/dev/null 2>&1; then
  curl -fsSL https://opencode.ai/install | bash
  export PATH="$HOME/.opencode/bin:$PATH"
fi

echo "==> RTK"
cargo install --git https://github.com/rtk-ai/rtk || true

echo "==> openrtk"
npm install -g openrtk

echo "==> DCP"
opencode plugin @tarquinen/opencode-dcp@latest --global || true

echo "==> oh-my-opencode-slim dry-run"
npx oh-my-opencode-slim@latest install \
  --skills=yes \
  --background-subagents=ask \
  --preset=opencode-go \
  --dry-run

echo "==> oh-my-opencode-slim install real"
npx oh-my-opencode-slim@latest install \
  --skills=yes \
  --background-subagents=ask \
  --preset=opencode-go

echo "==> Caveman"
curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash || true

echo "==> Cavekit"
npx -y skills add JuliusBrussee/cavekit -g -a opencode -y || npx -y skills add JuliusBrussee/cavekit

echo "==> Cavemem"
npm install -g cavemem || true
if command -v cavemem >/dev/null 2>&1; then
  cavemem install --ide opencode || true
else
  echo "Cavemem não instalou. Confira: node -v precisa ser v22.x"
fi

echo "==> Impeccable"
npx -y impeccable install || true

echo "==> Garantindo PATH e fnm no ~/.zshrc"
touch "$HOME/.zshrc"

grep -q '.opencode/bin' "$HOME/.zshrc" || cat >> "$HOME/.zshrc" <<'EOF'

# OpenCode
export PATH="$HOME/.opencode/bin:$PATH"
EOF

grep -q '.bun/bin' "$HOME/.zshrc" || cat >> "$HOME/.zshrc" <<'EOF'

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
EOF

grep -q '.cargo/bin' "$HOME/.zshrc" || cat >> "$HOME/.zshrc" <<'EOF'

# Rust/Cargo
export PATH="$HOME/.cargo/bin:$PATH"
EOF

grep -q '.npm-global/bin' "$HOME/.zshrc" || cat >> "$HOME/.zshrc" <<'EOF'

# npm global sem sudo
export PATH="$HOME/.npm-global/bin:$PATH"
EOF

grep -q 'fnm env' "$HOME/.zshrc" || cat >> "$HOME/.zshrc" <<'EOF'

# fnm / Node.js
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --use-on-cd --shell zsh)"
EOF

echo
echo "==> Finalizado."
echo
echo "Agora rode:"
echo "  source ~/.zshrc"
echo "  fnm use 22"
echo "  node -v"
echo "  opencode auth login"
echo "  opencode models --refresh"
echo "  opencode ."
echo
echo "Dentro do OpenCode teste:"
echo "  /caveman lite"
echo "  ping all agents"
echo "  /impeccable init"
echo
echo "Testes rápidos:"
echo "  rtk gain"
echo "  openrtk --help || true"
echo "  cavemem status || true"
echo "  npx skills list"