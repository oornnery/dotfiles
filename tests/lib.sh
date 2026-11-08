# shellcheck shell=bash
# Sourced by each test file. A test is a function named t_<what>; `check` runs
# them all, each in a fresh temp $HOME and dotfiles, and counts the failures.
#
#   t_link_sync() { make_pkg zsh .zshrc; dots link sync; is_link ~/.zshrc; }

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
CLI="$REPO/home/dots"   # the dots package of this checkout
[[ -d $CLI ]] || CLI="$REPO/dots"   # before the move to home/
FAILED=0

# The commands of this checkout, never the ones linked on this machine.
dots() { "$CLI/.local/bin/dots" "$@"; }

make_pkg() {  # make_pkg <pkg> <file>...: a config package in the temp dotfiles
    local pkg=$1 f; shift
    for f in "$@"; do mkdir -p "$(dirname "$DOTFILES_DIR/home/$pkg/$f")"; echo "$pkg $f" > "$DOTFILES_DIR/home/$pkg/$f"; done
}

is_link()  { [[ -L $1 && -e $1 ]] || { echo "not a working link: $1"; return 1; }; }
has()      { grep -qF -- "$1" <<< "$2" || { printf 'missing: %s\nin:\n%s\n' "$1" "$2"; return 1; }; }
lacks()    { ! grep -qF -- "$1" <<< "$2" || { printf 'unexpected: %s\nin:\n%s\n' "$1" "$2"; return 1; }; }

check() {
    local t out tmp
    for t in $(declare -F | awk '$3 ~ /^t_/ {print $3}'); do
        tmp=$(mktemp -d)
        mkdir -p "$tmp/home" "$tmp/dotfiles/home" "$tmp/dotfiles/machines"
        cp -r "$CLI" "$tmp/dotfiles/home/"
        if out=$(cd "$tmp" && HOME="$tmp/home" DOTFILES_DIR="$tmp/dotfiles" DOTS_LIB="$CLI/.local/lib/dots" \
                 DOTS_MACHINE=test XDG_CONFIG_HOME="$tmp/home/.config" XDG_STATE_HOME="$tmp/home/.local/state" \
                 XDG_CACHE_HOME="$tmp/home/.cache" NO_COLOR=1 "$t" 2>&1 </dev/null); then
            printf 'ok   %s\n' "$t"
        else
            printf 'FAIL %s\n%s\n' "$t" "$(sed 's/^/     /' <<< "$out")"
            FAILED=$(( FAILED + 1 ))
        fi
        rm -rf "$tmp"
    done
    exit "$FAILED"
}
