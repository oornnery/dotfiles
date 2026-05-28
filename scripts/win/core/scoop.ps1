# core/scoop.ps1 - install scoop + buckets (extras, nerd-fonts, komorebi).
#
# IMPORTANT: scoop is meant to be installed as a regular user, NOT elevated.
# win.ps1 auto-elevates the whole bootstrap to admin, so this module:
#   - skips silently if running as admin (with a clear message)
#   - tells the user to run the one-liner from a NON-elevated pwsh
# This is a one-time manual step, then re-run the dispatcher and everything
# else (scoop-using modules) just works.

#Requires -Version 7
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\..\lib\common.ps1"
Log-Banner 'core' 'scoop'

if (Have-Command scoop) {
    Log-Skip 'scoop already installed'
    # Add the buckets we need (idempotent).
    $buckets = @(
        @{ Name = 'extras';     Url = '' }
        @{ Name = 'nerd-fonts'; Url = '' }
        @{ Name = 'komorebi';   Url = 'https://github.com/LGUG2Z/komorebi-bucket' }
    )
    foreach ($b in $buckets) {
        $existing = scoop bucket list 2>$null | Select-String -SimpleMatch $b.Name
        if ($existing) { Log-Skip "bucket $($b.Name) already added"; continue }
        if ($b.Url) { scoop bucket add $b.Name $b.Url | Out-Null } else { scoop bucket add $b.Name | Out-Null }
        Log-Ok "added bucket: $($b.Name)"
    }
    Log-Ok 'scoop done'
    return
}

# Scoop missing. Detect admin and bail with instructions (don't try to force
# install elevated - it works but the official maintainers explicitly advise
# against it and the user fights weird permission issues later).
$wid = [Security.Principal.WindowsIdentity]::GetCurrent()
$isAdmin = [Security.Principal.WindowsPrincipal]::new($wid).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Log-Warn 'scoop is missing and this session is ELEVATED.'
    Log-Warn 'scoop installs per-user and refuses admin by design. Steps:'
    Log-Info ''
    Log-Info '  1. Open a NEW, non-elevated PowerShell 7 window'
    Log-Info '  2. Run:'
    Log-Info '       Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force'
    Log-Info '       irm get.scoop.sh | iex'
    Log-Info '  3. Close that window'
    Log-Info '  4. Re-run this dispatcher (.\scripts\win\win.ps1) from admin pwsh'
    Log-Info '     - core/scoop will detect scoop and just add the buckets.'
    Log-Info ''
    return
}

# Non-elevated path: do the canonical install.
Log-Info 'installing scoop (canonical per-user install)'
try {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop
} catch {
    Log-Warn "Set-ExecutionPolicy blocked by policy - the install may still work"
}
try {
    Invoke-Expression (Invoke-RestMethod get.scoop.sh)
} catch {
    Log-Err "scoop installer failed: $($_.Exception.Message)"
    return
}

# Buckets
scoop bucket add extras     | Out-Null
scoop bucket add nerd-fonts | Out-Null
scoop bucket add komorebi 'https://github.com/LGUG2Z/komorebi-bucket' | Out-Null

Log-Ok 'scoop done'
