#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

require_root
detect::system

log::banner "System" "Base utilities + microcode + fonts"

PKGS=(
    base-devel
    sudo git curl wget vim bash stow
    unzip zip tar gzip bzip2 xz 7zip
    openssl openssh ca-certificates
    xdg-utils xdg-user-dirs
    gvfs gvfs-mtp gvfs-nfs gvfs-smb
    ntfs-3g dosfstools exfatprogs
    ffmpegthumbnailer
    less man-db man-pages man-pages-pt_br
    pacman-contrib pkgfile arch-audit git-delta expac
    kernel-modules-hook
    inxi
)

log::info "Installing base packages"
sudo pacman -S --needed --noconfirm "${PKGS[@]}"

if [[ $IS_WSL -eq 0 && $IS_VM -eq 0 ]]; then
    case "$CPU_VENDOR" in
        intel)
            log::info "Installing intel-ucode"
            sudo pacman -S --needed --noconfirm intel-ucode
            log::warn "Regenerate bootloader config so microcode loads"
            ;;
        amd)
            log::info "Installing amd-ucode"
            sudo pacman -S --needed --noconfirm amd-ucode
            log::warn "Regenerate bootloader config so microcode loads"
            ;;
        *)
            log::skip "No microcode for CPU vendor: $CPU_VENDOR"
            ;;
    esac
else
    log::skip "WSL/VM: skipping microcode"
fi

log::info "Installing fonts (Nerd + Noto)"
sudo pacman -S --needed --noconfirm \
    ttf-jetbrains-mono-nerd ttf-firacode-nerd \
    noto-fonts noto-fonts-emoji noto-fonts-cjk

log::ok "Base utilities installed"
