#!/usr/bin/env bash
# arch2.sh — Unified Arch Linux bootstrap (single-file, post-archinstall).
#
# Almost everything runs automatically with sensible defaults.
# Only asks for: power management choice (laptop), desktop installs
# (Hyprland / GNOME), SSH key generation, and final reboot.
#
# Usage:
#   sudo bash arch2.sh             # interactive
#   sudo bash arch2.sh --unattended  # CI / unattended (defaults all asks to N)
#   sudo bash arch2.sh --dry-run     # show plan only, no system changes
set -euo pipefail
shopt -s inherit_errexit nullglob

# ─────────────────────────────────────────────────────────────────────────────
# Config (env-overridable)
# ─────────────────────────────────────────────────────────────────────────────
USER_NAME="${USER_NAME:-oornnery}"
USER_SHELL="${USER_SHELL:-/bin/zsh}"
TIMEZONE="${TIMEZONE:-America/Sao_Paulo}"
LOCALE="${LOCALE:-en_US.UTF-8}"
KEYMAP="${KEYMAP:-us}"
XKB_LAYOUT="${XKB_LAYOUT:-us,br}"
XKB_VARIANT="${XKB_VARIANT:-intl,abnt2}"
XKB_OPTIONS="${XKB_OPTIONS:-grp:alt_shift_toggle}"
MIRROR_COUNTRY="${MIRROR_COUNTRY:-Brazil}"
LOG_FILE="${LOG_FILE:-/var/log/arch-bootstrap.log}"
BACKUP_DIR="${BACKUP_DIR:-/var/backups/arch-bootstrap/$(date +%Y%m%d-%H%M%S)}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# ─────────────────────────────────────────────────────────────────────────────
# Flags
# ─────────────────────────────────────────────────────────────────────────────
UNATTENDED=0
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --unattended|-y) UNATTENDED=1 ;;
    --dry-run|-n)    DRY_RUN=1 ;;
    -h|--help)
      cat <<EOF
Usage: $0 [--unattended|-y] [--dry-run|-n]

Unified Arch Linux bootstrap. Asks only for: power-mgmt choice (laptop),
desktop installs (Hyprland/GNOME), SSH key gen, final reboot.

Flags:
  --unattended, -y   Skip all asks (defaults N), passes --noconfirm to pacman
  --dry-run,    -n   Show plan only, no system changes
EOF
      exit 0
      ;;
  esac
done

PAC_FLAGS=()
[[ $UNATTENDED -eq 1 ]] && PAC_FLAGS=(--noconfirm)

mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
: > "$LOG_FILE" 2>/dev/null || true

# ─────────────────────────────────────────────────────────────────────────────
# Colors + logging
# ─────────────────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  C_RED=$'\033[31m'; C_GRN=$'\033[32m'; C_YEL=$'\033[33m'; C_BLU=$'\033[34m'
  C_MAG=$'\033[35m'; C_CYN=$'\033[36m'; C_GRY=$'\033[90m'
  C_BOLD=$'\033[1m'; C_DIM=$'\033[2m'; C_RST=$'\033[0m'
else
  C_RED='' C_GRN='' C_YEL='' C_BLU='' C_MAG='' C_CYN='' C_GRY='' C_BOLD='' C_DIM='' C_RST=''
fi

STEP=0
_logfile() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" >> "$LOG_FILE" 2>/dev/null || true; }
log::info() { printf '%s==>%s %s\n' "$C_GRN$C_BOLD" "$C_RST" "$*"; _logfile "INFO  $*"; }
log::ok()   { printf '%s✓%s %s%s%s\n' "$C_GRN$C_BOLD" "$C_RST" "$C_GRN" "$*" "$C_RST"; _logfile "OK    $*"; }
log::warn() { printf '%s⚠ WARNING:%s %s%s%s\n' "$C_YEL$C_BOLD" "$C_RST" "$C_YEL" "$*" "$C_RST" >&2; _logfile "WARN  $*"; }
log::err()  { printf '%s✗ ERROR:%s %s%s%s\n' "$C_RED$C_BOLD" "$C_RST" "$C_RED" "$*" "$C_RST" >&2; _logfile "ERROR $*"; }
log::dim()  { printf '%s  %s%s\n' "$C_DIM" "$*" "$C_RST"; _logfile "      $*"; }
log::step() {
  STEP=$((STEP+1))
  printf '\n%s┌─[%d]─%s %s%s%s\n' "$C_BLU$C_BOLD" "$STEP" "$C_RST" "$C_CYN$C_BOLD" "$*" "$C_RST"
  _logfile "STEP $STEP $*"
}
log::section() {
  printf '\n%s═══ %s ═══%s\n' "$C_MAG$C_BOLD" "$*" "$C_RST"
  _logfile ">>>>> $* <<<<<"
}

# ─────────────────────────────────────────────────────────────────────────────
# Interaction + execution helpers
# ─────────────────────────────────────────────────────────────────────────────
_ask() {
  local default="$1" prompt="$2" hint yn
  if [[ "$default" == "y" ]]; then
    hint="${C_GRY}[${C_RST}${C_GRN}${C_BOLD}Y${C_RST}${C_GRY}/${C_DIM}n${C_RST}${C_GRY}]${C_RST}"
    [[ $UNATTENDED -eq 1 ]] && return 0
  else
    hint="${C_GRY}[${C_RST}${C_DIM}y${C_RST}${C_GRY}/${C_RST}${C_RED}${C_BOLD}N${C_RST}${C_GRY}]${C_RST}"
    [[ $UNATTENDED -eq 1 ]] && return 1
  fi
  while true; do
    read -rp "$(printf '%s?%s %s%s%s %s %s›%s ' \
      "$C_CYN$C_BOLD" "$C_RST" "$C_CYN" "$prompt" "$C_RST" "$hint" "$C_DIM" "$C_RST")" yn || true
    case "${yn,,}" in
      "")        [[ "$default" == "y" ]] && return 0 || return 1 ;;
      y|yes|s|sim) return 0 ;;
      n|no|nao|não) return 1 ;;
      *) log::err "Resposta inválida: '$yn' (use y/yes/n/no, Enter=default)." ;;
    esac
  done
}
ask()             { _ask n "$1"; }
ask_default_yes() { _ask y "$1"; }

