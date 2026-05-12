#!/usr/bin/env bash
# arch.sh — Arch Linux bootstrap orchestrator (post-archinstall).
#
# Philosophy: ASK before changing anything optional. Only minimal essentials
# (pacman.conf tweaks, system update, microcode for detected CPU, core CLI
# packages, fonts, locale/timezone/keymap, core service units) run silently.
#
# Usage:
#   sudo bash arch.sh              # interactive (recommended)
#   sudo bash arch.sh --unattended # CI / unattended (defaults all prompts to N)
#   sudo bash arch.sh --dry-run    # show plan only (no system changes)
set -euo pipefail

# ---- paths ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCH_DIR="$SCRIPT_DIR/arch"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
export DOTFILES_DIR

# ---- flags ----
UNATTENDED=0
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --unattended|-y) UNATTENDED=1 ;;
    --dry-run|-n)    DRY_RUN=1 ;;
    -h|--help)
      cat <<EOF
Usage: $0 [--unattended|-y] [--dry-run|-n]

Arch Linux bootstrap orchestrator (post-archinstall).
Dispatches to modules in scripts/arch/*.sh. Asks before each optional step.

Flags:
  --unattended, -y   Skip prompts (defaults to N), passes --noconfirm to pacman
  --dry-run,    -n   Show plan only, no system changes

Environment overrides:
  USER_NAME USER_SHELL TIMEZONE LOCALE KEYMAP XKB_LAYOUT
  MIRROR_COUNTRY LOG_FILE BACKUP_DIR
EOF
      exit 0
      ;;
  esac
done
export UNATTENDED DRY_RUN

# ---- logging ----
# Keep stdout/stderr as the real terminal so pacman/curl can render progress bars.
# Structured log::* helpers also append plain text to LOG_FILE (handled in lib.sh).
: "${LOG_FILE:=/var/log/arch-bootstrap.log}"
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
: > "$LOG_FILE" 2>/dev/null || true
export LOG_FILE

# ---- load library + modules ----
# shellcheck source=arch/lib.sh
source "$ARCH_DIR/lib.sh"
arch_lib::install_trap

for mod in preflight locale luks user core shell dev devops \
           gpu audio bluetooth print firewall network \
           laptop power gaming vm-guest \
           hyprland gnome displaymgr keyring \
           services aur flatpak chaotic security snapper zram \
           wsl stow; do
  # shellcheck source=/dev/null
  source "$ARCH_DIR/$mod.sh"
done

# ─────────────────────────────────────────────────────────────────────────────
# Environment detection (inlined — orchestrator-only logic, no module needed).
# Exports: IS_WSL IS_VM VM_TYPE IS_LAPTOP CHASSIS_TYPE DMI_VENDOR
#          CPU_VENDOR GPU_VENDORS KERNELS_INSTALLED
# ─────────────────────────────────────────────────────────────────────────────
detect::run() {
  log::step "Detecting environment."

  IS_WSL=0
  if grep -qi microsoft /proc/version 2>/dev/null; then
    IS_WSL=1
    log::info "WSL detected."
  else
    log::info "Native install."
  fi

  # systemd-detect-virt exits 1 when no VM is detected — but still prints "none".
  # Don't use `|| echo none` (would append a second "none").
  VM_TYPE="$(systemd-detect-virt 2>/dev/null || true)"
  [[ -z "$VM_TYPE" ]] && VM_TYPE="none"
  IS_VM=0
  if [[ "$VM_TYPE" != "none" ]] && [[ $IS_WSL -eq 0 ]]; then
    IS_VM=1
    log::info "VM detected: $VM_TYPE"
  fi

  IS_LAPTOP=0
  CHASSIS_TYPE="0"
  if [[ $IS_WSL -eq 0 ]] && [[ $IS_VM -eq 0 ]] && [[ -r /sys/class/dmi/id/chassis_type ]]; then
    CHASSIS_TYPE="$(cat /sys/class/dmi/id/chassis_type 2>/dev/null || echo 0)"
    case "$CHASSIS_TYPE" in
      8|9|10|14) IS_LAPTOP=1; log::info "Laptop chassis (type=$CHASSIS_TYPE)." ;;
    esac
  fi

  DMI_VENDOR="unknown"
  if [[ $IS_WSL -eq 0 ]] && [[ $IS_VM -eq 0 ]] && [[ -r /sys/class/dmi/id/sys_vendor ]]; then
    DMI_VENDOR="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || echo unknown)"
    log::info "DMI vendor: $DMI_VENDOR"
  fi

  CPU_VENDOR="unknown"
  if grep -q GenuineIntel /proc/cpuinfo; then
    CPU_VENDOR="intel"
  elif grep -q AuthenticAMD /proc/cpuinfo; then
    CPU_VENDOR="amd"
  fi
  log::info "CPU vendor: $CPU_VENDOR"

  GPU_VENDORS=()
  if [[ $IS_WSL -eq 0 ]] && [[ $IS_VM -eq 0 ]] && [[ -d /sys/class/drm ]]; then
    local v
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
  local k
  for k in linux linux-lts linux-zen linux-hardened; do
    pkg_installed "$k" && KERNELS_INSTALLED+=("$k")
  done
  if [[ ${#KERNELS_INSTALLED[@]} -gt 0 ]]; then
    log::info "Kernel(s) installed: ${KERNELS_INSTALLED[*]}"
  fi

  log::info "Log:     $LOG_FILE"
  log::info "Backups: $BACKUP_DIR"

  export IS_WSL IS_VM VM_TYPE IS_LAPTOP CHASSIS_TYPE DMI_VENDOR CPU_VENDOR
}

# ─────────────────────────────────────────────────────────────────────────────
# PHASE 1 — silent essentials (no prompts):
#   preflight (root, pacman lock, network, disk, pacman.conf + multilib, update, reflector)
#   detect    (WSL / VM / laptop / CPU / GPU / installed kernels)
# ─────────────────────────────────────────────────────────────────────────────
preflight::run
detect::run

log::section "Setup will start"
log::info "WSL=$IS_WSL  VM=$IS_VM ($VM_TYPE)  Laptop=$IS_LAPTOP  CPU=$CPU_VENDOR  GPU=${GPU_VENDORS[*]:-none}  Vendor=$DMI_VENDOR"
log::info "Log: $LOG_FILE   Backups: $BACKUP_DIR"
log::dim "Optional steps will ask before running. Press Ctrl-C to abort."

# ─────────────────────────────────────────────────────────────────────────────
# WSL fast path
# ─────────────────────────────────────────────────────────────────────────────
if [[ $IS_WSL -eq 1 ]]; then
  log::warn "WSL detected: hardware pkgs install inert; GUI terminals need WSLg."
  ask "Apply WSL setup (/etc/wsl.conf with systemd=true, default user=$USER_NAME)?" && wsl::run
  ask "Configure locale + timezone ($LOCALE / $TIMEZONE)?" && locale::run
  user::run
  ask "Install core packages (base-devel, git, archive tools, fonts, etc.)?" && { core::run; }
  ask "Install shell stack (zsh, tmux, neovim, fzf, bat, eza, ripgrep, ...)?" && shell::run
  ask "Install modern CLI replacements (gh, atuin, mise, direnv, ...)?" && shell::modern_cli
  ask "Install dev stack (python/rust/go/node/etc.)?" && dev::run
  ask "Install devops stack (docker/podman/distrobox)?" && devops::run
  ask "Install Oh My Zsh + plugins for $USER_NAME?" && shell::oh_my_zsh
  ask "Stow dotfiles now?" && stow::run
  echo
  log::section "Done"
  echo "From PowerShell: wsl --shutdown && wsl -d archlinux"
  echo "Verify after reopen: whoami && echo \$SHELL"
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# Native / VM path — most steps are prompted.
# ─────────────────────────────────────────────────────────────────────────────

# Locale — pretty much always wanted, but ask once.
ask "Configure locale + timezone + keymap ($LOCALE, $TIMEZONE, console=$KEYMAP, X11=$XKB_LAYOUT)?" \
  && locale::run

# User — already ask-gated inside the module (won't auto-modify).
user::run

# LUKS prompt config — only relevant if root is encrypted.
if has_luks_root; then
  if ask "Migrate mkinitcpio to systemd hooks (TUI LUKS prompt with asterisks, keymap pre-loaded)?"; then
    luks::run || log::err "LUKS migration failed; review logs before rebooting."
  fi
fi

# Core packages + microcode + fonts — these are the "basic" auto stack.
ask "Install core packages (base-devel, git, archive tools, ssh, certs, microcode, fonts)?" && {
  core::run
}

# Kernels — skip 'linux' if already installed (post-archinstall).
if [[ ${#KERNELS_INSTALLED[@]} -gt 0 ]]; then
  log::ok "Kernel(s) detected: ${KERNELS_INSTALLED[*]} — skipping base 'linux' install."
else
  if [[ $IS_VM -eq 0 ]] && ask "No kernel detected. Install linux + linux-headers?"; then
    pacman_install linux linux-headers
    REBOOT_NEEDED=1
  fi
fi
if [[ ! " ${KERNELS_INSTALLED[*]:-} " =~ " linux-zen " ]] \
   && ask "Add linux-zen as EXTRA kernel (perf-tuned, doesn't replace current)?"; then
  pacman_install linux-zen linux-zen-headers
  REBOOT_NEEDED=1
  log::warn "Regenerate bootloader config to add the linux-zen entry."
  PROMPTS_APPLIED+=("linux-zen kernel")
fi
if [[ ! " ${KERNELS_INSTALLED[*]:-} " =~ " linux-lts " ]] \
   && ask "Add linux-lts as fallback kernel?"; then
  pacman_install linux-lts linux-lts-headers
  REBOOT_NEEDED=1
  log::warn "Regenerate bootloader config to add the linux-lts entry."
  PROMPTS_APPLIED+=("linux-lts kernel")
fi

# Hardware / system stacks — all prompted.
ask "Install NetworkManager (network-manager-applet, brightnessctl)?"             && network::run
ask "Install GPU stack (mesa, vulkan, xf86-video-*, intel-media-driver, ...)?"    && gpu::run
if [[ " ${GPU_VENDORS[*]:-} " =~ " nvidia " ]] \
   && ask "NVIDIA detected. Also install nvidia-open proprietary drivers?"; then
  gpu::nvidia_proprietary
fi
ask "Install audio stack (PipeWire + codecs + SOF firmware)?"                     && audio::run
ask "Install Bluetooth stack (bluez + blueman + Experimental flag)?"              && bluetooth::run
ask "Install shell stack (zsh, tmux, neovim, fzf, bat, eza, ripgrep, lazygit, yazi, ghostty, alacritty)?" && shell::run
ask "Install modern CLI replacements (gh, atuin, mise, direnv, tealdeer, procs, dust, ...)?" && shell::modern_cli
ask "Install gnome-keyring + libsecret + PAM integration (secret + SSH key unlock on login)?" && keyring::run

# VM-only guest tools.
[[ $IS_VM -eq 1 ]] && ask "Install VM guest tools for $VM_TYPE?" && vm_guest::run

# Laptop stack
if [[ $IS_LAPTOP -eq 1 ]]; then
  if ask "Apply laptop stack (hwtools, fwupd, input group)?"; then
    laptop::run
    ask "Install libinput-gestures (3/4-finger touchpad)?" && laptop::gestures
    ask "Install webcam tools (v4l-utils + guvcview)?"     && laptop::webcam
    ask "Install fingerprint (fprintd) + PAM sudo?"        && laptop::fingerprint
    ask "Apply vendor quirks for $DMI_VENDOR (kernel cmdline)?" && laptop::vendor_quirks

    # Power management — mutex.
    echo
    log::info "Power management — choose one (default keeps power-profiles-daemon)."
    if ask "Use TLP (tunable, replaces PPD)?"; then
      power::tlp
    elif ask "Use auto-cpufreq (automatic, replaces PPD)?"; then
      power::auto_cpufreq
    else
      ask "Install power-profiles-daemon (default)?" && power::ppd
    fi
    ask "Add AMD power kernel params (amd_pstate=active, mem_sleep_default=s2idle)?" \
      && power::amd_kernel_params
  fi
fi

# Opt-in stacks
ask "Install dev stack (python/rust/go/node/etc.)?"                  && dev::run
ask "Install devops stack (docker/podman/distrobox/lazydocker)?"     && devops::run
ask "Install firewall (ufw, deny incoming/allow outgoing)?"          && firewall::run
ask "Install CUPS printing stack?"                                   && print::run
ask "Configure zram swap (half of RAM, zstd)?"                       && zram::run
ask "Install gaming stack (steam/lutris/wine/gamemode/mangohud)?"    && gaming::run

# ── Desktop environments — both can coexist, DM chooses session ────────────
HAS_GNOME=0
if [[ $IS_VM -eq 0 ]]; then
  ask "Install Hyprland (Wayland tiling)?" && hyprland::run
  if ask "Install GNOME desktop?"; then gnome::run; HAS_GNOME=1; fi
fi

# ── Display manager — gdm primary, greetd+tuigreet secondary, ly tertiary ──
if [[ $IS_VM -eq 0 ]]; then
  echo
  log::info "Display manager — gdm (primary), greetd+tuigreet (TUI), ly (TUI minimal)."
  DM_CHOICE=none
  if ask "Install gdm (primary, graphical, recommended for GNOME)?"; then
    DM_CHOICE=gdm
  elif ask "Install greetd + tuigreet (TUI alternative, polished Wayland)?"; then
    DM_CHOICE=greetd
    if [[ $HAS_GNOME -eq 1 ]]; then DM_SESSION_CMD="gnome-session"
    else                            DM_SESSION_CMD="Hyprland"
    fi
  elif ask "Install ly (TUI minimal)?"; then
    DM_CHOICE=ly
  fi
  export DM_CHOICE DM_SESSION_CMD
  [[ "$DM_CHOICE" != "none" ]] && displaymgr::run
fi

# ── Optional features ──────────────────────────────────────────────────────
ask "Add Chaotic-AUR repo (precompiled AUR pkgs)?"            && chaotic::run
ask "Install paru (AUR helper) + default AUR packages?"       && aur::run
ask "Install Flatpak + Flathub?"                              && flatpak::run
ask "Install snapper + snap-pac (btrfs snapshots)?"           && snapper::run

if [[ $IS_VM -eq 0 ]]; then
  ask "Install AppArmor (MAC, requires kernel LSM param)?"    && security::apparmor
  ask "Install usbguard (USB whitelist)?"                     && security::usbguard
  ask "Use iwd as NetworkManager wifi backend (modern, faster)?" && network::iwd_backend
fi

# Core services (enable units for already-installed pkgs) — safe to auto-run.
ask "Enable core systemd services (NetworkManager, bluetooth, timesyncd, resolved, paccache, pkgfile, earlyoom)?" \
  && services::run

# SSH key — interactive.
ask "Generate ed25519 SSH key for $USER_NAME?" && user::ssh_key

# Oh My Zsh + plugins.
ask "Install Oh My Zsh + plugins for $USER_NAME (autosuggestions, syntax-highlighting, completions, fzf-tab)?" \
  && shell::oh_my_zsh

# Stow dotfiles — explicit prompt.
ask "Stow dotfiles now (zsh, tmux, nvim, git, hyprland, ...)?" && stow::run

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────
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
  log::info "Optional features applied:"
  printf '  - %s\n' "${PROMPTS_APPLIED[@]}"
fi
echo

if [[ $DRY_RUN -eq 1 ]]; then
  log::ok "Dry-run complete. No system changes made."
elif [[ $REBOOT_NEEDED -eq 1 ]]; then
  log::warn "REBOOT STRONGLY RECOMMENDED (kernel/microcode/firmware/LUKS updated)."
  ask "Reboot now?" && reboot
fi
