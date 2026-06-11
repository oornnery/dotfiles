# dev/wsl.ps1 - link .wslconfig + (optionally) install WSL2.

#Requires -Version 7
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\..\lib\common.ps1"
Log-Banner 'dev' 'wsl'

$dotfiles = Get-DotfilesDir
$src = "$dotfiles\windows\.wslconfig"
$dst = "$Env:USERPROFILE\.wslconfig"

if (Test-Path $src) {
    if (Test-Path $dst) { Backup-Path $dst }
    Copy-Item $src $dst -Force
    Log-Ok "linked $src -> $dst"
} else {
    Log-Skip "no $src in repo (skipping .wslconfig link)"
}

if (-not (Have-Command wsl)) {
    Log-Info 'enabling WSL (requires reboot)'
    try {
        wsl --install --no-distribution
        Log-Ok 'wsl enabled - reboot, then `wsl --install -d Ubuntu`'
    } catch {
        Log-Warn "wsl install failed: $($_.Exception.Message)"
    }
} else {
    Log-Skip 'wsl already installed'
}