run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '%s[dry-run]%s %s\n' "$C_YEL" "$C_RST" "$*"
    return 0
  fi
  "$@"
}
as_user() { sudo -u "$USER_NAME" -H "$@"; }

snapshot() {
  local f="$1"
  [[ -e "$f" ]] || return 0
  mkdir -p "$BACKUP_DIR"
  cp -a --parents "$f" "$BACKUP_DIR/" 2>/dev/null || true
}

install_template() {
  local src="$DOTFILES_DIR/$1" dest="$2" sed_expr="${3:-}"
  if [[ ! -f "$src" ]]; then log::warn "Template missing: $src"; return 1; fi
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '%s[dry-run]%s install template %s -> %s\n' "$C_YEL" "$C_RST" "$src" "$dest"
    return 0
  fi
  install -d -m 755 "$(dirname "$dest")"
  if [[ -n "$sed_expr" ]]; then
    sed "$sed_expr" "$src" | install -m 644 /dev/stdin "$dest"
  else
    install -m 644 "$src" "$dest"
  fi
}

# Append kernel cmdline params (idempotent: systemd-boot + GRUB).
patch_boot_param() {
  local params="$1" match="$2"
  if [[ -d /boot/loader/entries ]]; then
    local f
    for f in /boot/loader/entries/*.conf; do
      grep -q "$match" "$f" && continue
      snapshot "$f"
      run sed -i "/^options/ s/\$/ $params/" "$f"
    done
  elif [[ -f /etc/default/grub ]]; then
    if ! grep -q "$match" /etc/default/grub; then
      snapshot /etc/default/grub
      run sed -i "s|GRUB_CMDLINE_LINUX_DEFAULT=\"\\(.*\\)\"|GRUB_CMDLINE_LINUX_DEFAULT=\"\\1 $params\"|" /etc/default/grub
      run grub-mkconfig -o /boot/grub/grub.cfg
    fi
  else
    log::warn "Unknown bootloader. Add manually: $params"
  fi
}

# Migrate cryptdevice= (encrypt hook) → rd.luks.name= (sd-encrypt hook).
migrate_boot_cryptdevice() {
  local uuid="$1" name="$2"
  local to="rd.luks.name=${uuid}=${name} root=/dev/mapper/${name}"
  if [[ -d /boot/loader/entries ]]; then
    local f
    for f in /boot/loader/entries/*.conf; do
      grep -q "rd.luks.name=${uuid}" "$f" && continue
      grep -q "cryptdevice=UUID=${uuid}" "$f" || continue
      snapshot "$f"
      run sed -i "s|cryptdevice=UUID=${uuid}:${name}[^ ]*|${to}|" "$f"
      run sed -i "s|root=/dev/mapper/${name}[[:space:]]*root=/dev/mapper/${name}|root=/dev/mapper/${name}|" "$f"
    done
  elif [[ -f /etc/default/grub ]]; then
    if grep -q "cryptdevice=UUID=${uuid}" /etc/default/grub \
       && ! grep -q "rd.luks.name=${uuid}" /etc/default/grub; then
      snapshot /etc/default/grub
      run sed -i "s|cryptdevice=UUID=${uuid}:${name}|${to}|" /etc/default/grub
      run grub-mkconfig -o /boot/grub/grub.cfg
    fi
  fi
}

has_luks_root() {
  local root_src
  root_src="$(findmnt -no SOURCE / 2>/dev/null || echo '')"
  [[ "$root_src" == /dev/mapper/* ]] || return 1
  LUKS_ROOT_NAME="${root_src##*/}"
  local backing
  backing="$(cryptsetup status "$LUKS_ROOT_NAME" 2>/dev/null | awk '/device:/ {print $2}')"
  [[ -n "$backing" ]] || return 1
  LUKS_ROOT_UUID="$(blkid -s UUID -o value "$backing" 2>/dev/null || echo '')"
  [[ -n "$LUKS_ROOT_UUID" ]] || return 1
  return 0
}

pkg_installed()    { pacman -Qq "$1" >/dev/null 2>&1; }
pacman_install()   { run pacman -S --needed "${PAC_FLAGS[@]}" "$@"; }
multilib_enabled() { grep -q '^\[multilib\]' /etc/pacman.conf; }

SERVICES_ENABLED=()
PROMPTS_APPLIED=()
REBOOT_NEEDED=0

# shellcheck disable=SC2154  # rc is assigned at trap time
trap 'rc=$?; log::err "Failed at line $LINENO (exit $rc). Last cmd: $BASH_COMMAND. Log: $LOG_FILE"; exit $rc' ERR

# ═════════════════════════════════════════════════════════════════════════════
# 1. Pre-flight checks
# ═════════════════════════════════════════════════════════════════════════════
[[ $EUID -eq 0 ]] || { log::err "Run as root."; exit 1; }
[[ -f /var/lib/pacman/db.lck ]] && { log::err "pacman db locked."; exit 1; }
ping -c1 -W3 archlinux.org >/dev/null 2>&1 || { log::err "No network."; exit 1; }
AVAIL_KB="$(df -k --output=avail / | tail -1 | tr -d ' ')"
if [[ -n "$AVAIL_KB" ]] && [[ "$AVAIL_KB" -lt 5242880 ]]; then
  log::err "Less than 5GB free on /. Free up space first."
  exit 1
fi

# ═════════════════════════════════════════════════════════════════════════════
# 2. pacman.conf tweaks + multilib
# ═════════════════════════════════════════════════════════════════════════════
log::step "Configuring pacman.conf."
snapshot /etc/pacman.conf
run sed -i 's/^#\?Color/Color/' /etc/pacman.conf
run sed -i 's/^#\?ParallelDownloads = .*/ParallelDownloads = 5/' /etc/pacman.conf
grep -qxF 'ILoveCandy' /etc/pacman.conf || run sed -i '/^Color/a ILoveCandy' /etc/pacman.conf
if grep -q '^#\[multilib\]$' /etc/pacman.conf; then
  run sed -i 's/^#\[multilib\]$/[multilib]/' /etc/pacman.conf
