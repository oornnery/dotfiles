#!/usr/bin/env bash
# arch/lib.sh — shared helpers for every arch/*.sh module.
# Source-only. Re-entrant safe (guarded by ARCH_LIB_LOADED).

[[ -n "${ARCH_LIB_LOADED:-}" ]] && return 0
ARCH_LIB_LOADED=1

# ---- defaults (env-overridable, also set by arch.sh) ----
: "${USER_NAME:=oornnery}"
: "${USER_SHELL:=/bin/zsh}"
: "${TIMEZONE:=America/Sao_Paulo}"
: "${LOCALE:=en_US.UTF-8}"
: "${KEYMAP:=us}"
: "${XKB_LAYOUT:=us,br}"
: "${XKB_VARIANT:=intl,abnt2}"
: "${XKB_OPTIONS:=grp:alt_shift_toggle}"
: "${MIRROR_COUNTRY:=Brazil}"
: "${LOG_FILE:=/var/log/arch-bootstrap.log}"
: "${BACKUP_DIR:=/var/backups/arch-bootstrap/$(date +%Y%m%d-%H%M%S)}"
: "${UNATTENDED:=0}"
: "${DRY_RUN:=0}"

PAC_FLAGS=()
[[ $UNATTENDED -eq 1 ]] && PAC_FLAGS=(--noconfirm)
export PAC_FLAGS

# ---- shared state arrays (orchestrator reads these in summary) ----
# shellcheck disable=SC2034  # read by arch.sh orchestrator after sourcing modules
SERVICES_ENABLED=()
# shellcheck disable=SC2034
PROMPTS_APPLIED=()
# shellcheck disable=SC2034
REBOOT_NEEDED=0
# shellcheck disable=SC2034
USE_PPD=1

# ---- colors ----
if [[ -t 1 ]] || [[ -n "${ARCH_FORCE_COLOR:-}" ]]; then
  C_RED=$'\033[31m'
  C_GRN=$'\033[32m'
  C_YEL=$'\033[33m'
  C_BLU=$'\033[34m'
  C_MAG=$'\033[35m'
  C_CYN=$'\033[36m'
  C_GRY=$'\033[90m'
  C_BOLD=$'\033[1m'
  C_DIM=$'\033[2m'
  C_RST=$'\033[0m'
else
  C_RED='' C_GRN='' C_YEL='' C_BLU='' C_MAG='' C_CYN='' C_GRY='' C_BOLD='' C_DIM='' C_RST=''
fi

# ---- logging ----
# Each log::* helper writes colored text to the terminal AND a plain-text
# timestamped line to $LOG_FILE (if set).
STEP=0
_log_file_append() {
  [[ -n "${LOG_FILE:-}" ]] || return 0
  # Skip silently if we can't write to the log (e.g. running without sudo for testing).
  [[ -w "$LOG_FILE" ]] || { [[ ! -e "$LOG_FILE" ]] && [[ -w "$(dirname "$LOG_FILE")" ]] || return 0; }
  printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" >> "$LOG_FILE" 2>/dev/null || true
}
log::info()  {
  printf '%s==>%s %s\n' "$C_GRN$C_BOLD" "$C_RST" "$*"
  _log_file_append "INFO  $*"
}
log::ok()    {
  printf '%s✓%s %s%s%s\n' "$C_GRN$C_BOLD" "$C_RST" "$C_GRN" "$*" "$C_RST"
  _log_file_append "OK    $*"
}
log::warn()  {
  printf '%s⚠ WARNING:%s %s%s%s\n' "$C_YEL$C_BOLD" "$C_RST" "$C_YEL" "$*" "$C_RST" >&2
  _log_file_append "WARN  $*"
}
log::err()   {
  printf '%s✗ ERROR:%s %s%s%s\n' "$C_RED$C_BOLD" "$C_RST" "$C_RED" "$*" "$C_RST" >&2
  _log_file_append "ERROR $*"
}
log::step()  {
  STEP=$((STEP+1))
  printf '\n%s┌─[%d]─%s %s%s%s\n' \
    "$C_BLU$C_BOLD" "$STEP" "$C_RST" \
    "$C_CYN$C_BOLD" "$*" "$C_RST"
  _log_file_append "STEP $STEP $*"
}
log::section() {
  printf '\n%s═══ %s ═══%s\n' "$C_MAG$C_BOLD" "$*" "$C_RST"
  _log_file_append ">>>>> $* <<<<<"
}
log::dim() {
  printf '%s  %s%s\n' "$C_DIM" "$*" "$C_RST"
  _log_file_append "      $*"
}

