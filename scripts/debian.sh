#!/usr/bin/env bash
set -euo pipefail

# Run after a fresh Debian install. Brings the box close to feature parity
# with scripts/arch (where it makes sense on Debian).
#
# Style: linear, no functions, no library — just echo + apt/curl. Read top
# to bottom. Comment out sections you don't want.
#
# After this finishes:
#   ./scripts/stow.sh   # link dotfiles into ~
#   ./scripts/zsh.sh    # Oh My Zsh + plugins

# ─── Bootstrap nala ─────────────────────────────────────────────────────────

echo "==> Installing nala (better apt frontend)"
sudo apt update
sudo apt install -y nala

# Use nala from now on
sudo nala update
sudo nala upgrade -y

# ─── Base utilities ─────────────────────────────────────────────────────────

echo "==> Base packages"
sudo nala install -y \
  build-essential ninja-build cmake make pkg-config gettext \
  curl wget git gh stow \
  vim zsh tmux \
  unzip zip tar gzip bzip2 xz-utils p7zip-full \
  openssl openssh-client ca-certificates \
  gvfs gvfs-backends gvfs-fuse \
  ntfs-3g exfatprogs dosfstools \
  ffmpegthumbnailer \
  man-db manpages manpages-extra \
  usbutils pciutils \
  libnotify-bin acpi inxi \
  jq tree

# ─── Fonts ──────────────────────────────────────────────────────────────────

echo "==> Fonts (JetBrains Mono Nerd + Noto)"
sudo nala install -y \
  fonts-jetbrains-mono \
  fonts-firacode \
  fonts-noto fonts-noto-color-emoji fonts-noto-cjk \
  fonts-font-awesome

# ─── Hardware monitoring ────────────────────────────────────────────────────

echo "==> Hardware monitoring (sensors + SMART + NVMe)"
sudo nala install -y \
  lm-sensors smartmontools nvme-cli

# ─── Laptop bits ────────────────────────────────────────────────────────────

echo "==> Laptop (brightness + battery + fwupd + webcam + lid switch)"
sudo nala install -y \
  brightnessctl upower fwupd \
  v4l-utils \
  libinput-tools \
  iio-sensor-proxy

# ─── Network + Bluetooth ────────────────────────────────────────────────────

echo "==> NetworkManager + Bluetooth"
sudo nala install -y \
  network-manager network-manager-gnome \
  bluez bluez-tools blueman

# ─── Audio (PipeWire) ───────────────────────────────────────────────────────

echo "==> PipeWire audio stack"
sudo nala install -y \
  pipewire pipewire-pulse pipewire-alsa pipewire-jack \
  wireplumber pavucontrol \
  alsa-utils alsa-firmware-loaders firmware-sof-signed \
  playerctl pamixer

# ─── Storage automount (USB pendrives etc.) ─────────────────────────────────

echo "==> USB / removable media (udisks2 + udiskie)"
sudo nala install -y \
  udisks2 udiskie policykit-1-gnome

# ─── Power management ───────────────────────────────────────────────────────

echo "==> power-profiles-daemon"
sudo nala install -y \
  power-profiles-daemon
sudo systemctl enable --now power-profiles-daemon.service

# ─── Snapshots (btrfs only) ─────────────────────────────────────────────────

if findmnt -no FSTYPE / 2>/dev/null | grep -qx btrfs; then
  echo "==> Snapper (root is btrfs)"
  sudo nala install -y snapper snapper-gui
else
  echo "==> Root is not btrfs — skipping snapper"
fi

# ─── Firewall ───────────────────────────────────────────────────────────────

echo "==> UFW firewall"
sudo nala install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw --force enable
sudo systemctl enable --now ufw

# ─── gnome-keyring (for SSH/secrets auto-unlock) ───────────────────────────

echo "==> gnome-keyring + libsecret"
sudo nala install -y \
  gnome-keyring libsecret-1-0 libsecret-tools seahorse policykit-1-gnome

# ─── Modern CLI replacements ────────────────────────────────────────────────

echo "==> Modern CLI tools (apt repo)"
sudo nala install -y \
  fzf ripgrep fd-find bat plocate \
  git-delta \
  btop htop fastfetch \
  tealdeer \
  procs \
  whois socat \
  tree-sitter-cli

# Debian rename helpers:  fd → fdfind,  bat → batcat
mkdir -p "$HOME/.local/bin"
[[ -x "$(command -v fdfind)"  ]] && ln -sf "$(command -v fdfind)"  "$HOME/.local/bin/fd"
[[ -x "$(command -v batcat)" ]] && ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"

# ─── OCR + screen recording (used by ~/.local/bin/ocr and record) ───────────

echo "==> OCR + screen recording (tesseract + wf-recorder)"
sudo nala install -y \
  tesseract-ocr tesseract-ocr-eng tesseract-ocr-por \
  wf-recorder grim slurp wl-clipboard

# ─── Wayland desktop bits (no Hyprland on Debian repos, but useful pieces) ─