fi
if awk '/^\[multilib\]/{f=1;next} f&&/^#\s*Include/{print;exit}' /etc/pacman.conf | grep -q .; then
  run sed -i '/^\[multilib\]/{n;s/^#\s*Include/Include/}' /etc/pacman.conf
fi

# ═════════════════════════════════════════════════════════════════════════════
# 3. System upgrade + reflector (auto)
# ═════════════════════════════════════════════════════════════════════════════
log::step "Updating system (pacman -Syyu)."
run pacman -Syyu "${PAC_FLAGS[@]}"

log::step "Refreshing mirrors via reflector (country=$MIRROR_COUNTRY)."
pacman_install reflector || log::warn "reflector install failed."
if command -v reflector >/dev/null 2>&1; then
  if [[ ! -f /etc/pacman.d/mirrorlist ]] \
     || find /etc/pacman.d/mirrorlist -mmin +720 2>/dev/null | grep -q .; then
    snapshot /etc/pacman.d/mirrorlist
    run reflector --country "$MIRROR_COUNTRY" --age 12 --protocol https \
      --sort rate --save /etc/pacman.d/mirrorlist \
      || log::warn "reflector run failed; keeping existing."
  else
    log::info "Mirrorlist fresh (<12h); skip refresh."
  fi
fi

# ═════════════════════════════════════════════════════════════════════════════
# 4. Detect environment
# ═════════════════════════════════════════════════════════════════════════════
log::step "Detecting environment."
IS_WSL=0
if grep -qi microsoft /proc/version 2>/dev/null; then IS_WSL=1; log::info "WSL detected."
else log::info "Native install."; fi

VM_TYPE="$(systemd-detect-virt 2>/dev/null || true)"
[[ -z "$VM_TYPE" ]] && VM_TYPE="none"
IS_VM=0
if [[ "$VM_TYPE" != "none" ]] && [[ $IS_WSL -eq 0 ]]; then IS_VM=1; log::info "VM detected: $VM_TYPE"; fi

IS_LAPTOP=0
if [[ $IS_WSL -eq 0 ]] && [[ $IS_VM -eq 0 ]] && [[ -r /sys/class/dmi/id/chassis_type ]]; then
  CHASSIS_TYPE="$(cat /sys/class/dmi/id/chassis_type 2>/dev/null || echo 0)"
  case "$CHASSIS_TYPE" in 8|9|10|14) IS_LAPTOP=1; log::info "Laptop chassis (type=$CHASSIS_TYPE).";; esac
fi

DMI_VENDOR="unknown"
[[ $IS_WSL -eq 0 ]] && [[ $IS_VM -eq 0 ]] && [[ -r /sys/class/dmi/id/sys_vendor ]] \
  && DMI_VENDOR="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || echo unknown)" \
  && log::info "DMI vendor: $DMI_VENDOR"

CPU_VENDOR="unknown"
if grep -q GenuineIntel /proc/cpuinfo; then CPU_VENDOR="intel"
elif grep -q AuthenticAMD /proc/cpuinfo; then CPU_VENDOR="amd"
fi
log::info "CPU vendor: $CPU_VENDOR"

