#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

USER_NAME="${USER_NAME:-${SUDO_USER:-$USER}}"
TEMPLATES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../templates" && pwd)"

require_root
detect::system

log::banner "WSL" "Base setup (/etc/wsl.conf)"

if [[ $IS_WSL -eq 0 ]]; then
    log::skip "Not running in WSL"
    exit 0
fi

src="$TEMPLATES_DIR/wsl/etc/wsl.conf"
dest=/etc/wsl.conf

if [[ -f "$src" ]]; then
    [[ -f "$dest" ]] && snapshot "$dest"
    sudo sed "s/__USER__/$USER_NAME/g" "$src" | sudo install -m 644 /dev/stdin "$dest"
    log::ok "Installed $dest"
else
    log::info "Writing default /etc/wsl.conf (no template found)"
    [[ -f "$dest" ]] && snapshot "$dest"
    sudo tee "$dest" >/dev/null <<EOF
[boot]
systemd=true

[user]
default=$USER_NAME

[interop]
enabled=true
appendWindowsPath=true

[network]
generateHosts=true
generateResolvConf=true
EOF
    log::ok "Wrote $dest"
fi

log::warn "From PowerShell: 'wsl --shutdown' then reopen Arch"
