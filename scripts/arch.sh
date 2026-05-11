#!/usr/bin/env bash
# arch.sh — Arch Linux bootstrap (native + WSL + VMs, hardware-aware)
#
# Supports:
#   - x86_64 desktop / laptop
#   - AMD Ryzen / Intel CPUs
#   - AMD Radeon / Intel iGPU / NVIDIA dGPU (auto-detect via DRM)
#   - Vaio + Dell vendor quirks (auto-detect via DMI)
#   - VMs: qemu/kvm, VirtualBox, VMware, Hyper-V (auto-detect via systemd)
#   - WSL2 (auto-detect via /proc/version)
#
# Usage:
#   sudo bash arch.sh              # interactive
#   sudo bash arch.sh --unattended # CI / unattended (defaults all prompts to N)
#   sudo bash arch.sh --dry-run    # show plan only (no system changes)
#
# Run AFTER archinstall completes base install + bootloader + user.
set -euo pipefail

# ---- config (env-overridable) ----
USER_NAME="${USER_NAME:-oornnery}"
USER_SHELL="${USER_SHELL:-/bin/zsh}"
TIMEZONE="${TIMEZONE:-America/Sao_Paulo}"
LOCALE="${LOCALE:-en_US.UTF-8}"
LOCALE_GEN_EN="en_US.UTF-8 UTF-8"
LOCALE_GEN_PT="pt_BR.UTF-8 UTF-8"
MIRROR_COUNTRY="${MIRROR_COUNTRY:-Brazil}"
LOG_FILE="${LOG_FILE:-/var/log/arch-bootstrap.log}"
BACKUP_DIR="${BACKUP_DIR:-/var/backups/arch-bootstrap/$(date +%Y%m%d-%H%M%S)}"

# Dotfiles repo root (parent of scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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

Unified Arch Linux bootstrap (native + WSL + VMs, hardware-aware).

Flags:
  --unattended, -y   Skip prompts (defaults to N), passes --noconfirm to pacman
  --dry-run,    -n   Show plan only, no system changes
  -h, --help         This help

Environment overrides:
  USER_NAME USER_SHELL TIMEZONE LOCALE MIRROR_COUNTRY
  LOG_FILE BACKUP_DIR
EOF
      exit 0
      ;;
  esac
done

PAC_FLAGS=()
[[ $UNATTENDED -eq 1 ]] && PAC_FLAGS=(--noconfirm)

# ---- logging ----
mkdir -p "$(dirname "$LOG_FILE")"
exec > >(tee -a "$LOG_FILE") 2>&1

# ---- helpers ----
if [[ -t 1 ]]; then
  C_YEL='\033[33m'; C_RED='\033[31m'; C_GRN='\033[32m'; C_BLU='\033[34m'; C_RST='\033[0m'
else
  C_YEL=''; C_RED=''; C_GRN=''; C_BLU=''; C_RST=''
fi
warn() { printf "${C_YEL}WARNING:${C_RST} %s\n" "$*"; }
err()  { printf "${C_RED}ERROR:${C_RST} %s\n" "$*" >&2; }
info() { printf "${C_GRN}==>${C_RST} %s\n" "$*"; }

STEP=0
info_step() {
  STEP=$((STEP+1))
  printf "${C_BLU}[%d]${C_RST} ${C_GRN}==>${C_RST} %s\n" "$STEP" "$*"
}

SERVICES_ENABLED=()
PROMPTS_APPLIED=()
REBOOT_NEEDED=0

trap 'rc=$?; err "Failed at line $LINENO (exit $rc). Last cmd: $BASH_COMMAND. Log: $LOG_FILE"; exit $rc' ERR

ask() {
  [[ $UNATTENDED -eq 1 ]] && return 1
  local prompt="$1" yn=""
  read -rp "$prompt [y/N] " yn || true
  [[ "$yn" =~ ^[Yy]$ ]]
}

as_user() { sudo -u "$USER_NAME" -H "$@"; }

snapshot() {
  local f="$1"
  [[ -e "$f" ]] || return 0
  mkdir -p "$BACKUP_DIR"
  cp -a --parents "$f" "$BACKUP_DIR/" 2>/dev/null || true
}

run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    printf "${C_YEL}[dry-run]${C_RST} %s\n" "$*"
    return 0
  fi
  "$@"
}

