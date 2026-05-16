#!/usr/bin/env bash
# arch.sh — Interactive bootstrap launcher for scripts/arch/* modules.
#
# Usage:
#   ./arch.sh              → interactive menu (↑/↓ + space + enter)
#   ./arch.sh all          → run the "all" curated preset
#   ./arch.sh <section>    → run all modules in a section
#   ./arch.sh <path>       → run a single module (e.g. dev/zsh)
#   ./arch.sh --help       → this help

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[[ -f "$ROOT_DIR/arch.conf" ]] && source "$ROOT_DIR/arch.conf"
source "$ROOT_DIR/lib/common.sh"

# ─── Module catalog ─────────────────────────────────────────────────────────

declare -A MODULES_DESC=(
    # core/ — foundational system + hardware + security + package infra
    [core/preflight]="Preflight checks + mirror refresh"
    [core/pacman]="Configure pacman.conf (parallel, color, multilib)"
    [core/base-utils]="Base packages + microcode + fonts"
    [core/locale]="Locale, timezone, keymap, X11 layout"
    [core/user]="Create user, wheel sudoers, linger, SSH key"
    [core/core-services]="Enable core systemd services + journald tuning"
    [core/keyring]="gnome-keyring + libsecret + PAM auto-unlock"
    [core/snapper]="snapper btrfs snapshots (snap-pac)"
    [core/networkmanager]="NetworkManager (+ iwd backend optional)"
    [core/bluetooth]="Bluetooth (bluez + bluetui)"
    [core/pipewire]="PipeWire audio stack (+ wiremix TUI)"
    [core/storage]="USB / removable media automount (udisks2 + udiskie)"
    [core/monitoring]="lm_sensors + smartmontools + nvme-cli"
    [core/amd-gpu]="AMD GPU drivers"
    [core/power]="Power management (ppd | tlp | auto-cpufreq)"
    [core/zram]="zram swap"
    [core/notebook-vaio]="VAIO notebook tuning + iio-sensor-proxy + AMD pstate"
    [core/vm-guest]="VM guest tools (qemu/virtualbox/vmware/hyper-v)"
    [core/ufw]="UFW firewall (+ ufw-docker)"
    [core/paru]="paru (AUR helper) + optional AUR_PKGS"
    [core/flatpak]="Flatpak + Flathub remote"
    [core/wsl]="WSL /etc/wsl.conf setup"
    [core/fingerprint]="Fingerprint reader (fprintd + PAM sudo/login)"
    [core/windows-vm]="Windows 11 VM via Docker (dockur/windows)"
    [core/firefoxpwa]="Firefox PWA backend (web-app launcher)"

    # desktop/
    [desktop/gdm]="GDM display manager"
    [desktop/greetd]="greetd + tuigreet display manager"
    [desktop/sddm]="SDDM display manager"
    [desktop/ly]="ly TUI display manager"
    [desktop/gnome]="GNOME desktop"
    [desktop/hyprland]="Hyprland + utilities + stow hyprland dotfiles"

    # dev/ — tools, shell, TUI, dotfiles workflow
    [dev/tools]="Modern CLI / TUI tools (eza, bat, fzf, lazygit, gum, neovim, tmux, …)"
    [dev/zsh]="zsh + Oh My Zsh + plugins + stow zsh dotfiles"
    [dev/bash]="bash + bash-completion + stow bash dotfiles"
    [dev/tmux]="tmux + tpm + stow tmux dotfiles"
    [dev/vim]="vim + vim-plug + plugins + stow vim dotfiles"
    [dev/nvim]="neovim + stow nvim or nvim-lazy (per NVIM_DISTRO)"
    [dev/alacritty]="alacritty (+ optional ghostty) + stow alacritty + seed theme"
    [dev/git]="git + github-cli + git-delta + stow git config"
    [dev/vscodium]="VSCodium + marketplace + features (AUR) + share settings with Code"
    [dev/stow]="Stow all dotfiles packages in one shot"
    [dev/languages]="Language toolchains (python, rust, node, go, …)"
    [dev/docker]="Docker + Podman + lazydocker"
    [dev/llms]="AI tools (Claude Code, Codex, Ollama, LM Studio, RTK, .agents)"

    # game/
    [game/gaming]="Steam + wine + gamemode + mangohud"
)

# Section listings (module names without the section/ prefix).
# Resolved via `local -n list="SECTION_$section"` (nameref) — shellcheck can't trace.
# shellcheck disable=SC2034
SECTION_core=(
    preflight pacman base-utils locale user core-services keyring
    snapper
    networkmanager bluetooth pipewire storage monitoring
    amd-gpu power zram notebook-vaio vm-guest
    ufw
    paru flatpak
    wsl
    fingerprint windows-vm firefoxpwa
)
# shellcheck disable=SC2034
SECTION_desktop=(hyprland gdm greetd sddm ly gnome)
# shellcheck disable=SC2034
SECTION_dev=(
    tools
    zsh bash tmux vim nvim alacritty git vscodium
    languages docker llms
    stow
)
# shellcheck disable=SC2034
SECTION_game=(gaming)

# Sensible "all" preset for the user's hardware (VAIO + AMD + btrfs + GNOME/Hyprland).
# Skips luks (destrutivo), other display managers, and gaming.
# The "all" preset is composed at runtime from DESKTOPS + DISPLAY_MANAGER
# (both come from arch.conf). Anything not driven by those vars is static.
_compose_all_preset() {
    local -a base=(
        core/preflight
        core/pacman
        core/base-utils
        core/locale
        core/user
        core/core-services
        core/keyring
        core/networkmanager
        core/bluetooth
        core/pipewire
        core/storage
        core/monitoring
        core/amd-gpu
        core/notebook-vaio
        core/power
        core/zram
        core/snapper
    )
    local -a after=(
        dev/zsh
        dev/stow
        dev/tools
        dev/languages
        dev/docker
        core/paru
        core/ufw
    )
    local -a desktops=()
    for d in "${DESKTOPS[@]:-hyprland}"; do
        desktops+=("desktop/$d")
    done
    local dm="${DISPLAY_MANAGER:-gdm}"
    ALL_PRESET=("${base[@]}" "${desktops[@]}" "desktop/$dm" "${after[@]}")
}
_compose_all_preset

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

# ─── Interactive menu ───────────────────────────────────────────────────────

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

    [[ -z "$picks" ]] && return 0

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        if [[ "$line" == *"Back to main menu"* ]]; then
            return 0
        fi
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
            "core     — base, hw, security, AUR infra (28 modules)" \
            "desktop  — gdm, greetd, sddm, ly, gnome, hyprland" \
            "dev      — tools, zsh, stow, languages, docker, llms" \
            "game     — gaming" \
            "Quit")"

        case "$choice" in
            "Run 'all' preset"*) run_all ;;
            core*)    section_menu core ;;
            desktop*) section_menu desktop ;;
            dev*)     section_menu dev ;;
            game*)    section_menu game ;;
            Quit|"")  log::info "Bye."; exit 0 ;;
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
    core|desktop|dev|game)
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
                                (core | desktop | dev | game)
    ./arch.sh <section>/<mod> → run a single module (e.g. dev/zsh)
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
