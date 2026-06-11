# dev/languages.ps1 - mirrors scripts/arch/dev/languages.sh.
# Splits the install across winget (big runtimes) and scoop (companion tools)
# per the repo convention.

#Requires -Version 7
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\..\lib\common.ps1"
Log-Banner 'dev' 'languages'

# ─── Big runtimes via winget (machine-wide, in PATH, Add/Remove Programs) ─
Winget-Install 'Python.Python.3.14'
Winget-Install 'OpenJS.NodeJS.LTS'
Winget-Install 'astral-sh.uv'
Winget-Install 'GoLang.Go'
Winget-Install 'Rustlang.Rustup'
Winget-Install 'Oven-sh.Bun'
Winget-Install 'Kitware.CMake'

# ─── Python: uv-managed Python + tools (ruff, pyright, pytest) ────────────
if (Have-Command uv) {
    Log-Info 'installing Python toolchain via uv'
    uv python install
    uv python update-shell

    # Equivalent of `pacman -S ruff pyright pytest` -- but isolated per-tool.
    foreach ($tool in @('ruff', 'pyright', 'pytest', 'mypy', 'black', 'ipython')) {
        $have = uv tool list 2>$null | Select-String -SimpleMatch "$tool "
        if ($have) { Log-Skip "uv tool $tool already installed"; continue }
        Log-Info "uv tool install $tool"
        uv tool install $tool 2>$null
    }
}

# ─── Rust: rustup-init (Rustup itself was installed above) ────────────────
if (Have-Command rustup) {
    if (-not (Test-Path "$Env:USERPROFILE\.cargo\bin\cargo.exe")) {
        Log-Info 'initializing rust stable toolchain (rustup default stable)'
        rustup default stable
        rustup component add rust-analyzer clippy rustfmt
    } else {
        Log-Skip 'rust toolchain already initialized'
    }
}

# ─── Companion tools via scoop ────────────────────────────────────────────
# Skip the whole block if scoop isn't installed yet (run core/scoop from a
# non-elevated pwsh first - see core/scoop.ps1 for instructions).
if (-not (Have-Command scoop)) {
    Log-Warn 'scoop missing - skipping pnpm/fnm/lua/zig/nim/build-tools'
    Log-Info 'install scoop in a non-elevated pwsh: irm get.scoop.sh | iex'
    Log-Ok 'languages done (winget side)'
    return
}

Scoop-Install @('pnpm', 'fnm')
Scoop-Install @('lua', 'luarocks')
Scoop-Install @('zig')

# nim: only available via scoop's 'extras' bucket; skip silently if not there
$nimAvail = $null
try { $nimAvail = scoop search nim 2>$null | Select-String -SimpleMatch 'nim ' } catch {}
if ($nimAvail) { Scoop-Install @('nim') }
else           { Log-Skip 'nim not in scoop buckets (install via choosenim if needed)' }

# Build tools (also used by dev/editor for nvim-treesitter)
Scoop-Install @('gcc', 'make', 'tree-sitter')

Log-Ok 'languages done'
