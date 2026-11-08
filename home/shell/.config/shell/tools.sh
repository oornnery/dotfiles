# ~/.config/shell/tools.sh
# Tool integrations shared by zsh and bash. Each block is skipped when the
# tool is not installed. Sourced after the shell's own setup (compinit in zsh).

if [ -n "${ZSH_VERSION:-}" ]; then _sh=zsh; else _sh=bash; fi

# less / man
export LESS='-FRXi'
if _has bat; then
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export MANROFFOPT='-c'
fi

# fzf: Ctrl-R history, Ctrl-T files, Alt-C directories, ** completion
if _has fzf; then
    if _has fd; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    fi
    # Terminal colors, so fzf follows `dots theme`.
    export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border --info=inline --color=16,hl:yellow,hl+:yellow,prompt:green,pointer:magenta,marker:magenta,border:bright-black'
    _has bat && export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :200 {}'"
    _has eza && export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {}'"

    eval "$(fzf --"$_sh")"
fi

# Tool versions, per project: mise (Node for now; see ~/.config/mise/config.toml).
# fnm only until migration 003 installs mise and removes it.
if _has mise; then
    eval "$(mise activate "$_sh")"
elif _has fnm; then
    eval "$(fnm env --use-on-cd --shell "$_sh")"
fi

# git-delta as the git pager, set here so git still works without it.
if _has delta; then
    export GIT_PAGER=delta
    export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=interactive.diffFilter GIT_CONFIG_VALUE_0='delta --color-only'
fi

# Per-directory environments (.envrc)
_has direnv && eval "$(direnv hook "$_sh")"

# History search (Ctrl-R). Keeps Up/Down as plain prefix search.
# In bash, atuin needs bash-preexec or ble.sh to be loaded first.
if _has atuin; then
    if [ "$_sh" = zsh ] || [ -n "${BLE_VERSION:-}" ] || [ -n "${bash_preexec_imported:-}" ]; then
        eval "$(atuin init "$_sh" --disable-up-arrow --disable-ai)"
    fi
fi

# Fix the last failed command: fuck
_has pay-respects && eval "$(pay-respects "$_sh" --alias fuck --nocnf)"

# Smarter cd (z, zi). Keep last: in bash it hooks PROMPT_COMMAND.
_has zoxide && eval "$(zoxide init "$_sh")"

unset _sh
