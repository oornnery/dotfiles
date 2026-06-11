# dev/shell.ps1 - link the pwsh profile + starship theme (mirrors scripts/arch/dev/shell.sh).

#Requires -Version 7
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\..\lib\common.ps1"
Log-Banner 'dev' 'shell'

$dotfiles = Get-DotfilesDir

# ─── pwsh profile ─────────────────────────────────────────────────────────
$profileSrc = "$dotfiles\windows\Powershell\Microsoft.PowerShell_profile.ps1"
$profileDst = "$Env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

if (-not (Test-Path $profileSrc)) { Log-Err "missing $profileSrc"; return }
New-Item -ItemType Directory -Path (Split-Path $profileDst) -Force | Out-Null
if (Test-Path $profileDst) { Backup-Path $profileDst }
Copy-Item $profileSrc $profileDst -Force
Log-Ok "linked profile $profileSrc -> $profileDst"

# ─── starship theme ───────────────────────────────────────────────────────
# Picks $Env:THEME from win.conf.ps1 (default 'catppuccin-mocha'). Each theme
# ships a full starship.toml under themes/<name>/starship.toml.
$theme = if ($Env:THEME) { $Env:THEME } else { 'catppuccin-mocha' }
$starshipSrc = "$dotfiles\themes\$theme\starship.toml"
$starshipDst = "$Env:USERPROFILE\.config\starship.toml"

if (Test-Path $starshipSrc) {
    New-Item -ItemType Directory -Path (Split-Path $starshipDst) -Force | Out-Null
    if (Test-Path $starshipDst) { Backup-Path $starshipDst }
    Copy-Item $starshipSrc $starshipDst -Force
    Log-Ok "linked starship theme '$theme' -> $starshipDst"
} else {
    Log-Warn "starship theme not found: $starshipSrc"
    Log-Info "available themes: $((Get-ChildItem "$dotfiles\themes" -Directory -ErrorAction SilentlyContinue).Name -join ', ')"
}

# Oh My Posh JSON (used as fallback if starship is missing; matches starship style).
$ompSrc = "$dotfiles\themes\$theme\oh-my-posh.json"
$ompDst = "$Env:USERPROFILE\.config\oh-my-posh.json"
if (Test-Path $ompSrc) {
    if (Test-Path $ompDst) { Backup-Path $ompDst }
    Copy-Item $ompSrc $ompDst -Force
    Log-Ok "linked oh-my-posh theme '$theme' -> $ompDst"
}

# Track the active theme in the same state file the Linux `theme` script uses.
$stateDir  = "$Env:LOCALAPPDATA\dotfiles"
$stateFile = "$stateDir\active-theme"
New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
Set-Content -LiteralPath $stateFile -Value $theme -NoNewline
Log-Info "active theme recorded at $stateFile"