# ---- interaction ----
# _ask <default-yes-or-no> <question>
#   - shows the default in CAPS in the [y/N] or [Y/n] hint
#   - empty input → uses the default
#   - "y"/"yes"/"n"/"no" (case-insensitive) → that choice
#   - anything else → error message, re-prompt
#   - UNATTENDED=1 → returns the default
_ask() {
  local default="$1" prompt="$2"
  local hint yn

  if [[ "$default" == "y" ]]; then
    hint="${C_GRY}[${C_RST}${C_GRN}${C_BOLD}Y${C_RST}${C_GRY}/${C_DIM}n${C_RST}${C_GRY}]${C_RST}"
    [[ $UNATTENDED -eq 1 ]] && return 0
  else
    hint="${C_GRY}[${C_RST}${C_DIM}y${C_RST}${C_GRY}/${C_RST}${C_RED}${C_BOLD}N${C_RST}${C_GRY}]${C_RST}"
    [[ $UNATTENDED -eq 1 ]] && return 1
  fi

  while true; do
    read -rp "$(printf '%s?%s %s%s%s %s%s%s ' \
      "$C_CYN$C_BOLD" "$C_RST" \
      "$C_CYN" "$prompt" "$C_RST" \
      "$hint" \
      "$C_DIM" "›$C_RST")" yn || true
    case "${yn,,}" in
      "")        [[ "$default" == "y" ]] && return 0 || return 1 ;;
      y|yes|s|sim) return 0 ;;
      n|no|nao|não) return 1 ;;
      *) log::err "Resposta inválida: '$yn' (use y/yes/n/no, ou Enter para o default)." ;;
    esac
  done
}

# ask "Question?" → default NO. Returns 0 (yes) or 1 (no).
ask() { _ask n "$1"; }

# ask_default_yes "Question?" → default YES.
ask_default_yes() { _ask y "$1"; }

# ---- execution ----
run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '%s[dry-run]%s %s\n' "$C_YEL" "$C_RST" "$*"
    return 0
  fi
  "$@"
}

as_user() { sudo -u "$USER_NAME" -H "$@"; }

# ---- backup + template ----
snapshot() {
  local f="$1"
  [[ -e "$f" ]] || return 0
  mkdir -p "$BACKUP_DIR"
  cp -a --parents "$f" "$BACKUP_DIR/" 2>/dev/null || true
}

# install_template <src-rel-to-dotfiles> <dest> [sed-expr]
install_template() {
  local src="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}/$1"
  local dest="$2" sed_expr="${3:-}"
  if [[ ! -f "$src" ]]; then
    log::warn "Template missing: $src"
    return 1
  fi
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '%s[dry-run]%s install template %s -> %s\n' "$C_YEL" "$C_RST" "$src" "$dest"
    return 0
  fi
  install -d -m 755 "$(dirname "$dest")"
  if [[ -n "$sed_expr" ]]; then
    sed "$sed_expr" "$src" | install -m 644 /dev/stdin "$dest"
  else
    install -m 644 "$src" "$dest"
  fi
}

