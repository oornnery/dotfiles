#!/usr/bin/env bash
set -euo pipefail

# Arch WSL bootstrap for this dotfiles repo.
#
# Run inside the Arch WSL distro as root:
#   sudo bash scripts/wsl.sh
#
# To change a default, pass variables through the environment:
#   sudo env USERNAME=fabio VIM_DISTRO=plug NVIM_DISTRO=lazy bash scripts/wsl.sh
#
# The ${VAR:-value} pattern means:
# - use $VAR when the variable is set
# - otherwise use the default value after :-

# -----------------------------------------------------------------------------
# User-configurable defaults
# -----------------------------------------------------------------------------

USERNAME="${USERNAME:-oornnery}"
TIMEZONE="${TIMEZONE:-America/Sao_Paulo}"
LOCALE="${LOCALE:-en_US.UTF-8}"

# Which Vim dotfiles package should be linked?
#   native -> stow vim/       (plain Vim, no plugin manager)
#   plug   -> stow vim.plug/  (Vim with vim-plug)
VIM_DISTRO="${VIM_DISTRO:-native}"

# Which Neovim dotfiles package should be linked?
#   native -> stow nvim/       (plain Neovim, no plugin manager)
#   mini   -> stow nvim.mini/  (mini.nvim based config)
#   lazy   -> stow nvim.lazy/  (native base + lazy.nvim plugins)
NVIM_DISTRO="${NVIM_DISTRO:-native}"

# 0: ask for a password when creating the user.
# 1: skip passwd, useful for automated rebuilds.
SKIP_PASSWD="${SKIP_PASSWD:-0}"

# Safety guard. Keep 0 for normal use.
# Use 1 only when testing outside WSL.
ALLOW_NON_WSL="${ALLOW_NON_WSL:-0}"

# Locale lines to enable in /etc/locale.gen.
LOCALE_GEN_LINES=("en_US.UTF-8 UTF-8" "pt_BR.UTF-8 UTF-8")

# Paths derived from this script location.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_DIR="${DOTFILES_DIR:-$(cd -- "$SCRIPT_DIR/.." && pwd -P)}"

# -----------------------------------------------------------------------------
# Small helpers
# -----------------------------------------------------------------------------

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  COLOR_RESET=$'\033[0m'
  COLOR_BLUE=$'\033[1;34m'
  COLOR_YELLOW=$'\033[1;33m'
else
  COLOR_RESET=""
  COLOR_BLUE=""
  COLOR_YELLOW=""
fi

timestamp() {
  date '+%Y-%m-%d %H:%M:%S'
}

log_line() {
  local level="$1"
  local color="$2"
  shift 2

  printf '%s %b%-5s%b %s\n' "$(timestamp)" "$color" "$level" "$COLOR_RESET" "$*"
}

log() {
  printf '\n'
  log_line "INFO" "$COLOR_BLUE" "$*"
}

warn() {
  log_line "WARN" "$COLOR_YELLOW" "$*" >&2
}

run_user() {
  # Run a command as the target user, preserving HOME.
  # Example: run_user git clone URL PATH
  if [[ "$USERNAME" == "root" ]]; then
    "$@"
  else
    sudo -u "$USERNAME" -H "$@"
  fi
}

# -----------------------------------------------------------------------------
# Package groups
# -----------------------------------------------------------------------------
#
# Bash arrays are lists. Each word below is one package.
# Comments inside arrays are ignored by Bash and exist only as documentation.

BASE_PKGS=(
  # System essentials: build tools, sudo, downloads and TLS/SSH.
  base-devel
  sudo
  git
  curl
  wget
  openssl
  openssh
  ca-certificates

  # CLI diagnostics.
  inxi           # Human-readable system summary for debugging.
  which          # Classic command lookup; still used by older scripts.
)

SHELL_PKGS=(
  # Shells, dotfile linking and terminal workflow.
  bash
  bash-completion
  zsh
  stow           # Symlink dotfiles from this repo into $HOME or /etc.
  tmux           # Terminal multiplexer.
  fzf            # Fuzzy finder used by the shell, tmux and scripts.
  atuin          # Searchable shell history database with optional sync.
  zoxide         # Smart cd based on directory frequency.
  mise           # Runtime version manager, similar to asdf.
  direnv         # Loads environment variables per project/directory.
)