# Append kernel cmdline params to systemd-boot entries or GRUB (idempotent).
# $1 = params to append; $2 = match token for idempotency check.
patch_boot_param() {
  local params="$1" match="$2"
  if [[ -d /boot/loader/entries ]]; then
    for f in /boot/loader/entries/*.conf; do
      [[ -f "$f" ]] || continue
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
    warn "Unknown bootloader. Add manually to kernel cmdline: $params"
  fi
}

# Install template file (with optional placeholder substitution).
# $1 = src under $SCRIPT_DIR; $2 = dest path; $3 (opt) = sed expr.
install_template() {
  local src="$SCRIPT_DIR/$1" dest="$2" sed_expr="${3:-}"
  if [[ ! -f "$src" ]]; then
    warn "Template missing: $src"
    return 1
  fi
  if [[ $DRY_RUN -eq 1 ]]; then
    printf "${C_YEL}[dry-run]${C_RST} install template %s -> %s\n" "$src" "$dest"
    return 0
  fi
  install -d -m 755 "$(dirname "$dest")"
  if [[ -n "$sed_expr" ]]; then
    sed "$sed_expr" "$src" | install -m 644 /dev/stdin "$dest"
  else
    install -m 644 "$src" "$dest"
  fi
}

# ---- pre-flight ----
[[ $EUID -eq 0 ]] || { err "Run as root."; exit 1; }

if [[ -f /var/lib/pacman/db.lck ]]; then
  err "pacman db locked (/var/lib/pacman/db.lck). Remove if no pacman process."
  exit 1
fi

if ! ping -c1 -W3 archlinux.org >/dev/null 2>&1; then
  err "No network (cannot reach archlinux.org)."
  exit 1
fi

AVAIL_KB="$(df -k --output=avail / | tail -1 | tr -d ' ')"
if [[ -n "$AVAIL_KB" ]] && [[ "$AVAIL_KB" -lt 5242880 ]]; then
  err "Less than 5GB free on /. Free up space first."
  exit 1
fi

# ---- detection ----
info_step "Detecting environment."

IS_WSL=0
if grep -qi microsoft /proc/version 2>/dev/null; then
  IS_WSL=1
  info "WSL detected."
else
  info "Native install."
fi

VM_TYPE="$(systemd-detect-virt 2>/dev/null || echo none)"
IS_VM=0
if [[ "$VM_TYPE" != "none" ]] && [[ $IS_WSL -eq 0 ]]; then
  IS_VM=1
  info "VM detected: $VM_TYPE"
fi

IS_LAPTOP=0
CHASSIS_TYPE="0"
if [[ $IS_WSL -eq 0 ]] && [[ $IS_VM -eq 0 ]] && [[ -r /sys/class/dmi/id/chassis_type ]]; then
  CHASSIS_TYPE="$(cat /sys/class/dmi/id/chassis_type 2>/dev/null || echo 0)"
  case "$CHASSIS_TYPE" in
    8|9|10|14) IS_LAPTOP=1; info "Laptop chassis (type=$CHASSIS_TYPE)." ;;
  esac
fi

DMI_VENDOR="unknown"
if [[ $IS_WSL -eq 0 ]] && [[ $IS_VM -eq 0 ]] && [[ -r /sys/class/dmi/id/sys_vendor ]]; then
  DMI_VENDOR="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || echo unknown)"
  info "DMI vendor: $DMI_VENDOR"
fi

CPU_VENDOR="unknown"
if grep -q GenuineIntel /proc/cpuinfo; then
  CPU_VENDOR="intel"
elif grep -q AuthenticAMD /proc/cpuinfo; then
  CPU_VENDOR="amd"
fi
info "CPU vendor: $CPU_VENDOR"

GPU_VENDORS=()
if [[ $IS_WSL -eq 0 ]] && [[ $IS_VM -eq 0 ]] && [[ -d /sys/class/drm ]]; then
  while IFS= read -r v; do
    case "$v" in
      0x1002) GPU_VENDORS+=(amd)    ;;
      0x8086) GPU_VENDORS+=(intel)  ;;
      0x10de) GPU_VENDORS+=(nvidia) ;;
    esac
  done < <(cat /sys/class/drm/card*/device/vendor 2>/dev/null | sort -u)
  [[ ${#GPU_VENDORS[@]} -gt 0 ]] && info "GPU vendor(s): ${GPU_VENDORS[*]}"
fi

USE_PPD=1
info "Log: $LOG_FILE"
info "Backups: $BACKUP_DIR"

# ---- pacman tweaks + multilib ----
info_step "Configuring pacman.conf."
snapshot /etc/pacman.conf
run sed -i 's/^#\?Color/Color/' /etc/pacman.conf
run sed -i 's/^#\?ParallelDownloads = .*/ParallelDownloads = 5/' /etc/pacman.conf
grep -qxF 'ILoveCandy' /etc/pacman.conf || run sed -i '/^Color/a ILoveCandy' /etc/pacman.conf

if grep -q '^#\[multilib\]$' /etc/pacman.conf; then
  info "Enabling [multilib] header."
  run sed -i 's/^#\[multilib\]$/[multilib]/' /etc/pacman.conf
fi
if awk '/^\[multilib\]/{f=1;next} f&&/^#\s*Include/{print;exit}' /etc/pacman.conf | grep -q .; then
  run sed -i '/^\[multilib\]/{n;s/^#\s*Include/Include/}' /etc/pacman.conf
fi

# ---- system update (BEFORE reflector to avoid partial-upgrade) ----
info_step "Updating system."
run pacman -Syyu "${PAC_FLAGS[@]}"

# ---- reflector (gated: only if mirrorlist >12h old) ----
info_step "Refreshing mirrors."
run pacman -S --needed "${PAC_FLAGS[@]}" reflector || warn "reflector install failed; skipping."
if command -v reflector >/dev/null 2>&1; then
  if [[ ! -f /etc/pacman.d/mirrorlist ]]; then
    warn "/etc/pacman.d/mirrorlist missing; running reflector to seed it."
    run reflector --country "$MIRROR_COUNTRY" --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist || warn "reflector run failed."
  elif find /etc/pacman.d/mirrorlist -mmin +720 2>/dev/null | grep -q .; then
    info "Mirrorlist >12h old; refreshing (country=$MIRROR_COUNTRY)."
    snapshot /etc/pacman.d/mirrorlist
    run reflector --country "$MIRROR_COUNTRY" --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist || warn "reflector run failed; keeping existing."
  else
    info "Mirrorlist fresh (<12h); skip refresh."
  fi
fi

# ---- microcode (native bare-metal only) ----
if [[ $IS_WSL -eq 0 ]] && [[ $IS_VM -eq 0 ]]; then
  if [[ "$CPU_VENDOR" == "intel" ]]; then
    info_step "Installing intel-ucode."
    run pacman -S --needed "${PAC_FLAGS[@]}" intel-ucode
    REBOOT_NEEDED=1
    warn "Regenerate bootloader config so microcode loads."
  elif [[ "$CPU_VENDOR" == "amd" ]]; then
    info_step "Installing amd-ucode."
    run pacman -S --needed "${PAC_FLAGS[@]}" amd-ucode
    REBOOT_NEEDED=1
    warn "Regenerate bootloader config so microcode loads."
  fi
fi

# ---- user creation + sudoers + linger ----
info_step "User setup."
if id "$USER_NAME" >/dev/null 2>&1; then
  info "User '$USER_NAME' exists."
  if ask "Ensure '$USER_NAME' is in wheel and uses $USER_SHELL?"; then
    run usermod -aG wheel "$USER_NAME"
    run chsh -s "$USER_SHELL" "$USER_NAME" || warn "chsh failed (shell not in /etc/shells yet?)."
  fi
else
  if ask "Create user '$USER_NAME' (wheel group, shell $USER_SHELL)?"; then
    run useradd -m -G wheel -s "$USER_SHELL" "$USER_NAME"
    if [[ $DRY_RUN -eq 0 ]] && [[ $UNATTENDED -eq 0 ]]; then
      echo "Set password for $USER_NAME:"
      passwd "$USER_NAME"
    fi
  fi
fi

# Wheel sudoers — validate via visudo in tempfile FIRST (lockout-safe)
if [[ ! -f /etc/sudoers.d/10-wheel ]]; then
  info "Granting wheel sudo (validated)."
  if [[ $DRY_RUN -eq 0 ]]; then
    tmp="$(mktemp)"
    printf '%%wheel ALL=(ALL:ALL) ALL\n' > "$tmp"
    if visudo -cf "$tmp" >/dev/null; then
      install -m 440 -o root -g root "$tmp" /etc/sudoers.d/10-wheel
      rm -f "$tmp"
    else
      rm -f "$tmp"
      err "visudo validation failed; aborting (no lockout)."
      exit 1
    fi
  else
    printf "[dry-run] install validated /etc/sudoers.d/10-wheel\n"
  fi
fi

# Linger (user systemd without login)
if id "$USER_NAME" >/dev/null 2>&1; then
  run loginctl enable-linger "$USER_NAME" 2>/dev/null || warn "enable-linger failed (no systemd active yet?)."
fi

# Single WSL caveat before all package installs
if [[ $IS_WSL -eq 1 ]]; then
  warn "WSL detected: hardware pkgs (bluez, ppd, brightnessctl) install inert; GUI terminals (ghostty, alacritty) need WSLg."
fi

# ---- core packages ----
info_step "Installing core packages."
run pacman -S --needed "${PAC_FLAGS[@]}" \
  base-devel sudo git curl wget vim bash stow \
  unzip zip tar gzip bzip2 xz 7zip \
  openssl openssh ca-certificates \
  networkmanager network-manager-applet \
  pipewire pipewire-pulse pipewire-alsa wireplumber pavucontrol \
  bluez bluez-utils blueman \
  power-profiles-daemon \
  xdg-utils xdg-user-dirs \
  gvfs gvfs-mtp \
  ntfs-3g \
  brightnessctl playerctl pamixer \
  less man-db man-pages man-pages-pt_br \
  pacman-contrib pkgfile arch-audit git-delta \
  ttf-jetbrains-mono-nerd ttf-firacode-nerd \
  noto-fonts noto-fonts-emoji noto-fonts-cjk

# ---- shell packages ----
info_step "Installing shell packages."
run pacman -S --needed "${PAC_FLAGS[@]}" \
  zsh tmux neovim \
  fastfetch btop htop \
  tree \
  ripgrep fd fzf \
  jq yq \
  bat eza zoxide \
  lazygit \
  yazi ghostty alacritty

# ---- dev packages ----
info_step "Installing dev packages."
run pacman -S --needed "${PAC_FLAGS[@]}" \
  python python-pipx uv ruff ty rumdl \
  rust nim \
  lua luarocks \
  make cmake \
  nodejs npm fnm bun pnpm \
  go zig \
  lazydocker

# ---- modern CLI replacements (opt-in) ----
if ask "Install modern CLI replacements (gh atuin mise direnv tealdeer procs dust duf sd xh bottom gping doggo tokei glab)?"; then
  info_step "Installing modern CLI tools."
  run pacman -S --needed "${PAC_FLAGS[@]}" \
    gh atuin mise direnv tealdeer \
    procs dust duf sd xh bottom \
    gping doggo tokei glab
  PROMPTS_APPLIED+=("modern CLI tools")
fi

# ---- VM guest tools (skip WSL, skip bare-metal) ----
if [[ $IS_VM -eq 1 ]]; then
  info_step "Installing VM guest tools for: $VM_TYPE"
  case "$VM_TYPE" in
    qemu|kvm)
      run pacman -S --needed "${PAC_FLAGS[@]}" mesa qemu-guest-agent spice-vdagent xf86-video-qxl
      run systemctl enable qemu-guest-agent.service spice-vdagent.service
      SERVICES_ENABLED+=(qemu-guest-agent spice-vdagent)
      ;;
    oracle)
      run pacman -S --needed "${PAC_FLAGS[@]}" virtualbox-guest-utils
      run systemctl enable vboxservice.service
      SERVICES_ENABLED+=(vboxservice)
      id "$USER_NAME" >/dev/null 2>&1 && run gpasswd -a "$USER_NAME" vboxsf
      ;;
    vmware)
      run pacman -S --needed "${PAC_FLAGS[@]}" open-vm-tools xf86-video-vmware
      run systemctl enable vmtoolsd.service vmware-vmblock-fuse.service
      SERVICES_ENABLED+=(vmtoolsd vmware-vmblock-fuse)
      ;;
    microsoft)
      run pacman -S --needed "${PAC_FLAGS[@]}" hyperv
      run systemctl enable hv_fcopy_daemon.service hv_kvp_daemon.service hv_vss_daemon.service
      SERVICES_ENABLED+=(hv_fcopy_daemon hv_kvp_daemon hv_vss_daemon)
      ;;
    *)
      warn "VM type '$VM_TYPE' has no known guest-tools package. Skipping."
      ;;
  esac
