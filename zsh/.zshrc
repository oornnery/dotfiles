# ~/.zshrc
# Interactive zsh only. Environment comes from ~/.zshenv; aliases, functions and
# tool integrations are shared with bash in ~/.config/shell/.
[[ -o interactive ]] || return

SHELL_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/shell"

# --- History ----------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS
setopt HIST_FIND_NO_DUPS HIST_VERIFY EXTENDED_HISTORY

# --- Behaviour --------------------------------------------------------------
# EXTENDED_GLOB is left off on purpose: it breaks `git show HEAD^`.
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
setopt INTERACTIVE_COMMENTS COMPLETE_IN_WORD NO_BEEP NOTIFY
WORDCHARS=${WORDCHARS//\//}   # Ctrl-W / Alt-Backspace stop at "/"

# --- Completion styles ------------------------------------------------------
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compcache"
zstyle ':completion:*' rehash true             # see new commands without rehash
zstyle ':completion:*' group-name ''
zstyle ':fzf-tab:complete:*' use-fzf-default-opts yes
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -A $realpath'

# --- Key bindings -----------------------------------------------------------
bindkey -e
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search edit-command-line
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
zle -N edit-command-line

bindkey '^[[A' up-line-or-beginning-search      # Up: history by prefix
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search    # Down
bindkey '^[OB' down-line-or-beginning-search
bindkey '^[[1;5D' backward-word                 # Ctrl+Left
bindkey '^[[1;5C' forward-word                  # Ctrl+Right
bindkey '^[[H'  beginning-of-line               # Home
bindkey '^[[1~' beginning-of-line
bindkey '^[[F'  end-of-line                     # End
bindkey '^[[4~' end-of-line
bindkey '^[[3~'   delete-char                   # Delete
bindkey '^[[3;5~' kill-word                     # Ctrl+Delete
bindkey '^[[Z' reverse-menu-complete            # Shift+Tab
bindkey '^X^E' edit-command-line                # edit the line in $EDITOR

# --- Plugins: Antigen -------------------------------------------------------
fpath=("$SHELL_DIR/completions" $fpath)   # before compinit, which Antigen runs
ANTIGEN_HOME="${ANTIGEN_HOME:-$HOME/.antigen}"
if [[ ! -r $ANTIGEN_HOME/antigen.zsh ]] && (( $+commands[git] )); then
    git clone --depth 1 https://github.com/zsh-users/antigen.git "$ANTIGEN_HOME"
fi
ANTIGEN_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
mkdir -p "${ANTIGEN_COMPDUMP:h}"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
if [[ -r $ANTIGEN_HOME/antigen.zsh ]]; then
    source "$ANTIGEN_HOME/antigen.zsh"
    antigen bundle zsh-users/zsh-completions
    (( $+commands[fzf] )) && antigen bundle Aloxaf/fzf-tab
    antigen bundle zsh-users/zsh-autosuggestions
    antigen bundle zsh-users/zsh-syntax-highlighting   # keep last
    antigen apply                                      # runs compinit
fi

# --- Shared config (same files bash uses) -----------------------------------
# conf.d: *.sh runs in both shells, *.zsh only here.
for _f in "$SHELL_DIR"/{aliases,functions,tools}.sh "$SHELL_DIR"/conf.d/*.(sh|zsh)(N) "$SHELL_DIR"/local.sh; do
    [[ -r $_f ]] && source "$_f"
done
unset _f

alias compreset='rm -f "${XDG_CACHE_HOME:-$HOME/.cache}"/zsh/zcompdump* && exec zsh'

# fzf's integration rebinds Tab; give it back to fzf-tab.
(( $+functions[enable-fzf-tab] )) && enable-fzf-tab
