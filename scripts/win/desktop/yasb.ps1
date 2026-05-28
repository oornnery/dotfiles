# desktop/yasb.ps1 - install yasb + link config.

#Requires -Version 7
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\..\lib\common.ps1"
Log-Banner 'desktop' 'yasb'

if ($Env:ENABLE_YASB -eq '0') { Log-Skip 'disabled via ENABLE_YASB=0'; return }

Scoop-Install @('yasb','JetBrainsMono-NF')

$dotfiles = Get-DotfilesDir
Stow-Junction "$dotfiles\windows\yasb" "$Env:USERPROFILE\.config\yasb"

Log-Ok 'yasb done'
