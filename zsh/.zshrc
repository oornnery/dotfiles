# ~/.zshrc
# This file is sourced for interactive shells.
# Put aliases, completions, plugins, keybindings, prompt, and interactive UX here.

# -------------------------------
# Oh My Zsh
# -------------------------------

export ZSH="$HOME/.oh-my-zsh"

# If you later switch to starship, set ZSH_THEME="" and initialize starship below.
ZSH_THEME="robbyrussell"

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

# Better listing with eza
alias ls='eza --icons=always'
alias ll='eza -la --icons=always --git'
alias la='eza -la --icons=always'
alias lt='eza --tree --icons=always'

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

# -------------------------------
# Functions
# -------------------------------

# Create a directory and enter it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract common archive types
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz)  tar xzf "$1" ;;
      *.bz2)     bunzip2 "$1" ;;
      *.rar)     unrar x "$1" ;;
      *.gz)      gunzip "$1" ;;
      *.tar)     tar xf "$1" ;;
      *.tbz2)    tar xjf "$1" ;;
      *.tgz)     tar xzf "$1" ;;
      *.zip)     unzip "$1" ;;
      *.7z)      7z x "$1" ;;
      *) echo "Cannot extract: $1" ;;
    esac
  else
    echo "File not found: $1"
  fi
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

# Enable zoxide later if you install it
# eval "$(zoxide init zsh)"

# Enable starship later if you switch from Oh My Zsh theme
# eval "$(starship init zsh)"

# Enable fnm later if you decide to use it instead of system node
# eval "$(fnm env --use-on-cd)"

source /usr/share/nvm/init-nvm.sh
