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

# Plugins:
# - git: git aliases and helpers
# - gh: GitHub CLI helpers
# - sudo: double-ESC to prepend sudo in many setups
# - z: fast directory jumping
# - fzf-tab: better tab completion UI
# - zsh-autosuggestions: fish-like command suggestions
# - zsh-syntax-highlighting: command highlighting
# - zsh-completions: extra completions
plugins=(
  git
  gh
  sudo
  z
  zsh-completions
  zsh-autosuggestions
  fzf-tab
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

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
# Aliasing sudo only affects interactive shells — scripts keep plain sudo.
if [[ -x "$HOME/.local/bin/sudo-askpass" ]]; then
    export SUDO_ASKPASS="$HOME/.local/bin/sudo-askpass"
    alias sudo='sudo -A'
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
command -v zoxide   >/dev/null && eval "$(zoxide init zsh)"
command -v fnm      >/dev/null && eval "$(fnm env --use-on-cd)"
command -v atuin    >/dev/null && eval "$(atuin init zsh)"
command -v mise     >/dev/null && eval "$(mise activate zsh)"
command -v direnv   >/dev/null && eval "$(direnv hook zsh)"
command -v starship >/dev/null && eval "$(starship init zsh)"
