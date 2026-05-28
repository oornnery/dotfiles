#!/usr/bin/env bash
set -euo pipefail

# Run after a fresh archinstall. Single linear script that does what the
# modular scripts/arch/ setup does — no functions, no library, just
# echo + pacman/systemctl/curl. Top to bottom; comment sections you
# don't want.
#
# Tuned for: VAIO laptop + AMD CPU + AMD GPU + btrfs root + GNOME/Hyprland.
# Adapts via detection vars (skips nvidia/intel-gpu, skips VM-only stuff).
#
# After this finishes:
#   reboot
#   # Log into Hyprland or GNOME from GDM

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"
DOTFILES_DIR="${DOTFILES_DIR:-/home/$USER_NAME/dotfiles}"
THEME="${THEME:-catppuccin-mocha}"
VIM_DISTRO="${VIM_DISTRO:-native}"     # native | plug
NVIM_DISTRO="${NVIM_DISTRO:-mini}"     # native | mini | lazy
USE_IWD="${USE_IWD:-1}"                # NM wifi backend
WEATHER_CITY="${WEATHER_CITY:-Salvador}"
MIRROR_COUNTRY="${MIRROR_COUNTRY:-Brazil}"

# ─── Preflight ──────────────────────────────────────────────────────────────

echo "==> Preflight checks"
[[ $EUID -eq 0 ]] || { echo "Run as root: sudo bash $0" >&2; exit 1; }
[[ -f /var/lib/pacman/db.lck ]] && { echo "pacman db locked" >&2; exit 1; }
ping -c1 -W3 archlinux.org >/dev/null 2>&1 || { echo "no network" >&2; exit 1; }
id "$USER_NAME" >/dev/null 2>&1 || { echo "user $USER_NAME doesn't exist" >&2; exit 1; }

# ─── Detection ──────────────────────────────────────────────────────────────

echo "==> Detecting system"
IS_WSL=0;  grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null && IS_WSL=1
VM_TYPE="$(systemd-detect-virt 2>/dev/null || echo none)"
[[ -z "$VM_TYPE" ]] && VM_TYPE=none
IS_VM=0;   [[ "$VM_TYPE" != "none" && $IS_WSL -eq 0 ]] && IS_VM=1
IS_LAPTOP=0
[[ $IS_WSL -eq 0 && $IS_VM -eq 0 && -r /sys/class/dmi/id/chassis_type ]] \
    && case "$(cat /sys/class/dmi/id/chassis_type 2>/dev/null)" in
        8|9|10|14) IS_LAPTOP=1 ;;
    esac
CPU_VENDOR=unknown
grep -q GenuineIntel /proc/cpuinfo && CPU_VENDOR=intel
grep -q AuthenticAMD /proc/cpuinfo && CPU_VENDOR=amd
GPU_VENDORS=""
if [[ $IS_WSL -eq 0 && $IS_VM -eq 0 ]]; then
    for f in /sys/class/drm/card*/device/vendor; do
        [[ -f "$f" ]] || continue
        case "$(cat "$f")" in
            0x1002) GPU_VENDORS+="amd " ;;
            0x8086) GPU_VENDORS+="intel " ;;
            0x10de) GPU_VENDORS+="nvidia " ;;
        esac
    done
fi
DMI_VENDOR="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || echo unknown)"
ROOT_FS="$(findmnt -no FSTYPE / 2>/dev/null || echo unknown)"
echo "    CPU=$CPU_VENDOR  GPU=${GPU_VENDORS:-none}  Laptop=$IS_LAPTOP  VM=$IS_VM  WSL=$IS_WSL  FS=$ROOT_FS  Vendor=$DMI_VENDOR"

# ─── pacman.conf tweaks ─────────────────────────────────────────────────────

echo "==> Tuning /etc/pacman.conf"
sed -i 's/^#\?Color/Color/' /etc/pacman.conf
sed -i 's/^#\?VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
sed -i 's/^#\?CheckSpace/CheckSpace/' /etc/pacman.conf
sed -i 's/^#\?ParallelDownloads = .*/ParallelDownloads = 10/' /etc/pacman.conf
grep -qxF ILoveCandy /etc/pacman.conf || sed -i '/^Color/a ILoveCandy' /etc/pacman.conf
# Enable [multilib] on x86_64
if [[ "$(uname -m)" == x86_64 ]]; then
    sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
fi

# ─── Mirror refresh + system update ────────────────────────────────────────

