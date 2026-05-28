# desktop/whkd.ps1 - install whkd + copy whkdrc.

#Requires -Version 7
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\..\lib\common.ps1"
Log-Banner 'desktop' 'whkd'

if ($Env:ENABLE_WHKD -eq '0') { Log-Skip 'disabled via ENABLE_WHKD=0'; return }

Scoop-Install @('whkd')

$dotfiles = Get-DotfilesDir
$src = "$dotfiles\windows\whkd\whkdrc"
$dst = "$Env:USERPROFILE\.config\whkdrc"
if (-not (Test-Path (Split-Path $dst))) { New-Item -ItemType Directory -Path (Split-Path $dst) -Force | Out-Null }
if (Test-Path $dst) { Backup-Path $dst }
Copy-Item $src $dst -Force
Log-Ok "linked $src -> $dst"
