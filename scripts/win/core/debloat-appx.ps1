# core/debloat-appx.ps1 - remove AppX/MSIX listed in pkgs/remove.txt
# (skips anything matching pkgs/keep.txt).

# NOTE: runs in Windows PowerShell 5.1 (dispatched by win.ps1) - native Appx
# cmdlets work there without the "Class not registered" issue.
#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\..\lib\common.ps1"
Require-Admin
Log-Banner 'core' 'debloat-appx'

$dotfiles = Get-DotfilesDir
$removeList = if ($Env:APPX_REMOVE_LIST) { $Env:APPX_REMOVE_LIST } else { "$dotfiles\scripts\win\pkgs\remove.txt" }
$keepList   = if ($Env:APPX_KEEP_LIST)   { $Env:APPX_KEEP_LIST }   else { "$dotfiles\scripts\win\pkgs\keep.txt" }

if (-not (Test-Path $removeList)) { Log-Err "missing $removeList"; return }

$toRemove = Get-Content $removeList | Where-Object { $_ -and -not $_.StartsWith('#') } | ForEach-Object { $_.Trim() }
$toKeep   = if (Test-Path $keepList) { Get-Content $keepList | Where-Object { $_ -and -not $_.StartsWith('#') } | ForEach-Object { ($_ -split '#')[0].Trim() } } else { @() }

foreach ($pattern in $toRemove) {
    $protected = $false
    foreach ($k in $toKeep) {
        if ($pattern -like $k -or $pattern -eq $k) { $protected = $true; break }
    }
    if ($protected) { Log-Skip "keep-list protects $pattern"; continue }
    Remove-AppxByName -Pattern $pattern
}

Log-Ok 'debloat-appx done'
