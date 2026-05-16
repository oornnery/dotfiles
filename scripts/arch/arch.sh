#!/usr/bin/env bash
# arch.sh — Interactive bootstrap launcher for scripts/arch/* modules.
#
# Usage:
#   ./arch.sh              → interactive menu (↑/↓ + space + enter)
#   ./arch.sh all          → run the "all" curated preset
#   ./arch.sh <section>    → run all modules in a section
#   ./arch.sh <path>       → run a single module (e.g. system/zsh)
#   ./arch.sh --help       → this help

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[[ -f "$ROOT_DIR/arch.conf" ]] && source "$ROOT_DIR/arch.conf"
source "$ROOT_DIR/lib/common.sh"

# ─── Module catalog ─────────────────────────────────────────────────────────

declare -A MODULES_DESC=(
    [system/preflight]="Preflight checks + mirror refresh"
    [system/pacman]="Configure pacman.conf (parallel, color, multilib)"
    [system/base-utils]="Base packages + microcode + fonts"
    [system/locale]="Locale, timezone, keymap, X11 layout"
    [system/user]="Create user, wheel sudoers, linger, SSH key"
    [system/core-services]="Enable core systemd services + journald tuning"
    [system/zsh]="zsh + Oh My Zsh + plugins + stow zsh dotfiles"
    [system/keyring]="gnome-keyring + libsecret + PAM auto-unlock"
    [system/snapper]="snapper btrfs snapshots (snap-pac)"
    [system/luks]="Migrate to systemd-cryptsetup TUI LUKS prompt"
    [system/plymouth]="Boot splash"
    [system/stow]="Symlink dotfiles via GNU stow"

    [hardware/networkmanager]="NetworkManager (+ iwd backend optional)"
    [hardware/bluetooth]="Bluetooth (bluez + bluetui)"
    [hardware/pipewire]="PipeWire audio stack (+ wiremix TUI)"
    [hardware/amd-gpu]="AMD GPU drivers"
    [hardware/nvidia-gpu]="NVIDIA drivers (nouveau + optional proprietary)"
    [hardware/intel-gpu]="Intel GPU drivers"
    [hardware/power]="Power management (ppd | tlp | auto-cpufreq)"
    [hardware/zram]="zram swap"
    [hardware/notebook-vaio]="VAIO notebook tuning + AMD pstate"
    [hardware/vm-guest]="VM guest tools (qemu/virtualbox/vmware/hyper-v)"
    [hardware/printing]="CUPS printing"

    [desktop/gdm]="GDM display manager"
    [desktop/greetd]="greetd + tuigreet display manager"
    [desktop/sddm]="SDDM display manager"
    [desktop/ly]="ly TUI display manager"
    [desktop/gnome]="GNOME desktop"
    [desktop/hyprland]="Hyprland + utilities + stow hyprland dotfiles"

    [dev/cli-tools]="Modern CLI replacements"
    [dev/languages]="Language toolchains (python, rust, node, go, ...)"
    [dev/docker]="Docker + Podman + lazydocker"
    [dev/llms]="AI tools (Claude Code, Codex, Ollama, LM Studio)"

    [aur/paru]="paru (AUR helper) + optional AUR_PKGS"
    [aur/chaotic-aur]="Chaotic-AUR repository"

    [apps/flatpak]="Flatpak + Flathub remote"
    [apps/gaming]="Steam + wine + gamemode + mangohud"

    [security/ufw]="UFW firewall (+ ufw-docker)"
    [security/hardening]="AppArmor + usbguard"

    [wsl/base]="WSL /etc/wsl.conf setup"
)

SECTION_system=(preflight pacman base-utils locale user core-services zsh keyring snapper plymouth stow)
SECTION_hardware=(networkmanager bluetooth pipewire amd-gpu nvidia-gpu intel-gpu power zram notebook-vaio vm-guest printing)
SECTION_desktop=(hyprland gdm greetd sddm ly gnome)
SECTION_dev=(cli-tools languages docker llms)
SECTION_aur=(paru chaotic-aur)
SECTION_apps=(flatpak gaming)
SECTION_security=(ufw hardening)
SECTION_wsl=(base)

SECTIONS=(system hardware desktop dev aur apps security wsl)

ALL_PRESET=(
    system/preflight
    system/pacman
    system/base-utils
    system/locale
    system/user
    system/core-services
    system/zsh
    system/keyring
    hardware/networkmanager
    hardware/bluetooth
    hardware/pipewire
    hardware/power
    hardware/zram
    desktop/hyprland
    dev/cli-tools
    dev/languages
    dev/docker
    aur/paru
    security/ufw
)

