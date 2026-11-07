# ~/.zshenv
# Read by EVERY zsh, scripts included. Keep it tiny.
# The real environment is shared with bash in ~/.config/shell/env.sh.

typeset -U path PATH

_env="${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.sh"

[[ -r $_env ]] && source "$_env"

unset _env
