#!/usr/bin/env bash
set -euo pipefail

# Debian-on-WSL bootstrap for this dotfiles repo.
#
# Combines the package flow of scripts/debian.sh with the WSL configuration of
# scripts/wsl.sh (user, /etc/wsl.conf, locale, stow). Terminal-first: no
# Hyprland / Wayland / laptop / audio bits (use Windows for the GUI side).
#
# Run as root inside the Debian WSL distro:
#   sudo bash scripts/debian-wsl.sh
# Override defaults via the environment:
#   sudo env USERNAME=fabio NVIM_DISTRO=lazy VIM_DISTRO=plug bash scripts/debian-wsl.sh

# ─── Config ──────────────────────────────────────────────────────────────────
USERNAME="${USERNAME:-oornnery}"
TIMEZONE="${TIMEZONE:-America/Sao_Paulo}"
LOCALE="${LOCALE:-en_US.UTF-8}"
VIM_DISTRO="${VIM_DISTRO:-native}"     # native | plug
NVIM_DISTRO="${NVIM_DISTRO:-native}"   # native | mini | lazy
SKIP_PASSWD="${SKIP_PASSWD:-0}"
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

log()  { printf '\n==> %s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }

[[ $EUID -eq 0 ]] || { echo "Run as root: sudo bash scripts/debian-wsl.sh" >&2; exit 1; }

# ─── nala + base packages ────────────────────────────────────────────────────
log "Bootstrap nala"
apt update
apt install -y nala
nala update && nala upgrade -y

log "Base utilities"
nala install -y \
  build-essential ninja-build cmake make pkg-config gettext \
  curl wget git gh stow \
  vim zsh tmux \
  unzip zip tar gzip bzip2 xz-utils p7zip-full \
  openssl openssh-client ca-certificates \
  man-db manpages \
  libnotify-bin jq tree sudo locales

log "Modern CLI tools"
nala install -y \
  fzf ripgrep fd-find bat plocate git-delta \
  btop htop fastfetch tealdeer procs \
  tesseract-ocr wl-clipboard
# Debian renames: fd → fdfind, bat → batcat
USER_HOME_EARLY="/home/$USERNAME"
mkdir -p "$USER_HOME_EARLY/.local/bin"
[[ -x "$(command -v fdfind 2>/dev/null)" ]] && ln -sf "$(command -v fdfind)" "$USER_HOME_EARLY/.local/bin/fd"
[[ -x "$(command -v batcat 2>/dev/null)" ]] && ln -sf "$(command -v batcat)" "$USER_HOME_EARLY/.local/bin/bat"

log "Languages: Python, Node, Rust, Go, Lua"
nala install -y \
  python3 python3-pip python3-venv pipx \
  nodejs npm golang rustc cargo lua5.4 luarocks

# ─── User, sudo, shell ───────────────────────────────────────────────────────
log "Create/update user $USERNAME"
created_user=0
if id "$USERNAME" >/dev/null 2>&1; then
  usermod -aG sudo "$USERNAME"
else
  useradd -m -G sudo -s /bin/zsh "$USERNAME"; created_user=1
fi
USER_HOME="$(getent passwd "$USERNAME" | cut -d: -f6)"

if [[ "$created_user" -eq 1 && "$SKIP_PASSWD" != "1" ]]; then
  passwd "$USERNAME"
elif [[ "$created_user" -eq 1 ]]; then
  warn "Password not set for $USERNAME (SKIP_PASSWD=1)"
fi

tmp_sudoers="$(mktemp)"
printf '%s\n' '%sudo ALL=(ALL:ALL) ALL' > "$tmp_sudoers"
visudo -cf "$tmp_sudoers" >/dev/null
install -m 0440 -o root -g root "$tmp_sudoers" /etc/sudoers.d/10-sudo
rm -f "$tmp_sudoers"

current_shell="$(getent passwd "$USERNAME" | cut -d: -f7)"
[[ "$current_shell" != "/bin/zsh" ]] && { chsh -s /bin/zsh "$USERNAME" || warn "chsh failed"; }

# ─── Locale, timezone, /etc/wsl.conf ─────────────────────────────────────────
log "Locale + timezone"
ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
sed -i "s/^#\s*\(${LOCALE//./\\.} UTF-8\)/\1/" /etc/locale.gen 2>/dev/null || true
grep -q "^${LOCALE} UTF-8" /etc/locale.gen || echo "${LOCALE} UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/default/locale

log "Configure /etc/wsl.conf"
if [[ -L /etc/wsl.conf ]]; then rm -f /etc/wsl.conf
elif [[ -e /etc/wsl.conf ]]; then cp -a /etc/wsl.conf "/etc/wsl.conf.bak.$(date +%Y%m%d%H%M%S)"; fi
if [[ -f "$DOTFILES_DIR/wsl/etc/wsl.conf" && "$USERNAME" == "oornnery" ]]; then
  install -D -m 0644 "$DOTFILES_DIR/wsl/etc/wsl.conf" /etc/wsl.conf
else
  cat > /etc/wsl.conf <<EOF
[boot]
systemd=true

[user]
default=$USERNAME

[interop]
enabled=true
appendWindowsPath=true

[network]
generateHosts=true
generateResolvConf=true
EOF
fi

# ─── External installers (curl|sh) — run as the user ─────────────────────────
log "User-level toolchain (uv, starship, zoxide, neovim, claude)"
sudo -u "$USERNAME" -H bash -lc '
  set -e
  export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
  command -v uv       >/dev/null || curl -LsSf https://astral.sh/uv/install.sh | sh
  command -v starship >/dev/null || curl -fsSL https://starship.rs/install.sh | sh -s -- -y
  command -v zoxide   >/dev/null || curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
  command -v claude   >/dev/null || curl -fsSL https://claude.ai/install.sh | bash
' || warn "some user-level installers failed (rerun later)"

# Neovim from source (Debian apt nvim is old) — optional, can be slow.
if [[ "${SKIP_NVIM_BUILD:-0}" != "1" ]]; then
  log "Neovim (build from source)"
  nala install -y ninja-build gettext cmake unzip curl build-essential
  rm -rf /tmp/neovim
  git clone --depth 1 --branch stable https://github.com/neovim/neovim /tmp/neovim
  ( cd /tmp/neovim && make CMAKE_BUILD_TYPE=Release && make install )
  rm -rf /tmp/neovim
fi

# ─── Stow dotfiles (terminal-only) as the user ───────────────────────────────
log "Stow dotfiles"
case "$VIM_DISTRO" in plug) vim_pkg=vim.plug ;; *) vim_pkg=vim ;; esac
case "$NVIM_DISTRO" in mini) nvim_pkg=nvim.mini ;; lazy) nvim_pkg=nvim.lazy ;; *) nvim_pkg=nvim ;; esac
CORE_PKGS=(bash zsh tmux git editor bin wsl "$vim_pkg" "$nvim_pkg")

sudo -u "$USERNAME" -H bash -lc "
  cd '$DOTFILES_DIR'
  # unstow conflicting editor variants first
  for p in vim vim.plug nvim nvim.mini nvim.lazy; do stow -D -t '$USER_HOME' \$p 2>/dev/null || true; done
  if stow -n -R -t '$USER_HOME' ${CORE_PKGS[*]} 2>/dev/null; then
    stow -R -t '$USER_HOME' ${CORE_PKGS[*]}
  else
    echo 'stow reported conflicts — back up the real files then re-run: dots stow <pkg>' >&2
  fi
"

log "Debian-WSL setup finished."
cat <<EOF

Next:
  - Run 'wsl --shutdown' in PowerShell, then reopen the distro (systemd + default user).
  - Vim: $VIM_DISTRO   Neovim: $NVIM_DISTRO
  - 'dots help' for cheatsheets, 'dots --help' for the CLI.
EOF