echo "==> Refreshing mirrors via reflector"
pacman -S --needed --noconfirm reflector
reflector --country "$MIRROR_COUNTRY" --age 12 --protocol https \
    --sort rate --save /etc/pacman.d/mirrorlist || true

echo "==> System upgrade (pacman -Syyu)"
pacman -Syyu --noconfirm

# ─── Base utilities ─────────────────────────────────────────────────────────

echo "==> Base packages + microcode + fonts"
pacman -S --needed --noconfirm \
    base-devel sudo git curl wget vim bash \
    unzip zip tar gzip bzip2 xz 7zip \
    openssl openssh ca-certificates \
    xdg-utils xdg-user-dirs \
    gvfs gvfs-mtp gvfs-nfs gvfs-smb \
    ntfs-3g dosfstools exfatprogs \
    ffmpegthumbnailer \
    less man-db man-pages man-pages-pt_br \
    pacman-contrib pkgfile arch-audit git-delta expac \
    kernel-modules-hook \
    inxi usbutils \
    libnotify acpi

# Microcode by CPU vendor
if [[ $IS_WSL -eq 0 && $IS_VM -eq 0 ]]; then
    case "$CPU_VENDOR" in
        intel) pacman -S --needed --noconfirm intel-ucode ;;
        amd)   pacman -S --needed --noconfirm amd-ucode ;;
    esac
fi

pacman -S --needed --noconfirm \
    ttf-jetbrains-mono-nerd ttf-firacode-nerd \
    noto-fonts noto-fonts-emoji noto-fonts-cjk

# ─── Locale + timezone + keymap ─────────────────────────────────────────────

echo "==> Locale + timezone + keymap"
for l in "en_US.UTF-8 UTF-8" "pt_BR.UTF-8 UTF-8"; do
    sed -i "s/^#\s*\(${l//./\\.}\)/\1/" /etc/locale.gen
done
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
if [[ $IS_WSL -eq 0 && $IS_VM -eq 0 ]]; then
    hwclock --systohc || true
fi
echo "KEYMAP=us" > /etc/vconsole.conf
install -d -m 755 /etc/X11/xorg.conf.d
cat > /etc/X11/xorg.conf.d/00-keyboard.conf <<EOF
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout"  "us,br"
    Option "XkbVariant" "intl,abnt2"
    Option "XkbOptions" "grp:alt_shift_toggle"
EndSection
EOF

# ─── Wheel sudo + user linger ──────────────────────────────────────────────

echo "==> User setup (wheel sudo, linger)"
if ! id -nG "$USER_NAME" | grep -qw wheel; then
    usermod -aG wheel "$USER_NAME"
fi
if [[ ! -f /etc/sudoers.d/10-wheel ]]; then
    tmp="$(mktemp)"
    echo '%wheel ALL=(ALL:ALL) ALL' > "$tmp"
    visudo -cf "$tmp" >/dev/null && install -m 440 -o root -g root "$tmp" /etc/sudoers.d/10-wheel
    rm -f "$tmp"
fi
loginctl enable-linger "$USER_NAME" 2>/dev/null || true

# ─── Core services ──────────────────────────────────────────────────────────

echo "==> Enabling core systemd services"
systemctl enable systemd-timesyncd.service
systemctl enable systemd-resolved.service
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf 2>/dev/null || true
systemctl enable paccache.timer
systemctl enable pkgfile-update.timer

# earlyoom (OOM prevention)
pacman -S --needed --noconfirm earlyoom
systemctl enable earlyoom.service

# journald: cap to 200M
sed -i 's/^#\?\s*SystemMaxUse=.*/SystemMaxUse=200M/' /etc/systemd/journald.conf

# ─── gnome-keyring + PAM ────────────────────────────────────────────────────

echo "==> gnome-keyring + libsecret + PAM auto-unlock"
pacman -S --needed --noconfirm \
    gnome-keyring libsecret seahorse polkit-gnome

for f in /etc/pam.d/login /etc/pam.d/gdm-password; do
    [[ -f "$f" ]] || continue
    grep -q "pam_gnome_keyring.so" "$f" && continue
    if grep -q '^auth.*pam_unix.so' "$f"; then
        sed -i '/^auth.*pam_unix.so/i auth       optional     pam_gnome_keyring.so' "$f"
    else
        echo 'auth       optional     pam_gnome_keyring.so' >> "$f"
    fi
    if grep -q '^session.*pam_unix.so' "$f"; then
        sed -i '/^session.*pam_unix.so/a session    optional     pam_gnome_keyring.so auto_start' "$f"
    else
        echo 'session    optional     pam_gnome_keyring.so auto_start' >> "$f"
    fi
