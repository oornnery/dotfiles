# game/bluestacks.ps1 - BlueStacks 5 (Android emulator for mobile games).
# Heavy install, kept as its own module so users can opt-in explicitly.

#Requires -Version 7
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\..\lib\common.ps1"
Log-Banner 'game' 'bluestacks'

Winget-Install 'BlueStack.BlueStacks'

Log-Info 'First launch: pick "Performance" profile -> set RAM/cores to half your host'
Log-Info 'For best perf: enable Hyper-V / virtualization in BIOS if not already on'
Log-Ok 'bluestacks done'
