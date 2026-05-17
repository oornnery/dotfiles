#!/usr/bin/env bash
# common.sh — self-contained TUI + execution helpers for scripts/arch/*.
#
# API:
#   log::info / log::ok / log::warn / log::error / log::skip / log::step
#   log::banner "Section" "Subtitle"
#   ask::confirm  "?"                      → 0/1, ←/→ Yes/No, y/n, ESC=no
#   ask::input    "?" [regex] [err]        → echoes text, validates with regex
#   ask::select   "?" a b c …              → echoes pick, ↑/↓ + Enter
#   ask::multi    "?" a b c …              → echoes one per line, ↑/↓ + Space + Enter
#                                            (type to filter, ^A all, ^D none)
#   die / require_root / as_user / snapshot
#
# Env knobs (set before sourcing):
#   LOG_FILE=/path      append plain log entries (default: lib/arch.log)
#   NO_COLOR=1          disable ANSI colors
#   FORCE_COLOR=1       force colors even on non-TTY
#   FORCE_UNICODE=1     force unicode glyphs even on TERM=linux

[[ "${_COMMON_LOADED:-0}" == "1" ]] && return 0
_COMMON_LOADED=1

set -euo pipefail
shopt -s inherit_errexit nullglob 2>/dev/null || true

_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${LOG_FILE:-$_LIB_DIR/arch.log}"
PAD="${PAD:-  }"

mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
touch "$LOG_FILE" 2>/dev/null || true

# ─── Capability detection ───────────────────────────────────────────────────

USE_COLOR=1
[[ -n "${NO_COLOR:-}" ]]        && USE_COLOR=0
[[ ! -t 1 ]]                    && USE_COLOR=0
[[ "${TERM:-}" == "dumb" ]]     && USE_COLOR=0
[[ "${FORCE_COLOR:-0}"   == "1" ]] && USE_COLOR=1

USE_UNICODE=1
[[ "${TERM:-}" == "linux" ]]      && USE_UNICODE=0
[[ "${FORCE_UNICODE:-0}" == "1" ]] && USE_UNICODE=1

# ─── Palette ────────────────────────────────────────────────────────────────

if (( USE_COLOR )); then
    C_RESET=$'\033[0m'
    C_DIM=$'\033[2m'
    C_BOLD=$'\033[1m'

    C_FG=$'\033[38;5;252m'
    C_MUTED=$'\033[38;5;243m'
    C_PRIMARY=$'\033[38;5;212m'     # pink
    C_ACCENT=$'\033[38;5;86m'       # cyan
    C_SUCCESS=$'\033[38;5;114m'     # green
    C_WARN=$'\033[38;5;220m'        # yellow
    C_ERROR=$'\033[38;5;203m'       # red
    C_INFO=$'\033[38;5;111m'        # blue

    BG_INFO=$'\033[48;5;111m\033[38;5;235m'
    BG_OK=$'\033[48;5;114m\033[38;5;235m'
    BG_WARN=$'\033[48;5;220m\033[38;5;235m'
    BG_ERROR=$'\033[48;5;203m\033[38;5;231m'
    BG_SKIP=$'\033[48;5;240m\033[38;5;252m'
    BG_STEP=$'\033[48;5;212m\033[38;5;235m'

    SEL_BG=$'\033[48;5;237m\033[38;5;231m'
else
    C_RESET='' C_DIM='' C_BOLD=''
    C_FG='' C_MUTED='' C_PRIMARY='' C_ACCENT=''
    C_SUCCESS='' C_WARN='' C_ERROR='' C_INFO=''
    BG_INFO='' BG_OK='' BG_WARN='' BG_ERROR='' BG_SKIP='' BG_STEP=''
    SEL_BG=''
fi

# ─── Glyphs ─────────────────────────────────────────────────────────────────

