# ~/.zshrc
# This file is sourced for interactive shells.
# Put aliases, completions, plugins, keybindings, prompt, and interactive UX here.

# -------------------------------
# Zellij (manual start — no auto-attach)
# -------------------------------
# Zellij is available but not auto-started.
# Run `zellij` manually when you want the multiplexer.
# Install with: sudo pacman -S zellij

# -------------------------------
# Antigen + Oh My Zsh
# -------------------------------

# Antigen is the plugin manager. It can load Oh My Zsh plugins and themes
# without requiring a separate ~/.oh-my-zsh install.
export ANTIGEN_HOME="${ANTIGEN_HOME:-$HOME/.antigen}"

# Oh My Zsh's gh plugin writes generated completions here on first load.
# Fresh Antigen installs may not have created the directory yet.
export ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-$ANTIGEN_HOME/bundles/robbyrussell/oh-my-zsh/cache}"
mkdir -p "$ZSH_CACHE_DIR/completions" 2>/dev/null || true

# Active theme drop-in written by the `theme` command.
# It may set ANTIGEN_THEME and terminal-tool color variables before plugins load.
[[ -f "$HOME/.config/zsh/theme.zsh" ]] && source "$HOME/.config/zsh/theme.zsh"

# Change this before starting zsh to try another Oh My Zsh theme:
#   ANTIGEN_THEME=agnoster zsh
export ANTIGEN_THEME="${ANTIGEN_THEME:-robbyrussell}"

