# common.ps1 - shared helpers (mirrors scripts/arch/lib/common.sh).
# Dot-source from modules:
#   . "$PSScriptRoot\..\lib\common.ps1"

$script:ESC    = [char]0x1B
$script:Reset  = "$ESC[0m"
$script:Cyan   = "$ESC[36m"
$script:Green  = "$ESC[32m"
$script:Yellow = "$ESC[33m"
$script:Red    = "$ESC[31m"
$script:Gray   = "$ESC[90m"
$script:Bold   = "$ESC[1m"

function Log-Banner {
    param([string]$Section, [string]$Module)
    Write-Host ""
    Write-Host "$Bold$Cyan>> [$Section] $Module$Reset"
}
function Log-Info  { Write-Host "$Cyan::$Reset $args" }
function Log-Ok    { Write-Host "$Green ok$Reset $args" }
function Log-Warn  { Write-Host "$Yellow !!$Reset $args" }
function Log-Skip  { Write-Host "$Gray .. $args$Reset" }
function Log-Err   { Write-Host "$Red xx$Reset $args" }

function Require-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = [Security.Principal.WindowsPrincipal]::new($id)
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Log-Err "this module needs Administrator. Re-run as admin."
        throw 'admin required'   # throw (caught by dispatcher) instead of exit (kills it)
    }
}

function Get-DotfilesDir {
    if ($Env:DOTFILES_DIR) { return $Env:DOTFILES_DIR }
    return "$Env:USERPROFILE\dotfiles"
}

function Backup-Path {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    $ts = Get-Date -Format 'yyyyMMddHHmmss'
    $bak = "$Path.bak.$ts"
    Move-Item -LiteralPath $Path -Destination $bak -Force
    Log-Warn "backed up $Path -> $bak"
}

# Stow-style link. Dir = junction, file = copy. Backs up pre-existing $Dst.
function Stow-Junction {
    param([Parameter(Mandatory)][string]$Src, [Parameter(Mandatory)][string]$Dst)
    if (-not (Test-Path -LiteralPath $Src)) { Log-Warn "stow: src missing $Src"; return }
    $parent = Split-Path -Parent $Dst
    if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    if (Test-Path -LiteralPath $Dst) {
        $item = Get-Item -LiteralPath $Dst -Force
        if ($item.LinkType -eq 'Junction' -or $item.LinkType -eq 'SymbolicLink') {
            Remove-Item -LiteralPath $Dst -Force -Recurse
        } else {
            Backup-Path $Dst
        }
    }
    $srcItem = Get-Item -LiteralPath $Src
    if ($srcItem.PSIsContainer) {
        New-Item -ItemType Junction -Path $Dst -Target $Src | Out-Null
    } else {
        Copy-Item -LiteralPath $Src -Destination $Dst -Force
    }
    Log-Ok "linked $Src -> $Dst"
}

function Have-Command { param([string]$Name) [bool](Get-Command $Name -ErrorAction SilentlyContinue) }

# Import a Windows-PowerShell-only module (Appx, DISM, ScheduledTasks, ...).
# On pwsh 7 these throw "Class not registered" without the compatibility shim.
function Import-WindowsCompatModule {
    param([Parameter(Mandatory)][string]$Name)
    if (Get-Module -Name $Name) { return }
    if ($PSVersionTable.PSEdition -eq 'Core') {
        try {
            Import-Module $Name -UseWindowsPowerShell -WarningAction SilentlyContinue -ErrorAction Stop
        } catch {
            Log-Warn "import $Name (compat) failed: $($_.Exception.Message)"
        }
    } else {
        Import-Module $Name -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
    }
}

function Winget-Install {
    param([Parameter(Mandatory)][string]$Id)
    $listed = winget list --id $Id --exact 2>$null | Select-String -SimpleMatch $Id
    if ($listed) { Log-Skip "winget $Id already installed"; return }
    Log-Info "winget install $Id"
    winget install --id $Id --exact --silent --accept-package-agreements --accept-source-agreements | Out-Null
}

