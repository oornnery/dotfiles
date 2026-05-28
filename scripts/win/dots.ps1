# dots.ps1 - dotfiles command dispatcher (analog of bin/.local/bin/dots on Linux).
#
# Mirrors the Linux verb dispatch model:
#   dots setup [section|module|preset]   -> scripts/win/win.ps1
#   dots theme [list|get|set|cycle]      -> scripts/win/desktop/theme.ps1
#   dots update                          -> topgrade (winget + scoop + npm + ...)
#   dots bundle <name>                   -> open .ubundle in UniGetUI
#   dots help / dots                     -> this help

#Requires -Version 7
[CmdletBinding()]
param(
    [Parameter(Position = 0)][string]$Verb,
    [Parameter(Position = 1, ValueFromRemainingArguments = $true)][string[]]$Rest
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\lib\common.ps1"

$dotfiles   = Get-DotfilesDir
$winScripts = "$dotfiles\scripts\win"

function Show-Help {
    Write-Host ""
    Write-Host "$Bold$Cyan dots$Reset - dotfiles command dispatcher"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  dots <verb> [args...]"
    Write-Host ""
    Write-Host "$Bold""setup$Reset (scripts/win/win.ps1)"
    Write-Host "  dots setup                       interactive menu (loops)"
    Write-Host "  dots setup all                   full bootstrap"
    Write-Host "  dots setup debloat               debloat preset"
    Write-Host "  dots setup core                  all of core/"
    Write-Host "  dots setup desktop               all of desktop/"
    Write-Host "  dots setup dev                   all of dev/"
    Write-Host "  dots setup game                  all of game/"
    Write-Host "  dots setup <section>/<module>    e.g. core/debloat-appx, desktop/theme"
    Write-Host ""
    Write-Host "$Bold""theme$Reset (scripts/win/desktop/theme.ps1)"
    Write-Host "  dots theme                       interactive picker"
    Write-Host "  dots theme list                  list available themes"
    Write-Host "  dots theme get                   show active theme"
    Write-Host "  dots theme set <name>            apply a theme"
    Write-Host "  dots theme cycle                 rotate to next"
    Write-Host ""
    Write-Host "$Bold""maintenance$Reset"
    Write-Host "  dots update                      topgrade (winget + scoop + npm + ...)"
    Write-Host "  dots bundle <name>               open a UniGetUI .ubundle"
    Write-Host "                                   names: core / desktop / dev / work / game / llms / all"
    Write-Host "  dots help                        this help"
    Write-Host ""
}

# Ensure $Rest is always an array (PowerShell makes it $null when no args follow).
if (-not $Rest) { $Rest = @() }

switch -Regex ($Verb) {
    '^$|^(-h|--help|help)$' {
        Show-Help
        return
    }

    '^setup$' {
        & "$winScripts\win.ps1" @Rest
        return
    }

    '^theme$' {
        & "$winScripts\desktop\theme.ps1" @Rest
        return
    }

    '^update$' {
        if (Have-Command topgrade) {
            topgrade --yes @Rest
        } else {
            Log-Info 'topgrade missing - using winget + scoop directly'
            winget upgrade --all --silent --accept-package-agreements --accept-source-agreements
            if (Have-Command scoop) { scoop update *; scoop cleanup * }
        }
        return
    }

    '^bundle$' {
        if ($Rest.Count -eq 0) {
            Log-Err 'usage: dots bundle <core|desktop|dev|work|game|llms|all>'
            return
        }
        $name = $Rest[0]
        $bundle = if ($name -eq 'all') { "$winScripts\pkgs.ubundle" } else { "$winScripts\pkgs\$name.ubundle" }
        if (-not (Test-Path $bundle)) {
            Log-Err "no such bundle: $bundle"
            Log-Info "available: $((Get-ChildItem "$winScripts\pkgs\*.ubundle").BaseName -join ', '), all"
            return
        }
        Log-Info "opening $bundle in default handler (UniGetUI)"
        Start-Process $bundle
        return
    }

    default {
        Log-Err "unknown command: $Verb"
        Log-Info "run 'dots' for help"
        exit 1
    }
}