EDITOR_PKGS=(
  # Editors and parser tooling.
  vim
  neovim
  tree-sitter-cli # Parser CLI used by Neovim and other editors.
)

ARCHIVE_DOC_PKGS=(
  # Common archive formats.
  unzip
  zip
  tar
  gzip
  bzip2
  xz
  7zip

  # Local documentation. texinfo provides GNU info pages.
  less
  man-db
  man-pages
  man-pages-pt_br
  texinfo
)

ARCH_MAINTENANCE_PKGS=(
  # Arch/pacman helpers.
  pacman-contrib # paccache, checkupdates and other pacman tools.
  pkgfile        # Finds which package provides a file or command.
  arch-audit     # Checks installed packages against Arch security advisories.
  expac          # Queries pacman metadata from scripts.
  reflector      # Refreshes mirrorlist by country, age and speed.
  git-delta      # Modern, readable pager for git diffs.
)

SEARCH_VIEW_PKGS=(
  # Search, list and view files.
  ripgrep        # rg: modern grep, fast recursive search.
  fd             # Modern find with simpler defaults.
  bat            # Modern cat with syntax highlighting.
  eza            # Modern ls/tree replacement.
  plocate        # Fast locate database for finding files by name.
)

DATA_PKGS=(
  # Structured data tools.
  jq             # Query/transform JSON.
  yq             # Query/transform YAML.
  htmlq          # CSS-selector style queries for HTML.
  xmlstarlet     # Query/edit XML from scripts.
)

MODERN_REPLACEMENT_PKGS=(
  # Friendly replacements for old Unix tools.
  procs          # Modern ps.
  dust           # Modern du focused on disk usage.
  duf            # Modern df.
  sd             # Simpler search/replace than sed.
  xh             # HTTP client similar to curl/httpie.
  bottom         # top/htop-style system monitor.
  btop           # Another top/htop-style system monitor.
  gping          # Visual ping.
  doggo          # Modern dig/nslookup DNS client.
  tokei          # Code line counter, similar to cloc.
  fastfetch      # Terminal system summary.
)

TUI_PKGS=(
  # Terminal apps.
  lazygit        # Git TUI.
  yazi           # Terminal file manager.
  tealdeer       # Fast tldr client for command examples.
  usage          # Quick command usage examples.
  gum            # Nice interactive prompts in shell scripts.
)

FORGE_NETWORK_PKGS=(
  # Git forges and network debugging.
  github-cli     # gh: GitHub CLI.
  glab           # GitLab CLI.
  whois
  inetutils      # Classic network tools such as telnet/ftp/hostname.
  socat          # Socket relay/debugging tool.
)

LANGUAGE_PKGS=(
  # Python.
  python
  python-pip
  python-pipx
  uv
  ruff
  pyright
  python-pytest

  # Node/JS.
  nodejs
  npm
  fnm
  bun
  pnpm

  # Other everyday toolchains.
  rust
  go
  zig
  nim
  lua
  luarocks
  make
  cmake
)

# -----------------------------------------------------------------------------
# Preflight
# -----------------------------------------------------------------------------

[[ $EUID -eq 0 ]] || { echo "Run as root: sudo bash $0" >&2; exit 1; }

if ! grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null \
  && ! grep -qi "wsl" /proc/sys/kernel/osrelease 2>/dev/null; then
  [[ "$ALLOW_NON_WSL" == "1" ]] || {
    echo "This script is intended for Arch WSL. Set ALLOW_NON_WSL=1 to force." >&2
    exit 1
  }
fi

[[ -f /var/lib/pacman/db.lck ]] && { echo "pacman db locked" >&2; exit 1; }

# -----------------------------------------------------------------------------
# pacman
# -----------------------------------------------------------------------------

