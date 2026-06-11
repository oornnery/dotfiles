# core/winscript.ps1 - apply scripts/win/winscript.json via flick9000.WinScript.
# The JSON lives next to this script tree (it's install-script data, not a dotfile).

#Requires -Version 7
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\..\lib\common.ps1"
Require-Admin
Log-Banner 'core' 'winscript'

$config = "$PSScriptRoot\..\winscript.json"
if (-not (Test-Path $config)) {
    # Backward compat: fall back to legacy location if someone has an old layout.
    $legacy = "$(Get-DotfilesDir)\windows\winscript.json"
    if (Test-Path $legacy) { $config = $legacy }
}
if (-not (Test-Path $config)) { Log-Err "missing $config"; return }

function Find-WinScript {
    Get-ChildItem -Path "$Env:LOCALAPPDATA\Microsoft\WinGet\Packages\flick9000.WinScript*", `
                        "$Env:ProgramFiles\WinScript", `
                        "${Env:ProgramFiles(x86)}\WinScript" `
        -Filter 'WinScript.exe' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
}

$exe = Find-WinScript
if (-not $exe) {
    Log-Info 'WinScript.exe missing - installing flick9000.WinScript'
    Winget-Install 'flick9000.WinScript'
    $exe = Find-WinScript
}
if (-not $exe) {
    Log-Warn "WinScript.exe still not found after install - skipping"
    return
}

Log-Info "applying $config via $($exe.FullName)"
& $exe.FullName --config $config
Log-Ok 'winscript done'
