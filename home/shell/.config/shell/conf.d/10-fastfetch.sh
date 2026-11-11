# fastfetch once per terminal: nested shells (exec zsh, bash inside zsh,
# zellij panes) inherit the flag and stay quiet.
_has fastfetch || return 0
if [ -z "${FASTFETCH_SHOWN:-}" ]; then
    export FASTFETCH_SHOWN=1
    fastfetch
fi
