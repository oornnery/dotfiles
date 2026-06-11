# detect.ps1 - populate $script:* env vars (mirrors scripts/arch/lib/detect.sh)

function Detect-System {
    $cs   = Get-CimInstance Win32_ComputerSystem
    $cpu  = Get-CimInstance Win32_Processor | Select-Object -First 1
    $gpus = Get-CimInstance Win32_VideoController

    $script:IS_LAPTOP    = [int]($cs.PCSystemType -eq 2)
    $script:DMI_VENDOR   = $cs.Manufacturer
    $script:CHASSIS_TYPE = $cs.PCSystemType

    $vendor = ($cpu.Manufacturer + ' ' + $cpu.Name).ToLower()
    $script:CPU_VENDOR =
        if     ($vendor -match 'amd|authenticamd')         { 'amd' }
        elseif ($vendor -match 'intel|genuineintel')       { 'intel' }
        else                                               { 'unknown' }

    $script:GPU_VENDORS = @()
    foreach ($g in $gpus) {
        $n = $g.Name.ToLower()
        if ($n -match 'nvidia|geforce|quadro|rtx') { $script:GPU_VENDORS += 'nvidia' }
        if ($n -match 'amd|radeon')                { $script:GPU_VENDORS += 'amd' }
        if ($n -match 'intel|uhd|hd graphics|iris'){ $script:GPU_VENDORS += 'intel' }
    }
    $script:GPU_VENDORS = $script:GPU_VENDORS | Select-Object -Unique

    $os = Get-CimInstance Win32_OperatingSystem
    $script:WIN_BUILD   = [int]$os.BuildNumber
    $script:WIN_EDITION = $os.Caption
    $script:WIN_VERSION = $os.Version

    $script:IS_WSL = 0
    $script:IS_VM  = [int]([bool](Get-Service -Name vmms,VMTools,vmhgfs -ErrorAction SilentlyContinue))
    $script:HAS_BLUETOOTH = [int]([bool](Get-PnpDevice -Class Bluetooth -ErrorAction SilentlyContinue))
}
