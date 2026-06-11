#!/usr/bin/env bash
# mdns.sh — Avahi + nss-mdns para descobrir dispositivos .local na rede
# (printers, NAS, AirPlay, etc.). Edita /etc/nsswitch.conf pra incluir
# mdns_minimal antes do resolve dns.

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/detect.sh"

require_root
detect::system

log::banner "Core" "mDNS / Avahi"

if [[ $IS_WSL -eq 1 ]]; then
    log::skip "WSL: mDNS via Windows host"
    exit 0
fi

log::info "Installing avahi + nss-mdns"
sudo pacman -S --needed --noconfirm avahi nss-mdns

# Edit /etc/nsswitch.conf: ensure `mdns_minimal [NOTFOUND=return]` is
# present in the `hosts:` line, before `resolve` and `dns`.
NSSWITCH=/etc/nsswitch.conf
if grep -qE '^hosts:.*mdns_minimal' "$NSSWITCH"; then
    log::skip "/etc/nsswitch.conf já tem mdns_minimal"
else
    log::info "Patching /etc/nsswitch.conf (backup → .bak)"
    sudo cp "$NSSWITCH" "${NSSWITCH}.bak.$(date +%Y%m%d%H%M%S)"
    # Insert 'mdns_minimal [NOTFOUND=return]' before 'resolve' (or 'dns'
    # if resolve not present). sed-friendly.
    sudo sed -i -E \
        's|^(hosts:[[:space:]]+.*)\<(resolve|dns)\>|\1mdns_minimal [NOTFOUND=return] \2|' \
        "$NSSWITCH"
    log::ok "nsswitch.conf patched"
fi

log::info "Enabling avahi-daemon.service"
sudo systemctl enable --now avahi-daemon.service

log::ok "mDNS ativo — teste com 'ping <host>.local'"
