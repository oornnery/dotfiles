# The same keys as in Zellij, for when there is no Zellij around: Zellij takes them
# first, so inside it these never run.
bindkey -s '^[e' 'y\n'                  # Alt-e: yazi
bindkey -s '^[g' 'lazygit\n'            # Alt-g: lazygit
bindkey -s '^[/' 'dots palette\n'       # Alt-/: search everything
bindkey -s '^[?' 'dots palette help\n'  # Alt-?: help; by default it lists every command
bindkey -s '^[u' 'dots palette tui\n'   # Alt-u: pick a TUI
