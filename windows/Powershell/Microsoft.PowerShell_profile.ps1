# Microsoft.PowerShell_profile.ps1 — interactive shell setup.
#
# Mirrors zsh/.zshrc as closely as PowerShell allows:
#   • PSReadLine for fuzzy history + autosuggestions
#   • starship for prompt (fallback to oh-my-posh)
#   • zoxide as `cd` replacement
#   • fzf integration (Ctrl-R, Ctrl-T)
#   • Same aliases as Linux (ls/ll/cat/g/lg/v/…)

# ─── PSReadLine (line editor) ──────────────────────────────────────────────

if (-not (Get-Module -Name PSReadLine)) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue
}

Set-PSReadLineOption -EditMode Emacs                  # like zsh default
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView    # fish-like suggestions
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -HistorySearchCursorMovesToEnd

# History substring search via ↑/↓ (zsh-history-substring-search analog)
Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab       -Function MenuComplete
Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardKillWord

# ─── Prompt: starship → oh-my-posh fallback ────────────────────────────────

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (& starship init powershell)
} elseif (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh `
        --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/amro.omp.json' `
        | Invoke-Expression
}

# ─── zoxide (cd replacement; same --cmd cd convention as Linux) ───────────

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& zoxide init powershell --cmd cd | Out-String)
}

# ─── fzf integration (Ctrl-R history, Ctrl-T file picker) ────────────────

if (Get-Command fzf -ErrorAction SilentlyContinue) {
    if (Get-Module -ListAvailable PSFzf) {
        Import-Module PSFzf
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' `
                        -PSReadlineChordReverseHistory 'Ctrl+r'
    } else {
        Write-Host 'tip: Install-Module PSFzf  # for Ctrl-T / Ctrl-R fzf integration' -ForegroundColor DarkGray
    }
}

# ─── Modern CLI tool aliases (gated on Get-Command) ──────────────────────

if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ls   { eza --icons=always @args }
    function ll   { eza -la --icons=always --git @args }
    function la   { eza -la --icons=always @args }
    function lt   { eza --tree --icons=always @args }
    function lta  { eza --tree -la --icons=always @args }
}

if (Get-Command bat -ErrorAction SilentlyContinue) {
    function cat  { bat @args }
    function catp { bat -p @args }
}

if (Get-Command btm  -ErrorAction SilentlyContinue) { Set-Alias top  btm }
if (Get-Command dust -ErrorAction SilentlyContinue) { Set-Alias du   dust }
if (Get-Command duf  -ErrorAction SilentlyContinue) { Set-Alias df   duf  }
if (Get-Command xh   -ErrorAction SilentlyContinue) { Set-Alias http xh   }

Set-Alias g    git
Set-Alias lg   lazygit
Set-Alias ld   lazydocker
Set-Alias v    nvim
Set-Alias py   python

function reload { . $PROFILE }

# Navigation (mirrors zsh)
function ..    { Set-Location .. }
function ...   { Set-Location ../.. }
function ....  { Set-Location ../../.. }

# Quick edit shortcuts
function editz { nvim $PROFILE }

# ─── PATH additions (~/.local/bin like Linux) ────────────────────────────

if (Test-Path "$HOME\.local\bin") {
    $Env:PATH += ";$HOME\.local\bin"
}

# ─── tldr cache warm-up (lazy, once per week) ────────────────────────────

if (Get-Command tldr -ErrorAction SilentlyContinue) {
    $marker = "$Env:LOCALAPPDATA\tldr-last-update"
    if (-not (Test-Path $marker) -or
        (Get-Item $marker).LastWriteTime -lt (Get-Date).AddDays(-7)) {
        Start-Job { tldr --update *> $null } | Out-Null
        New-Item -ItemType File -Path $marker -Force | Out-Null
    }
}