log "Tune pacman"
sed -i 's/^#\?Color/Color/' /etc/pacman.conf
sed -i 's/^#\?VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
sed -i 's/^#\?CheckSpace/CheckSpace/' /etc/pacman.conf
sed -i 's/^#\?ParallelDownloads = .*/ParallelDownloads = 10/' /etc/pacman.conf
grep -qxF ILoveCandy /etc/pacman.conf || sed -i '/^Color/a ILoveCandy' /etc/pacman.conf

log "Update keyring and system"
pacman-key --init
pacman-key --populate archlinux
pacman -Sy --needed --noconfirm archlinux-keyring
pacman -Syu --noconfirm

log "Install base packages"
pacman -S --needed --noconfirm "${BASE_PKGS[@]}"

log "Install shell packages"
pacman -S --needed --noconfirm "${SHELL_PKGS[@]}"

log "Install editor packages"
pacman -S --needed --noconfirm "${EDITOR_PKGS[@]}"

log "Install archive and documentation packages"
pacman -S --needed --noconfirm "${ARCHIVE_DOC_PKGS[@]}"

log "Install Arch maintenance packages"
pacman -S --needed --noconfirm "${ARCH_MAINTENANCE_PKGS[@]}"

log "Install search, view and data packages"
pacman -S --needed --noconfirm "${SEARCH_VIEW_PKGS[@]}" "${DATA_PKGS[@]}"

log "Install modern CLI replacements"
pacman -S --needed --noconfirm "${MODERN_REPLACEMENT_PKGS[@]}"

log "Install TUI and network packages"
pacman -S --needed --noconfirm "${TUI_PKGS[@]}" "${FORGE_NETWORK_PKGS[@]}"

log "Install language toolchains"
pacman -S --needed --noconfirm "${LANGUAGE_PKGS[@]}"

# Docker/Podman and desktop/WM packages are intentionally not installed here.
# Use Docker Desktop on Windows and enable WSL integration for this distro.
# WSL is terminal-first in this setup; do not depend on WSLg.

# -----------------------------------------------------------------------------
# User, sudo and shell
# -----------------------------------------------------------------------------

log "Create/update user"
created_user=0

if id "$USERNAME" >/dev/null 2>&1; then
  usermod -aG wheel "$USERNAME"
else
  useradd -m -G wheel -s /bin/zsh "$USERNAME"
  created_user=1
fi

USER_HOME="$(getent passwd "$USERNAME" | cut -d: -f6)"

if [[ "$created_user" -eq 1 && "$SKIP_PASSWD" != "1" ]]; then
  passwd "$USERNAME"
elif [[ "$created_user" -eq 1 ]]; then
  warn "Password not set for $USERNAME because SKIP_PASSWD=1"
fi

tmp_sudoers="$(mktemp)"
printf '%s\n' '%wheel ALL=(ALL:ALL) ALL' > "$tmp_sudoers"
visudo -cf "$tmp_sudoers" >/dev/null
install -m 0440 -o root -g root "$tmp_sudoers" /etc/sudoers.d/10-wheel
rm -f "$tmp_sudoers"

current_shell="$(getent passwd "$USERNAME" | cut -d: -f7)"
if [[ "$current_shell" != "/bin/zsh" ]]; then
  chsh -s /bin/zsh "$USERNAME" || warn "chsh failed for $USERNAME"
fi

# -----------------------------------------------------------------------------
# Locale, timezone and WSL config
# -----------------------------------------------------------------------------

log "Configure locale and timezone"
ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime

for locale_line in "${LOCALE_GEN_LINES[@]}"; do
  sed -i "s/^#\s*\(${locale_line//./\\.}\)/\1/" /etc/locale.gen
done

locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf

log "Configure /etc/wsl.conf"
if [[ -L /etc/wsl.conf ]]; then
  rm -f /etc/wsl.conf
elif [[ -e /etc/wsl.conf ]]; then
  cp -a /etc/wsl.conf "/etc/wsl.conf.bak.$(date +%Y%m%d%H%M%S)"
fi

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