if (( USE_UNICODE )); then
    G_CHEVRON='❯' G_CURSOR='❯' G_QMARK='?' G_ARROW='↳'
    G_CHECK='✓'   G_CROSS='✗'
    G_CHECKBOX_OFF='[ ]' G_CHECKBOX_ON='[x]'
    G_DBL_TL='╔' G_DBL_TR='╗' G_DBL_BL='╚' G_DBL_BR='╝' G_DBL_H='═' G_DBL_V='║'
else
    G_CHEVRON='>' G_CURSOR='>' G_QMARK='?' G_ARROW='>'
    G_CHECK='+'   G_CROSS='x'
    G_CHECKBOX_OFF='[ ]' G_CHECKBOX_ON='[x]'
    G_DBL_TL='+' G_DBL_TR='+' G_DBL_BL='+' G_DBL_BR='+' G_DBL_H='=' G_DBL_V='|'
fi

# ─── Terminal state safeguard ───────────────────────────────────────────────
# Helpers that hide the cursor / reserve lines must bump _TUI_RESERVED so a
# Ctrl+C trap can move past the rendered zone and restore the cursor.

_TUI_RESERVED=0
_TUI_HIDDEN=0

_tui_begin() {
    _TUI_RESERVED="${1:-0}"
    printf '\033[?25l' >/dev/tty 2>/dev/null || true
    _TUI_HIDDEN=1
}

_tui_end() {
    if (( _TUI_RESERVED > 0 )); then
        printf '\033[%dB' "$_TUI_RESERVED" >/dev/tty 2>/dev/null || true
        _TUI_RESERVED=0
    fi
    if (( _TUI_HIDDEN )); then
        printf '\033[?25h' >/dev/tty 2>/dev/null || true
        _TUI_HIDDEN=0
    fi
}

_tui_abort() {
    _tui_end
    printf '\n' >/dev/tty 2>/dev/null || true
    exit 130
}

trap '_tui_end' EXIT
trap '_tui_abort' INT TERM

_term_width() {
    local w
    w=$(tput cols 2>/dev/null || echo 80)
    [[ "$w" =~ ^[0-9]+$ ]] || w=80
    printf '%s' "$w"
}

# ─── Logging ────────────────────────────────────────────────────────────────

_logfile() {
    printf '[%s] %s\n' "$(date +'%H:%M:%S')" "$*" >> "$LOG_FILE" 2>/dev/null || true
}

_badge() {
    local bg="$1" tag="$2"; shift 2
    _logfile "$tag $*"
    printf '%s%s %-5s %s %s\n' "$PAD" "$bg" "$tag" "$C_RESET" "$*"
}

log::info()  { _badge "$BG_INFO"  "INFO"  "$@"; }
log::ok()    { _badge "$BG_OK"    "OK"    "$@"; }
log::warn()  { _badge "$BG_WARN"  "WARN"  "$@" >&2; }
log::error() { _badge "$BG_ERROR" "ERROR" "$@" >&2; }
log::skip()  { _badge "$BG_SKIP"  "SKIP"  "$@"; }
log::step()  { printf '\n'; _badge "$BG_STEP" "STEP" "$@"; }

