# ~/.config/shell/functions.sh
# Functions shared by zsh and bash. Only what needs the shell itself (cd, fc)
# or real logic stays here; plain one-liners are pet snippets (Ctrl-X Ctrl-R).

# mkcd <dir>  -> create a directory and enter it
mkcd() {
    [ -n "$1" ] || { echo "Usage: mkcd <dir>" >&2; return 1; }
    mkdir -p -- "$1" && cd -- "$1"
}

# extract <archive>...  -> detects the format
extract() {
    [ $# -gt 0 ] || { echo "Usage: extract <archive>..." >&2; return 1; }
    local f
    for f in "$@"; do
        [ -f "$f" ] || { echo "extract: not a file: $f" >&2; continue; }
        case "$f" in
            *.tar.zst|*.tzst) tar --zstd -xf "$f" ;;
            *.tar.gz|*.tgz)   tar -xzf "$f" ;;
            *.tar.bz2|*.tbz2) tar -xjf "$f" ;;
            *.tar.xz|*.txz)   tar -xJf "$f" ;;
            *.tar)            tar -xf "$f" ;;
            *.zip)            unzip -q "$f" ;;
            *.7z)             7z x "$f" ;;
            *.rar)            unrar x "$f" ;;
            *.zst)            unzstd "$f" ;;
            *.gz)             gunzip -k "$f" ;;
            *.bz2)            bunzip2 -k "$f" ;;
            *.xz)             unxz -k "$f" ;;
            *) echo "extract: unknown format: $f" >&2 ;;
        esac
    done
}

# bak <file>  -> timestamped copy next to the original
bak() {
    [ -n "$1" ] || { echo "Usage: bak <file>" >&2; return 1; }
    cp -a -- "$1" "$1.bak.$(date +%Y%m%d-%H%M%S)"
}

# fe [fd-args]  -> fuzzy-find a file and open it in $EDITOR
fe() {
    local f
    f=$(fd --type f --hidden --exclude .git "$@" | fzf --preview 'bat -n --color=always {}')
    [ -n "$f" ] && ${EDITOR:-vi} "$f"
}

# y [dir]  -> yazi; on leaving, the shell stays in the folder you were in
y() {
    local tmp cwd
    tmp=$(mktemp)
    yazi --cwd-file="$tmp" "$@"
    cwd=$(cat "$tmp")
    rm -f "$tmp"
    if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then cd "$cwd" || return; fi
}

# dev -> this folder as a Zellij session, with the dev layout; again, it comes back to it
dev() {
    if [ -n "${ZELLIJ:-}" ]; then
        zellij action new-tab --layout dev --cwd "$PWD" >/dev/null
    else
        zellij attach "${PWD##*/}" 2>/dev/null || zellij -s "${PWD##*/}" -n dev
    fi
}

# prev -> save the previous command as a pet snippet
prev() {
    pet new "$(fc -lrn | head -n 1 | sed 's/^[[:space:]]*//')"
}
