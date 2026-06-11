# game/stack.ps1 - game launchers (Steam, Epic, EA, LoL, Minecraft, ...).
# Controller stack lives in game/controllers.ps1.
# BlueStacks (Android emulator) lives in game/bluestacks.ps1 (opt-in).

#Requires -Version 7
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\..\lib\common.ps1"
Log-Banner 'game' 'stack'

# Configurable via $Env:GAME_LAUNCHERS in win.conf.ps1.
$launchers = if ($Env:GAME_LAUNCHERS) { $Env:GAME_LAUNCHERS -split ',' } else {
    @(
        'Valve.Steam',
        'EpicGames.EpicGamesLauncher',
        'ElectronicArts.EADesktop',
        'RiotGames.LeagueOfLegends.BR',
        'Mojang.MinecraftLauncher',
        'Overwolf.CurseForge',
        'Blitz.Blitz'
    )
}
foreach ($id in $launchers) { Winget-Install $id.Trim() }

Log-Info 'consider also: game/controllers, game/bluestacks, core/power'
Log-Ok 'game stack done'
