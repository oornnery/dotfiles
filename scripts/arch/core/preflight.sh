#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

MIRROR_COUNTRY="${MIRROR_COUNTRY:-Brazil}"

require_root

log::step "Preflight checks"

log::info "Checking pacman lock"
if [[ -f /var/lib/pacman/db.lck ]]; then
    die "pacman db locked (/var/lib/pacman/db.lck). Remove if no pacman process."
fi
log::ok "pacman not locked"

log::info "Checking network"
if ping -c1 -W3 archlinux.org >/dev/null 2>&1; then
    log::ok "Network reachable"
else
    die "No network (cannot reach archlinux.org)."
fi

log::info "Checking disk space on /"
avail_kb="$(df -k --output=avail / | tail -1 | tr -d ' ')"
if [[ -n "$avail_kb" && "$avail_kb" -lt 5242880 ]]; then
    die "Less than 5GB free on /. Free up space first."
fi
log::ok "Disk space: $((avail_kb / 1024)) MB free on /"

log::step "Refreshing mirrors"

if ! pacman -Qq reflector >/dev/null 2>&1; then
    log::info "Installing reflector"
    sudo pacman -S --needed --noconfirm reflector
fi

if [[ ! -f /etc/pacman.d/mirrorlist ]]; then
    log::info "Seeding mirrorlist (country=$MIRROR_COUNTRY)"
    sudo reflector --country "$MIRROR_COUNTRY" --age 12 --protocol https \
        --sort rate --save /etc/pacman.d/mirrorlist
    log::ok "Mirrorlist seeded"
elif find /etc/pacman.d/mirrorlist -mmin +720 2>/dev/null | grep -q .; then
    snapshot /etc/pacman.d/mirrorlist
    log::info "Mirrorlist >12h old; refreshing"
    sudo reflector --country "$MIRROR_COUNTRY" --age 12 --protocol https \
        --sort rate --save /etc/pacman.d/mirrorlist
    log::ok "Mirrorlist refreshed"
else
    log::skip "Mirrorlist fresh (<12h)"
fi

log::step "Syncing pacman database"
sudo pacman -Sy --noconfirm

log::ok "Preflight completed"
