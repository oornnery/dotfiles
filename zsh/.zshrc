# ~/.zshrc
# This file is sourced for interactive shells.
# Put aliases, completions, plugins, keybindings, prompt, and interactive UX here.

# -------------------------------
# Oh My Zsh
# -------------------------------

export ZSH="$HOME/.oh-my-zsh"

# Starship owns the prompt — empty ZSH_THEME stops OMZ from setting its own.
# (Plugins/completion from OMZ stay loaded; only the theme is disabled.)
ZSH_THEME=""

# Plugins (order matters — see notes):
# - zsh-vi-mode: vi modal in shell. MUST come first; it remaps keys others rely on.
# - git / gh: aliases (gst, ga, gco, …)
# - sudo: double-ESC to prepend sudo
# - z: fast dir jumping (still useful alongside zoxide)
# - fzf-tab: fuzzy tab completion UI
# - zsh-autosuggestions: fish-like ghost text from history
# - zsh-completions: extra completions catalog
# - zsh-history-substring-search: type "git" then ↑/↓ navigates only matching history
# - fast-syntax-highlighting: replaces the slower zsh-syntax-highlighting. MUST be
#   loaded near the end (before history-substring-search) per upstream docs.
plugins=(
  zsh-vi-mode
  git
  gh
  sudo
  zsh-completions
  zsh-autosuggestions
  fzf-tab
  fast-syntax-highlighting
  zsh-history-substring-search
)
# Note: dropped OMZ's `z` plugin — zoxide does the same with --cmd cd below.

source "$ZSH/oh-my-zsh.sh"

# zsh-history-substring-search: bind ↑/↓ to substring search after a query.
# Both Emacs (default) and vi insert/normal mode covered.
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# -------------------------------
# Completion and navigation
# -------------------------------

# fzf shell integration
# This enables keybindings and fuzzy completion features.
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# Better completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --color=always $realpath'
zstyle ':fzf-tab:complete:*' use-fzf-default-opts yes

# -------------------------------
# History
# -------------------------------

# History file location
HISTFILE="$HOME/.zhistory"
HISTSIZE=10000
SAVEHIST=10000

# History behavior
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY

# -------------------------------
# Shell behavior
# -------------------------------

# Auto change into a directory by typing its name
setopt AUTO_CD

# Correct minor spelling mistakes in commands
#setopt CORRECT

# Enable recursive globbing with **
setopt EXTENDED_GLOB

# -------------------------------
# Aliases
# -------------------------------

# Safer core commands
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# Sudo with a gum-based TUI password prompt (no fragile echo|sudo -S pipe).
# Use a zsh function instead of an alias: aliases don't expand inside
# other functions (e.g. `sudo-unlock` below), but functions do — so the
# gum prompt fires consistently for interactive commands AND for any
# helper that wraps sudo. Bash scripts still get the plain prompt
# (they don't inherit zsh functions); use `sudo -A` explicitly there.
if [[ -x "$HOME/.local/bin/sudo-askpass" ]]; then
    export SUDO_ASKPASS="$HOME/.local/bin/sudo-askpass"
    sudo() { command sudo -A "$@" }
fi

# Clear PAM faillock counters after canceling a sudo prompt locks you out.
# Usage: sudo-unlock           (current user)
#        sudo-unlock alice     (another user)
sudo-unlock() {
    sudo faillock --user "${1:-$USER}" --reset
}

# Better listing with eza
alias ls='eza --icons=always'
alias ll='eza -la --icons=always --git'
alias la='eza -la --icons=always'
alias lsa='eza -la --icons=always'
alias lt='eza --tree --icons=always'
alias lta='eza --tree -la --icons=always'

# fzf with bat preview (omarchy-style)
alias ff='fzf --preview "bat --style=numbers --color=always {} 2>/dev/null || cat {}"'

# Better cat with bat
alias cat='bat'
alias catp='bat -p'

# Nice-to-have CLI shortcuts
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Reload shell config quickly
alias reload='exec zsh'

# Quick editor shortcuts
alias editz='nvim ~/.zshrc'
alias edit-zenv='nvim ~/.zshenv'
alias edit-zprofile='nvim ~/.zprofile'
alias edit-zlogin='nvim ~/.zlogin'

# Arch package management
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias remove='sudo pacman -Rns'
alias search='pacman -Ss'
alias clean='sudo pacman -Sc'

# Modern tooling
alias py='python'
alias v='nvim'
alias g='git'
alias lg='lazygit'
alias ld='lazydocker'

# -------------------------------
# Functions
# -------------------------------

# Library: compress, decompress, iso2sd, format-drive, fip, dip, lip, rfwd
[[ -f "$HOME/.zsh_functions" ]] && source "$HOME/.zsh_functions"

# Create a directory and enter it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# -------------------------------
# Prompt / UI extras
# -------------------------------

# Show fastfetch only once per login/session tree.
# This avoids visual noise in every subshell.
if [[ -o interactive ]] && [[ -z "${FASTFETCH_SHOWN:-}" ]]; then
  export FASTFETCH_SHOWN=1
  command -v fastfetch >/dev/null 2>&1 && fastfetch
fi

# -------------------------------
# Optional tool initializations
# -------------------------------

# Tool initializations (each gated by `command -v` so missing tools are no-ops).
# --cmd cd: zoxide replaces the `cd` builtin entirely.
# - `cd foo/bar` (valid path) → cd as usual
# - `cd <fragment>` → jump to most-frecent matching dir
# - `cdi` → interactive picker with fzf
command -v zoxide   >/dev/null && eval "$(zoxide init zsh --cmd cd)"

# Bare-word fallback: typing just `ve-tools` (no `cd` prefix) → if it's not
# a command AND not a subdir of $PWD, try zoxide to find a frecent match.
# This restores autojump-style UX while still letting AUTO_CD handle direct
# subdir names first.
if command -v zoxide >/dev/null 2>&1; then
  command_not_found_handler() {
    if [[ -n "$1" ]]; then
      local target
      if target="$(zoxide query "$@" 2>/dev/null)" && [[ -n "$target" ]]; then
        cd "$target" && return 0
      fi
    fi
    print -r -- "zsh: command not found: $1" >&2
    return 127
  }
fi
command -v fnm      >/dev/null && eval "$(fnm env --use-on-cd)"
command -v atuin    >/dev/null && eval "$(atuin init zsh)"
command -v mise     >/dev/null && eval "$(mise activate zsh)"
command -v direnv   >/dev/null && eval "$(direnv hook zsh)"
command -v starship >/dev/null && eval "$(starship init zsh)"