fi

# ---- GPU stack (bare-metal only; iGPU + dGPU possible) ----
if [[ $IS_WSL -eq 0 ]] && [[ $IS_VM -eq 0 ]] && [[ ${#GPU_VENDORS[@]} -gt 0 ]]; then
  for gpu in "${GPU_VENDORS[@]}"; do
    case "$gpu" in
      amd)
        info_step "Installing AMD GPU stack (Mesa + Vulkan radeon)."
        run pacman -S --needed "${PAC_FLAGS[@]}" \
          mesa vulkan-radeon libva-mesa-driver mesa-vdpau \
          lib32-mesa lib32-vulkan-radeon \
          vulkan-icd-loader lib32-vulkan-icd-loader \
          libva-utils vdpauinfo radeontop
        ;;
      intel)
        info_step "Installing Intel GPU stack (Mesa + Vulkan intel)."
        run pacman -S --needed "${PAC_FLAGS[@]}" \
          mesa vulkan-intel intel-media-driver libva-intel-driver \
          lib32-mesa lib32-vulkan-intel \
          vulkan-icd-loader lib32-vulkan-icd-loader \
          libva-utils intel-gpu-tools
        ;;
      nvidia)
        if ask "NVIDIA GPU detected. Install nvidia-open drivers?"; then
          info_step "Installing NVIDIA open drivers."
          warn "If you later install linux-zen/linux-lts, switch to nvidia-open-dkms variant."
          run pacman -S --needed "${PAC_FLAGS[@]}" \
            nvidia-open nvidia-utils nvidia-settings \
            lib32-nvidia-utils libva-nvidia-driver \
            vulkan-icd-loader lib32-vulkan-icd-loader
          REBOOT_NEEDED=1
          warn "If 'nvidia-open' fails on older Maxwell/Pascal cards, retry with proprietary 'nvidia'."
          PROMPTS_APPLIED+=("NVIDIA drivers")
        fi
        ;;
    esac
  done
