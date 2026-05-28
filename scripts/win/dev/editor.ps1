# dev/editor.ps1 - Neovim + VSCode + configs.
# nvim config is COPIED (not junction) from the Linux stow package, so the
# repo stays the source of truth but Windows treats it as a normal dir.

#Requires -Version 7
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\..\lib\common.ps1"
Log-Banner 'dev' 'editor'

Winget-Install 'Neovim.Neovim'
Winget-Install 'Microsoft.VisualStudioCode'

$dotfiles = Get-DotfilesDir

# ─── Neovim: copy from Linux stow layout -> %LOCALAPPDATA%\nvim ─
$nvimSrc = switch ($Env:NVIM_DISTRO) {
    'native' { "$dotfiles\nvim\.config\nvim"; break }
    'mini'   { "$dotfiles\nvim.mini\.config\nvim"; break }
    'lazy'   { "$dotfiles\nvim.lazy\.config\nvim"; break }
    default  { "$dotfiles\nvim.lazy\.config\nvim" }
}
$nvimDst = "$Env:LOCALAPPDATA\nvim"

if (Test-Path $nvimSrc) {
    if (Test-Path $nvimDst) {
        $item = Get-Item -LiteralPath $nvimDst -Force
        if ($item.LinkType) {
            Remove-Item -LiteralPath $nvimDst -Force -Recurse
            Log-Info "removed existing junction at $nvimDst"
        } else {
            Backup-Path $nvimDst
        }
    }
    New-Item -ItemType Directory -Path $nvimDst -Force | Out-Null
    Copy-Item -Path "$nvimSrc\*" -Destination $nvimDst -Recurse -Force
    Log-Ok "copied $nvimSrc -> $nvimDst"

    # Clean nvim plugin caches so first launch reinstalls cleanly.
    $caches = @(
        "$Env:LOCALAPPDATA\nvim-data\lazy"
        "$Env:LOCALAPPDATA\nvim-data\mason"
    )
    foreach ($c in $caches) {
        if (Test-Path $c) {
            Log-Info "cleaning $c (forces re-sync)"
            Remove-Item -LiteralPath $c -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # Native build deps for Telescope / nvim-treesitter on Windows.
    # (Also installed by dev/languages.ps1 - idempotent here so editor works standalone.)
    Scoop-Install @('gcc','make','tree-sitter')
} else {
    Log-Skip "no nvim config in $nvimSrc"
}

# ─── VSCode: settings.json + keybindings.json + extensions ─
$vscPairs = @(
    @{ Src = "$dotfiles\vscode\.config\Code\User\settings.json";    Dst = "$Env:APPDATA\Code\User\settings.json" }
    @{ Src = "$dotfiles\vscode\.config\Code\User\keybindings.json"; Dst = "$Env:APPDATA\Code\User\keybindings.json" }
)
foreach ($p in $vscPairs) {
    if (-not (Test-Path $p.Src)) { continue }
    New-Item -ItemType Directory -Path (Split-Path $p.Dst) -Force | Out-Null
    if (Test-Path $p.Dst) { Backup-Path $p.Dst }
    Copy-Item $p.Src $p.Dst -Force
    Log-Ok "copied $($p.Src) -> $($p.Dst)"
}

# Install VSCode extensions from scripts/code-extensions.sh if present.
$extScript = "$dotfiles\scripts\code-extensions.sh"
if ((Test-Path $extScript) -and (Have-Command code)) {
    Log-Info 'installing VSCode extensions from scripts/code-extensions.sh'
    Get-Content $extScript |
        Where-Object { $_ -match '^\s*code\s+--install-extension\s+(\S+)' } |
        ForEach-Object {
            $ext = ($_ -replace '^\s*code\s+--install-extension\s+(\S+).*', '$1').Trim()
            code --install-extension $ext --force 2>$null
        }
    Log-Ok 'VSCode extensions done'
}

Log-Ok 'editor done'
