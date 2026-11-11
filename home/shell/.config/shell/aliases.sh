# ~/.config/shell/aliases.sh
# Aliases shared by zsh and bash. Anything that depends on an optional tool
# is gated, so a missing tool never breaks a command.

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='clear'

# Safer file operations
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I'
alias mkdir='mkdir -pv'

# Let aliases expand after sudo (sudo ll)
alias sudo='sudo '

# Listing
if _has eza; then
    alias ls='eza --group-directories-first'
    alias ll='eza -lah --group-directories-first --git'
    alias la='eza -a --group-directories-first'
    alias lt='eza --tree --level=2'
else
    alias ls='ls --color=auto --group-directories-first -h'
    alias ll='ls -lAh'
    alias la='ls -A'
fi

# Output
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ip='ip -c'
alias ping='ping -c 4'
_has bat && alias b='bat'
_has chafa && alias img='chafa'   # an image in the terminal: sixel in Windows Terminal
_has lazysql && alias lazysql='lazysql --no-telemetry'   # it asks to send usage counts

# Editor (Arch names the helix binary `helix`)
alias v='${EDITOR:-vi}'
alias hx='helix'

# Git
alias g='git'
alias gs='git status --short --branch'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gco='git checkout'
alias gsw='git switch'
alias gb='git branch'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate -20'
alias gp='git push'
alias gpl='git pull --ff-only'
_has lazygit && alias lg='lazygit'

# Docker
alias d='docker'
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f --tail=100'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
_has lazydocker && alias ld='lazydocker'

# Python
alias py='python3'
alias uvr='uv run'
alias uvs='uv sync'
alias uva='uv add'
alias va='source .venv/bin/activate'

# Snippets (snip, or snip -t net for one tag). Ctrl-X Ctrl-R puts one on the line.
_has pet && alias snip='pet exec'

# Network
alias ports='ss -tulpn'
alias myip='curl -s https://ifconfig.me; echo'

# Reload the current shell
reload() { exec "${ZSH_VERSION:+zsh}${BASH_VERSION:+bash}"; }