# ─── Runners ────────────────────────────────────────────────────────────────

run_module() {
    local mod="$1"
    local path="$ROOT_DIR/$mod.sh"
    if [[ ! -f "$path" ]]; then
        log::error "Module not found: $mod"
        return 1
    fi
    log::step "Running: $mod"
    bash "$path"
}

run_section() {
    local section="$1"
    local -n list="SECTION_$section" 2>/dev/null || {
        log::error "Unknown section: $section"; return 1; }
    for mod in "${list[@]}"; do
        run_module "$section/$mod" || log::warn "$section/$mod failed (continuing)"
    done
}

run_all() {
    log::banner "Bootstrap" "Running 'all' preset (${#ALL_PRESET[@]} modules)"
    for mod in "${ALL_PRESET[@]}"; do
        run_module "$mod" || log::warn "$mod failed (continuing)"
    done
    log::ok "Bootstrap completed"
}

# ─── Interactive menu (uses rich-log ask::select / ask::multi) ──────────────

section_menu() {
    local section="$1"
    local -n list="SECTION_$section"

    local labels=()
    for mod in "${list[@]}"; do
        local key="$section/$mod"
        local desc="${MODULES_DESC[$key]:-}"
        labels+=("$mod — $desc")
    done
    labels+=("⟪ Run ALL in this section ⟫")
    labels+=("⟪ Back to main menu ⟫")

    local picks
    picks="$(ask::multi "Pick modules to run in [$section]" "${labels[@]}" || true)"

    # Empty pick (cancel or nothing toggled) → return to main menu.
    [[ -z "$picks" ]] && return 0

    # If "Back" was selected, return regardless of other picks.
    if grep -q "Back to main menu" <<< "$picks"; then
        return 0
    fi

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        if [[ "$line" == *"Run ALL in this section"* ]]; then
            run_section "$section"
            return 0
        fi
        local mod="${line%% — *}"
        run_module "$section/$mod" || log::warn "$section/$mod failed (continuing)"
    done <<< "$picks"
}

main_menu() {
    local host
    host="${HOSTNAME:-$(cat /etc/hostname 2>/dev/null || echo localhost)}"
    local user="${USER_NAME:-${SUDO_USER:-$USER}}"

    while true; do
        log::banner "scripts/arch" "Bootstrap menu — $user@$host"

        local choice
        choice="$(ask::select "What to run?" \
            "Run 'all' preset (recommended initial setup)" \
            "system    — base, locale, user, zsh, keyring, snapper" \
            "hardware  — net, bluetooth, audio, gpu, power, zram, vm-guest" \
            "desktop   — hyprland, gnome, gdm/greetd/sddm/ly" \
            "dev       — cli-tools, languages, docker, llms" \
            "aur       — paru, chaotic-aur" \
            "apps      — flatpak, gaming" \
            "security  — ufw, hardening" \
            "wsl       — wsl.conf" \
            "Quit")"

        case "$choice" in
            "Run 'all' preset"*) run_all ;;
            system*)   section_menu system ;;
            hardware*) section_menu hardware ;;
            desktop*)  section_menu desktop ;;
            dev*)      section_menu dev ;;
            aur*)      section_menu aur ;;
            apps*)     section_menu apps ;;
            security*) section_menu security ;;
            wsl*)      section_menu wsl ;;
            Quit|"")   log::info "Bye."; exit 0 ;;
        esac
    done
}

# ─── Entry point ────────────────────────────────────────────────────────────

case "${1:-menu}" in
    menu)
        main_menu
        ;;
    all)
        run_all
        ;;
    system|hardware|desktop|dev|aur|apps|security|wsl)
        run_section "$1"
        ;;
    */*)
        run_module "$1"
        ;;
    -h|--help|help)
        cat <<EOF
arch.sh — interactive bootstrap launcher

USAGE:
    ./arch.sh                 → interactive menu (↑/↓ + space + enter)
    ./arch.sh all             → run the curated "all" preset
    ./arch.sh <section>       → run all modules in a section
                                (system | hardware | desktop | dev | aur | apps | security | wsl)
    ./arch.sh <section>/<mod> → run a single module (e.g. system/zsh)
    ./arch.sh -h              → this help

CONFIG:
    Defaults come from $ROOT_DIR/arch.conf. Edit it once, then re-run any module.
EOF
        ;;
    *)
        log::error "Unknown command: $1"
        log::info "Try: ./arch.sh --help"
        exit 1
        ;;
esac
