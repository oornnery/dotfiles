#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

CONF=/etc/pacman.conf
PARALLEL_DL_VALUE=10

log::step "Configuring pacman"

log::info "Setting ParallelDownloads = $PARALLEL_DL_VALUE"

if grep -qE "^ParallelDownloads\s*=\s*$PARALLEL_DL_VALUE\$" "$CONF"; then
    log::skip "ParallelDownloads already set to $PARALLEL_DL_VALUE"
elif grep -qE "^#?ParallelDownloads\s*=" "$CONF"; then
    sudo sed -i "s/^#\?ParallelDownloads\s*=.*/ParallelDownloads = $PARALLEL_DL_VALUE/" "$CONF"
    log::ok "Set ParallelDownloads = $PARALLEL_DL_VALUE"
else
    sudo sed -i "/^\[options\]/a ParallelDownloads = $PARALLEL_DL_VALUE" "$CONF"
    log::ok "Added ParallelDownloads = $PARALLEL_DL_VALUE"
fi

log::info "Setting VerbosePkgLists = true"

if grep -qx 'ILoveCandy' "$CONF"; then
    log::skip "ILoveCandy already enabled"
elif grep -qx '#ILoveCandy' "$CONF"; then
    sudo sed -i 's/^#ILoveCandy$/ILoveCandy/' "$CONF"
    log::ok "Uncommented ILoveCandy"
else
    sudo sed -i '/^\[options\]/a ILoveCandy' "$CONF"
    log::ok "Added ILoveCandy"
fi

log::info "Enabling Color output"

if grep -qx 'Color' "$CONF"; then
    log::skip "Color already enabled"
elif grep -qx '#Color' "$CONF"; then
    sudo sed -i 's/^#Color$/Color/' "$CONF"
    log::ok "Uncommented Color"
else
    sudo sed -i '/^\[options\]/a Color' "$CONF"
    log::ok "Added Color"
fi

log::info "Enabling VerbosePkgLists"

if grep -qx 'VerbosePkgLists' "$CONF"; then
    log::skip "VerbosePkgLists already enabled"
elif grep -qx '#VerbosePkgLists' "$CONF"; then
    sudo sed -i 's/^#VerbosePkgLists$/VerbosePkgLists/' "$CONF"
    log::ok "Uncommented VerbosePkgLists"
else
    sudo sed -i '/^\[options\]/a VerbosePkgLists' "$CONF"
    log::ok "Added VerbosePkgLists"
fi

log::info "Enabling CheckSpace"

if grep -qx 'CheckSpace' "$CONF"; then
    log::skip "CheckSpace already enabled"
elif grep -qx '#CheckSpace' "$CONF"; then
    sudo sed -i 's/^#CheckSpace$/CheckSpace/' "$CONF"
    log::ok "Uncommented CheckSpace"
else
    sudo sed -i '/^\[options\]/a CheckSpace' "$CONF"
    log::ok "Added CheckSpace"
fi

if [[ "$(uname -m)" == "x86_64" ]]; then
    if grep -qE '^\[multilib\]' "$CONF"; then
        log::skip "multilib already enabled"
    elif grep -qE '^#\[multilib\]' "$CONF"; then
        sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' "$CONF"
        log::ok "Uncommented multilib section"
    else
        sudo tee -a "$CONF" >/dev/null <<'EOL'
[multilib]
Include = /etc/pacman.d/mirrorlist
EOL
        log::ok "Appended multilib section"
    fi
else
    log::warn "Skipping multilib enablement since system is not x86_64"
fi