# core/qol-registry.ps1 - QoL: dark mode, clipboard history, end-task in taskbar,
# long paths, show extensions/hidden, mouse-accel off, etc.

#Requires -Version 7
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\..\lib\common.ps1"
Require-Admin
Log-Banner 'core' 'qol-registry'

# Dark mode (apps + system)
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'AppsUseLightTheme'    0
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'SystemUsesLightTheme' 0

# Clipboard history (Win+V), local-only
Set-Reg 'HKCU:\Software\Microsoft\Clipboard' 'EnableClipboardHistory'       1
Set-Reg 'HKCU:\Software\Microsoft\Clipboard' 'CloudClipboardAutomaticUpload' 0

# End Task in taskbar right-click (Win11 23H2+)
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings' 'TaskbarEndTask' 1

# Long paths (>260 chars)
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' 'LongPathsEnabled' 1

# Explorer: show extensions + hidden files, launch to This PC
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'HideFileExt'                  0
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Hidden'                       1
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'LaunchTo'                     1
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowSyncProviderNotifications' 0
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' 'ShowFrequent' 0
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' 'ShowRecent'   0

# Mouse: disable acceleration
Set-Reg 'HKCU:\Control Panel\Mouse' 'MouseSpeed'      '0' -Type String
Set-Reg 'HKCU:\Control Panel\Mouse' 'MouseThreshold1' '0' -Type String
Set-Reg 'HKCU:\Control Panel\Mouse' 'MouseThreshold2' '0' -Type String

# Sticky/filter/toggle keys: off
Set-Reg 'HKCU:\Control Panel\Accessibility\StickyKeys'        'Flags' '506' -Type String
Set-Reg 'HKCU:\Control Panel\Accessibility\Keyboard Response' 'Flags' '122' -Type String
Set-Reg 'HKCU:\Control Panel\Accessibility\ToggleKeys'        'Flags' '58'  -Type String

# Free Win+Enter for personal use (Windows reserves it for Narrator launch).
Set-Reg 'HKCU:\Software\Microsoft\Narrator\NoRoam' 'WinEnterLaunchEnabled' 0

# Alt+Tab: only windows, never browser tabs (Edge/Chrome show tabs by default).
# 0 = 20 tabs (default), 1 = 5 tabs, 2 = 3 tabs, 3 = no tabs (windows only)
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'MultiTaskingAltTabFilter' 3
# Belt-and-suspenders for Edge specifically
Set-Reg 'HKCU:\Software\Microsoft\Edge' 'AltTabSettings' 1

# PrintScreen opens Snipping Tool
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'PrintScreenKeyForSnippingEnabled' 1

# Show seconds in taskbar clock
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowSecondsInSystemClock' 1

# Verbose status on startup/shutdown
Set-Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'VerboseStatus' 1

Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Process explorer

Log-Ok 'qol-registry done'