GPU_VENDORS=()
if [[ $IS_WSL -eq 0 ]] && [[ $IS_VM -eq 0 ]] && [[ -d /sys/class/drm ]]; then
  while IFS= read -r v; do
    case "$v" in
      0x1002) GPU_VENDORS+=(amd)    ;;
      0x8086) GPU_VENDORS+=(intel)  ;;
      0x10de) GPU_VENDORS+=(nvidia) ;;
    esac
  done < <(cat /sys/class/drm/card*/device/vendor 2>/dev/null | sort -u)
  [[ ${#GPU_VENDORS[@]} -gt 0 ]] && log::info "GPU vendor(s): ${GPU_VENDORS[*]}"
fi

KERNELS_INSTALLED=()
for k in linux linux-lts linux-zen linux-hardened; do
  pkg_installed "$k" && KERNELS_INSTALLED+=("$k")
done
[[ ${#KERNELS_INSTALLED[@]} -gt 0 ]] && log::info "Kernel(s) installed: ${KERNELS_INSTALLED[*]}"

log::section "Setup will start"
log::info "WSL=$IS_WSL  VM=$IS_VM ($VM_TYPE)  Laptop=$IS_LAPTOP  CPU=$CPU_VENDOR  GPU=${GPU_VENDORS[*]:-none}  Vendor=$DMI_VENDOR"
log::dim "Log: $LOG_FILE   Backups: $BACKUP_DIR"

# ═════════════════════════════════════════════════════════════════════════════
# 5. WSL config (only if WSL)
# ═════════════════════════════════════════════════════════════════════════════
if [[ $IS_WSL -eq 1 ]]; then
  log::warn "WSL detected: hardware pkgs install inert; GUI terminals need WSLg."
  log::step "Writing /etc/wsl.conf."
  install_template "wsl/etc/wsl.conf" "/etc/wsl.conf" "s/__USER__/$USER_NAME/"
fi

# ═════════════════════════════════════════════════════════════════════════════
# 6. Locale + timezone + keymap (auto)
# ═════════════════════════════════════════════════════════════════════════════
log::step "Configuring locale, timezone, keymap."
snapshot /etc/locale.gen
for l in "en_US.UTF-8 UTF-8" "pt_BR.UTF-8 UTF-8"; do
  if ! grep -q "^${l}$" /etc/locale.gen 2>/dev/null; then
    run sed -i "s/^#\s*\(${l//./\\.}\)/\1/" /etc/locale.gen
  fi
done
run locale-gen
[[ $DRY_RUN -eq 0 ]] && printf 'LANG=%s\n' "$LOCALE" > /etc/locale.conf
log::info "Setting timezone $TIMEZONE."
run ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
if [[ $IS_WSL -eq 0 ]] && [[ $IS_VM -eq 0 ]]; then
  run hwclock --systohc || log::warn "hwclock --systohc failed."
fi

if [[ $IS_WSL -eq 0 ]]; then
  [[ $DRY_RUN -eq 0 ]] && printf 'KEYMAP=%s\n' "$KEYMAP" > /etc/vconsole.conf
  if [[ $DRY_RUN -eq 0 ]]; then
    install -d -m 755 /etc/X11/xorg.conf.d
    cat > /etc/X11/xorg.conf.d/00-keyboard.conf <<EOF
# Managed by arch2.sh — dual layout, Alt+Shift toggle.
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout"  "$XKB_LAYOUT"
    Option "XkbVariant" "$XKB_VARIANT"
    Option "XkbOptions" "$XKB_OPTIONS"
EndSection
EOF
  fi
  log::info "X11/Wayland layout: $XKB_LAYOUT (variants: $XKB_VARIANT, toggle: $XKB_OPTIONS)."
fi

# ═════════════════════════════════════════════════════════════════════════════
# 7. LUKS TUI migration (auto, only if root is encrypted)
# ═════════════════════════════════════════════════════════════════════════════
if [[ $IS_WSL -eq 0 ]] && has_luks_root; then
  log::step "Migrating LUKS to systemd-cryptsetup (TUI prompt)."
  log::info "LUKS root: /dev/mapper/$LUKS_ROOT_NAME (UUID=$LUKS_ROOT_UUID)"
  pacman_install cryptsetup
  if grep -E '^HOOKS=.*systemd' /etc/mkinitcpio.conf >/dev/null 2>&1 \
     && grep -E '^HOOKS=.*sd-encrypt' /etc/mkinitcpio.conf >/dev/null 2>&1; then
    log::ok "mkinitcpio.conf already uses systemd hooks."
  else
    snapshot /etc/mkinitcpio.conf
    [[ $DRY_RUN -eq 0 ]] && sed -i -E \
      's|^HOOKS=.*|HOOKS=(base systemd autodetect microcode modconf kms sd-vconsole block sd-encrypt filesystems fsck)|' \
      /etc/mkinitcpio.conf
    migrate_boot_cryptdevice "$LUKS_ROOT_UUID" "$LUKS_ROOT_NAME"
    run mkinitcpio -P
    if [[ $DRY_RUN -eq 0 ]] && command -v lsinitcpio >/dev/null 2>&1; then
      if ! lsinitcpio /boot/initramfs-linux.img 2>/dev/null | grep -q systemd-cryptsetup; then
        log::err "systemd-cryptsetup not in initramfs! Restoring backup."
        [[ -f "$BACKUP_DIR/etc/mkinitcpio.conf" ]] \
          && cp -a "$BACKUP_DIR/etc/mkinitcpio.conf" /etc/mkinitcpio.conf \
          && run mkinitcpio -P
      else
        log::ok "Sanity check passed: systemd-cryptsetup in initramfs."
        REBOOT_NEEDED=1
        PROMPTS_APPLIED+=("LUKS systemd-cryptsetup TUI")
      fi
    fi
  fi
fi

# ═════════════════════════════════════════════════════════════════════════════
# 8. User setup (smart asks if user exists with mismatched config)
# ═════════════════════════════════════════════════════════════════════════════
log::step "User setup."
if id "$USER_NAME" >/dev/null 2>&1; then
  current_shell="$(getent passwd "$USER_NAME" | cut -d: -f7)"
  in_wheel=0
  id -nG "$USER_NAME" | grep -qw wheel && in_wheel=1
  log::info "User '$USER_NAME' exists. shell=$current_shell, wheel=$in_wheel."
  if [[ "$current_shell" != "$USER_SHELL" ]] || [[ $in_wheel -eq 0 ]]; then
    if ask "Ensure '$USER_NAME' is in wheel + uses $USER_SHELL?"; then
      [[ $in_wheel -eq 0 ]] && run usermod -aG wheel "$USER_NAME"
      [[ "$current_shell" != "$USER_SHELL" ]] && { run chsh -s "$USER_SHELL" "$USER_NAME" || log::warn "chsh failed."; }
    fi
  else
    log::ok "User '$USER_NAME' already correctly configured."
  fi
else
  if ask "User '$USER_NAME' not found. Create it (wheel, shell=$USER_SHELL)?"; then
    run useradd -m -G wheel -s "$USER_SHELL" "$USER_NAME"
    if [[ $DRY_RUN -eq 0 ]] && [[ $UNATTENDED -eq 0 ]]; then
      echo "Set password for $USER_NAME:"
      passwd "$USER_NAME"
    fi
  fi
fi

if [[ ! -f /etc/sudoers.d/10-wheel ]] && [[ $DRY_RUN -eq 0 ]]; then
  log::info "Granting wheel sudo (validated)."
  tmp="$(mktemp)"
  printf '%%wheel ALL=(ALL:ALL) ALL\n' > "$tmp"
  if visudo -cf "$tmp" >/dev/null; then
    install -m 440 -o root -g root "$tmp" /etc/sudoers.d/10-wheel
    rm -f "$tmp"
  else
    rm -f "$tmp"
    log::err "visudo validation failed; aborting (no lockout)."
    exit 1
  fi
fi

if id "$USER_NAME" >/dev/null 2>&1 \
   && ! loginctl show-user "$USER_NAME" 2>/dev/null | grep -q '^Linger=yes'; then
  run loginctl enable-linger "$USER_NAME" 2>/dev/null || log::warn "enable-linger failed."
fi

# ═════════════════════════════════════════════════════════════════════════════
# 9. Microcode (CPU-specific, auto)
# ═════════════════════════════════════════════════════════════════════════════
if [[ $IS_WSL -eq 0 ]] && [[ $IS_VM -eq 0 ]]; then
  case "$CPU_VENDOR" in
    intel) log::step "Installing intel-ucode."; pacman_install intel-ucode; REBOOT_NEEDED=1 ;;
    amd)   log::step "Installing amd-ucode.";   pacman_install amd-ucode;   REBOOT_NEEDED=1 ;;
  esac
fi

# ═════════════════════════════════════════════════════════════════════════════
# 10. Core packages + fonts (auto)
# ═════════════════════════════════════════════════════════════════════════════
log::step "Installing core packages."
pacman_install \
  base-devel sudo git curl wget vim bash stow \
  unzip zip tar gzip bzip2 xz 7zip \
  openssl openssh ca-certificates \
  xdg-utils xdg-user-dirs \
  gvfs gvfs-mtp ntfs-3g \
  less man-db man-pages man-pages-pt_br \
  pacman-contrib pkgfile arch-audit git-delta

log::step "Installing fonts (Nerd + Noto)."
pacman_install \
  ttf-jetbrains-mono-nerd ttf-firacode-nerd \
  noto-fonts noto-fonts-emoji noto-fonts-cjk

# ═════════════════════════════════════════════════════════════════════════════
# 11. WSL fast path — install shell+dev and exit
# ═════════════════════════════════════════════════════════════════════════════
if [[ $IS_WSL -eq 1 ]]; then
  log::step "Installing shell + dev + devops for WSL."
  pacman_install \
    zsh tmux neovim fastfetch btop htop tree \
    ripgrep fd fzf jq yq bat eza zoxide lazygit yazi \
    github-cli atuin mise direnv tealdeer procs dust duf sd xh bottom gping doggo tokei glab \
    python python-pipx uv ruff ty rumdl \
    rust nim lua luarocks make cmake \
    nodejs npm fnm bun pnpm go zig \
    docker docker-compose docker-buildx podman buildah skopeo distrobox lazydocker
  log::section "WSL Done"
  echo "From PowerShell: wsl --shutdown && wsl -d archlinux"
  exit 0
fi

# ═════════════════════════════════════════════════════════════════════════════
# 12. NetworkManager (auto)
# ═════════════════════════════════════════════════════════════════════════════
log::step "Installing NetworkManager."
pacman_install networkmanager network-manager-applet brightnessctl

# ═════════════════════════════════════════════════════════════════════════════
# 13. GPU stack (auto, vendor-detected)
# ═════════════════════════════════════════════════════════════════════════════
log::step "Installing GPU stack."
pacman_install mesa vulkan-icd-loader libva-utils vdpauinfo
multilib_enabled && pacman_install lib32-mesa lib32-vulkan-icd-loader

for g in "${GPU_VENDORS[@]:-}"; do
  case "$g" in
    amd)
      log::info "AMD GPU stack."
      pacman_install vulkan-radeon xf86-video-amdgpu xf86-video-ati radeontop
      multilib_enabled && pacman_install lib32-vulkan-radeon
      ;;
    intel)
      log::info "Intel GPU stack."
      pacman_install vulkan-intel intel-media-driver libva-intel-driver intel-gpu-tools
      multilib_enabled && pacman_install lib32-vulkan-intel
      ;;
    nvidia)
      log::info "Nouveau (FOSS NVIDIA) + vulkan-nouveau."
      pacman_install xf86-video-nouveau vulkan-nouveau
      ;;
  esac
done

# ═════════════════════════════════════════════════════════════════════════════
# 14. Audio stack (PipeWire) (auto)
# ═════════════════════════════════════════════════════════════════════════════
log::step "Installing audio stack (PipeWire)."
pacman_install \
  pipewire pipewire-pulse pipewire-alsa pipewire-jack \
  wireplumber pavucontrol \
  alsa-utils alsa-firmware alsa-ucm-conf sof-firmware \
  playerctl pamixer \
  gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav \
  ffmpeg

# ═════════════════════════════════════════════════════════════════════════════
# 15. Bluetooth (auto)
# ═════════════════════════════════════════════════════════════════════════════
log::step "Installing Bluetooth."
pacman_install bluez bluez-utils blueman
if [[ $IS_VM -eq 0 ]] && [[ -f /etc/bluetooth/main.conf ]] \
   && ! grep -q '^Experimental = true' /etc/bluetooth/main.conf; then
  snapshot /etc/bluetooth/main.conf
  run sed -i 's/^#\?\s*Experimental.*$/Experimental = true/' /etc/bluetooth/main.conf
fi

# ═════════════════════════════════════════════════════════════════════════════
# 16. gnome-keyring + PAM (auto)
# ═════════════════════════════════════════════════════════════════════════════
log::step "Installing gnome-keyring + libsecret."
pacman_install gnome-keyring libsecret seahorse
for pam_file in /etc/pam.d/login /etc/pam.d/passwd; do
  [[ -f "$pam_file" ]] || continue
  grep -q "pam_gnome_keyring.so" "$pam_file" && continue
  snapshot "$pam_file"
  [[ $DRY_RUN -eq 1 ]] && continue
  if grep -q '^auth.*pam_unix.so' "$pam_file"; then
    sed -i '/^auth.*pam_unix.so/i auth       optional     pam_gnome_keyring.so' "$pam_file"
  else
    echo 'auth       optional     pam_gnome_keyring.so' >> "$pam_file"
  fi
  if grep -q '^session.*pam_unix.so' "$pam_file"; then
    sed -i '/^session.*pam_unix.so/a session    optional     pam_gnome_keyring.so auto_start' "$pam_file"
  else
    echo 'session    optional     pam_gnome_keyring.so auto_start' >> "$pam_file"
  fi
done
PROMPTS_APPLIED+=("gnome-keyring + PAM")

# ═════════════════════════════════════════════════════════════════════════════
# 17. Shell stack + modern CLI (auto)
# ═════════════════════════════════════════════════════════════════════════════
log::step "Installing shell stack."
pacman_install \
  zsh tmux neovim \
  fastfetch btop htop tree \
  ripgrep fd fzf jq yq \
  bat eza zoxide \
  lazygit yazi \
  ghostty alacritty

log::step "Installing modern CLI replacements."
pacman_install \
  github-cli atuin mise direnv tealdeer \
  procs dust duf sd xh bottom \
  gping doggo tokei glab

# ═════════════════════════════════════════════════════════════════════════════
# 18. Dev + DevOps stacks (auto)
# ═════════════════════════════════════════════════════════════════════════════
log::step "Installing dev stack."
pacman_install \
  python python-pipx uv ruff ty rumdl \
  rust nim lua luarocks \
  make cmake \
  nodejs npm fnm bun pnpm \
  go zig

log::step "Installing devops stack (containers)."
pacman_install \
  docker docker-compose docker-buildx \
  podman buildah skopeo \
  distrobox lazydocker
run systemctl enable docker.socket
SERVICES_ENABLED+=(docker.socket)
id "$USER_NAME" >/dev/null 2>&1 && run gpasswd -a "$USER_NAME" docker
log::warn "'docker' group ≈ root access. Re-login required."

# ═════════════════════════════════════════════════════════════════════════════
# 19. VM guest tools (auto, if VM)
# ═════════════════════════════════════════════════════════════════════════════
if [[ $IS_VM -eq 1 ]]; then
  log::step "Installing VM guest tools for: $VM_TYPE"
  case "$VM_TYPE" in
    qemu|kvm)
      pacman_install qemu-guest-agent spice-vdagent xf86-video-qxl
      run systemctl enable qemu-guest-agent.service spice-vdagent.service
      SERVICES_ENABLED+=(qemu-guest-agent spice-vdagent) ;;
    oracle)
      pacman_install virtualbox-guest-utils
      run systemctl enable vboxservice.service
      SERVICES_ENABLED+=(vboxservice)
      id "$USER_NAME" >/dev/null 2>&1 && run gpasswd -a "$USER_NAME" vboxsf ;;
    vmware)
      pacman_install open-vm-tools xf86-video-vmware
      run systemctl enable vmtoolsd.service vmware-vmblock-fuse.service
      SERVICES_ENABLED+=(vmtoolsd vmware-vmblock-fuse) ;;
    microsoft)
      pacman_install hyperv
      run systemctl enable hv_fcopy_daemon.service hv_kvp_daemon.service hv_vss_daemon.service
      SERVICES_ENABLED+=(hv_fcopy_daemon hv_kvp_daemon hv_vss_daemon) ;;
    *)
      log::warn "VM type '$VM_TYPE' has no known guest-tools." ;;
  esac
