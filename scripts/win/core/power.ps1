# core/power.ps1 - Ultimate Performance plan + game/dev perf tweaks.

#Requires -Version 7
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\..\lib\common.ps1"
Require-Admin
Log-Banner 'core' 'power'

# Ultimate Performance plan.
# Some OEM laptops / AMD chipsets emit "Attempted to write to unsupported
# setting" from /duplicatescheme even when the duplicate succeeds; suppress.
$ultimateGuid = 'e9a42b02-d5df-448d-aa00-03f14749eb61'
$existing = (powercfg /list) -match $ultimateGuid
if (-not $existing) {
    Log-Info "duplicating Ultimate Performance scheme"
    powercfg /duplicatescheme $ultimateGuid 2>$null | Out-Null
} else {
    Log-Skip "Ultimate Performance already present"
}
powercfg /setactive $ultimateGuid 2>$null | Out-Null
Log-Ok 'power plan set to Ultimate Performance'

# HAGS (Hardware-accelerated GPU scheduling)
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'HwSchMode' 2

# MMCSS: zero throttling for foreground apps
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' 'SystemResponsiveness' 0
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile' 'NetworkThrottlingIndex' 0xFFFFFFFF
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games' 'GPU Priority' 8
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games' 'Priority' 6
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games' 'Scheduling Category' 'High' -Type String

# Win32 priority for foreground
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' 'Win32PrioritySeparation' 38

Log-Ok 'power done'
