# The same keys as in Zellij, for when there is no Zellij around: Zellij takes them
# first, so inside it these never run.
#
# Each key is a widget: what you were typing is set aside, the command runs, and the
# line comes back. The leading space keeps the command out of the history.
typeset -gA _dots_keys=(
    dots-yazi         ' y'                  # Alt-e: yazi; the shell follows to its folder
    dots-lazygit      ' lazygit'            # Alt-g
    dots-palette      ' dots palette'       # Alt-/: search everything
    dots-palette-help ' dots palette help'  # Alt-?: help
    dots-palette-tui  ' dots palette tui'   # Alt-u: pick a TUI
)
_dots_key() { zle push-input; BUFFER=${_dots_keys[$WIDGET]}; zle accept-line; }
for _w in ${(k)_dots_keys}; do zle -N "$_w" _dots_key; done
unset _w

bindkey '^[e' dots-yazi
bindkey '^[g' dots-lazygit
bindkey '^[/' dots-palette
bindkey '^[?' dots-palette-help
bindkey '^[u' dots-palette-tui