# Append kernel cmdline params to systemd-boot entries or GRUB (idempotent).
# $1 = params to append; $2 = match token for idempotency check.
patch_boot_param() {
  local params="$1" match="$2"
  if [[ -d /boot/loader/entries ]]; then
    local f
    for f in /boot/loader/entries/*.conf; do
      [[ -f "$f" ]] || continue
      grep -q "$match" "$f" && continue
      snapshot "$f"
      run sed -i "/^options/ s/\$/ $params/" "$f"
    done
  elif [[ -f /etc/default/grub ]]; then
    if ! grep -q "$match" /etc/default/grub; then
      snapshot /etc/default/grub
      run sed -i "s|GRUB_CMDLINE_LINUX_DEFAULT=\"\\(.*\\)\"|GRUB_CMDLINE_LINUX_DEFAULT=\"\\1 $params\"|" /etc/default/grub
      run grub-mkconfig -o /boot/grub/grub.cfg
    fi
  else
    log::warn "Unknown bootloader. Add manually to kernel cmdline: $params"
  fi
}

# Replace cryptdevice= (encrypt hook) with rd.luks.name= (sd-encrypt hook).
# $1 = LUKS UUID; $2 = mapper name (e.g. root)
migrate_boot_cryptdevice() {
  local uuid="$1" name="$2"
  local to="rd.luks.name=${uuid}=${name} root=/dev/mapper/${name}"
  if [[ -d /boot/loader/entries ]]; then
    local f
    for f in /boot/loader/entries/*.conf; do
      [[ -f "$f" ]] || continue
      grep -q "rd.luks.name=${uuid}" "$f" && continue
      grep -q "cryptdevice=UUID=${uuid}" "$f" || continue
      snapshot "$f"
      run sed -i "s|cryptdevice=UUID=${uuid}:${name}[^ ]*|${to}|" "$f"
      run sed -i "s|root=/dev/mapper/${name}[[:space:]]*root=/dev/mapper/${name}|root=/dev/mapper/${name}|" "$f"
    done
  elif [[ -f /etc/default/grub ]]; then
    if grep -q "cryptdevice=UUID=${uuid}" /etc/default/grub \
       && ! grep -q "rd.luks.name=${uuid}" /etc/default/grub; then
      snapshot /etc/default/grub
      run sed -i "s|cryptdevice=UUID=${uuid}:${name}|${to}|" /etc/default/grub
      run grub-mkconfig -o /boot/grub/grub.cfg
    fi
  fi
}

# ---- LUKS detection ----
# Sets LUKS_ROOT_UUID (UUID of LUKS container) and LUKS_ROOT_NAME (mapper name).
# Returns 0 if LUKS root detected, 1 otherwise.
has_luks_root() {
  # /dev/mapper/<name> mounted at /
  local root_src
  root_src="$(findmnt -no SOURCE / 2>/dev/null || echo '')"
  [[ "$root_src" == /dev/mapper/* ]] || return 1
  LUKS_ROOT_NAME="${root_src##*/}"
  local backing
  backing="$(cryptsetup status "$LUKS_ROOT_NAME" 2>/dev/null | awk '/device:/ {print $2}')"
  [[ -n "$backing" ]] || return 1
  LUKS_ROOT_UUID="$(blkid -s UUID -o value "$backing" 2>/dev/null || echo '')"
  [[ -n "$LUKS_ROOT_UUID" ]] || return 1
  export LUKS_ROOT_UUID LUKS_ROOT_NAME
  return 0
}

# ---- pkg helpers ----
# pkg_installed <pkg>  → 0 if installed
pkg_installed() { pacman -Qq "$1" >/dev/null 2>&1; }

# svc_enabled <unit>   → 0 if enabled
svc_enabled() { systemctl is-enabled --quiet "$1" 2>/dev/null; }

# pacman_install pkg1 pkg2 ...
pacman_install() {
  run pacman -S --needed "${PAC_FLAGS[@]}" "$@"
}

# multilib_enabled → 0 if [multilib] is uncommented in pacman.conf
multilib_enabled() {
  grep -q '^\[multilib\]' /etc/pacman.conf
}

# ---- error trap (installed by orchestrator) ----
arch_lib::install_trap() {
  # shellcheck disable=SC2154  # rc is assigned at trap time
  trap 'rc=$?; log::err "Failed at line $LINENO (exit $rc). Last cmd: $BASH_COMMAND. Log: $LOG_FILE"; exit $rc' ERR
}

# ---- exports ----
export USER_NAME USER_SHELL TIMEZONE LOCALE KEYMAP XKB_LAYOUT XKB_VARIANT XKB_OPTIONS
export MIRROR_COUNTRY LOG_FILE BACKUP_DIR UNATTENDED DRY_RUN
export REBOOT_NEEDED USE_PPD
