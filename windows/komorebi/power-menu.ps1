# power-menu.ps1 — analog to bin/power-menu (walker dmenu).
# Uses Windows.Forms inputbox-style picker since Flow Launcher's dmenu isn't
# stable across versions. Bound to Alt+Shift+P via whkdrc.

Add-Type -AssemblyName System.Windows.Forms

$choices = @(
    @{ Label = '󰌾 Lock';     Action = { rundll32.exe user32.dll,LockWorkStation } }
    @{ Label = '󰤄 Sleep';    Action = { rundll32.exe powrprof.dll,SetSuspendState 0,1,0 } }
    @{ Label = '󰍃 Sign out'; Action = { shutdown.exe /l } }
    @{ Label = '󰜉 Restart';  Action = { shutdown.exe /r /t 0 } }
    @{ Label = '󰐥 Shutdown'; Action = { shutdown.exe /s /t 0 } }
)

$labels = $choices | ForEach-Object { $_.Label }

# Simple ChoiceDescription prompt — minimal UI but reliable.
$prompt = [System.Management.Automation.Host.ChoiceDescription[]]@(
    $labels | ForEach-Object { New-Object System.Management.Automation.Host.ChoiceDescription "&$_" }
)
$pick = $Host.UI.PromptForChoice('Power', 'Select:', $prompt, -1)

if ($pick -ge 0 -and $pick -lt $choices.Count) {
    $choice = $choices[$pick]
    if ($choice.Label -match 'Restart|Shutdown') {
        # Confirm destructive actions.
        $confirm = $Host.UI.PromptForChoice('Confirm', "Really $($choice.Label)?",
            [System.Management.Automation.Host.ChoiceDescription[]]@('&Cancel', '&Confirm'), 0)
        if ($confirm -ne 1) { return }
    }
    & $choice.Action
}
