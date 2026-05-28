# win.ps1 - Windows bootstrap dispatcher (mirrors scripts/arch/arch.sh).
#
# Run as Administrator in PowerShell 7+:
#   pwsh.exe -ExecutionPolicy Bypass -File windows\win.ps1                    # TUI menu
#   pwsh.exe -ExecutionPolicy Bypass -File windows\win.ps1 all                # full bootstrap
#   pwsh.exe -ExecutionPolicy Bypass -File windows\win.ps1 debloat            # only debloat preset
#   pwsh.exe -ExecutionPolicy Bypass -File windows\win.ps1 core               # all of core/
#   pwsh.exe -ExecutionPolicy Bypass -File windows\win.ps1 core/debloat-appx  # single module

#Requires -Version 7
[CmdletBinding()]
param([Parameter(Position = 0)][string]$Target)

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot

. "$here\lib\common.ps1"
. "$here\lib\detect.ps1"
. "$here\win.conf.ps1"

# Auto-elevate: most core/* modules need Administrator. Relaunch in a new
# elevated pwsh window if we are not already.
$wid = [Security.Principal.WindowsIdentity]::GetCurrent()
$isAdmin = [Security.Principal.WindowsPrincipal]::new($wid).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Log-Warn "not running as admin - relaunching elevated"
    $argList = @('-NoExit','-ExecutionPolicy','Bypass','-File',"`"$($MyInvocation.MyCommand.Path)`"")
    if ($Target) { $argList += $Target }
    Start-Process pwsh -Verb RunAs -ArgumentList $argList
    exit
}

Detect-System
Log-Info "host: $DMI_VENDOR / CPU=$CPU_VENDOR / GPU=$($GPU_VENDORS -join ',') / build=$WIN_BUILD"

# Module registry
$descriptions = [ordered]@{
    'core/folders'                = 'move known folders out of OneDrive'
    'core/onedrive-disable'       = 'kill OneDrive + block re-install'
    'core/scoop'                  = 'install scoop + buckets'
    'core/debloat-appx'           = 'uninstall AppX listed in pkgs/remove.txt'
    'core/debloat-capabilities'   = 'remove Windows DISM capabilities'
    'core/debloat-features'       = 'disable Windows optional features'
    'core/debloat-services'       = 'disable telemetry / unused services'
    'core/debloat-tasks'          = 'disable telemetry scheduled tasks'
    'core/debloat-registry'       = 'strip ads / Copilot / Recall / Bing'
    'core/qol-registry'           = 'dark mode, clipboard history, end-task, long paths, etc.'
    'core/power'                  = 'Ultimate Performance + game/dev perf tweaks'
    'core/winscript'              = 'apply scripts/win/winscript.json (flick9000/WinScript)'

    'desktop/terminal'            = 'Windows Terminal + Nerd Font + pwsh modules + settings'
    'desktop/theme'               = 'switch theme across starship + Terminal (mocha/tokyo/latte)'
    'desktop/powertoys'           = 'PowerToys (launcher, OCR, ColorPicker, FancyZones)'
    'desktop/wintoys'             = 'Wintoys + PC Manager + WinScript + Windhawk'
    'desktop/komorebi'            = 'komorebi tiling WM + config'
    'desktop/whkd'                = 'whkd keybinder + whkdrc'
    'desktop/yasb'                = 'yasb status bar + config'

    'dev/tools'                   = 'modern CLI stack (fzf/eza/bat/rg/lazygit/topgrade/...)'
    'dev/shell'                   = 'link pwsh profile'
    'dev/languages'               = 'Python + Node + Go + Rust + Bun + uv + pnpm + fnm + Lua + Zig + cmake'
    'dev/editor'                  = 'Neovim + VSCode + configs'
    'dev/llms'                    = 'Claude Code + Codex (+ Ollama optional)'
    'dev/wsl'                     = 'WSL2 + .wslconfig'

    'game/stack'                  = 'launchers (Steam + Epic + EA + LoL + Minecraft + ...)'
    'game/controllers'            = 'PS4/PS5 controller stack (ViGEmBus + HidHide + DS4Windows)'
    'game/bluestacks'             = 'BlueStacks 5 Android emulator (opt-in)'
}

# Presets
$presets = @{
    'all' = @(
        'core/folders', 'core/onedrive-disable',
        'core/scoop',
        'core/debloat-appx', 'core/debloat-capabilities', 'core/debloat-features',
        'core/debloat-services', 'core/debloat-tasks',
        'core/debloat-registry', 'core/qol-registry', 'core/power', 'core/winscript',
        'desktop/terminal', 'desktop/powertoys', 'desktop/wintoys',
        'desktop/komorebi', 'desktop/whkd', 'desktop/yasb',
        'dev/tools', 'dev/languages', 'dev/shell', 'dev/editor', 'dev/llms', 'dev/wsl',
        'game/stack', 'game/controllers'
        # game/bluestacks is opt-in - run manually if you want it.
    )
    'debloat' = @(
        'core/folders', 'core/onedrive-disable',
        'core/debloat-appx', 'core/debloat-capabilities', 'core/debloat-features',
        'core/debloat-services', 'core/debloat-tasks',
        'core/debloat-registry', 'core/qol-registry', 'core/winscript'
    )
    'core'    = $descriptions.Keys | Where-Object { $_ -like 'core/*' }
    'desktop' = $descriptions.Keys | Where-Object { $_ -like 'desktop/*' }
    'dev'     = $descriptions.Keys | Where-Object { $_ -like 'dev/*' }
    'game'    = $descriptions.Keys | Where-Object { $_ -like 'game/*' }
}

function Invoke-Module {
    param([string]$Id)
    $path = "$here\$Id.ps1"
    if (-not (Test-Path $path)) { Log-Err "no module: $Id ($path)"; return }

    # AppX/DISM cmdlets throw "Class not registered" on pwsh 7 / Win11 26200
    # even with -UseWindowsPowerShell. Run these in real Windows PowerShell 5.1.
    $needsWinPS = @('core/debloat-appx', 'core/debloat-capabilities', 'core/debloat-features')

    try {
        if ($needsWinPS -contains $Id) {
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $path
        } else {
            & $path                   # same-process call (no pwsh spin-up)
        }
    } catch {
        Log-Err "module $Id failed: $($_.Exception.Message)"
    }
}

function Show-Menu {
    Write-Host ""
    Write-Host "$Bold$Cyan== Windows bootstrap ==$Reset"
    Write-Host ""
    Write-Host "$Bold""Presets$Reset (run a curated group):"
    Write-Host "  all          - everything (core + desktop + dev + game)"
    Write-Host "  debloat      - debloat modules only (folders + onedrive + appx + caps + ...)"
    Write-Host "  core         - all core/* modules"
    Write-Host "  desktop      - all desktop/* modules"
    Write-Host "  dev          - all dev/* modules"
    Write-Host "  game         - all game/* modules"
    foreach ($section in 'core','desktop','dev','game') {
        Write-Host ""
        Write-Host "$Bold$section/$Reset"
        foreach ($k in $descriptions.Keys) {
            if ($k -like "$section/*") {
                Write-Host ("  {0,-32} {1}" -f $k, $descriptions[$k])
            }
        }
    }
    Write-Host ""
    Write-Host "Type a preset ('core', 'debloat', 'all', ...), a single module ('core/debloat-appx'),"
    Write-Host "or 'q' to quit."
    Write-Host ""
    return (Read-Host 'choose')
}

# Dispatch
$shortcuts = @{ 'a' = 'all'; 'd' = 'debloat'; 'c' = 'core'; 'g' = 'game' }

function Dispatch {
    param([string]$T)
    if ($shortcuts.ContainsKey($T)) { $T = $shortcuts[$T] }
    switch -Regex ($T) {
        '^$'              { return $true }   # empty -> show menu again
        '^(q|quit|exit)$' { return $false }  # quit signal
        default {
            if ($presets.ContainsKey($T))            { $presets[$T] | ForEach-Object { Invoke-Module $_ } }
            elseif ($descriptions.Contains($T))      { Invoke-Module $T }
            else {
                Log-Err "unknown target: $T"
                Log-Info "known: $(($descriptions.Keys + $presets.Keys) -join ', ')"
            }
            Write-Host ""
            Write-Host "$Green== done ==$Reset"
            return $true
        }
    }
}

# CLI mode (arg passed): dispatch once and exit.
if ($PSBoundParameters.ContainsKey('Target') -and $Target) {
    [void](Dispatch $Target)
    return
}

# Interactive mode: loop the menu until user types q/quit.
while ($true) {
    $choice = Show-Menu
    if (-not (Dispatch $choice)) { break }
}