fi

# ═════════════════════════════════════════════════════════════════════════════
# 20. Laptop stack (auto, all sub-features)
# ═════════════════════════════════════════════════════════════════════════════
if [[ $IS_LAPTOP -eq 1 ]]; then
  log::step "Applying laptop stack."
  pacman_install lshw inxi hwinfo dmidecode usbutils pciutils fwupd
  id "$USER_NAME" >/dev/null 2>&1 && run gpasswd -a "$USER_NAME" input >/dev/null

  log::info "Installing libinput-gestures."
  pacman_install libinput libinput-gestures

  log::info "Installing webcam tools."
  pacman_install v4l-utils guvcview

  log::info "Installing fingerprint (fprintd) + PAM sudo."
  pacman_install fprintd libfprint
  if [[ $DRY_RUN -eq 0 ]] && ! grep -q "pam_fprintd.so" /etc/pam.d/sudo; then
    snapshot /etc/pam.d/sudo
    if grep -q '^#%PAM-1.0' /etc/pam.d/sudo; then
      sed -i '/^#%PAM-1.0/a auth      [success=1 default=ignore]  pam_fprintd.so' /etc/pam.d/sudo
    else
      sed -i '1i auth      [success=1 default=ignore]  pam_fprintd.so' /etc/pam.d/sudo
    fi
    log::info "PAM sudo patched. After reboot: fprintd-enroll"
  fi
  PROMPTS_APPLIED+=("fprintd + PAM sudo")

  if [[ "$DMI_VENDOR" == *VAIO* ]]; then
    log::info "Vaio ACPI quirks."
    patch_boot_param "acpi_osi=Linux acpi_backlight=vendor" "acpi_osi=Linux"
    REBOOT_NEEDED=1
    PROMPTS_APPLIED+=("Vaio ACPI quirks")
  fi
  if [[ "$DMI_VENDOR" == Dell* ]]; then
    log::info "Dell panel quirk."
    patch_boot_param "i915.enable_psr=0" "i915.enable_psr"
    REBOOT_NEEDED=1
    PROMPTS_APPLIED+=("Dell panel quirk")
  fi
