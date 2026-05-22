# scratchpad.ps1 — analog to bin/scratch (Hyprland quake-style terminal).
# Bound to Alt+` via whkdrc.
#
# Toggles a single floating Windows Terminal instance with a unique title.
# komorebi's float_rules in komorebi.json catches it by title.

$title = 'Scratchpad'
$existing = Get-Process -Name WindowsTerminal -ErrorAction SilentlyContinue |
    Where-Object { $_.MainWindowTitle -eq $title }

if ($existing) {
    # Toggle visibility by minimizing / restoring.
    $sig = '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);'
    Add-Type -MemberDefinition $sig -Name Win32 -Namespace _SP -ErrorAction SilentlyContinue
    foreach ($p in $existing) {
        [_SP.Win32]::ShowWindow($p.MainWindowHandle, 9)  # SW_RESTORE
    }
} else {
    wt.exe --title $title pwsh.exe -NoLogo
}
