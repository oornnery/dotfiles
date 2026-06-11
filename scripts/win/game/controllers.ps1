# game/controllers.ps1 - PS4/PS5 (DualShock 4 / DualSense) controller stack.
#
# Install order matters:
#   1. ViGEmBus  (kernel driver - virtual Xbox 360 / DS4 gamepad)
#   2. HidHide   (hides the real controller from games -> no double-input)
#   3. DS4Windows (GUI that ties it all together + creates profiles)
#
# Skip with $Env:SKIP_CONTROLLER_STACK='1' in win.conf.ps1.

#Requires -Version 7
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\..\lib\common.ps1"
Log-Banner 'game' 'controllers'

if ($Env:SKIP_CONTROLLER_STACK -eq '1') {
    Log-Skip 'disabled via SKIP_CONTROLLER_STACK=1'
    return
}

# Order matters: kernel driver -> hide layer -> GUI.
Winget-Install 'ViGEm.ViGEmBus'
Winget-Install 'Nefarius.HidHide'
Winget-Install 'Ryochan7.DS4Windows'

Log-Info ''
Log-Info 'Post-install (1 min manual setup):'
Log-Info '  1. Open HidHide -> Applications tab -> add DS4Windows.exe to whitelist'
Log-Info '  2. Connect your controller (USB or Bluetooth)'
Log-Info '  3. HidHide -> Devices tab -> tick the controller'
Log-Info '  4. Reboot (ViGEmBus kernel driver needs it)'
Log-Info '  5. Open DS4Windows -> it should detect the controller -> create a profile'
Log-Ok 'controllers done'