# log::banner "Title" "subtitle?"
log::banner() {
    local title="$1" subtitle="${2:-}"
    local cols; cols=$(_term_width)
    local pad_len=${#PAD}
    local width=$(( cols - 2 * pad_len ))
    (( width > 70 )) && width=70
    local min=$(( ${#title} > ${#subtitle} ? ${#title} : ${#subtitle} ))
    (( width < min + 6 )) && width=$(( min + 6 ))

    local line
    printf -v line '%*s' "$width" ''; line="${line// /$G_DBL_H}"

    _center() {
        local txt="$1" len=${#1} w=$2
        local lp=$(( (w - len) / 2 ))
        local rp=$(( w - len - lp ))
        printf '%*s%s%*s' "$lp" '' "$txt" "$rp" ''
    }

    local title_line; title_line=$(_center "$title" "$width")
    printf '\n%s%s%s%s%s%s\n' "$PAD" "$C_PRIMARY" "$G_DBL_TL" "$line" "$G_DBL_TR" "$C_RESET"
    printf '%s%s%s%s%s%s%s%s%s%s\n' \
        "$PAD" "$C_PRIMARY" "$G_DBL_V" "$C_RESET" \
        "$C_BOLD$C_PRIMARY" "$title_line" "$C_RESET" \
        "$C_PRIMARY" "$G_DBL_V" "$C_RESET"
    if [[ -n "$subtitle" ]]; then
        local sub_line; sub_line=$(_center "$subtitle" "$width")
        printf '%s%s%s%s%s%s%s%s%s%s\n' \
            "$PAD" "$C_PRIMARY" "$G_DBL_V" "$C_RESET" \
            "$C_MUTED" "$sub_line" "$C_RESET" \
            "$C_PRIMARY" "$G_DBL_V" "$C_RESET"
    fi
    printf '%s%s%s%s%s%s\n\n' "$PAD" "$C_PRIMARY" "$G_DBL_BL" "$line" "$G_DBL_BR" "$C_RESET"
    _logfile "BANNER $title${subtitle:+ — $subtitle}"
}

# ─── Prompts ────────────────────────────────────────────────────────────────

# ask::confirm "question?"  → returns 0 on yes, 1 on no
ask::confirm() {
    local prompt="$*" choice=0 key seq
    printf '\n%s%s%s%s %s%s%s\n\n' \
        "$PAD" "$C_PRIMARY" "$G_QMARK" "$C_RESET" \
        "$C_BOLD" "$prompt" "$C_RESET" >/dev/tty
    _tui_begin 0

    local btn_blur="${BG_SKIP:-}"
    _render() {
        local y_style="$btn_blur" n_style="$btn_blur"
        (( choice == 0 )) && y_style="$BG_OK$C_BOLD"
        (( choice == 1 )) && n_style="$BG_ERROR$C_BOLD"
        printf '\r\033[K%s%s  Yes  %s   %s  No  %s' \
            "$PAD" "$y_style" "$C_RESET" "$n_style" "$C_RESET" >/dev/tty
    }
    _render

    while IFS= read -rsn1 key </dev/tty; do
        case "$key" in
            $'\033')
                read -rsn2 -t 0.01 seq </dev/tty || seq=""
                case "$seq" in
                    '[D'|'[A') choice=0 ;;
                    '[C'|'[B') choice=1 ;;
                    '')        choice=1; break ;;
                esac ;;
            y|Y) choice=0; break ;;
            n|N) choice=1; break ;;
            '')  break ;;
        esac
        _render
    done

    _render
    printf '\n\n' >/dev/tty
    _tui_end
    _logfile "CONFIRM $prompt → $((1 - choice))"
    return "$choice"
}

# ask::input "prompt" [regex] [error_message]   → echoes the response
ask::input() {
    local prompt="$1" pattern="${2:-}" err="${3:-Invalid input.}"
    local response
    printf '\n' >/dev/tty
    while true; do
        printf '%s%s%s%s %s%s%s\n' "$PAD" "$C_PRIMARY" "$G_QMARK" "$C_RESET" \
            "$C_BOLD" "$prompt" "$C_RESET" >/dev/tty
        printf '%s%s%s%s ' "$PAD" "$C_PRIMARY" "$G_CHEVRON" "$C_RESET" >/dev/tty
        IFS= read -r response </dev/tty
        if [[ -z "$pattern" ]] || [[ "$response" =~ $pattern ]]; then
            _logfile "INPUT $prompt → $response"
            printf '\n' >/dev/tty
            printf '%s\n' "$response"
            return 0
        fi
        printf '%s%s%s%s %s\n\n' "$PAD" "$C_ERROR" "$G_CROSS" "$C_RESET" "$err" >/dev/tty
    done
}

