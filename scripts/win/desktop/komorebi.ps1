# desktop/komorebi.ps1 - install komorebi + link config.

#Requires -Version 7
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\..\lib\common.ps1"
Log-Banner 'desktop' 'komorebi'

if ($Env:ENABLE_KOMOREBI -eq '0') { Log-Skip 'disabled via ENABLE_KOMOREBI=0'; return }

Scoop-Install @('komorebi')

$dotfiles = Get-DotfilesDir
Stow-Junction "$dotfiles\windows\komorebi" "$Env:USERPROFILE\.config\komorebi"

Log-Info 'autostart: drop .lnk -> "komorebic.exe start --whkd --bar" into shell:startup'
Log-Ok 'komorebi done'
