# ~/.bashrc
# Interactive bash only. Mirrors ~/.zshrc: aliases, functions and tool
# integrations are shared in ~/.config/shell/. Readline settings: ~/.inputrc.
case $- in *i*) ;; *) return ;; esac

SHELL_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/shell"
[ -r "$SHELL_DIR/env.sh" ] && . "$SHELL_DIR/env.sh"

# Optional, if installed: ble.sh gives bash autosuggestions + syntax highlighting.
#   git clone --recursive https://github.com/akinomyoga/ble.sh ~/.local/src/ble.sh
#   make -C ~/.local/src/ble.sh install PREFIX=~/.local
[ -r "$XDG_DATA_HOME/blesh/ble.sh" ] && . "$XDG_DATA_HOME/blesh/ble.sh" --noattach

# --- History ----------------------------------------------------------------
HISTFILE="$HOME/.bash_history"
HISTSIZE=50000
HISTFILESIZE=50000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT='%F %T '
shopt -s histappend cmdhist
PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"   # share history across shells

# --- Behaviour --------------------------------------------------------------
shopt -s checkwinsize autocd cdspell dirspell globstar extglob
stty -ixon 2>/dev/null   # free Ctrl-S / Ctrl-Q

# --- Completion -------------------------------------------------------------
[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# --- Shared config (same files zsh uses) ------------------------------------
# atuin needs bash-preexec in bash; loaded first when present.
[ -r "$HOME/.bash-preexec.sh" ] && . "$HOME/.bash-preexec.sh"

# conf.d: *.sh runs in both shells, *.bash only here.
for _f in "$SHELL_DIR"/{aliases,functions,tools}.sh "$SHELL_DIR"/conf.d/*.sh "$SHELL_DIR"/conf.d/*.bash "$SHELL_DIR"/local.sh; do
    [ -r "$_f" ] && . "$_f"
done
unset _f

[[ ${BLE_VERSION-} ]] && ble-attach
