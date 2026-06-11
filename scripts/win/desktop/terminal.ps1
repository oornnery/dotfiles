# desktop/terminal.ps1 - Windows Terminal + Nerd Font + PowerShell QoL modules.

#Requires -Version 7
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\..\lib\common.ps1"
Log-Banner 'desktop' 'terminal'

Winget-Install 'Microsoft.WindowsTerminal'
Winget-Install 'Microsoft.PowerShell'

# Nerd Font for the terminal (matches yasb / nvim icons).
Scoop-Install @('JetBrainsMono-NF')

# pwsh modules used by the profile (zsh plugin analogs).
$modules = @(
    @{ Name = 'PSReadLine';      MinVersion = '2.3.0' }   # autosuggestions + predictions
    @{ Name = 'Terminal-Icons';  MinVersion = '0.10.0' }  # icons in ls/Get-ChildItem
    @{ Name = 'PSFzf';           MinVersion = '2.5.0' }   # fzf integration (Ctrl+R / Ctrl+T)
    @{ Name = 'posh-git';        MinVersion = '1.1.0' }   # git status in prompt + completion
)
foreach ($m in $modules) {
    $have = Get-Module -ListAvailable -Name $m.Name | Where-Object { $_.Version -ge [version]$m.MinVersion }
    if ($have) { Log-Skip "module $($m.Name) already installed"; continue }
    Log-Info "installing module $($m.Name)"
    try {
        Install-Module -Name $m.Name -Scope CurrentUser -Force -AllowClobber -MinimumVersion $m.MinVersion -AcceptLicense
        Log-Ok "installed $($m.Name)"
    } catch {
        Log-Warn "failed $($m.Name): $($_.Exception.Message)"
    }
}

# Link terminal settings.
$dotfiles = Get-DotfilesDir
$src = "$dotfiles\windows\terminal\settings.json"
$dst = "$Env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $src) {
    $dstDir = Split-Path $dst -Parent
    if (-not (Test-Path $dstDir)) {
        Log-Warn 'Windows Terminal LocalState dir missing - launch Terminal once, then re-run this module'
    } else {
        if (Test-Path $dst) { Backup-Path $dst }
        Copy-Item $src $dst -Force
        Log-Ok "linked $src -> $dst"
    }
} else {
    Log-Skip "no $src - skipping settings link"
}

Log-Ok 'terminal done'
