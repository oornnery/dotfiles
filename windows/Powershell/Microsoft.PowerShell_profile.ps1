# Microsoft.PowerShell_profile.ps1 - mirrors the Linux .zshrc as closely as
# PowerShell allows. Linked into $PROFILE by dev/shell.ps1.
#
# Expects pwsh 7+. Tools are gated by Get-Command so missing binaries no-op.

# ─── PSReadLine: history + predictions (zsh-autosuggestions analog) ────────
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue

    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -BellStyle None

    # Substring history search on Up/Down (zsh-history-substring-search analog)
    Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

    # Tab = menu complete (fzf-tab-ish UX)
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

    # Accept current prediction with Right arrow (fish/zsh-autosuggestions UX)
    Set-PSReadLineKeyHandler -Key RightArrow -Function ForwardChar
}

# Helper used throughout the profile to silently check for a command's presence.
function Have { param([string]$Name) [bool](Get-Command $Name -ErrorAction SilentlyContinue) }

# ─── Modules ──────────────────────────────────────────────────────────────
# Terminal-Icons: file icons in `ls` (eza-icons equivalent for native ls).
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    try { Import-Module Terminal-Icons -ErrorAction Stop } catch {}
}

# PSFzf: fzf integration (Ctrl+R history, Ctrl+T file picker).
# Only load if BOTH the module AND the fzf binary exist - PSFzf throws a
# terminating error at import-time if fzf isn't in PATH, and -ErrorAction
# SilentlyContinue doesn't suppress that. (Symptom: profile spams red text
# until you run dev/tools to install fzf.)
if ((Have fzf) -and (Get-Module -ListAvailable -Name PSFzf)) {
    try {
        Import-Module PSFzf -ErrorAction Stop
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    } catch {}
}

# ─── Aliases (mirror .zshrc) ──────────────────────────────────────────────

# Modern listing via eza (drop-in for ls).
if (Have eza) {
    function ls   { eza --icons=always @args }
    function ll   { eza -la --icons=always --git @args }
    function la   { eza -la --icons=always @args }
    function lsa  { eza -la --icons=always @args }
    function lt   { eza --tree --icons=always @args }
    function lta  { eza --tree -la --icons=always @args }
}

# bat: better cat.
if (Have bat) {
    Remove-Item Alias:cat -ErrorAction SilentlyContinue
    function cat  { bat @args }
    function catp { bat -p @args }
}

# fzf with bat preview.
if (Have fzf) {
    function ff {
        fzf --preview 'bat --style=numbers --color=always {} 2>$null'
    }
}

# Modern CLI replacements - gated.
if (Have btm)   { function top { btm @args } }
if (Have dust)  { Set-Alias du dust   -Force }
if (Have duf)   { Set-Alias df duf    -Force }
if (Have procs) { Set-Alias ps procs  -Force -Option AllScope -ErrorAction SilentlyContinue }
if (Have xh)    { Set-Alias http xh   -Force }

# Quick tools
Set-Alias v   nvim       -Force -ErrorAction SilentlyContinue
Set-Alias g   git        -Force -ErrorAction SilentlyContinue
Set-Alias lg  lazygit    -Force -ErrorAction SilentlyContinue
Set-Alias ld  lazydocker -Force -ErrorAction SilentlyContinue
Set-Alias py  python     -Force -ErrorAction SilentlyContinue

# Windows-equivalent "package management" aliases.
# `update` uses topgrade (one-shot for winget + scoop + npm + WSL + pwsh modules
# + git repos + ...). Falls back to manual winget+scoop if topgrade missing.
function update {
    if (Have topgrade) {
        topgrade --yes @args
    } else {
        winget upgrade --all --silent --accept-package-agreements --accept-source-agreements
        if (Have scoop) { scoop update *; scoop cleanup * }
    }
}
function install { winget install --id $args[0] --silent --accept-package-agreements --accept-source-agreements }
function remove  { winget uninstall --id $args[0] --silent }
function search  { winget search $args[0] }
function clean   { if (Have scoop) { scoop cleanup *; scoop cache rm * }; Clear-RecycleBin -Force -ErrorAction SilentlyContinue }