fi

# ═════════════════════════════════════════════════════════════════════════════
# 21. Power management (ASK mutex — laptop only)
# ═════════════════════════════════════════════════════════════════════════════
USE_PPD=1
if [[ $IS_LAPTOP -eq 1 ]]; then
  echo
  log::info "Power management — choose one (default keeps power-profiles-daemon)."
  if ask "Use TLP (tunable, replaces PPD)?"; then
    pacman_install tlp tlp-rdw
    run systemctl enable tlp.service
    run systemctl mask systemd-rfkill.service systemd-rfkill.socket || true
    USE_PPD=0
    SERVICES_ENABLED+=(tlp)
    PROMPTS_APPLIED+=("TLP power mgmt")
  elif ask "Use auto-cpufreq (automatic, replaces PPD)?"; then
    pacman_install auto-cpufreq
    run systemctl enable auto-cpufreq.service
    USE_PPD=0
    SERVICES_ENABLED+=(auto-cpufreq)
    PROMPTS_APPLIED+=("auto-cpufreq")
  else
    pacman_install power-profiles-daemon
    PROMPTS_APPLIED+=("power-profiles-daemon")
  fi

  if [[ "$CPU_VENDOR" == "amd" ]]; then
    log::info "AMD power kernel params (amd_pstate=active, mem_sleep_default=s2idle)."
    patch_boot_param "amd_pstate=active mem_sleep_default=s2idle" "amd_pstate"
    REBOOT_NEEDED=1
    PROMPTS_APPLIED+=("amd_pstate kernel params")
  fi
fi

