# !/bin/bash

# Base
sudo pacman -S base base-devel

# Utils
sudo pacman -S man-db man-pages man-pages-pt_br texinfo \
    vim neovim wget curl git reflector htop cpufetch fastfetch archlinux-wallpaper python-pywal

# Files system
sudo pacman -S dosfstools ntfs-3g mtools btrfs-progs exfat-utils

# Video drivers
sudo pacman -S mesa lib32-mesa mesa-vdpau libva-mesa-driver\
    vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader vulkan-tools \
    xf86-video-amdgpu brightnessctl

# Audio drivers
sudo pacman -S pipewire pipewire-pulse pipewire-alsa pipewire-jack \
    alsa-utils pavucontrol ffmpeg ffmpegthumbnailer gstreamer gst-libav \
    noise-suppression-for-voice vlc mpv playerctl

# Profile system
sudo pacman -S power-profiles-daemon
sudo systemctl enable --now power-profiles-daemon.service

# SELinux
sudo pacman -S selinux-utils

# Configure automativ BTRFS snapshots
sudo pacman -S snapper
sudo snapper -c root create-config /
sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer

### System Monitoring
# Install Netdata for real-time system monitoring:
# sudo pacman -S netdata
# sudo systemctl enable --now netdata
# Access via http://localhost:19999
