# core/debloat-features.ps1 - disable Windows optional features.

# NOTE: runs in Windows PowerShell 5.1 (dispatched by win.ps1).
#Requires -Version 5.1
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\..\lib\common.ps1"
Require-Admin
Log-Banner 'core' 'debloat-features'

$features = @(
    'WorkFolders-Client'
    'Printing-XPSServices-Features'
    'Internet-Explorer-Optional-amd64'
    'WindowsMediaPlayer'
    'MicrosoftWindowsPowerShellV2'
    'MicrosoftWindowsPowerShellV2Root'
    'FaxServicesClientPackage'
)

foreach ($f in $features) {
    $state = Get-WindowsOptionalFeature -Online -FeatureName $f -ErrorAction SilentlyContinue
    if (-not $state) { Log-Skip "not present: $f"; continue }
    if ($state.State -eq 'Disabled') { Log-Skip "already disabled: $f"; continue }
    try {
        Disable-WindowsOptionalFeature -Online -FeatureName $f -NoRestart -ErrorAction Stop | Out-Null
        Log-Ok "disabled feature: $f"
    } catch {
        Log-Warn "failed: $f - $($_.Exception.Message)"
    }
}

Log-Ok 'debloat-features done'