# Reload profile (alias for `exec zsh`).
function reload  { . $PROFILE }

# ─── dots: master CLI (analog of bin/dots on Linux) ───────────────────────
# `dots setup core`, `dots theme set tokyo-night`, `dots update`, etc.
# Run `dots` (no args) for the full help.
function dots {
    $dotfiles = if ($Env:DOTFILES_DIR) { $Env:DOTFILES_DIR } else { "$Env:USERPROFILE\dotfiles" }
    & "$dotfiles\scripts\win\dots.ps1" @args
}

# Shortcuts (so `theme`, `update` keep working as standalone verbs too)
function theme { dots theme @args }

# Quick edit shortcuts
function editp   { nvim $PROFILE }
function editv   { nvim "$Env:LOCALAPPDATA\nvim\init.lua" }

# Navigation
function ..      { Set-Location .. }
function ...     { Set-Location ..\.. }
function ....    { Set-Location ..\..\.. }

# pay-respects (typo corrector). `f` after a failed command -> fix it.
if (Have pay-respects) {
    Invoke-Expression (pay-respects powershell --alias f | Out-String)
}

# ─── Functions ────────────────────────────────────────────────────────────
function mkcd { param([string]$Path) New-Item -ItemType Directory -Path $Path -Force | Out-Null; Set-Location $Path }

# Recursive grep with ripgrep fallback to Select-String.
function rgi {
    if (Have rg) { rg --color=always --line-number --hidden --glob '!.git' @args }
    else         { Select-String -Path * -Pattern $args[0] -List }
}

# Quick fzf-based directory picker (zoxide interactive).
function cdi {
    if (Have zoxide) { zoxide query --interactive | ForEach-Object { Set-Location $_ } }
}

# ─── Tool initializations ─────────────────────────────────────────────────
# zoxide replaces cd. `cd foo` -> dir if valid, frecent match otherwise.
if (Have zoxide) {
    Invoke-Expression (& { (zoxide init powershell --cmd cd) -join "`n" })
}

# Prompt: starship is primary. Oh My Posh is a fallback that uses a JSON
# crafted to mimic the active starship theme (themes/<theme>/oh-my-posh.json,
# linked to ~/.config/oh-my-posh.json by dev/shell.ps1 / desktop/theme.ps1).
if (Have starship) {
    Invoke-Expression (& { (starship init powershell --print-full-init) -join "`n" })
} elseif (Have oh-my-posh) {
    $omp = "$Env:USERPROFILE\.config\oh-my-posh.json"
    if (Test-Path $omp) {
        oh-my-posh init pwsh --config $omp | Invoke-Expression
    } else {
        oh-my-posh init pwsh | Invoke-Expression
    }
}

# Deferred (not as critical on Windows - just init inline):
if (Have fnm)    { fnm env --use-on-cd | Out-String | Invoke-Expression }
if (Have direnv) { Invoke-Expression "$(direnv hook pwsh)" }

# ─── Fastfetch once per session ───────────────────────────────────────────
if (-not $Env:FASTFETCH_SHOWN -and (Have fastfetch)) {
    $Env:FASTFETCH_SHOWN = '1'
    fastfetch
}

# ─── Win-specific QoL ─────────────────────────────────────────────────────
# Open Windows Settings deep-link, e.g. `settings display`
function settings { param([string]$Page) Start-Process "ms-settings:$Page" }

# Touch a file (Unix touch analog).
function touch { param([Parameter(ValueFromRemainingArguments)]$Paths)
    foreach ($p in $Paths) {
        if (Test-Path $p) { (Get-Item $p).LastWriteTime = Get-Date }
        else { New-Item -ItemType File -Path $p -Force | Out-Null }
    }
}

# which - locate a command (Unix which analog).
function which { param([string]$Name) (Get-Command $Name -ErrorAction SilentlyContinue).Source }