fi

# ---- alt kernels (native bare-metal, AFTER GPU prompts) ----
if [[ $IS_WSL -eq 0 ]] && [[ $IS_VM -eq 0 ]]; then
  if ask "Install linux-zen kernel (perf-tuned)?"; then
    info_step "Installing linux-zen."
    run pacman -S --needed "${PAC_FLAGS[@]}" linux-zen linux-zen-headers
    REBOOT_NEEDED=1
    warn "Regenerate bootloader config to add the new kernel entry."
    PROMPTS_APPLIED+=("linux-zen kernel")
  fi
  if ask "Install linux-lts kernel (LTS fallback)?"; then
    info_step "Installing linux-lts."
    run pacman -S --needed "${PAC_FLAGS[@]}" linux-lts linux-lts-headers
    REBOOT_NEEDED=1
    warn "Regenerate bootloader config to add the LTS entry."
    PROMPTS_APPLIED+=("linux-lts kernel")
  fi
fi

# ---- laptop stack (bare-metal laptop only) ----
if [[ $IS_LAPTOP -eq 1 ]]; then
  info_step "Applying laptop stack."

  # ---- laptop: hardware (audio, codecs, tools, gestures, webcam, gaming) ----
  info "Installing audio firmware (SOF + ALSA UCM)."
  run pacman -S --needed "${PAC_FLAGS[@]}" sof-firmware alsa-ucm-conf alsa-firmware alsa-utils

  info "Installing multimedia codecs."
  run pacman -S --needed "${PAC_FLAGS[@]}" \
    gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav \
    ffmpeg

  info "Installing hardware tools + fwupd."
  run pacman -S --needed "${PAC_FLAGS[@]}" \
    lshw inxi hwinfo dmidecode usbutils pciutils fwupd

  id "$USER_NAME" >/dev/null 2>&1 && run gpasswd -a "$USER_NAME" input >/dev/null || true

  if ask "Install libinput-gestures (3/4-finger touchpad gestures, X11)?"; then
    run pacman -S --needed "${PAC_FLAGS[@]}" libinput libinput-gestures
    info "Config at ~/.config/libinput-gestures.conf (copy from /etc/libinput-gestures.conf)."
  fi

  if ask "Install webcam tools (v4l-utils + guvcview)?"; then
    run pacman -S --needed "${PAC_FLAGS[@]}" v4l-utils guvcview
  fi

  if ask "Install gaming stack (steam + wine + gamemode + mangohud)?"; then
    run pacman -S --needed "${PAC_FLAGS[@]}" \
      steam wine wine-mono wine-gecko winetricks \
      gamemode lib32-gamemode mangohud lib32-mangohud
    PROMPTS_APPLIED+=("gaming stack")
  fi

  # ---- laptop: power (mutually exclusive) ----
  echo
  info "Power management: choose one (TLP / auto-cpufreq / keep PPD)."
  if ask "Use TLP (tunable, replaces power-profiles-daemon)?"; then
    run pacman -S --needed "${PAC_FLAGS[@]}" tlp tlp-rdw
    run systemctl enable tlp.service
    run systemctl mask systemd-rfkill.service systemd-rfkill.socket || true
    USE_PPD=0
    SERVICES_ENABLED+=(tlp)
    info "TLP enabled. Tune /etc/tlp.conf (CPU_SCALING_GOVERNOR_*, *_CHARGE_THRESH_BAT0)."
  elif ask "Use auto-cpufreq (simpler, automatic, replaces PPD)?"; then
    run pacman -S --needed "${PAC_FLAGS[@]}" auto-cpufreq
    run systemctl enable auto-cpufreq.service
    USE_PPD=0
    SERVICES_ENABLED+=(auto-cpufreq)
  fi

  # ---- laptop: kernel cmdline + vendor quirks ----
  if [[ "$CPU_VENDOR" == "amd" ]] && ask "Add kernel params (amd_pstate=active mem_sleep_default=s2idle)?"; then
    patch_boot_param "amd_pstate=active mem_sleep_default=s2idle" "amd_pstate"
    REBOOT_NEEDED=1
    PROMPTS_APPLIED+=("amd_pstate kernel params")
  fi

  if [[ "$DMI_VENDOR" == *VAIO* ]] && ask "Vaio detected. Add ACPI quirks (acpi_osi=Linux acpi_backlight=vendor)?"; then
    patch_boot_param "acpi_osi=Linux acpi_backlight=vendor" "acpi_osi=Linux"
    REBOOT_NEEDED=1
    PROMPTS_APPLIED+=("Vaio ACPI quirks")
  fi

  if [[ "$DMI_VENDOR" == Dell* ]] && ask "Dell detected. Add i915.enable_psr=0 (fix panel flicker)?"; then
    patch_boot_param "i915.enable_psr=0" "i915.enable_psr"
    REBOOT_NEEDED=1
    PROMPTS_APPLIED+=("Dell panel quirk")
  fi

  # ---- laptop: fingerprint (PAM — kept last, isolated) ----
  if ask "Install fingerprint stack (fprintd) + enable for sudo via PAM?"; then
    run pacman -S --needed "${PAC_FLAGS[@]}" fprintd libfprint
    if [[ $DRY_RUN -eq 0 ]] && ! grep -q "pam_fprintd.so" /etc/pam.d/sudo; then
      snapshot /etc/pam.d/sudo
      if grep -q '^#%PAM-1.0' /etc/pam.d/sudo; then
        sed -i '/^#%PAM-1.0/a auth      [success=1 default=ignore]  pam_fprintd.so' /etc/pam.d/sudo
      else
        warn "/etc/pam.d/sudo missing #%PAM-1.0 header; prepending fprintd line directly."
        sed -i '1i auth      [success=1 default=ignore]  pam_fprintd.so' /etc/pam.d/sudo
      fi
      info "PAM sudo patched. After reboot, enroll: fprintd-enroll"
    fi
    PROMPTS_APPLIED+=("fprintd + PAM sudo")
  fi
