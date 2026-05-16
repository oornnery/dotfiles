#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

DM_SESSION_CMD="${DM_SESSION_CMD:-Hyprland}"
TEMPLATES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../templates" && pwd)"

require_root
detect::system

log::banner "Desktop" "greetd + tuigreet"

if [[ $IS_WSL -eq 1 || $IS_VM -eq 1 ]]; then
    log::skip "WSL/VM: no display manager needed"
    exit 0
fi

log::info "Installing greetd + tuigreet"
sudo pacman -S --needed --noconfirm greetd greetd-tuigreet

log::info "Disabling other display managers"
for unit in gdm.service sddm.service ly.service; do
    if systemctl is-enabled --quiet "$unit" 2>/dev/null; then
        sudo systemctl disable --now "$unit" || true
        log::ok "Disabled $unit"
    fi
done

sudo install -d -m 755 /etc/greetd

src="$TEMPLATES_DIR/etc/greetd/config.toml"
dest=/etc/greetd/config.toml

if [[ -f "$src" ]]; then
    [[ -f "$dest" ]] && snapshot "$dest"
    sudo sed "s|__SESSION_CMD__|$DM_SESSION_CMD|g" "$src" | sudo install -m 644 /dev/stdin "$dest"
    log::ok "Installed $dest"
else
    log::info "Writing greetd config (no template found)"
    [[ -f "$dest" ]] && snapshot "$dest"
    sudo tee "$dest" >/dev/null <<EOF
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --remember-session --asterisks --cmd $DM_SESSION_CMD"
user = "greeter"
EOF
    log::ok "Wrote $dest"
fi

sudo systemctl enable greetd.service

log::ok "greetd enabled (session: $DM_SESSION_CMD)"
