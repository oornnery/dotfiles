#!/usr/bin/env bash
# arch/audio.sh — PipeWire stack + ALSA UCM + SOF firmware + codecs.
[[ -z "${ARCH_LIB_LOADED:-}" ]] && source "${BASH_SOURCE%/*}/lib.sh"

audio::run() {
  log::step "Installing audio stack (PipeWire)."
  pacman_install \
    pipewire pipewire-pulse pipewire-alsa pipewire-jack \
    wireplumber pavucontrol \
    alsa-utils alsa-firmware alsa-ucm-conf \
    sof-firmware \
    playerctl pamixer \
    gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav \
    ffmpeg
}
