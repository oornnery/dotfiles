# core/onedrive-disable.ps1 - kill OneDrive completely.
# Order matters: stop -> uninstall -> remove leftovers -> block via policy.

#Requires -Version 7
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\..\lib\common.ps1"
Require-Admin
Log-Banner 'core' 'onedrive-disable'

# 1) Stop the process
Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
Log-Ok 'OneDrive process killed'

# 2) Run the official uninstaller
$setup = @(
    "$Env:SystemRoot\SysWOW64\OneDriveSetup.exe"
    "$Env:SystemRoot\System32\OneDriveSetup.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($setup) {
    Log-Info "running $setup /uninstall"
    Start-Process -FilePath $setup -ArgumentList '/uninstall' -Wait -NoNewWindow
    Log-Ok 'OneDriveSetup /uninstall completed'
} else {
    Log-Skip 'OneDriveSetup.exe not found (already uninstalled?)'
}

# 3) Also try winget (covers the new MSIX installer)
winget uninstall --id Microsoft.OneDrive --silent 2>$null | Out-Null

# 4) Remove startup registry entries
$runKeys = @(
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run'
    'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'
)
foreach ($k in $runKeys) {
    if (Test-Path $k) {
        $names = @('OneDrive','OneDriveSetup')
        foreach ($n in $names) {
            $v = Get-ItemProperty -Path $k -Name $n -ErrorAction SilentlyContinue
            if ($v) {
                Remove-ItemProperty -Path $k -Name $n -Force -ErrorAction SilentlyContinue
                Log-Ok "removed run-key $k\$n"
            }
        }
    }
}

# 5) Remove leftover folders.
# Program/cache leftovers - safe to force-nuke (uninstall left binaries behind).
$forceNuke = @(
    "$Env:LOCALAPPDATA\Microsoft\OneDrive"
    "$Env:PROGRAMDATA\Microsoft OneDrive"
    "$Env:SystemDrive\OneDriveTemp"
)
foreach ($p in $forceNuke) {
    if (-not (Test-Path $p)) { continue }
    Remove-Item -LiteralPath $p -Recurse -Force -ErrorAction SilentlyContinue
    if (Test-Path $p) { Log-Warn "could not fully remove $p (some files locked)" }
    else              { Log-Ok "removed $p" }
}

# %USERPROFILE%\OneDrive - force-nuke by default (script is "onedrive-disable",
# not "onedrive-warn-about"). Common content is OneDrive sync metadata and
# 'Anexos' = Outlook attachment cache (Outlook re-creates it).
# Set $Env:ONEDRIVE_KEEP_USER_FOLDER='1' to keep the folder + only warn.
$userOneDrive = "$Env:USERPROFILE\OneDrive"
if (Test-Path $userOneDrive) {
    if ($Env:ONEDRIVE_KEEP_USER_FOLDER -eq '1') {
        $first = Get-ChildItem -LiteralPath $userOneDrive -Force -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $first) {
            Remove-Item -LiteralPath $userOneDrive -Recurse -Force -ErrorAction SilentlyContinue
            Log-Ok "removed empty $userOneDrive"
        } else {
            Log-Warn "$userOneDrive not empty (e.g. '$($first.Name)') - kept (ONEDRIVE_KEEP_USER_FOLDER=1)"
        }
    } else {
        Remove-Item -LiteralPath $userOneDrive -Recurse -Force -ErrorAction SilentlyContinue
        if (Test-Path $userOneDrive) {
            Log-Warn "could not fully remove $userOneDrive (some files locked - reboot and re-run)"
        } else {
            Log-Ok "removed $userOneDrive"
        }
    }
}

# 6) Unpin OneDrive from Explorer left pane (32 and 64-bit CLSIDs)
$clsids = @(
    'HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}'
    'HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}'
)
foreach ($c in $clsids) {
    if (Test-Path $c) {
        Set-ItemProperty -Path $c -Name 'System.IsPinnedToNameSpaceTree' -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        Log-Ok "unpinned $c from Explorer tree"
    }
}

# 7) Block via Group Policy (also stops new-user provisioning)
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' 'DisableFileSyncNGSC'      1
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' 'DisableFileSync'          1
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' 'DisableMeteredNetworkFileSync' 1
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' 'KFMBlockOptIn'            1

# 8) Deprovision the AppX for new accounts (already covered by remove.txt but double-tap)
Remove-AppxByName -Pattern 'Microsoft.OneDrive'
Remove-AppxByName -Pattern 'Microsoft.OneDriveSync'

Log-Ok 'onedrive-disable done'
Log-Info 'reboot recommended so Explorer fully drops the tree pin.'