# ═════════════════════════════════════════════════════════════════════════════
# 22. Optional features (auto: install ALL)
# ═════════════════════════════════════════════════════════════════════════════
# Firewall
log::step "Installing ufw firewall."
pacman_install ufw
run ufw default deny incoming
run ufw default allow outgoing
run ufw --force enable
run systemctl enable ufw.service
SERVICES_ENABLED+=(ufw)
PROMPTS_APPLIED+=("ufw")

# CUPS printing
log::step "Installing CUPS."
pacman_install cups cups-filters system-config-printer
run systemctl enable cups.service cups.socket
SERVICES_ENABLED+=(cups)
PROMPTS_APPLIED+=("CUPS")

# zram swap (skip in VM)
if [[ $IS_VM -eq 0 ]]; then
  log::step "Configuring zram swap."
  pacman_install zram-generator
  install_template "system/etc/systemd/zram-generator.conf" "/etc/systemd/zram-generator.conf"
  PROMPTS_APPLIED+=("zram swap")
fi

# Gaming stack (needs multilib)
if multilib_enabled; then
  log::step "Installing gaming stack."
  pacman_install \
    steam lutris \
    wine wine-mono wine-gecko winetricks \
    gamemode lib32-gamemode \
    mangohud lib32-mangohud
  PROMPTS_APPLIED+=("gaming stack")
else
  log::warn "[multilib] not enabled — skipping gaming stack."
fi

# Snapper (btrfs only)
ROOT_FS="$(findmnt -no FSTYPE / 2>/dev/null || true)"
if [[ "$ROOT_FS" == "btrfs" ]]; then
  log::step "Installing snapper + snap-pac."
  pacman_install snapper snap-pac
  if [[ $DRY_RUN -eq 0 ]] && ! snapper -c root list >/dev/null 2>&1; then
    run snapper -c root create-config / || log::warn "snapper config failed."
  fi
  PROMPTS_APPLIED+=("snapper")
fi

# AppArmor + usbguard + iwd (skip in VM)
if [[ $IS_VM -eq 0 ]]; then
  log::step "Installing AppArmor."
  pacman_install apparmor
  run systemctl enable apparmor.service
  SERVICES_ENABLED+=(apparmor)
  log::warn "AppArmor needs kernel param: lsm=landlock,lockdown,yama,integrity,apparmor,bpf"
  REBOOT_NEEDED=1
  PROMPTS_APPLIED+=("AppArmor")

  log::step "Installing usbguard."
  pacman_install usbguard
  run systemctl enable usbguard.service
  SERVICES_ENABLED+=(usbguard)
  log::warn "Generate policy after reboot: usbguard generate-policy > /etc/usbguard/rules.conf"
  PROMPTS_APPLIED+=("usbguard")

  log::step "Switching NetworkManager to iwd backend."
  pacman_install iwd
  install_template "system/etc/NetworkManager/conf.d/wifi_backend.conf" \
    "/etc/NetworkManager/conf.d/wifi_backend.conf"
  PROMPTS_APPLIED+=("iwd backend")
fi

# Flatpak
log::step "Installing Flatpak + Flathub."
pacman_install flatpak
run flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
PROMPTS_APPLIED+=("Flatpak")

# Chaotic-AUR
if ! grep -q '^\[chaotic-aur\]' /etc/pacman.conf 2>/dev/null; then
  log::step "Adding Chaotic-AUR."
  if [[ $DRY_RUN -eq 0 ]]; then
    pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    pacman-key --lsign-key 3056513887B78AEB
    pacman -U --noconfirm \
      'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
      'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    snapshot /etc/pacman.conf
    cat >> /etc/pacman.conf <<'EOF'

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
    pacman -Sy
  fi
  PROMPTS_APPLIED+=("Chaotic-AUR")
fi

# ═════════════════════════════════════════════════════════════════════════════
# 23. paru + AUR packages (auto)
# ═════════════════════════════════════════════════════════════════════════════
if id "$USER_NAME" >/dev/null 2>&1 && ! command -v paru >/dev/null 2>&1; then
  log::step "Building paru as $USER_NAME."
  if [[ $DRY_RUN -eq 0 ]]; then
    sudo -u "$USER_NAME" -H bash -c '
      set -e
      cd /tmp
      rm -rf paru
      git clone https://aur.archlinux.org/paru.git
      cd paru
      makepkg -si --noconfirm
    ' || log::warn "paru build failed."
  fi
  PROMPTS_APPLIED+=("paru AUR helper")
fi
if id "$USER_NAME" >/dev/null 2>&1 && command -v paru >/dev/null 2>&1; then
  log::step "Installing AUR packages."
  AUR_PKGS=("${AUR_PKGS[@]:-pacsea-bin}")
  if [[ $DRY_RUN -eq 0 ]]; then
    sudo -u "$USER_NAME" -H paru -S --needed --noconfirm "${AUR_PKGS[@]}" \
      || log::warn "paru install failed for: ${AUR_PKGS[*]}"
  fi
  PROMPTS_APPLIED+=("AUR pkgs: ${AUR_PKGS[*]}")
fi

# ═════════════════════════════════════════════════════════════════════════════
# 24. Desktop (ASK each: Hyprland + GNOME — can coexist)
# ═════════════════════════════════════════════════════════════════════════════
if [[ $IS_VM -eq 0 ]]; then
  if ask "Install Hyprland (Wayland tiling)?"; then
    log::step "Installing Hyprland."
    pacman_install \
      hyprland hypridle hyprlock hyprshot hyprpaper hyprsunset \
      xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
      waybar swaync wofi rofi-wayland \
      swww nwg-look kvantum \
      qt5-wayland qt6-wayland \
      hyprpolkitagent \
      grim slurp swappy wlogout \
      wl-clipboard cliphist
    PROMPTS_APPLIED+=("Hyprland")
  fi
  if ask "Install GNOME desktop?"; then
    log::step "Installing GNOME."
    pacman_install \
      gnome gnome-tweaks gnome-shell-extensions gnome-software \
      xdg-desktop-portal-gnome \
      gst-plugin-pipewire
    PROMPTS_APPLIED+=("GNOME")
  fi
