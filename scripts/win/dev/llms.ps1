# dev/llms.ps1 - AI CLIs + desktop apps (mirrors scripts/arch/dev/llms.sh).
# Assumes dev/languages.ps1 already installed node (some fallbacks use npm).

#Requires -Version 7
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\..\lib\common.ps1"
Log-Banner 'dev' 'llms'

if (-not (Have-Command node)) {
    Log-Warn 'node not found - run dev/languages first (some fallbacks need npm)'
}

# ── Claude Code (CLI) ──────────────────────────────────────
# Prefer official winget package; fall back to claude.ai/install.ps1.
if ($Env:ENABLE_CLAUDE_CODE -ne '0') {
    if (Have-Command claude) {
        Log-Skip 'claude already installed'
    } else {
        Winget-Install 'Anthropic.ClaudeCode'
        if (-not (Have-Command claude)) {
            Log-Info 'winget install failed - trying claude.ai/install.ps1'
            try { Invoke-Expression (Invoke-RestMethod 'https://claude.ai/install.ps1') }
            catch { Log-Warn "claude install failed: $($_.Exception.Message)" }
        }
    }
}

# ── Claude (desktop) ───────────────────────────────────────
if ($Env:ENABLE_CLAUDE_DESKTOP -ne '0') {
    Winget-Install 'Anthropic.Claude'
}

# ── Codex CLI ──────────────────────────────────────────────
# OpenAI.Codex (winget) is the official CLI, replaces msstore + npm fallback.
if ($Env:ENABLE_CODEX -ne '0') {
    if (Have-Command codex) {
        Log-Skip 'codex already installed'
    } else {
        Winget-Install 'OpenAI.Codex'
        if (-not (Have-Command codex)) {
            Log-Info 'winget install failed - falling back to npm install -g @openai/codex'
            try { npm install -g '@openai/codex' 2>$null }
            catch { Log-Warn "codex npm fallback failed: $($_.Exception.Message)" }
        }
    }
}

# ── Codex desktop (msstore) ────────────────────────────────
# Official OpenAI Codex GUI - multi-agent command center.
if ($Env:ENABLE_CODEX_DESKTOP -ne '0') {
    $listed = winget list --id '9PLM9XGG6VKS' --exact --source msstore 2>$null | Select-String -SimpleMatch '9PLM9XGG6VKS'
    if ($listed) {
        Log-Skip 'Codex desktop (msstore) already installed'
    } else {
        Log-Info 'installing Codex desktop (msstore)'
        winget install --id '9PLM9XGG6VKS' --source msstore --silent --accept-package-agreements --accept-source-agreements | Out-Null
    }
}

# ── Antigravity IDE (Google) ───────────────────────────────
# Agentic dev platform, fork of VS Code. CLI ships with the IDE.
if ($Env:ENABLE_ANTIGRAVITY -ne '0') {
    Winget-Install 'Google.AntigravityIDE'
}

# Antigravity 2.0 - standalone agent orchestrator (optional, separate from IDE).
if ($Env:ENABLE_ANTIGRAVITY_ORCH -eq '1') {
    Winget-Install 'Google.Antigravity'
}

# ── Clawd on Desk ──────────────────────────────────────────
# Desktop companion pet reacting to Claude Code / Codex / Copilot / Gemini /
# Cursor / opencode in real time. Pixel crab + Calico themes.
if ($Env:ENABLE_CLAWD -ne '0') {
    Winget-Install 'rullerzhou-afk.clawd-on-desk'
}

# ── OmniRoute desktop ──────────────────────────────────────
# AI gateway: one endpoint, 160+ providers. No winget pkg - pulls the latest
# NSIS installer (`OmniRoute.Setup.X.X.X.exe`) from GitHub releases and runs
# it silently. Idempotent: detects existing install via the standard NSIS
# uninstall key.
if ($Env:ENABLE_OMNIROUTE -ne '0') {
    $installed = $false
    foreach ($hive in 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
                      'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall',
                      'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall') {
        if (Test-Path $hive) {
            $hit = Get-ChildItem $hive -ErrorAction SilentlyContinue |
                ForEach-Object { Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue } |
                Where-Object { $_.DisplayName -like 'OmniRoute*' } | Select-Object -First 1
            if ($hit) { $installed = $true; break }
        }
    }
    if ($installed) {
        Log-Skip 'OmniRoute already installed'
    } else {
        try {
            Log-Info 'fetching latest OmniRoute release from GitHub'
            $rel = Invoke-RestMethod -Uri 'https://api.github.com/repos/diegosouzapw/OmniRoute/releases/latest' `
                                     -Headers @{ 'User-Agent' = 'dotfiles-bootstrap' } -ErrorAction Stop
            $asset = $rel.assets | Where-Object { $_.name -like 'OmniRoute.Setup.*.exe' } | Select-Object -First 1
            if (-not $asset) {
                Log-Warn 'no OmniRoute.Setup.*.exe in latest release'
            } else {
                $dst = Join-Path $Env:TEMP $asset.name
                Log-Info "downloading $($asset.name) (~$([math]::Round($asset.size/1MB)) MB)"
                Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $dst -UseBasicParsing -ErrorAction Stop
                Log-Info 'running silent NSIS installer'
                $proc = Start-Process -FilePath $dst -ArgumentList '/S' -Wait -PassThru
                if ($proc.ExitCode -eq 0) {
                    Log-Ok "OmniRoute $($rel.tag_name) installed"
                } else {
                    Log-Warn "OmniRoute installer exit code: $($proc.ExitCode)"
                }
                Remove-Item $dst -ErrorAction SilentlyContinue
            }
        } catch {
            Log-Warn "OmniRoute install failed: $($_.Exception.Message)"
        }
    }
}

# ── Local model runners ────────────────────────────────────
if ($Env:ENABLE_OLLAMA -eq '1')    { Winget-Install 'Ollama.Ollama' }
if ($Env:ENABLE_LM_STUDIO -eq '1') { Winget-Install 'ElementLabs.LMStudio' }

Log-Ok 'llms done'
