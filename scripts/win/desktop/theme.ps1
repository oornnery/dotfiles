# desktop/theme.ps1 - switch the visual theme across pwsh stack (mirrors bin/theme on Linux).
#
# Themes live in $DOTFILES_DIR/themes/<name>/ and ship a `starship.toml`.
# Windows Terminal color schemes are baked into windows/terminal/settings.json
# (one per theme); this script flips the active 'colorScheme' in the defaults.
#
# Usage (interactive or via args):
#   .\theme.ps1                        # show current + list
#   .\theme.ps1 list
#   .\theme.ps1 get
#   .\theme.ps1 set tokyo-night
#   .\theme.ps1 cycle
#
# Companion to bin/theme on Linux. Uses the SAME state file convention
# ($LOCALAPPDATA\dotfiles\active-theme) so future cross-machine sync works.

#Requires -Version 7
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\..\lib\common.ps1"

# Theme name -> Windows Terminal colorScheme name (must match settings.json).
$schemeMap = @{
    'catppuccin-mocha'  = 'Catppuccin Mocha'
    'tokyo-night'       = 'Tokyo Night'
    'catppuccin-latte'  = 'Catppuccin Latte'
}

$dotfiles  = Get-DotfilesDir
$themesDir = "$dotfiles\themes"
$stateDir  = "$Env:LOCALAPPDATA\dotfiles"
$stateFile = "$stateDir\active-theme"

function Get-Themes {
    Get-ChildItem -Path $themesDir -Directory -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Name | Sort-Object
}

function Get-Current {
    if (Test-Path $stateFile) { (Get-Content -LiteralPath $stateFile -Raw).Trim() }
    else                      { 'catppuccin-mocha' }
}

function Apply-Theme {
    param([Parameter(Mandatory)][string]$Name)
    $themeDir = "$themesDir\$Name"
    if (-not (Test-Path $themeDir)) {
        Log-Err "no such theme: $Name"
        Log-Info "available: $((Get-Themes) -join ', ')"
        return $false
    }

    # 1. starship
    $sSrc = "$themeDir\starship.toml"
    $sDst = "$Env:USERPROFILE\.config\starship.toml"
    if (Test-Path $sSrc) {
        New-Item -ItemType Directory -Path (Split-Path $sDst) -Force | Out-Null
        Copy-Item $sSrc $sDst -Force
        Log-Ok "starship -> $sDst"
    }

    # 1b. oh-my-posh (mirror of starship - used when starship is absent)
    $oSrc = "$themeDir\oh-my-posh.json"
    $oDst = "$Env:USERPROFILE\.config\oh-my-posh.json"
    if (Test-Path $oSrc) {
        Copy-Item $oSrc $oDst -Force
        Log-Ok "oh-my-posh -> $oDst"
    }

    # 2. Windows Terminal: flip the active colorScheme in profiles.defaults.
    $wtSettings = "$Env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    if (Test-Path $wtSettings) {
        $schemeName = $schemeMap[$Name]
        if (-not $schemeName) {
            Log-Warn "no Windows Terminal scheme mapped for theme '$Name' (add to \$schemeMap in theme.ps1)"
        } else {
            # Read as text to preserve comments; do a regex swap on the defaults.colorScheme line.
            $raw = Get-Content -LiteralPath $wtSettings -Raw
            $new = [regex]::Replace($raw,
                '("colorScheme"\s*:\s*)"[^"]*"',
                "`$1""$schemeName""",
                'IgnoreCase')
            if ($new -ne $raw) {
                Set-Content -LiteralPath $wtSettings -Value $new -Encoding UTF8 -NoNewline
                Log-Ok "Windows Terminal scheme -> '$schemeName'"
            } else {
                Log-Skip "Windows Terminal already on '$schemeName'"
            }
        }
    } else {
        Log-Skip "Windows Terminal settings.json not found (launch Terminal once)"
    }

    # 3. Record state
    New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
    Set-Content -LiteralPath $stateFile -Value $Name -NoNewline
    Log-Info "active-theme state -> $stateFile"

    return $true
}

# ─── CLI ──────────────────────────────────────────────────────────────────
$action = if ($args.Count -gt 0) { $args[0].ToLower() } else { 'menu' }

switch ($action) {
    'list' {
        Log-Banner 'theme' 'list'
        $cur = Get-Current
        foreach ($t in Get-Themes) {
            $marker = if ($t -eq $cur) { ' (active)' } else { '' }
            Write-Host "  $t$marker"
        }
    }

    'get' {
        Write-Output (Get-Current)
    }

    'set' {
        if ($args.Count -lt 2) { Log-Err "usage: theme.ps1 set <name>"; return }
        Log-Banner 'theme' "set $($args[1])"
        [void](Apply-Theme -Name $args[1])
        Log-Info '. $PROFILE  # to reload starship in the current session'
    }

    'cycle' {
        Log-Banner 'theme' 'cycle'
        $themes = @(Get-Themes)
        $idx = [array]::IndexOf($themes, (Get-Current))
        $next = $themes[($idx + 1) % $themes.Count]
        [void](Apply-Theme -Name $next)
        Log-Ok "now: $next"
    }

    default {
        # No arg or 'menu' -> show interactive picker.
        Log-Banner 'theme' 'menu'
        $cur = Get-Current
        Log-Info "current: $cur"
        $themes = @(Get-Themes)
        for ($i = 0; $i -lt $themes.Count; $i++) {
            $marker = if ($themes[$i] -eq $cur) { ' (active)' } else { '' }
            Write-Host "  [$($i+1)] $($themes[$i])$marker"
        }
        $pick = Read-Host "pick (1-$($themes.Count), Enter to cancel)"
        if ($pick -and $pick -match '^\d+$' -and [int]$pick -ge 1 -and [int]$pick -le $themes.Count) {
            [void](Apply-Theme -Name $themes[[int]$pick - 1])
            Log-Info '. $PROFILE  # to reload starship in the current session'
        } else {
            Log-Skip 'cancelled'
        }
    }
}