fi

# ═════════════════════════════════════════════════════════════════════════════
# 25. Display manager: ly (auto)
# ═════════════════════════════════════════════════════════════════════════════
if [[ $IS_VM -eq 0 ]]; then
  log::step "Installing display manager (ly, TUI)."
  pacman_install ly
  run systemctl enable ly.service
  SERVICES_ENABLED+=(ly)
  PROMPTS_APPLIED+=("ly display manager")
fi

# ═════════════════════════════════════════════════════════════════════════════
# 26. Core services + earlyoom + journald tune (auto)
# ═════════════════════════════════════════════════════════════════════════════
log::step "Enabling core services."
run systemctl enable NetworkManager.service
run systemctl enable bluetooth.service
run systemctl enable systemd-timesyncd.service
run systemctl enable systemd-resolved.service
[[ $DRY_RUN -eq 0 ]] && ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf 2>/dev/null || true
SERVICES_ENABLED+=(NetworkManager bluetooth systemd-timesyncd systemd-resolved)

if [[ $USE_PPD -eq 1 ]]; then
  run systemctl enable power-profiles-daemon.service
  SERVICES_ENABLED+=(power-profiles-daemon)
fi

run systemctl enable paccache.timer pkgfile-update.timer
SERVICES_ENABLED+=(paccache.timer pkgfile-update.timer)

log::info "Installing earlyoom."
pacman_install earlyoom
run systemctl enable earlyoom.service
SERVICES_ENABLED+=(earlyoom)

if [[ $DRY_RUN -eq 0 ]] && [[ -f /etc/systemd/journald.conf ]] \
   && ! grep -q '^SystemMaxUse=200M' /etc/systemd/journald.conf; then
  snapshot /etc/systemd/journald.conf
  sed -i 's/^#\?\s*SystemMaxUse=.*/SystemMaxUse=200M/' /etc/systemd/journald.conf
fi

# ═════════════════════════════════════════════════════════════════════════════
# 27. SSH key (ASK — needs email + passphrase)
# ═════════════════════════════════════════════════════════════════════════════
if id "$USER_NAME" >/dev/null 2>&1; then
  USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
  KEY="$USER_HOME/.ssh/id_ed25519"
  if [[ -n "$USER_HOME" ]] && [[ ! -f "$KEY" ]] \
     && ask "Generate ed25519 SSH key for $USER_NAME?"; then
    ke=""
    [[ $UNATTENDED -eq 0 ]] && [[ $DRY_RUN -eq 0 ]] && read -rp "  email comment: " ke || true
    log::warn "ssh-keygen will prompt for passphrase. Leave empty only if you understand the risk."
    run as_user mkdir -p "$USER_HOME/.ssh"
    run as_user chmod 700 "$USER_HOME/.ssh"
    run as_user ssh-keygen -t ed25519 -C "$ke" -f "$KEY"
    if [[ $DRY_RUN -eq 0 ]] && [[ -f "${KEY}.pub" ]]; then
      echo
      log::info "Public key (paste into GitHub/GitLab):"
      cat "${KEY}.pub"
      echo
    fi
  fi
fi

# ═════════════════════════════════════════════════════════════════════════════
# 28. Oh My Zsh + plugins (auto, as user)
# ═════════════════════════════════════════════════════════════════════════════
if id "$USER_NAME" >/dev/null 2>&1 && [[ -f "$SCRIPT_DIR/zsh.sh" ]]; then
  log::step "Installing Oh My Zsh + plugins as $USER_NAME."
  run as_user bash "$SCRIPT_DIR/zsh.sh" || log::warn "zsh.sh returned non-zero."
fi

# ═════════════════════════════════════════════════════════════════════════════
# 29. Stow dotfiles (auto)
# ═════════════════════════════════════════════════════════════════════════════
if id "$USER_NAME" >/dev/null 2>&1 && command -v stow >/dev/null 2>&1; then
  USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
  DF_DIR="$USER_HOME/dotfiles"
  if [[ -d "$DF_DIR" ]]; then
    log::step "Stowing dotfiles from $DF_DIR."
    packages=(bash zsh tmux nvim git editor fabric system)
    pkg_installed hyprland && packages+=(hyprland)
    for pkg in "${packages[@]}"; do
      [[ -d "$DF_DIR/$pkg" ]] || { log::dim "skip $pkg (not in repo)"; continue; }
      log::info "Stowing '$pkg'."
      run as_user stow -d "$DF_DIR" -t "$USER_HOME" -R "$pkg" \
        || log::warn "stow failed for '$pkg' (conflict?)."
    done
    PROMPTS_APPLIED+=("stow dotfiles")
  else
    log::warn "$DF_DIR not found — clone the dotfiles repo there first."
  fi
fi

# ═════════════════════════════════════════════════════════════════════════════
# Summary
# ═════════════════════════════════════════════════════════════════════════════
echo
log::section "Setup Summary"
log::info "Environment: WSL=$IS_WSL  VM=$IS_VM  Laptop=$IS_LAPTOP  CPU=$CPU_VENDOR  GPU=${GPU_VENDORS[*]:-none}  Vendor=$DMI_VENDOR"
log::info "Log:     $LOG_FILE"
log::info "Backups: $BACKUP_DIR"
if [[ ${#SERVICES_ENABLED[@]} -gt 0 ]]; then
  log::info "Services enabled:"
  printf '  - %s\n' "${SERVICES_ENABLED[@]}"
fi
if [[ ${#PROMPTS_APPLIED[@]} -gt 0 ]]; then
  log::info "Features applied:"
  printf '  - %s\n' "${PROMPTS_APPLIED[@]}"
fi
echo

if [[ $DRY_RUN -eq 1 ]]; then
  log::ok "Dry-run complete. No system changes made."
elif [[ $REBOOT_NEEDED -eq 1 ]]; then
  log::warn "REBOOT STRONGLY RECOMMENDED (kernel/microcode/firmware/LUKS updated)."
  ask "Reboot now?" && reboot
fi
