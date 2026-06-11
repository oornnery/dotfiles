# cheatsheet.ps1 — analog to bin/dots-cheatsheet (walker picker + glow viewer).
# Bound to Alt+Shift+H via whkdrc.
#
# Opens a fzf-like picker over the docs/cheatsheets/*.md, then renders with
# glow piped to less (if glow is installed) — same UX as Linux.

$dotfiles = if ($Env:DOTFILES_DIR) { $Env:DOTFILES_DIR } else { "$Env:USERPROFILE\dotfiles" }
$docsDir  = Join-Path $dotfiles 'docs\cheatsheets'

if (-not (Test-Path $docsDir)) {
    [System.Windows.Forms.MessageBox]::Show("docs/cheatsheets not found at $docsDir", 'Cheatsheet', 'OK', 'Warning') | Out-Null
    return
}

$choices = Get-ChildItem $docsDir -Filter *.md | ForEach-Object { $_.BaseName }
$pick = $choices | fzf --prompt='Cheatsheet: '

if (-not $pick) { return }
$file = Join-Path $docsDir "$pick.md"

# Render with glow (best), fall back to bat, fall back to Get-Content.
if (Get-Command glow -ErrorAction SilentlyContinue) {
    if (Get-Command less -ErrorAction SilentlyContinue) {
        wt.exe -p 'PowerShell' pwsh.exe -NoProfile -Command "glow -s dark -w 90 '$file' | less -R -i"
    } else {
        wt.exe -p 'PowerShell' pwsh.exe -NoProfile -Command "glow -s dark -w 90 -p '$file'"
    }
} elseif (Get-Command bat -ErrorAction SilentlyContinue) {
    wt.exe -p 'PowerShell' pwsh.exe -NoProfile -Command "bat --paging=always --language=md '$file'"
} else {
    wt.exe -p 'PowerShell' pwsh.exe -NoProfile -Command "Get-Content '$file' | more"
}
