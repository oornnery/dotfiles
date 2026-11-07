# pet snippets: Ctrl-X Ctrl-R inserts the chosen command without running it.
_has pet || return 0
pet-select() {
    READLINE_LINE=$(pet search --query "$READLINE_LINE" || true)
    READLINE_POINT=${#READLINE_LINE}
}
bind -x '"\C-x\C-r": pet-select'
