# Active theme, written by `dots theme`: sets the terminal palette.
_theme_file="${XDG_STATE_HOME:-$HOME/.local/state}/dots/theme.sh"
# shellcheck source=/dev/null
[ -r "$_theme_file" ] && . "$_theme_file"
unset _theme_file
