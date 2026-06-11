# desktop/wintoys.ps1 — install Wintoys + Microsoft PC Manager + WinScript + PowerToys.
# Note: Wintoys (Microsoft Store, MSIX) is GUI-only and does NOT consume a JSON config.
# Use it for one-click cleanup / startup tweaks. WinScript (flick9000) IS the JSON-driven
# tweaker; core/winscript.ps1 applies scripts/win/winscript.json.

#Requires -Version 7
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\..\lib\common.ps1"
Log-Banner 'desktop' 'wintoys'

# Store apps via winget (Store source) - IDs from the Microsoft Store.
$storeApps = @(
    '9P8LTPGCBZXD'    # Wintoys
    '9PM860492SZD'    # Microsoft PC Manager
)
foreach ($id in $storeApps) {
    Log-Info "winget install (msstore) $id"
    winget install --id $id --source msstore --silent --accept-package-agreements --accept-source-agreements 2>$null | Out-Null
}

# Standard winget IDs
Winget-Install 'flick9000.WinScript'
Winget-Install 'Microsoft.PowerToys'
Winget-Install 'RamenSoftware.Windhawk'

Log-Info 'WinScript JSON config: run `.\win.ps1 core/winscript` to apply scripts/win/winscript.json'
Log-Ok 'wintoys done'