if [[ -f "$ANTIGEN_HOME/antigen.zsh" ]]; then
  source "$ANTIGEN_HOME/antigen.zsh"

  antigen use oh-my-zsh

  # Bundles are loaded in order. Keep zsh-vi-mode early because it remaps keys,
  # and keep highlighting/history search near the end because they wrap widgets.
  antigen bundle romkatv/zsh-defer
  antigen bundle jeffreytse/zsh-vi-mode
  antigen bundle git
  antigen bundle gh
  antigen bundle sudo
  antigen bundle zsh-users/zsh-completions
  antigen bundle zsh-users/zsh-autosuggestions
  antigen bundle Aloxaf/fzf-tab
  # forgit: antigen's auto-clone is flaky here (leaves an empty dir → "Error!
  # Activate logging" every shell). Pre-clone so antigen just sources it.
  [[ -f "$ANTIGEN_HOME/bundles/wfxr/forgit/forgit.plugin.zsh" ]] \
    || { rm -rf "$ANTIGEN_HOME/bundles/wfxr/forgit"; git clone --depth 1 -q https://github.com/wfxr/forgit "$ANTIGEN_HOME/bundles/wfxr/forgit" 2>/dev/null; }
  antigen bundle wfxr/forgit
  antigen bundle zdharma-continuum/fast-syntax-highlighting
  antigen bundle zsh-users/zsh-history-substring-search

  # Prompt: Starship drives it when installed (see the Starship block below);
  # otherwise fall back to the Antigen/Oh-My-Zsh theme.
  command -v starship >/dev/null 2>&1 || antigen theme "$ANTIGEN_THEME"
  antigen apply
else
  print -P "%F{yellow}Antigen not found at $ANTIGEN_HOME/antigen.zsh%f"
fi

# -------------------------------
# Starship prompt
# -------------------------------
# Borderless prompt with git/lang icons, themed per palette via
# ~/.config/starship.toml (linked by `dots theme set`). Deferred through
# zsh-vi-mode's init hook so vi-mode can't clobber it; immediate when zvm absent.
if command -v starship >/dev/null 2>&1; then
  _dotfiles_starship_init() { eval "$(starship init zsh)"; }
  if (( $+parameters[zvm_after_init_commands] )); then
    zvm_after_init_commands+=(_dotfiles_starship_init)
  else
    _dotfiles_starship_init
  fi
fi

# zsh-history-substring-search: bind ↑/↓ to substring search after a query.
# Both Emacs (default) and vi insert/normal mode covered.
if (( $+widgets[history-substring-search-up] )); then
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down
fi

# Zellij statusline vi-mode support (when inside Zellij)
_dotfiles_zellij_set_vi_mode() {
  [[ -n "${ZELLIJ:-}" ]] || return 0

  local mode="${ZVM_MODE:-}" label="INSERT"
  if [[ -n "${ZVM_MODE_NORMAL:-}" && "$mode" == "$ZVM_MODE_NORMAL" ]]; then
    label="NORMAL"
  elif [[ -n "${ZVM_MODE_VISUAL:-}" && "$mode" == "$ZVM_MODE_VISUAL" ]]; then
    label="VISUAL"
  elif [[ -n "${ZVM_MODE_VISUAL_LINE:-}" && "$mode" == "$ZVM_MODE_VISUAL_LINE" ]]; then
    label="V-LINE"
  elif [[ -n "${ZVM_MODE_REPLACE:-}" && "$mode" == "$ZVM_MODE_REPLACE" ]]; then
    label="REPLACE"
  elif [[ "${KEYMAP:-}" == "vicmd" ]]; then
    label="NORMAL"
  fi

  command zellij action write-chars " $label " 2>/dev/null || true
}

if (( $+parameters[zvm_after_select_vi_mode_commands] )); then
  zvm_after_select_vi_mode_commands+=(_dotfiles_zellij_set_vi_mode)
fi
_dotfiles_zellij_set_vi_mode

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
if [[ -x "$HOME/.local/lib/dots/askpass" ]]; then
    export SUDO_ASKPASS="$HOME/.local/lib/dots/askpass"
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
alias editz='hx ~/.zshrc'
alias edit-zenv='hx ~/.zshenv'
alias edit-zprofile='hx ~/.zprofile'
alias edit-zlogin='hx ~/.zlogin'

# Arch package management
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias remove='sudo pacman -Rns'
alias search='pacman -Ss'
alias clean='sudo pacman -Sc'

# Modern tooling
alias py='python'
alias v='hx'
alias g='git'
alias lg='lazygit'
alias ld='lazydocker'

# Modern CLI replacements (all gated → no-op if tool missing)
command -v btm   >/dev/null && alias top='btm'
command -v dust  >/dev/null && alias du='dust'
command -v duf   >/dev/null && alias df='duf'
command -v procs >/dev/null && alias ps='procs'
command -v xh    >/dev/null && alias http='xh'
# `sd` keeps original name — no alias (would shadow sed which is still useful)
# `tldr` keeps original name
# `jless` keeps original name (used inline: `cat file.json | jless`)

# pay-respects (typo corrector) — type `f` after a failed command to fix it
if command -v pay-respects >/dev/null 2>&1; then
    eval "$(pay-respects zsh --alias f)"
fi

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

# Show fastfetch once per "terminal": once per tmux window (not on every split
# pane), else once per non-tmux shell tree. Inside tmux we key off a *window*
# option instead of an exported env var — an exported var gets captured into
# tmux's global environment and would then suppress fastfetch in every pane.
if [[ -o interactive ]] && command -v fastfetch >/dev/null 2>&1; then
  if [[ -n "${ZELLIJ:-}" ]]; then
    if [[ "$(zellij action query-swap-layout 2>/dev/null)" != "" ]] || true; then
      # inside zellij — fastfetch once per session
      [[ -z "${ZELLIJ_FASTFETCH_SHOWN:-}" ]] && export ZELLIJ_FASTFETCH_SHOWN=1 && fastfetch
    fi
  elif [[ -n "${TMUX:-}" ]]; then
    if [[ "$(tmux show-options -wqv @fastfetch_shown 2>/dev/null)" != 1 ]]; then
      tmux set-option -w @fastfetch_shown 1 2>/dev/null
      fastfetch
    fi
  elif [[ -z "${FASTFETCH_SHOWN:-}" ]]; then
    export FASTFETCH_SHOWN=1
    fastfetch
  fi
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
# a command AND not a subdir of $PWD AND zoxide has a frecent match, rewrite
# the buffer to `cd <word>` before submitting. Restores autojump-style UX.
#
# NB: a command_not_found_handler would not work — zsh runs that in a context
# where `cd` doesn't persist. Intercepting accept-line (Enter) at the ZLE
# layer lets us rewrite the buffer in the parent shell.
if command -v zoxide >/dev/null 2>&1; then
  _zoxide_accept_line() {
    # Single bare word with no special chars / args / pipes? Try it.
    if [[ "$BUFFER" =~ ^[[:space:]]*([^[:space:]/$\|\&\;\<\>]+)[[:space:]]*$ ]]; then
      local word="${match[1]}"
      # Skip if it's already a known command, builtin, alias, function, or dir.
      if ! command -v "$word" >/dev/null 2>&1 && [[ ! -d "$word" ]]; then
        local target
        if target="$(zoxide query "$word" 2>/dev/null)" && [[ -n "$target" ]]; then
          BUFFER="cd ${(q)word}"
        fi
      fi
    fi
    zle .accept-line
  }
  zle -N accept-line _zoxide_accept_line
fi
# Everything else deferred to AFTER the first prompt via zsh-defer if loaded.
# Shaves ~200ms off shell startup by moving fnm/atuin/mise/direnv off the hot
# path. They become active a few hundred ms later (you won't notice unless
# you immediately need direnv for the very first command).
if (( $+functions[zsh-defer] )); then
    command -v fnm    >/dev/null && zsh-defer eval "$(fnm env --use-on-cd)"
    command -v atuin  >/dev/null && zsh-defer eval "$(atuin init zsh)"
    command -v mise   >/dev/null && zsh-defer eval "$(mise activate zsh)"
    command -v direnv >/dev/null && zsh-defer eval "$(direnv hook zsh)"
else
    command -v fnm    >/dev/null && eval "$(fnm env --use-on-cd)"
    command -v atuin  >/dev/null && eval "$(atuin init zsh)"
    command -v mise   >/dev/null && eval "$(mise activate zsh)"
    command -v direnv >/dev/null && eval "$(direnv hook zsh)"
fi

# opencode
export PATH=/home/oornnery/.opencode/bin:$PATH