done
grep -qxF 'password optional pam_gnome_keyring.so' /etc/pam.d/passwd \
    || echo 'password optional pam_gnome_keyring.so' >> /etc/pam.d/passwd

# ─── NetworkManager (+ iwd backend) ─────────────────────────────────────────

if [[ $IS_WSL -eq 0 ]]; then
    echo "==> NetworkManager"
    pacman -S --needed --noconfirm networkmanager network-manager-applet
    systemctl enable NetworkManager.service

    if [[ "$USE_IWD" == "1" ]]; then
        echo "==> Switching NM backend to iwd (+ impala TUI)"
        pacman -S --needed --noconfirm iwd impala
        sudo -u "$USER_NAME" stow -d "$DOTFILES_DIR" -t / -R iwd 2>/dev/null \
            || install -D -m 644 "$DOTFILES_DIR/iwd/etc/NetworkManager/conf.d/wifi_backend.conf" \
                /etc/NetworkManager/conf.d/wifi_backend.conf
    fi
fi

# ─── Bluetooth ──────────────────────────────────────────────────────────────

if [[ $IS_WSL -eq 0 ]] && compgen -G "/sys/class/bluetooth/hci*" >/dev/null; then
    echo "==> Bluetooth (bluez + bluetui)"
    pacman -S --needed --noconfirm bluez bluez-utils bluez-obex blueman bluetui
    systemctl enable bluetooth.service
    if [[ $IS_VM -eq 0 && -f /etc/bluetooth/main.conf ]] \
       && ! grep -q '^Experimental = true' /etc/bluetooth/main.conf; then
        sed -i 's/^#\?\s*Experimental.*$/Experimental = true/' /etc/bluetooth/main.conf
    fi
fi

# ─── PipeWire audio ─────────────────────────────────────────────────────────

echo "==> PipeWire audio stack"
pacman -S --needed --noconfirm \
    pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack \
    wireplumber pavucontrol \
    alsa-utils alsa-ucm-conf \
    playerctl pamixer wiremix \
    gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav \
    ffmpeg sof-firmware alsa-firmware

# ─── Storage automount (USB pendrives) ──────────────────────────────────────

echo "==> Storage (udisks2 + udiskie + polkit)"
pacman -S --needed --noconfirm udisks2 udiskie polkit
[[ "$ROOT_FS" == btrfs ]] && pacman -S --needed --noconfirm udisks2-btrfs

# ─── Hardware monitoring ────────────────────────────────────────────────────

if [[ $IS_WSL -eq 0 ]]; then
    echo "==> Hardware monitoring (sensors + SMART + NVMe)"
    pacman -S --needed --noconfirm lm_sensors smartmontools
    compgen -G "/dev/nvme*" >/dev/null && pacman -S --needed --noconfirm nvme-cli
    [[ $IS_VM -eq 0 ]] && systemctl enable smartd.service
fi

# ─── AMD GPU stack (skip on VM/WSL) ─────────────────────────────────────────

if [[ $IS_WSL -eq 0 && $IS_VM -eq 0 ]] && [[ " $GPU_VENDORS " == *" amd "* ]]; then
    echo "==> AMD GPU drivers"
    pacman -S --needed --noconfirm \
        mesa mesa-utils \
        vulkan-icd-loader vulkan-radeon \
        libva-utils vdpauinfo \
        libva-mesa-driver libvdpau-va-gl \
        xf86-video-amdgpu xf86-video-ati \
        radeontop nvtop corectrl \
        lib32-mesa lib32-vulkan-icd-loader lib32-vulkan-radeon
fi

# ─── Notebook VAIO bits ────────────────────────────────────────────────────