echo "==> Wayland helpers (alacritty + waybar + mako + wofi + cliphist)"
sudo nala install -y \
  alacritty \
  waybar \
  mako-notifier \
  wofi \
  cliphist 2>/dev/null || true   # cliphist may not be packaged on older Debian

# ─── Languages / runtimes ───────────────────────────────────────────────────

echo "==> Languages: Python, Node, Rust, Go, Lua, Nim"
sudo nala install -y \
  python3 python3-pip python3-venv pipx \
  nodejs npm \
  golang \
  rustc cargo \
  nim \
  lua5.4 luarocks

# ─── Containers (Docker) ────────────────────────────────────────────────────

echo "==> Docker + Compose"
sudo nala install -y docker.io docker-compose-plugin
sudo systemctl enable --now docker
if id "$USER" >/dev/null 2>&1; then
  sudo usermod -aG docker "$USER" || true
  echo "    Added $USER to docker group — log out/in to apply."
fi

# ─── External installers (curl|sh — not in apt) ─────────────────────────────

echo "==> Astral uv"
curl -LsSf https://astral.sh/uv/install.sh | sh

echo "==> Bun"
curl -fsSL https://bun.sh/install | bash

echo "==> pnpm"
curl -fsSL https://get.pnpm.io/install.sh | sh -

echo "==> Starship prompt"
curl -fsSL https://starship.rs/install.sh | sh -s -- -y

echo "==> Zoxide"
curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

echo "==> Atuin (shell history)"
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh || true

echo "==> Mise (runtime manager)"
curl https://mise.run | sh || true

echo "==> direnv"
curl -sfL https://direnv.net/install.sh | bash || true

echo "==> lazygit (latest release binary)"
LAZYGIT_VERSION="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
  | grep -oE '"tag_name": "v[^"]+' | sed 's/.*v//')"
if [[ -n "$LAZYGIT_VERSION" ]]; then
  curl -fsSL "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" -o /tmp/lazygit.tgz
  tar -xzf /tmp/lazygit.tgz -C /tmp lazygit
  sudo install -m 755 /tmp/lazygit /usr/local/bin/lazygit
  rm -f /tmp/lazygit /tmp/lazygit.tgz
fi

echo "==> lazydocker"
curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash || true

echo "==> eza (cargo)"
if command -v cargo >/dev/null; then
  cargo install --locked eza
fi

echo "==> ruff / ty / rumdl (via uv tool)"
if command -v uv >/dev/null; then
  uv tool install ruff || true
  uv tool install ty || true
  uv tool install rumdl || true
fi

# ─── Neovim (latest stable from source) ─────────────────────────────────────

echo "==> Neovim (built from source — Debian's apt version is old)"
rm -rf /tmp/neovim
git clone --depth 1 --branch stable https://github.com/neovim/neovim /tmp/neovim
(
  cd /tmp/neovim
  make CMAKE_BUILD_TYPE=Release
  sudo make install
)
rm -rf /tmp/neovim

# ─── AI / LLM tools ─────────────────────────────────────────────────────────

echo "==> Claude Code"
curl -fsSL https://claude.ai/install.sh | bash

echo "==> OpenAI Codex (npm global)"
if command -v npm >/dev/null; then
  mkdir -p "$HOME/.local/npm"
  npm config set prefix "$HOME/.local/npm"
  npm install -g @openai/codex || true
fi

echo "==> Ollama (local LLM runtime)"
curl -fsSL https://ollama.com/install.sh | sh

echo "==> RTK (prompt optimizer)"
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
if command -v rtk >/dev/null; then
  rtk init --global || true
fi

echo "==> Custom agent skills → ~/.agents"
if [[ ! -d "$HOME/.agents" ]] && command -v gh >/dev/null; then
  gh repo clone oornnery/.agents "$HOME/.agents" || \
    echo "    (gh clone failed — run 'gh auth login' then retry)"
fi

# ─── Flatpak + Flathub ──────────────────────────────────────────────────────

echo "==> Flatpak + Flathub"
sudo nala install -y flatpak gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# ─── Done ───────────────────────────────────────────────────────────────────

echo
echo "==> Debian setup finished."
echo
echo "Next steps:"
echo "  ./scripts/stow.sh                 # link dotfiles into \$HOME"
echo "  ./scripts/zsh.sh                  # Oh My Zsh + plugins + chsh"
echo "  fprintd-enroll                    # if you have a fingerprint reader"
echo "  sudo sensors-detect --auto        # populate /etc/modules-load.d for lm-sensors"
echo "  flatpak install flathub <app-id>  # install GUI apps via flathub"
echo
echo "Notes:"
echo "  - Hyprland isn't packaged for Debian stable yet — skip the Wayland WM"
echo "    if you're on Debian. GNOME works out of the box."
echo "  - Snapper only set up if root is btrfs."
echo "  - PATH should include \$HOME/.local/bin and \$HOME/.local/npm/bin —"
echo "    .zshenv handles this; for bash, add it to .bashrc manually."
echo
