#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

LOCALE="${LOCALE:-en_US.UTF-8}"
TIMEZONE="${TIMEZONE:-America/Sao_Paulo}"
KEYMAP="${KEYMAP:-us}"
XKB_LAYOUT="${XKB_LAYOUT:-us,br}"
XKB_VARIANT="${XKB_VARIANT:-intl,abnt2}"
XKB_OPTIONS="${XKB_OPTIONS:-grp:alt_shift_toggle}"

require_root
detect::system

log::step "Configuring locale, timezone, keymap"

log::info "Enabling locales in /etc/locale.gen"
snapshot /etc/locale.gen
for l in "en_US.UTF-8 UTF-8" "pt_BR.UTF-8 UTF-8"; do
    if grep -q "^${l}$" /etc/locale.gen; then
        log::skip "Locale already enabled: $l"
    else
        sudo sed -i "s/^#\s*\(${l//./\\.}\)/\1/" /etc/locale.gen
        log::ok "Enabled locale: $l"
    fi
done

log::info "Running locale-gen"
sudo locale-gen

log::info "Writing /etc/locale.conf (LANG=$LOCALE)"
echo "LANG=$LOCALE" | sudo tee /etc/locale.conf >/dev/null
log::ok "Locale configured"

log::info "Setting timezone: $TIMEZONE"
sudo ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime

if [[ $IS_WSL -eq 0 && $IS_VM -eq 0 ]]; then
    sudo hwclock --systohc || log::warn "hwclock --systohc failed"
    log::ok "Hardware clock synced"
fi

if [[ $IS_WSL -eq 1 ]]; then
    log::skip "WSL: skipping vconsole and X11 layout"
    exit 0
fi

log::info "Setting console keymap: $KEYMAP"
echo "KEYMAP=$KEYMAP" | sudo tee /etc/vconsole.conf >/dev/null
log::ok "Console keymap set"

log::info "Configuring X11/Wayland keyboard layout: $XKB_LAYOUT"
sudo install -d -m 755 /etc/X11/xorg.conf.d
sudo tee /etc/X11/xorg.conf.d/00-keyboard.conf >/dev/null <<EOF
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout"  "$XKB_LAYOUT"
    Option "XkbVariant" "$XKB_VARIANT"
    Option "XkbOptions" "$XKB_OPTIONS"
EndSection
EOF
log::ok "X11/Wayland layout: $XKB_LAYOUT (toggle: $XKB_OPTIONS)"
