#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

TEMPLATES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../templates" && pwd)"

require_root
detect::system

log::banner "Hardware" "zram swap"

if [[ $IS_VM -eq 1 ]]; then
    log::skip "VM: skipping zram"
    exit 0
fi

log::info "Installing zram-generator"
sudo pacman -S --needed --noconfirm zram-generator

src="$TEMPLATES_DIR/etc/systemd/zram-generator.conf"
dest=/etc/systemd/zram-generator.conf

if [[ ! -f "$src" ]]; then
    die "Template missing: $src"
fi

if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
    log::skip "$dest already up to date"
else
    [[ -f "$dest" ]] && snapshot "$dest"
    sudo install -m 644 "$src" "$dest"
    log::ok "Installed $dest"
fi

log::ok "zram configured (active after reboot)"