# ask::select "prompt" opt1 opt2 …   → echoes selected option
ask::select() {
    local prompt="$1"; shift
    local options=("$@")
    local n=${#options[@]}
    (( n == 0 )) && { log::error "ask::select: no options"; return 1; }

    printf '\n%s%s%s%s %s%s%s\n\n' \
        "$PAD" "$C_PRIMARY" "$G_QMARK" "$C_RESET" \
        "$C_BOLD" "$prompt" "$C_RESET" >/dev/tty

    # Reserve n lines (the option list).
    local i
    for (( i = 0; i < n; i++ )); do printf '\n' >/dev/tty; done
    printf '\033[%dA' "$n" >/dev/tty
    _tui_begin "$n"

    local cursor=0 key seq

    _render() {
        for i in "${!options[@]}"; do
            if (( i == cursor )); then
                printf '\r\033[K%s%s%s%s %s %s %s\n' \
                    "$PAD" "$C_PRIMARY" "$G_CURSOR" "$C_RESET" \
                    "$SEL_BG" "${options[i]}" "$C_RESET" >/dev/tty
            else
                printf '\r\033[K%s  %s%s%s\n' \
                    "$PAD" "$C_FG" "${options[i]}" "$C_RESET" >/dev/tty
            fi
        done
        printf '\033[%dA' "$n" >/dev/tty
    }
    _render

    while IFS= read -rsn1 key </dev/tty; do
        case "$key" in
            $'\033')
                read -rsn2 -t 0.01 seq </dev/tty || seq=""
                case "$seq" in
                    '[A') (( cursor > 0 ))     && cursor=$(( cursor - 1 )) ;;
                    '[B') (( cursor < n - 1 )) && cursor=$(( cursor + 1 )) ;;
                esac ;;
            k) (( cursor > 0 ))     && cursor=$(( cursor - 1 )) ;;
            j) (( cursor < n - 1 )) && cursor=$(( cursor + 1 )) ;;
            '') break ;;
        esac
        _render
    done

    _tui_end
    printf '\n' >/dev/tty
    _logfile "SELECT $prompt → ${options[cursor]}"
    printf '%s\n' "${options[cursor]}"
}

