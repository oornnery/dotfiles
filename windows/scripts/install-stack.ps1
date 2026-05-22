# install-stack.ps1 — bootstrap komorebi + yasb + whkd + Flow Launcher + tools.
#
# Run as Administrator in PowerShell 7+:
#   pwsh.exe -ExecutionPolicy Bypass -File windows\scripts\install-stack.ps1
#
# Uses scoop where possible (no admin needed once scoop bootstrapped) and
# falls back to winget for desktop apps.

#Requires -Version 7

$ErrorActionPreference = 'Stop'

Write-Host '== Windows desktop stack bootstrap ==' -ForegroundColor Cyan

# ─── Scoop ─────────────────────────────────────────────────────────────────
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host '[1/6] Installing scoop' -ForegroundColor Yellow
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
}

scoop bucket add extras  2>$null
scoop bucket add nerd-fonts 2>$null
scoop bucket add komorebi  https://github.com/LGUG2Z/komorebi-bucket 2>$null

# ─── Core: komorebi + whkd + yasb ──────────────────────────────────────────
Write-Host '[2/6] Installing komorebi + whkd + yasb' -ForegroundColor Yellow
scoop install komorebi whkd
# yasb is distributed on Scoop as 'yasb' (statusbar)
scoop install yasb

# ─── Launcher: Flow Launcher (walker analog) ──────────────────────────────
Write-Host '[3/6] Installing Flow Launcher (walker analog)' -ForegroundColor Yellow
winget install --id Flow-Launcher.Flow-Launcher --silent --accept-package-agreements --accept-source-agreements

# ─── Terminal + shell tools ───────────────────────────────────────────────
Write-Host '[4/6] Installing terminal + shell tools' -ForegroundColor Yellow
scoop install pwsh starship zoxide fzf bat eza ripgrep fd sd dust duf bottom delta jless git-delta
scoop install JetBrainsMono-NF                                  # Nerd font for yasb/term
winget install Microsoft.WindowsTerminal --silent 2>$null       # in case not already installed

# ─── Pickers / convenience ────────────────────────────────────────────────
Write-Host '[5/6] Installing pickers + AI clis' -ForegroundColor Yellow
scoop install lazygit lazydocker glow
# Claude Code official installer (mirrors scripts/arch/dev/llms.sh)
iwr https://claude.ai/install.sh -OutFile $env:TEMP\claude-install.sh
# Codex via npm
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { scoop install nodejs }
npm install -g @openai/codex 2>$null

# ─── Stow-style config linking ────────────────────────────────────────────
Write-Host '[6/6] Linking configs (admin junctions)' -ForegroundColor Yellow
$dotfiles = if ($Env:DOTFILES_DIR) { $Env:DOTFILES_DIR } else { "$Env:USERPROFILE\dotfiles" }
$pairs = @(
    @{ src = "$dotfiles\windows\komorebi"; dst = "$Env:USERPROFILE\.config\komorebi" }
    @{ src = "$dotfiles\windows\whkd";     dst = "$Env:USERPROFILE\.config\whkdrc"   }
    @{ src = "$dotfiles\windows\yasb";     dst = "$Env:USERPROFILE\.config\yasb"     }
)
foreach ($p in $pairs) {
    $parent = Split-Path $p.dst -Parent
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
    if (Test-Path $p.dst) {
        Write-Host "  - $($p.dst) exists; backing up to .bak" -ForegroundColor DarkYellow
        Move-Item $p.dst "$($p.dst).bak"
    }
    # whkdrc is a FILE, others are DIRs
    if ($p.src -like '*whkd*') {
        Copy-Item "$($p.src)\whkdrc" $p.dst
    } else {
        New-Item -ItemType Junction -Path $p.dst -Target $p.src | Out-Null
    }
    Write-Host "  - linked $($p.src) -> $($p.dst)" -ForegroundColor Green
}

Write-Host ''
Write-Host '== Done ==' -ForegroundColor Green
Write-Host 'Next steps:'
Write-Host '  1. Restart your terminal session (or run `pwsh`).'
Write-Host '  2. Start the stack:'
Write-Host '       komorebic start --whkd --bar'
Write-Host '     (this also starts yasb if --bar is supported in your komorebi version,'
Write-Host '      otherwise run `yasb` separately in a second terminal.)'
Write-Host '  3. Add the autostart shortcut: place a .lnk pointing to'
Write-Host '       komorebic.exe start --whkd --bar'
Write-Host "     into  shell:startup  ($Env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup)"
