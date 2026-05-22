# bootstrap.ps1 — first-run setup: core tools + user-folder relocation + shell profile.
#
# Run as Administrator in PowerShell 7+:
#   pwsh.exe -ExecutionPolicy Bypass -File windows\scripts\bootstrap.ps1
#
# Idempotent: re-running skips already-installed pkgs and won't overwrite a
# customized profile (you'll be prompted).

#Requires -Version 7
$ErrorActionPreference = 'Stop'

$dotfiles = if ($Env:DOTFILES_DIR) { $Env:DOTFILES_DIR } else { "$Env:USERPROFILE\dotfiles" }
$userProfile = [Environment]::GetFolderPath('UserProfile')

Write-Host '== Bootstrap: core tools + folders + profile ==' -ForegroundColor Cyan

# ─── Core CLIs via winget ─────────────────────────────────────────────────

Write-Host '[1/4] Installing core tools via winget' -ForegroundColor Yellow
$wingetPkgs = @(
    'astral-sh.uv',                  # Python toolchain (replaces pip/venv/pyenv)
    'Git.Git',
    'GitHub.cli',
    'Microsoft.PowerShell',          # pwsh 7
    'Microsoft.WindowsTerminal',
    'JanDeDobbeleer.OhMyPosh',       # prompt (alt to starship)
    'MartiCliment.UniGetUI',         # GUI package manager
    'flick9000.WinScript'            # debloat config (see winscript.json)
)
foreach ($pkg in $wingetPkgs) {
    winget install --id $pkg --silent --accept-package-agreements --accept-source-agreements 2>$null
}

# uv: install Python toolchain it manages.
if (Get-Command uv -ErrorAction SilentlyContinue) {
    uv python install
    uv python update-shell
}

# ─── User folders out of OneDrive (back to %USERPROFILE%\…) ──────────────

Write-Host '[2/4] Relocating known user folders out of OneDrive' -ForegroundColor Yellow

$oneDriveRoot = Join-Path $userProfile 'OneDrive'

function Set-KnownFolderPath {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$RelativePath
    )
    $target = Join-Path $userProfile $RelativePath
    New-Item -ItemType Directory -Path $target -Force | Out-Null
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' `
                     -Name $Name -Value "%USERPROFILE%\$RelativePath"
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders' `
                     -Name $Name -Value $target
    return $target
}

$knownFolders = @(
    @{ Name = 'Desktop';                                  RelativePath = 'Desktop' }
    @{ Name = 'Personal';                                 RelativePath = 'Documents' }
    @{ Name = '{374DE290-123F-4565-9164-39C4925E467B}';   RelativePath = 'Downloads' }
    @{ Name = 'My Pictures';                              RelativePath = 'Pictures' }
    @{ Name = 'My Music';                                 RelativePath = 'Music' }
    @{ Name = 'My Video';                                 RelativePath = 'Videos' }
    @{ Name = 'Favorites';                                RelativePath = 'Favorites' }
    @{ Name = 'Links';                                    RelativePath = 'Links' }
    @{ Name = 'Searches';                                 RelativePath = 'Searches' }
    @{ Name = 'Contacts';                                 RelativePath = 'Contacts' }
    @{ Name = '{4C5C32FF-BB9D-43B0-BF5C-BAEC0C46B74A}';   RelativePath = 'Saved Games' }
)

foreach ($folder in $knownFolders) {
    $current = (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders' `
                                 -Name $folder.Name -ErrorAction SilentlyContinue).$($folder.Name)
    $target = Set-KnownFolderPath -Name $folder.Name -RelativePath $folder.RelativePath

    # If it was inside OneDrive, move existing contents back.
    if ($current -and $current -like "$oneDriveRoot*" -and ($current -ne $target)) {
        if (Test-Path $current) {
            Get-ChildItem -Path $current -Force -ErrorAction SilentlyContinue | ForEach-Object {
                Move-Item -Path $_.FullName -Destination $target -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

# Apply without reboot.
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Process explorer

# ─── PowerShell profile (link to dotfiles) ───────────────────────────────

Write-Host '[3/4] Linking PowerShell profile' -ForegroundColor Yellow
$profileDir = "$userProfile\Documents\PowerShell"
$profilePath = "$profileDir\Microsoft.PowerShell_profile.ps1"
$profileSrc = "$dotfiles\windows\PowerShell\Microsoft.PowerShell_profile.ps1"

New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
if (Test-Path $profilePath) {
    Move-Item $profilePath "$profilePath.bak.$(Get-Date -Format yyyyMMddHHmmss)" -Force
    Write-Host "  - backed up existing profile" -ForegroundColor DarkYellow
}
Copy-Item $profileSrc $profilePath -Force
Write-Host "  - copied $profileSrc -> $profilePath" -ForegroundColor Green

# ─── WSL config ──────────────────────────────────────────────────────────

Write-Host '[4/4] Linking .wslconfig' -ForegroundColor Yellow
Copy-Item "$dotfiles\windows\.wslconfig" "$userProfile\.wslconfig" -Force
Write-Host "  - $userProfile\.wslconfig" -ForegroundColor Green

Write-Host ''
Write-Host '== Bootstrap done ==' -ForegroundColor Green
Write-Host 'Next:  pwsh.exe -ExecutionPolicy Bypass -File windows\scripts\desktop.ps1'
Write-Host '       (installs komorebi + yasb + whkd + PowerToys + modern CLIs)'