fi

# ---- paru (AUR helper) ----
if id "$USER_NAME" >/dev/null 2>&1 && ! command -v paru >/dev/null 2>&1; then
  if ask "Install paru (AUR helper)?"; then
    info_step "Building paru as $USER_NAME."
    if [[ $DRY_RUN -eq 0 ]]; then
      sudo -u "$USER_NAME" -H bash -c '
        set -e
        cd /tmp
        rm -rf paru
        git clone https://aur.archlinux.org/paru.git
        cd paru
        makepkg -si --noconfirm
      ' || warn "paru build failed."
    else
      printf "[dry-run] clone+makepkg paru as %s\n" "$USER_NAME"
    fi
    PROMPTS_APPLIED+=("paru AUR helper")
  fi
fi

# ---- AUR packages via paru ----
if id "$USER_NAME" >/dev/null 2>&1 && command -v paru >/dev/null 2>&1; then
  info_step "Installing AUR packages via paru."
  AUR_PKGS=(pacsea-bin)
  if [[ $DRY_RUN -eq 0 ]]; then
    sudo -u "$USER_NAME" -H paru -S --needed --noconfirm "${AUR_PKGS[@]}" || warn "paru install failed for: ${AUR_PKGS[*]}"
  else
    printf "[dry-run] paru -S --needed --noconfirm %s\n" "${AUR_PKGS[*]}"
  fi
  PROMPTS_APPLIED+=("AUR pkgs: ${AUR_PKGS[*]}")
