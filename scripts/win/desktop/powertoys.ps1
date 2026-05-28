# desktop/powertoys.ps1 - install PowerToys (launcher + ColorPicker + OCR + FancyZones + ...)

#Requires -Version 7
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\..\lib\common.ps1"
Log-Banner 'desktop' 'powertoys'

if ($Env:ENABLE_POWERTOYS -eq '0') { Log-Skip 'disabled via ENABLE_POWERTOYS=0'; return }

Winget-Install 'Microsoft.PowerToys'

Log-Info 'configure PowerToys: launcher binding = Alt+Space (see windows/whkd/whkdrc)'
Log-Ok 'powertoys done'