# ask::multi "prompt" opt1 opt2 …   → echoes selected options one per line.
# Controls: ↑/↓ nav, Space toggle, Ctrl+A all, Ctrl+D none, type to filter, Enter confirm.
ask::multi() {
    local prompt="$1"; shift
    local options=("$@")
    local n=${#options[@]}
    (( n == 0 )) && { log::error "ask::multi: no options"; return 1; }

    local selected=() i
    for (( i = 0; i < n; i++ )); do selected[i]=0; done

    printf '\n%s%s%s%s %s%s%s\n'    "$PAD" "$C_PRIMARY" "$G_QMARK" "$C_RESET" "$C_BOLD" "$prompt" "$C_RESET" >/dev/tty
    printf '%s%stype to filter · ↑/↓ nav · space toggle · ^A/^D all/none · enter confirm%s\n' \
        "$PAD" "$C_MUTED" "$C_RESET" >/dev/tty

    local reserved=$(( n + 2 ))
    for (( i = 0; i < reserved; i++ )); do printf '\n' >/dev/tty; done
    printf '\033[%dA' "$reserved" >/dev/tty
    _tui_begin "$reserved"

    local query="" cursor=0 key seq idx_sel
    local filtered=()

    _compute() {
        filtered=()
        local idx
        for idx in "${!options[@]}"; do
            if [[ -z "$query" ]] || [[ "${options[idx],,}" == *"${query,,}"* ]]; then
                filtered+=("$idx")
            fi
        done
        local nf=${#filtered[@]}
        if (( nf == 0 )); then cursor=0
        elif (( cursor >= nf )); then cursor=$(( nf - 1 ))
        fi
    }

    _render() {
        _compute
        printf '\r\033[K%s%s/%s %s%s_%s\n' "$PAD" "$C_ACCENT" "$C_RESET" "$query" "$C_DIM" "$C_RESET" >/dev/tty
        printf '\r\033[K\n' >/dev/tty
        local nf=${#filtered[@]} j idx mark color
        for (( j = 0; j < n; j++ )); do
            if (( j < nf )); then
                idx="${filtered[j]}"
                if (( selected[idx] == 1 )); then mark="$G_CHECKBOX_ON"
                else mark="$G_CHECKBOX_OFF"; fi
                if (( j == cursor )); then
                    printf '\r\033[K%s%s%s%s %s %s %s %s\n' \
                        "$PAD" "$C_PRIMARY" "$G_CURSOR" "$C_RESET" \
                        "$SEL_BG" "$mark" "${options[idx]}" "$C_RESET" >/dev/tty
                else
                    if (( selected[idx] == 1 )); then color="$C_SUCCESS"
                    else color="$C_FG"; fi
                    printf '\r\033[K%s  %s%s %s%s\n' "$PAD" "$color" "$mark" "${options[idx]}" "$C_RESET" >/dev/tty
                fi
            else
                printf '\r\033[K\n' >/dev/tty
            fi
        done
        printf '\033[%dA' "$reserved" >/dev/tty
    }
    _render

    while IFS= read -rsn1 key </dev/tty; do
        case "$key" in
            $'\033')
                read -rsn2 -t 0.01 seq </dev/tty || seq=""
                case "$seq" in
                    '[A') (( cursor > 0 )) && cursor=$(( cursor - 1 )) ;;
                    '[B') (( cursor < ${#filtered[@]} - 1 )) && cursor=$(( cursor + 1 )) ;;
                    '')   query=""; cursor=0 ;;
                esac ;;
            $'\x7f'|$'\b')
                [[ -n "$query" ]] && { query="${query%?}"; cursor=0; } ;;
            ' ')
                if (( ${#filtered[@]} > 0 )); then
                    idx_sel="${filtered[cursor]}"
                    selected[idx_sel]=$(( 1 - selected[idx_sel] ))
                fi ;;
            $'\x01') for i in "${filtered[@]}"; do selected[i]=1; done ;;
            $'\x04') for i in "${filtered[@]}"; do selected[i]=0; done ;;
            '') break ;;
            *)
                if [[ "$key" =~ [[:print:]] ]]; then
                    query+="$key"; cursor=0
                fi ;;
        esac
        _render
    done

    _tui_end
    printf '\n' >/dev/tty

    local picks=()
    for i in "${!options[@]}"; do
        (( selected[i] == 1 )) && picks+=("${options[i]}")
    done
    _logfile "MULTI $prompt → ${picks[*]:-(none)}"
    if (( ${#picks[@]} > 0 )); then
        printf '%s\n' "${picks[@]}"
    fi
    return 0
}

# ─── Execution helpers ──────────────────────────────────────────────────────

die() {
    log::error "$*"
    exit 1
}

require_root() {
    if [[ $EUID -eq 0 ]]; then return 0; fi
    if sudo -n true 2>/dev/null; then return 0; fi
    log::warn "Some operations require sudo. You may be prompted for your password."
}

as_user() {
    local user="$1"; shift
    if [[ $EUID -eq 0 ]]; then
        sudo -u "$user" -H "$@"
    else
        "$@"
    fi
}

snapshot() {
    local path="$1"
    [[ -e "$path" ]] || return 0
    local ts; ts="$(date +%Y%m%d%H%M%S)"
    local backup="${path}.bak.${ts}"
    if [[ $EUID -eq 0 ]]; then
        cp -a "$path" "$backup"
    else
        sudo cp -a "$path" "$backup" 2>/dev/null || cp -a "$path" "$backup"
    fi
    log::info "Snapshot: $path → $backup"
}

# stow_safe <package> [target] [dotfiles_dir]
# Stows a package, backing up any conflicting real files first.
# Auto-drops privilege to $SUDO_USER when called from a root script.
# Idempotent: re-stowing replaces previous symlinks.
stow_safe() {
    local pkg="$1"
    local user="${SUDO_USER:-${USER_NAME:-$USER}}"
    local user_home
    user_home="$(getent passwd "$user" | cut -d: -f6)"
    local target="${2:-$user_home}"
    local dotfiles_dir="${3:-${DOTFILES_DIR:-$user_home/dotfiles}}"

    if [[ ! -d "$dotfiles_dir/$pkg" ]]; then
        log::skip "Stow source missing: $pkg"
        return 0
    fi
    if ! command -v stow >/dev/null 2>&1; then
        log::warn "stow not installed — install with: pacman -S stow"
        return 1
    fi

    # Run any command as the real user (drops priv when called from root).
    _as_user_priv() {
        if [[ $EUID -eq 0 && "$user" != "root" ]]; then
            sudo -u "$user" -H "$@"
        else
            "$@"
        fi
    }

    # Dry-run: parse stow's stderr for `existing target` warnings.
    local conflict ts
    while IFS= read -r conflict; do
        [[ -z "$conflict" ]] && continue
        conflict="$target/$conflict"
        [[ -e "$conflict" && ! -L "$conflict" ]] || continue
        ts="$(date +%Y%m%d%H%M%S)"
        _as_user_priv mv "$conflict" "${conflict}.bak.${ts}"
        log::info "Backed up: $conflict → ${conflict}.bak.${ts}"
    done < <(
        _as_user_priv stow -n -d "$dotfiles_dir" -t "$target" "$pkg" 2>&1 \
            | sed -nE '
                s/.*existing target is (neither a link nor a directory|not owned by stow): //p
                s/.*over existing target ([^ ]+) since neither a link nor a directory.*/\1/p
            '
    )

    if _as_user_priv stow -d "$dotfiles_dir" -t "$target" -R "$pkg"; then
        log::ok "Stowed: $pkg"
    else
        log::warn "stow_safe: failed to stow '$pkg'"
        return 1
    fi
}

# stow_system <package> [dotfiles_dir]
# Stows a package's tree onto / (system-wide). Used for /etc/* configs
# managed through dotfiles (e.g. greetd, gdm). Always runs as root.
# Conflict files are backed up with .bak.<timestamp>.
stow_system() {
    local pkg="$1"
    local user="${SUDO_USER:-${USER_NAME:-$USER}}"
    local user_home
    user_home="$(getent passwd "$user" | cut -d: -f6)"
    local dotfiles_dir="${2:-${DOTFILES_DIR:-$user_home/dotfiles}}"

    if [[ ! -d "$dotfiles_dir/$pkg" ]]; then
        log::skip "System stow source missing: $pkg"
        return 0
    fi
    if ! command -v stow >/dev/null 2>&1; then
        log::warn "stow not installed"
        return 1
    fi

    # Backup conflicts under target /
    local conflict ts
    while IFS= read -r conflict; do
        [[ -z "$conflict" ]] && continue
        conflict="/$conflict"
        [[ -e "$conflict" && ! -L "$conflict" ]] || continue
        ts="$(date +%Y%m%d%H%M%S)"
        sudo mv "$conflict" "${conflict}.bak.${ts}"
        log::info "Backed up: $conflict → ${conflict}.bak.${ts}"
    done < <(
        stow -n -d "$dotfiles_dir" -t / "$pkg" 2>&1 \
            | sed -nE '
                s/.*existing target is (neither a link nor a directory|not owned by stow): //p
                s/.*over existing target ([^ ]+) since neither a link nor a directory.*/\1/p
            '
    )

    if sudo stow -d "$dotfiles_dir" -t / -R "$pkg"; then
        log::ok "System stowed: $pkg → /"
    else
        log::warn "stow_system: failed for '$pkg'"
        return 1
    fi
}