fi

# ---- native-only block (firewall, zram, printing, btrfs, bluetooth) ----
if [[ $IS_WSL -eq 0 ]]; then
  if ask "Install + enable ufw (deny incoming, allow outgoing)?"; then
    info_step "Installing ufw."
    run pacman -S --needed "${PAC_FLAGS[@]}" ufw
    run ufw default deny incoming
    run ufw default allow outgoing
    run ufw --force enable
    run systemctl enable ufw.service
    SERVICES_ENABLED+=(ufw)
    PROMPTS_APPLIED+=("ufw firewall")
  fi

  if [[ $IS_VM -eq 0 ]] && ask "Configure zram swap (half of RAM, zstd)?"; then
    info_step "Configuring zram."
    run pacman -S --needed "${PAC_FLAGS[@]}" zram-generator
    install_template "system/etc/systemd/zram-generator.conf" "/etc/systemd/zram-generator.conf"
    PROMPTS_APPLIED+=("zram swap")
  fi

  if ask "Install CUPS printing stack?"; then
    info_step "Installing CUPS."
    run pacman -S --needed "${PAC_FLAGS[@]}" cups system-config-printer
    run systemctl enable cups.service
    SERVICES_ENABLED+=(cups)
    PROMPTS_APPLIED+=("CUPS printing")
  fi

  ROOT_FS="$(findmnt -no FSTYPE / 2>/dev/null || true)"
  if [[ "$ROOT_FS" == "btrfs" ]] && ask "Install snapper + snap-pac (btrfs snapshots on pacman ops)?"; then
    info_step "Installing snapper."
    run pacman -S --needed "${PAC_FLAGS[@]}" snapper snap-pac
    if ! snapper -c root list >/dev/null 2>&1; then
      run snapper -c root create-config / || warn "snapper config failed (existing subvolume?)."
    fi
    PROMPTS_APPLIED+=("snapper btrfs snapshots")
  fi

  if [[ $IS_VM -eq 0 ]] && [[ -f /etc/bluetooth/main.conf ]] && ! grep -q '^Experimental = true' /etc/bluetooth/main.conf; then
    info_step "Enabling bluetooth Experimental flag (headphone battery report)."
    snapshot /etc/bluetooth/main.conf
    run sed -i 's/^#\?\s*Experimental.*$/Experimental = true/' /etc/bluetooth/main.conf
  fi
fi

# ---- git config (detect, do not prompt — uses stowed git/.gitconfig) ----
if id "$USER_NAME" >/dev/null 2>&1; then
  USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
  if [[ -n "$USER_HOME" ]] && [[ -f "$USER_HOME/.gitconfig" ]] \
     && as_user git config --global --get user.name >/dev/null 2>&1; then
    info "git already configured for $USER_NAME (likely via stow git/)."
  else
    warn "No ~/.gitconfig for $USER_NAME. After this script: cd ~/dotfiles && stow -t ~ git"
  fi
