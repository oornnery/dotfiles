#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"
EXTRAS="${EXTRAS:-0}"

require_root
detect::system
detect::audio
detect::bluetooth

log::banner "Hardware" "PipeWire audio stack"

if [[ $IS_WSL -eq 1 ]]; then
    log::warn "WSL: audio support is limited (WSLg required)"
fi

PKGS=(
    pipewire pipewire-audio
    pipewire-alsa pipewire-pulse pipewire-jack
    wireplumber pavucontrol
    alsa-utils alsa-ucm-conf
    playerctl pamixer wiremix
    gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav
    ffmpeg
)

if printf '%s\n' "${AUDIO_DRIVERS[@]:-}" | grep -qi sof; then
    PKGS+=(sof-firmware)
fi

if printf '%s\n' "${AUDIO_DRIVERS[@]:-}" | grep -qi snd_hda; then
    PKGS+=(alsa-firmware)
fi

if [[ $HAS_BLUETOOTH -eq 1 ]]; then
    PKGS+=(pipewire-bluetooth)
fi

if [[ $EXTRAS -eq 1 ]]; then
    PKGS+=(qpwgraph helvum easyeffects realtime-privileges lsp-plugins)
fi

log::info "Installing PipeWire packages"
sudo pacman -S --needed --noconfirm "${PKGS[@]}"

if [[ $EXTRAS -eq 1 ]] && id "$USER_NAME" >/dev/null 2>&1; then
    log::info "Adding $USER_NAME to realtime group"
    sudo gpasswd -a "$USER_NAME" realtime || true
fi

log::ok "PipeWire stack installed"