# These timers need systemd. On a fresh WSL install, systemd may only become
# active after /etc/wsl.conf is written and you run `wsl --shutdown`.
log "Enable WSL-safe maintenance timers"
if [[ -d /run/systemd/system ]] && command -v systemctl >/dev/null 2>&1; then
  systemctl enable --now paccache.timer 2>/dev/null || warn "paccache.timer was not enabled"
  systemctl enable --now pkgfile-update.timer 2>/dev/null || warn "pkgfile-update.timer was not enabled"
  systemctl enable --now plocate-updatedb.timer 2>/dev/null || warn "plocate-updatedb.timer was not enabled"
  loginctl enable-linger "$USERNAME" 2>/dev/null || true
else
  warn "systemd is not active yet. Run 'wsl --shutdown' in PowerShell after this script."
fi

pkgfile --update 2>/dev/null || warn "pkgfile --update failed"

# -----------------------------------------------------------------------------
# Zsh and Antigen
# -----------------------------------------------------------------------------

log "Install Antigen"
ANTIGEN_DIR="$USER_HOME/.antigen"

if [[ -d "$ANTIGEN_DIR/.git" ]]; then
  echo "    skip antigen"
else
  run_user git clone --depth 1 https://github.com/zsh-users/antigen.git "$ANTIGEN_DIR"
fi

run_user atuin import auto 2>/dev/null || true

# -----------------------------------------------------------------------------
# Manual dotfiles instructions
# -----------------------------------------------------------------------------

log "Prepare manual dotfiles instructions"

# Keep WSL stow scope terminal-only.
# Do not stow desktop/WM packages here:
# - fabric is a fabric-shell config, not useful in plain WSL
# - alacritty, hyprland, waybar, wofi, walker, mako and astal are desktop config
CORE_STOW_PKGS=(
  bin
  zsh
)

OPTIONAL_STOW_PKGS=(
  bash
  tmux
  git
  editor
)

# VIM_DISTRO is configured at the top of this file.
# It chooses which Vim config package gets linked.
case "$VIM_DISTRO" in
  native|plain|basic|vim)
    VIM_PKG="vim"
    ;;
  plug|vim-plug|vimplug|vim.plug)
    VIM_PKG="vim.plug"
    ;;
  *)
    warn "Unknown VIM_DISTRO=$VIM_DISTRO; using native"
    VIM_DISTRO="native"
    VIM_PKG="vim"
    ;;
esac
CORE_STOW_PKGS+=("$VIM_PKG")

# NVIM_DISTRO is configured at the top of this file.
# It chooses which Neovim config package gets linked.
case "$NVIM_DISTRO" in
  lazy|lazyvim|nvim.lazy)
    NVIM_PKG="nvim.lazy"
    ;;
  mini|minimal|nvim.mini)
    NVIM_PKG="nvim.mini"
    ;;
  native|plain|basic|nvim)
    NVIM_PKG="nvim"
    ;;
  *)
    warn "Unknown NVIM_DISTRO=$NVIM_DISTRO; using native"
    NVIM_DISTRO="native"
    NVIM_PKG="nvim"
    ;;
esac
CORE_STOW_PKGS+=("$NVIM_PKG")

cat <<EOF

==> Arch WSL setup finished.

Next steps from PowerShell:
  wsl --shutdown
  wsl

Notes:
  - Default WSL user: $USERNAME
  - Vim distro: $VIM_DISTRO
  - Neovim distro: $NVIM_DISTRO
  - Dotfiles source: $DOTFILES_DIR
  - Dotfiles were not stowed automatically.
  - Docker daemon was not installed here; use Docker Desktop WSL integration.

Manual dotfiles step:
  # Run these as $USERNAME, not as root:
  cd "$DOTFILES_DIR"
  stow -n -R -t "$USER_HOME" ${CORE_STOW_PKGS[*]}
  stow -R -t "$USER_HOME" ${CORE_STOW_PKGS[*]}
  "$USER_HOME/.local/bin/theme" set "\$("$USER_HOME/.local/bin/theme" get)"

Optional dotfiles, after checking/backing up conflicts:
  stow -n -R -t "$USER_HOME" ${OPTIONAL_STOW_PKGS[*]}
  stow -R -t "$USER_HOME" ${OPTIONAL_STOW_PKGS[*]}

If stow reports existing-target conflicts, back up the real file or stale
symlink first, then run the same stow command again.
EOF