fi

# ---- ssh key (passphrase prompt — security) ----
if id "$USER_NAME" >/dev/null 2>&1; then
  USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
  KEY="$USER_HOME/.ssh/id_ed25519"
  if [[ -n "$USER_HOME" ]] && [[ ! -f "$KEY" ]]; then
    if ask "Generate ed25519 SSH key for $USER_NAME?"; then
      read -rp "  email comment for key: " ke
      warn "ssh-keygen will prompt for a passphrase. Leave empty only if you understand the risk."
      run as_user mkdir -p "$USER_HOME/.ssh"
      run as_user chmod 700 "$USER_HOME/.ssh"
      run as_user ssh-keygen -t ed25519 -C "$ke" -f "$KEY"
      if [[ $DRY_RUN -eq 0 ]] && [[ -f "${KEY}.pub" ]]; then
        echo
        info "Public key (paste into GitHub/GitLab):"
        cat "${KEY}.pub"
        echo
      fi
    fi
  fi
fi

# ---- WSL-specific setup ----
if [[ $IS_WSL -eq 1 ]]; then
  warn "Next writes /etc/wsl.conf (systemd=true, default user=$USER_NAME) + sets timezone + generates locales."
  warn "WSL-ONLY. Do NOT apply on native Arch — archinstall already handled these."
  if ask "Apply WSL setup (wsl.conf + timezone + locale)?"; then
    info_step "Applying WSL setup."
    info "Setting timezone $TIMEZONE."
    run ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime

    info "Generating locales."
    snapshot /etc/locale.gen
    run sed -i "s/^#\($LOCALE_GEN_EN\)/\1/" /etc/locale.gen
    run sed -i "s/^#\($LOCALE_GEN_PT\)/\1/" /etc/locale.gen
    run locale-gen
    if [[ $DRY_RUN -eq 0 ]]; then
      printf 'LANG=%s\n' "$LOCALE" > /etc/locale.conf
    fi

    info "Writing /etc/wsl.conf from template."
    install_template "wsl/etc/wsl.conf" "/etc/wsl.conf" "s/__USER__/$USER_NAME/"

    echo
    echo "WSL setup applied. From PowerShell:"
    echo "  wsl --shutdown"
    echo "Then reopen Arch."
    PROMPTS_APPLIED+=("WSL setup")
  fi
fi

# ---- core services (native) ----
if [[ $IS_WSL -eq 0 ]]; then
  info_step "Enabling core services."
  run systemctl enable NetworkManager.service
  run systemctl enable bluetooth.service
  run systemctl enable systemd-timesyncd.service
  run systemctl enable systemd-resolved.service
  if [[ $DRY_RUN -eq 0 ]]; then
    ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf || true
  fi
  SERVICES_ENABLED+=(NetworkManager bluetooth systemd-timesyncd systemd-resolved)

  if [[ $USE_PPD -eq 1 ]]; then
    run systemctl enable power-profiles-daemon.service
    SERVICES_ENABLED+=(power-profiles-daemon)
  else
    info "Skipping power-profiles-daemon (TLP or auto-cpufreq selected)."
  fi

  run systemctl enable paccache.timer
  run systemctl enable pkgfile-update.timer
  SERVICES_ENABLED+=(paccache.timer pkgfile-update.timer)

  info_step "Installing earlyoom (OOM prevention)."
  run pacman -S --needed "${PAC_FLAGS[@]}" earlyoom
  run systemctl enable earlyoom.service
  SERVICES_ENABLED+=(earlyoom)

  if [[ $DRY_RUN -eq 0 ]] && [[ -f /etc/systemd/journald.conf ]]; then
    snapshot /etc/systemd/journald.conf
    sed -i 's/^#\?\s*SystemMaxUse=.*/SystemMaxUse=200M/' /etc/systemd/journald.conf
  fi
fi

# ---- desktop (native bare-metal, Hyprland/GNOME mutex) ----
if [[ $IS_WSL -eq 0 ]] && [[ $IS_VM -eq 0 ]]; then
  if ask "Install Hyprland desktop?"; then
    info_step "Installing Hyprland."
    run pacman -S --needed "${PAC_FLAGS[@]}" \
      hyprland hypridle hyprlock hyprshot hyprpaper hyprsunset \
      xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
      waybar swaync \
      wofi rofi-wayland \
      swww nwg-look kvantum qt5-wayland qt6-wayland \
      hyprpolkitagent \
      grim slurp swappy wlogout \
      wl-clipboard cliphist
    PROMPTS_APPLIED+=("Hyprland desktop")
  elif ask "Install GNOME desktop?"; then
    info_step "Installing GNOME."
    run pacman -S --needed "${PAC_FLAGS[@]}" \
      gnome gnome-tweaks gnome-software \
      xdg-desktop-portal-gnome gst-plugin-pipewire
    run systemctl enable gdm.service
    SERVICES_ENABLED+=(gdm)
    PROMPTS_APPLIED+=("GNOME desktop")
  fi
