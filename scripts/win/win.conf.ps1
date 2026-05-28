# win.conf.ps1 - overrides for the Windows bootstrap (mirrors arch.conf).
# Dot-sourced by win.ps1.

$Env:USER_NAME      = $Env:USERNAME
$Env:DOTFILES_DIR   = "$Env:USERPROFILE\dotfiles"
$Env:WEATHER_CITY   = 'Sao Paulo'

# Theme: catppuccin-mocha (default) | tokyo-night | catppuccin-latte
$Env:THEME = 'catppuccin-mocha'

# Editor: mini | lazy
$Env:NVIM_DISTRO = 'lazy'

# Dev: AI clis + desktop apps
$Env:ENABLE_CLAUDE_CODE     = '1'   # Anthropic.ClaudeCode (CLI)
$Env:ENABLE_CLAUDE_DESKTOP  = '1'   # Anthropic.Claude (desktop)
$Env:ENABLE_CODEX           = '1'   # OpenAI.Codex (CLI, winget)
$Env:ENABLE_CODEX_DESKTOP   = '1'   # Codex GUI (msstore 9PLM9XGG6VKS)
$Env:ENABLE_ANTIGRAVITY     = '1'   # Google.AntigravityIDE
$Env:ENABLE_ANTIGRAVITY_ORCH= '0'   # Google.Antigravity (standalone orchestrator)
$Env:ENABLE_OMNIROUTE       = '1'   # OmniRoute desktop (GitHub release, NSIS)
$Env:ENABLE_CLAWD           = '1'   # rullerzhou-afk.clawd-on-desk
$Env:ENABLE_OLLAMA          = '0'
$Env:ENABLE_LM_STUDIO       = '0'

# Desktop stack
$Env:ENABLE_KOMOREBI    = '1'
$Env:ENABLE_YASB        = '1'
$Env:ENABLE_WHKD        = '1'
$Env:ENABLE_POWERTOYS   = '1'

# Game launchers (comma-separated winget IDs). Leave empty to use game/stack.ps1 default.
$Env:GAME_LAUNCHERS = 'Valve.Steam,EpicGames.EpicGamesLauncher,ElectronicArts.EADesktop,RiotGames.LeagueOfLegends.BR,Mojang.MinecraftLauncher,Overwolf.CurseForge,Blitz.Blitz'

# Controller stack (game/controllers): 1 = skip, 0 = install ViGEmBus+HidHide+DS4Windows.
$Env:SKIP_CONTROLLER_STACK = '0'

# BlueStacks (game/bluestacks): opt-in module - run manually:
#   .\scripts\win\win.ps1 game/bluestacks

# Debloat lists
$Env:APPX_REMOVE_LIST    = "$Env:USERPROFILE\dotfiles\scripts\win\pkgs\remove.txt"
$Env:APPX_KEEP_LIST      = "$Env:USERPROFILE\dotfiles\scripts\win\pkgs\keep.txt"
$Env:WINGET_INSTALL_LIST = "$Env:USERPROFILE\dotfiles\scripts\win\pkgs\install.txt"
