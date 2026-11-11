# ~/.config/shell/env.sh
# Environment shared by zsh and bash.
# Sourced from ~/.zshenv and ~/.bashrc. Runs in every shell: no output, no forks.

_has() { command -v "$1" >/dev/null 2>&1; }

export LANG="${LANG:-en_US.UTF-8}"

# XDG base directories
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Tool homes (defined before PATH, which uses them)
export PNPM_HOME="${PNPM_HOME:-$XDG_DATA_HOME/pnpm}"

# What each tool adds to the environment, in env.d/: one file per setup (go, bun,
# python...), linked by dots install with it. _path_add puts a folder in PATH once.
_path_add() { [ -d "$1" ] || return 0; case ":$PATH:" in *":$1:"*) ;; *) PATH="$1:$PATH" ;; esac; }
_source_dir() {  # every *.sh of a folder; none is fine (zsh would complain without nullglob)
    [ -n "${ZSH_VERSION:-}" ] && setopt localoptions nullglob
    for _f in "$1"/*.sh; do [ -r "$_f" ] && . "$_f"; done
    unset _f
}
_source_dir "$XDG_CONFIG_HOME/shell/env.d"

# PATH: first listed = highest priority.
# Only directories that exist and are not already in PATH are added,
# so nested shells never accumulate duplicates.
_new_path=""
for _d in \
    "$HOME/.local/bin" \
    "$PNPM_HOME/bin" \
    "$HOME/.cargo/bin"
do
    [ -d "$_d" ] || continue
    case ":$PATH:$_new_path:" in *":$_d:"*) continue ;; esac
    _new_path="${_new_path:+$_new_path:}$_d"
done
PATH="${_new_path:+$_new_path:}$PATH"
unset _d _new_path

# vite-plus env. Sourced here once, so the line its installer appends to
# ~/.zshrc / ~/.bashrc can be deleted.
[ -r "$XDG_CONFIG_HOME/vite-plus/env" ] && . "$XDG_CONFIG_HOME/vite-plus/env"

# The Node of mise first, also where the shell is not interactive (editors, scripts):
# its shims. Interactive shells activate mise itself in tools.sh.
PATH="$HOME/.local/share/mise/shims:$PATH"

# Links open in the browser of Windows, through ~/.local/bin/browser.
[ -x /mnt/c/Windows/explorer.exe ] && export BROWSER="$HOME/.local/bin/browser"

# Editor (Arch names the helix binary `helix`)
if _has helix; then EDITOR=helix; else EDITOR=vi; fi
export EDITOR VISUAL="$EDITOR"

# glow does not expand ~ in its own config.
[ -r "$XDG_CONFIG_HOME/glow/dots.json" ] && export GLOW_STYLE="$XDG_CONFIG_HOME/glow/dots.json"

# eza: icons on a terminal, none when piped.
export EZA_ICONS_AUTO=1

# Private API keys (local, chmod 600, never tracked).
[ -r "$XDG_CONFIG_HOME/ai/env" ] && . "$XDG_CONFIG_HOME/ai/env"