fi

# ---- optional modern features (native) ----
if [[ $IS_WSL -eq 0 ]]; then
  if ask "Add Chaotic-AUR repo (precompiled AUR pkgs)?"; then
    info_step "Adding Chaotic-AUR."
    if [[ $DRY_RUN -eq 0 ]]; then
      pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
      pacman-key --lsign-key 3056513887B78AEB
      pacman -U --noconfirm \
        'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
        'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
      if ! grep -q '^\[chaotic-aur\]' /etc/pacman.conf; then
        snapshot /etc/pacman.conf
        cat >> /etc/pacman.conf <<'EOF'

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
        pacman -Sy
      fi
    fi
    PROMPTS_APPLIED+=("Chaotic-AUR repo")
  fi

  if ask "Install Flatpak + Flathub?"; then
    info_step "Installing Flatpak."
    run pacman -S --needed "${PAC_FLAGS[@]}" flatpak
    run flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    PROMPTS_APPLIED+=("Flatpak")
  fi

  # Bare-metal-only sub-block (security frameworks + iwd)
  if [[ $IS_VM -eq 0 ]]; then
    if ask "Install AppArmor (MAC security framework)?"; then
      info_step "Installing AppArmor."
      run pacman -S --needed "${PAC_FLAGS[@]}" apparmor
      run systemctl enable apparmor.service
      SERVICES_ENABLED+=(apparmor)
      warn "AppArmor needs kernel param: lsm=landlock,lockdown,yama,integrity,apparmor,bpf — add to bootloader manually."
      REBOOT_NEEDED=1
      PROMPTS_APPLIED+=("AppArmor")
    fi

    if ask "Install usbguard (USB device whitelist)?"; then
      info_step "Installing usbguard."
      run pacman -S --needed "${PAC_FLAGS[@]}" usbguard
      run systemctl enable usbguard.service
      SERVICES_ENABLED+=(usbguard)
      warn "Generate initial policy after reboot: usbguard generate-policy > /etc/usbguard/rules.conf"
      PROMPTS_APPLIED+=("usbguard")
    fi

    if ask "Use iwd as NetworkManager wifi backend (modern, faster)?"; then
      info_step "Switching NM to iwd backend."
      run pacman -S --needed "${PAC_FLAGS[@]}" iwd
      install_template "system/etc/NetworkManager/conf.d/wifi_backend.conf" "/etc/NetworkManager/conf.d/wifi_backend.conf"
      PROMPTS_APPLIED+=("NetworkManager iwd backend")
    fi
  fi
fi

# ---- Docker/Podman container stack (native only) ----
if [[ $IS_WSL -eq 0 ]] && ask "Install Docker + Podman container stack?"; then
  info_step "Installing container stack."
  run pacman -S --needed "${PAC_FLAGS[@]}" docker docker-buildx docker-compose podman buildah skopeo
  run systemctl enable docker.service
  SERVICES_ENABLED+=(docker)
  if id "$USER_NAME" >/dev/null 2>&1; then
    run gpasswd -a "$USER_NAME" docker
    warn "User added to docker group — re-login required. Note: docker group = root-equivalent."
  fi
  PROMPTS_APPLIED+=("Docker + Podman")
fi

# ---- end summary ----
echo
info "==================== Setup Summary ===================="
info "Environment: WSL=$IS_WSL VM=$IS_VM Laptop=$IS_LAPTOP CPU=$CPU_VENDOR GPU=${GPU_VENDORS[*]:-none} Vendor=$DMI_VENDOR"
info "Log:       $LOG_FILE"
info "Backups:   $BACKUP_DIR"
[[ ${#SERVICES_ENABLED[@]} -gt 0 ]] && info "Services enabled: ${SERVICES_ENABLED[*]}"
if [[ ${#PROMPTS_APPLIED[@]} -gt 0 ]]; then
  info "Optional features applied:"
  for p in "${PROMPTS_APPLIED[@]}"; do
    info "  - $p"
  done
fi
info "======================================================="
echo

if [[ $IS_WSL -eq 1 ]]; then
  echo "Next from PowerShell: wsl --shutdown && wsl -d archlinux"
  echo "Verify after reopen: whoami && echo \$SHELL"
elif [[ $DRY_RUN -eq 1 ]]; then
  info "Dry-run complete. No system changes made."
else
  echo "Next:"
  echo "  bash scripts/zsh.sh           # Oh My Zsh + plugins"
  echo "  stow -v -t ~ zsh nvim tmux git # link dotfiles"
  if [[ $REBOOT_NEEDED -eq 1 ]]; then
    warn "REBOOT STRONGLY RECOMMENDED (kernel/microcode/firmware updated)."
    ask "Reboot now?" && reboot
  fi
fi
echo