if [[ $IS_WSL -eq 0 && $IS_VM -eq 0 && $IS_LAPTOP -eq 1 ]]; then
    echo "==> Notebook setup (VAIO + AMD)"
    pacman -S --needed --noconfirm \
        brightnessctl upower fwupd v4l-utils libinput \
        iio-sensor-proxy \
        power-profiles-daemon
    systemctl enable power-profiles-daemon.service
    gpasswd -a "$USER_NAME" input || true
    gpasswd -a "$USER_NAME" video || true

    # AMD kernel params (amd_pstate=active + s2idle)
    if [[ "$CPU_VENDOR" == amd ]]; then
        if [[ -d /boot/loader/entries ]]; then
            for f in /boot/loader/entries/*.conf; do
                grep -q amd_pstate "$f" && continue
                sed -i "/^options/ s/\$/ amd_pstate=active mem_sleep_default=s2idle/" "$f"
            done
        elif [[ -f /etc/default/grub ]]; then
            if ! grep -q amd_pstate /etc/default/grub; then
                sed -i 's|GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"|GRUB_CMDLINE_LINUX_DEFAULT="\1 amd_pstate=active mem_sleep_default=s2idle"|' /etc/default/grub
                command -v grub-mkconfig >/dev/null && grub-mkconfig -o /boot/grub/grub.cfg
            fi
        fi
    fi
fi

# ─── zram swap (stow-managed config) ───────────────────────────────────────

if [[ $IS_WSL -eq 0 && $IS_VM -eq 0 ]]; then
    echo "==> zram swap (size = ram, zstd)"
    pacman -S --needed --noconfirm zram-generator
    stow -d "$DOTFILES_DIR" -t / -R zram 2>/dev/null \
        || install -D -m 644 "$DOTFILES_DIR/zram/etc/systemd/zram-generator.conf" \
            /etc/systemd/zram-generator.conf
    systemctl daemon-reload
    systemctl restart systemd-zram-setup@zram0.service || true
fi

# ─── Snapper (btrfs only) ──────────────────────────────────────────────────

if [[ "$ROOT_FS" == btrfs ]]; then
    echo "==> Snapper (btrfs snapshots + snap-pac hooks)"
    pacman -S --needed --noconfirm snapper snap-pac btrfs-progs
    snapper -c root list >/dev/null 2>&1 \
        || snapper -c root create-config / || true
fi

# ─── UFW firewall ───────────────────────────────────────────────────────────

echo "==> UFW firewall"
pacman -S --needed --noconfirm ufw ufw-docker
ufw default deny incoming
ufw default allow outgoing
ufw --force enable
systemctl enable ufw.service

# ─── paru (AUR helper) ──────────────────────────────────────────────────────

if ! sudo -u "$USER_NAME" -H bash -c 'command -v paru' >/dev/null 2>&1; then
    echo "==> Building paru from AUR"
    sudo -u "$USER_NAME" -H bash -c '
        set -e
        cd /tmp && rm -rf paru
        git clone https://aur.archlinux.org/paru.git
        cd paru && makepkg -si --noconfirm
    '
fi

# ─── Flatpak + Flathub ──────────────────────────────────────────────────────

echo "==> Flatpak + Flathub"
pacman -S --needed --noconfirm flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# ─── Modern CLI tools ───────────────────────────────────────────────────────

echo "==> Modern CLI / TUI tools"
pacman -S --needed --noconfirm \
    tmux neovim \
    ripgrep fd fzf \
    jq yq htmlq xmlstarlet \
    bat eza zoxide plocate \
    atuin starship \
    mise direnv \
    lazygit yazi \
    tealdeer usage gum \
    procs dust duf sd xh bottom gping doggo tokei \
    fastfetch btop \
    github-cli glab \
    whois inetutils socat \
    tree-sitter-cli \
    tesseract tesseract-data-eng tesseract-data-por \
    wf-recorder

# ─── Languages / runtimes ───────────────────────────────────────────────────

echo "==> Languages (Python, Node, Rust, Go, Lua)"
pacman -S --needed --noconfirm \
    python python-pip python-pipx uv ruff pyright python-pytest \
    rust nim lua luarocks \
    make cmake \
    nodejs npm fnm bun pnpm \
    go zig

# ─── Containers (Docker + Podman + lazydocker) ──────────────────────────────

echo "==> Docker + Podman + lazydocker"
pacman -S --needed --noconfirm \
    docker docker-compose docker-buildx \
    podman buildah skopeo \
    distrobox lazydocker
systemctl enable docker.socket
gpasswd -a "$USER_NAME" docker || true

# ─── Hyprland stack ─────────────────────────────────────────────────────────

if [[ $IS_WSL -eq 0 ]]; then
    echo "==> Hyprland + Wayland helpers + utils"
    pacman -S --needed --noconfirm \
        hyprland hypridle hyprlock hyprshot hyprpaper hyprsunset hyprpicker \
        hyprland-qtutils hyprpolkitagent \
        xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
        xdg-terminal-exec uwsm \
        waybar swaync mako swayosd \
        wofi rofi-wayland \
        swww nwg-look kvantum \
        qt5-wayland qt6-wayland qt5ct qt6ct \
        xorg-xwayland \
        grim slurp satty swappy wlogout \
        wl-clipboard cliphist \
        woff2-font-awesome \
        alacritty ghostty
fi

# ─── GNOME desktop ──────────────────────────────────────────────────────────

if [[ $IS_WSL -eq 0 && $IS_VM -eq 0 ]]; then
    echo "==> GNOME desktop"
    pacman -S --needed --noconfirm \
        gnome-shell gnome-control-center gnome-session gnome-settings-daemon \
        gnome-terminal nautilus gnome-text-editor gnome-calculator \
        gnome-disk-utility gnome-system-monitor \
        gnome-tweaks gnome-shell-extensions gnome-software \
        xdg-desktop-portal xdg-desktop-portal-gnome \
        gst-plugin-pipewire
fi

# ─── GDM (login manager) ────────────────────────────────────────────────────

if [[ $IS_WSL -eq 0 && $IS_VM -eq 0 ]]; then
    echo "==> GDM + stow /etc/gdm/custom.conf"
    pacman -S --needed --noconfirm gdm
    # Disable competing DMs if previously enabled
    for unit in sddm.service ly.service greetd.service; do
        systemctl is-enabled --quiet "$unit" 2>/dev/null \
            && systemctl disable --now "$unit" || true
    done
    stow -d "$DOTFILES_DIR" -t / -R gdm 2>/dev/null \
        || install -D -m 644 "$DOTFILES_DIR/gdm/etc/gdm/custom.conf" /etc/gdm/custom.conf
    systemctl enable gdm.service
fi

# ─── AI / LLM tools ─────────────────────────────────────────────────────────

echo "==> Claude Code"
sudo -u "$USER_NAME" -H bash -c 'curl -fsSL https://claude.ai/install.sh | bash' || true

echo "==> OpenAI Codex (npm global, user-local)"
sudo -u "$USER_NAME" -H bash -c '
    mkdir -p "$HOME/.local/npm"
    npm config set prefix "$HOME/.local/npm"
    npm install -g @openai/codex
' || true

echo "==> Ollama"
pacman -S --needed --noconfirm ollama
systemctl enable --now ollama.service || true

echo "==> RTK (prompt optimizer)"
sudo -u "$USER_NAME" -H bash -c '
    curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
    command -v rtk >/dev/null && rtk init --global || true
' || true

echo "==> Custom agent skills → ~/.agents"
sudo -u "$USER_NAME" -H bash -c '
    if [[ ! -d "$HOME/.agents" ]] && command -v gh >/dev/null; then
        gh repo clone oornnery/.agents "$HOME/.agents" || true
    fi
' || true

# ─── Oh My Zsh + plugins ────────────────────────────────────────────────────

echo "==> zsh + Oh My Zsh + plugins"
pacman -S --needed --noconfirm zsh stow
USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
OMZ="$USER_HOME/.oh-my-zsh"
if [[ ! -d "$OMZ" ]]; then
    sudo -u "$USER_NAME" -H env RUNZSH=no CHSH=no KEEP_ZSHRC=yes bash -c \
        'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
fi
for spec in \
    "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions" \
    "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting" \
    "zsh-completions|https://github.com/zsh-users/zsh-completions" \
    "fzf-tab|https://github.com/Aloxaf/fzf-tab"; do
    name="${spec%%|*}"; url="${spec##*|}"
    target="$OMZ/custom/plugins/$name"
    [[ -d "$target" ]] || sudo -u "$USER_NAME" -H git clone --depth 1 "$url" "$target"
done
# chsh to zsh
current_shell="$(getent passwd "$USER_NAME" | cut -d: -f7)"
[[ "$current_shell" != /bin/zsh ]] && chsh -s /bin/zsh "$USER_NAME" || true

# ─── Tmux Plugin Manager (tpm) ──────────────────────────────────────────────

echo "==> Tmux Plugin Manager"
TPM_DIR="$USER_HOME/.tmux/plugins/tpm"
[[ -d "$TPM_DIR" ]] || sudo -u "$USER_NAME" -H git clone --depth 1 \
    https://github.com/tmux-plugins/tpm "$TPM_DIR"

# ─── Stow all dotfiles ──────────────────────────────────────────────────────

echo "==> Stowing dotfiles → \$HOME"
PACKAGES=(bash zsh tmux git editor fabric alacritty bin waybar wofi mako hyprland)
case "$VIM_DISTRO" in
    native|plain|basic) PACKAGES+=(vim) ;;
    plug|vim-plug|vimplug) PACKAGES+=(vim.plug) ;;
    *)
        echo "WARN: unknown VIM_DISTRO=$VIM_DISTRO; using native" >&2
        VIM_DISTRO="native"
        PACKAGES+=(vim)
        ;;
esac
case "$NVIM_DISTRO" in
    native|plain|basic) PACKAGES+=(nvim) ;;
    mini|minimal)       PACKAGES+=(nvim.mini) ;;
    lazy|lazyvim)       PACKAGES+=(nvim.lazy) ;;
    *)
        echo "WARN: unknown NVIM_DISTRO=$NVIM_DISTRO; using mini" >&2
        NVIM_DISTRO="mini"
        PACKAGES+=(nvim.mini)
        ;;
esac
[[ $IS_WSL -eq 1 ]] && PACKAGES+=(wsl)

for editor_pkg in vim vim.plug nvim nvim.mini nvim.lazy; do
    case " ${PACKAGES[*]} " in
        *" $editor_pkg "*) continue ;;
    esac

    [[ -d "$DOTFILES_DIR/$editor_pkg" ]] || continue
    sudo -u "$USER_NAME" -H stow -d "$DOTFILES_DIR" -t "$USER_HOME" -D "$editor_pkg" 2>/dev/null || true
done

for pkg in "${PACKAGES[@]}"; do
    if [[ ! -d "$DOTFILES_DIR/$pkg" ]]; then
        echo "    skip $pkg (no source dir)"; continue
    fi
    # backup real-file conflicts before stowing
    while IFS= read -r conflict; do
        [[ -z "$conflict" ]] && continue
        path="$USER_HOME/$conflict"
        [[ -e "$path" && ! -L "$path" ]] || continue
        sudo -u "$USER_NAME" -H mv "$path" "${path}.bak.$(date +%Y%m%d%H%M%S)"
    done < <(
        sudo -u "$USER_NAME" -H stow -n -d "$DOTFILES_DIR" -t "$USER_HOME" "$pkg" 2>&1 \
            | sed -nE 's/.*existing target is (neither a link nor a directory|not owned by stow): //p'
    )
    sudo -u "$USER_NAME" -H stow -d "$DOTFILES_DIR" -t "$USER_HOME" -R "$pkg" \
        && echo "    stowed $pkg" \
        || echo "    FAILED $pkg"
done

# ─── Apply active theme (alacritty/waybar/wofi/mako/starship) ──────────────

echo "==> Applying theme: $THEME"
sudo -u "$USER_NAME" -H "$USER_HOME/.local/bin/theme" set "$THEME" 2>/dev/null \
    || echo "    (theme switcher not available yet — run 'theme set $THEME' after relogin)"

# ─── Hyprland config: udiskie autostart, screenshot dir ────────────────────

if [[ $IS_WSL -eq 0 ]]; then
    sudo -u "$USER_NAME" -H mkdir -p "$USER_HOME/Pictures/screenshots" "$USER_HOME/Videos/recordings"
fi

# ─── Done ───────────────────────────────────────────────────────────────────

echo
echo "==> Arch setup finished."
echo
echo "Next steps:"
echo "  reboot                                  # kernel params + initramfs"
echo "  # Log into Hyprland or GNOME at GDM"
echo "  theme list                              # available palettes"
echo "  theme set tokyo-night                   # switch theme"
echo "  sudo sensors-detect --auto              # populate lm_sensors modules"
echo
echo "Opt-in modules (run as needed):"
echo "  sudo bash scripts/arch/core/fingerprint.sh   # fprintd + PAM"
echo "  sudo bash scripts/arch/core/firefoxpwa.sh    # PWA backend"
echo "  sudo bash scripts/arch/core/windows-vm.sh    # Windows 11 in Docker"
echo "  sudo bash scripts/arch/dev/vscodium.sh       # VSCodium + extensions"
echo "  sudo bash scripts/arch/game/gaming.sh        # Steam + wine"
echo
echo "Useful binaries now in ~/.local/bin/:"
echo "  notice  web-app  theme  power-profile  clipboard  screenshot  ocr"
echo "  wallpaper  emoji  unicode  dnd  update  record  night-mode  …"
echo
echo "Config to tweak:"
echo "  $DOTFILES_DIR/scripts/arch/arch.conf     # vars (theme, NVIM_DISTRO, etc.)"
echo "  $DOTFILES_DIR/hyprland/.config/hypr/     # bindings, monitors, hyprland.conf"
echo "  $DOTFILES_DIR/zsh/, $DOTFILES_DIR/alacritty/, etc.  # everything is stowed"
echo