function Scoop-Install {
    param([Parameter(Mandatory)][string[]]$Apps)
    if (-not (Have-Command scoop)) { Log-Warn "scoop missing - run core/scoop.ps1 first"; return }

    # Scoop refuses bucket/install ops in elevated sessions and often returns
    # silently (we observed `Couldn't find manifest` symptoms). Detect and
    # bail loudly with the exact command to run instead.
    $wid = [Security.Principal.WindowsIdentity]::GetCurrent()
    $isAdmin = [Security.Principal.WindowsPrincipal]::new($wid).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($isAdmin) {
        Log-Warn "scoop ops in an ELEVATED session - scoop refuses admin."
        Log-Info "Open a non-elevated pwsh and run:"
        Log-Info "    scoop install $($Apps -join ' ')"
        return
    }

    foreach ($a in $Apps) {
        $installed = scoop list $a 2>$null | Select-String -SimpleMatch $a
        if ($installed) { Log-Skip "scoop $a already installed"; continue }
        Log-Info "scoop install $a"
        scoop install $a | Out-Null
    }
}

function Set-Reg {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)]$Value,
        [ValidateSet('String','ExpandString','Binary','DWord','MultiString','QWord')]
        [string]$Type = 'DWord'
    )
    try {
        if (-not (Test-Path -LiteralPath $Path)) { New-Item -Path $Path -Force -ErrorAction Stop | Out-Null }
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force -ErrorAction Stop | Out-Null
    } catch {
        Log-Warn "reg failed: $Path\$Name - $($_.Exception.Message)"
    }
}

function Disable-ScheduledTaskSafe {
    param([Parameter(Mandatory)][string]$TaskPath, [Parameter(Mandatory)][string]$TaskName)
    try {
        Disable-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -ErrorAction Stop | Out-Null
        Log-Ok "task disabled: $TaskPath$TaskName"
    } catch {
        Log-Skip "task not found: $TaskPath$TaskName"
    }
}

function Disable-ServiceSafe {
    param([Parameter(Mandatory)][string]$Name)
    $svc = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if (-not $svc) { Log-Skip "service not found: $Name"; return }
    if ($svc.Status -eq 'Running') {
        try { Stop-Service -Name $Name -Force -ErrorAction Stop } catch {}
    }
    Set-Service -Name $Name -StartupType Disabled -ErrorAction SilentlyContinue
    Log-Ok "service disabled: $Name"
}

function Remove-AppxByName {
    param([Parameter(Mandatory)][string]$Pattern)
    Import-WindowsCompatModule Appx
    Import-WindowsCompatModule Dism       # Get-AppxProvisionedPackage lives in Dism

    $pkgs = Get-AppxPackage -AllUsers -Name $Pattern -ErrorAction SilentlyContinue
    if ($pkgs) {
        foreach ($p in $pkgs) {
            try {
                Remove-AppxPackage -Package $p.PackageFullName -AllUsers -ErrorAction Stop
                Log-Ok "removed appx: $($p.Name)"
            } catch {
                Log-Warn "failed appx: $($p.Name) - $($_.Exception.Message)"
            }
        }
    } else {
        Log-Skip "appx not found: $Pattern"
    }

    # Deprovisioning (so new users don't get it back). Get-AppxProvisionedPackage
    # can throw "Class not registered" on some pwsh 7 setups - swallow it.
    try {
        $prov = Get-AppxProvisionedPackage -Online -ErrorAction Stop | Where-Object DisplayName -Like $Pattern
        foreach ($p in $prov) {
            try {
                Remove-AppxProvisionedPackage -Online -PackageName $p.PackageName -ErrorAction Stop | Out-Null
                Log-Ok "deprovisioned: $($p.DisplayName)"
            } catch {}
        }
    } catch {
        Log-Skip "Get-AppxProvisionedPackage unavailable in this session (Dism compat shim missing)"
    }
}
