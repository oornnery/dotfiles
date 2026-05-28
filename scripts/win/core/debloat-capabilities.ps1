# core/debloat-capabilities.ps1 - remove Windows DISM capabilities.

# NOTE: runs in Windows PowerShell 5.1 (dispatched by win.ps1).
#Requires -Version 5.1
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\..\lib\common.ps1"
Require-Admin
Log-Banner 'core' 'debloat-capabilities'

$capabilities = @(
    'App.StepsRecorder~~~~0.0.1.0'
    'Microsoft.Windows.WordPad~~~~0.0.1.0'
    'MathRecognizer~~~~0.0.1.0'
    'Print.Fax.Scan~~~~0.0.1.0'
    'XPS.Viewer~~~~0.0.1.0'
    'Media.WindowsMediaPlayer~~~~0.0.12.0'
    'Browser.InternetExplorer~~~~0.0.11.0'
    'Microsoft.Windows.PowerShell.ISE~~~~0.0.1.0'
    'App.Support.QuickAssist~~~~0.0.1.0'
)

foreach ($cap in $capabilities) {
    $state = Get-WindowsCapability -Online -Name $cap -ErrorAction SilentlyContinue
    if (-not $state) { Log-Skip "not present: $cap"; continue }
    if ($state.State -eq 'NotPresent') { Log-Skip "already removed: $cap"; continue }
    try {
        Remove-WindowsCapability -Online -Name $cap -ErrorAction Stop | Out-Null
        Log-Ok "removed capability: $cap"
    } catch {
        Log-Warn "failed: $cap - $($_.Exception.Message)"
    }
}

Log-Ok 'debloat-capabilities done'
