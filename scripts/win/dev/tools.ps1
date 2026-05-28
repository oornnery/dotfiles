# dev/tools.ps1 - modern CLI stack (mirrors scripts/arch/dev/tools.sh).
# Languages/runtimes live in dev/languages.ps1.

#Requires -Version 7
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\..\lib\common.ps1"
Log-Banner 'dev' 'tools'

$wingetIds = @(
    'Git.Git',
    'GitHub.cli',
    'Microsoft.PowerShell',
    'Starship.Starship',            # prompt - winget so it works pre-scoop
    'JanDeDobbeleer.OhMyPosh',
    'MartiCliment.UniGetUI',
    'flick9000.WinScript'
)
foreach ($id in $wingetIds) { Winget-Install $id }

Scoop-Install @(
    'zoxide','fzf','bat','eza','ripgrep','fd','sd',
    'dust','duf','bottom','delta','jless','jq',
    'lazygit','lazydocker','glow','hyperfine','tokei',
    'topgrade'                      # one-shot updater (winget + scoop + npm + ...)
)

Log-Ok 'tools done'
