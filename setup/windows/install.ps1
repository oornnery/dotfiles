# Requires -Version 7.0

using namespace System.Security.Principal

# Check if running as admin
if (-not ([SecurityPrincipal]::GetCurrent().IsInRole([SecurityPrincipal]::Builtin\Administrators))) {
    Write-Warning "You need to run this script as an administrator"
    exit
}

# Install modules
Write-Host "Installing modules"
install-module -Name powershell-yaml -Scope CurrentUser -Repository PSGallery -InstallationPolicy Trusted

# Read and parse the YAML configuration file
$config = Get-Content -Path "config.yml" | ConvertFrom-Yaml

# Set Restore point
Write-Host "Creating restore point"
Checkpoint-Computer -Description $config.restore_point.description -RestorePointType $config.restore_point.type

# Set firewall rules
if ($config.firewall -or $config.firewall.enabled) {
    Write-Host "Setting firewall rules"
    Set-NetFirewallProfile -Profile $config.firewall.profile -Enabled $config.firewall.enabled
}

# Set network
if ($config.network) {
    Write-Host "Setting network"
    # Network discovery
    if ($config.network.discovery) {
        Write-Host "Setting network discovery"
        Set-NetConnectionProfile -NetworkCategory $config.network.discovery
    }
    # File sharing
    if ($config.network.file_sharing -eq $true) {
        Write-Host "Enable file sharing"
        Set-SmbServerConfiguration -EnableSMB1Protocol true
    } else {
        Write-Host "Disabling file sharing"
        Set-SmbServerConfiguration -EnableSMB1Protocol false
    }
    # IPV6 enabled/disabled
    if ($config.network.ipv6 -eq $true) {
        Write-Host "Enable IPV6"
        Enable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6
    } else {
        Write-Host "Disabling IPV6"
        Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6
    }
    # Set DNS
    if ($config.network.dns) {
        Write-Host "Setting DNS"
        if ($config.network.dns.index -eq 0) {
            Set-DnsClientServerAddress -InterfaceIndex "*" -ServerAddresses $config.network.dns.addresses
            # foreach ($interface in Get-NetAdapter) {
            #     if ($interface.Status -eq "Up") {
            #     }
            # }
        } else {
            Set-DnsClientServerAddress -InterfaceIndex $config.network.dns.index -ServerAddresses $config.network.dns.addresses
        }
    }
    # Set-DnsClientServerAddress -InterfaceIndex <ÍNDICE_DA_INTERFACE> -ResetServerAddresses
}

# Set Windows Defender
$pathDefender = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
if ($config.windows_defender -eq $true -or $config.windows_defender.enabled -eq $true) {
    Write-Host "Enable Windows Defender"
    Set-ItemProperty -Path $pathDefender -Name "DisableAntiSpyware" -Value 0
} else {
    Write-Host "Disabling Windows Defender"
    Set-ItemProperty -Path $pathDefender -Name "DisableAntiSpyware" -Value 1
}

# Set Windows Update
$pathWindowsUpdate = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
if ($config.windows_update -eq $true -or $config.windows_update.enabled -eq $true) {
    Write-Host "Enable Windows Update"
    Set-ItemProperty -Path $pathWindowsUpdate -Name "DisableWindowsUpdateAccess" -Value 0
} else {
    Write-Host "Disabling Windows Update"
    Set-ItemProperty -Path $pathWindowsUpdate -Name "DisableWindowsUpdateAccess" -Value 1
}

# Set privacy
if ($config.privacy) {
    # Set Advertising ID
    Write-Host "Setting Advertising ID"
    $pathAdInfo = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
    $AdInfoValue = 0
    if ($config.privacy.advertising_id -eq $true -or $config.privacy.advertising_id.enabled -eq $true) {
        Write-Host "Enable advertising ID"
        $AdInfoValue = 1
    }
    Set-ItemProperty -Path $pathAdInfo -Name "Enabled" -Value $AdInfoValue
    # Set tailored experiences
    Write-Host "Setting tailored experiences"
    $pathPrivacy = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"
    $tailoredExperiencesValue = 0
    if ($config.privacy.tailored_experiences -eq $true -or $config.privacy.tailored_experiences.enabled -eq $true) {
        Write-Host "Enabling tailored experiences"
        $tailoredExperiencesValue = 1
    }
    # Set location
    Write-Host "Setting location"
    Set-ItemProperty -Path $pathPrivacy -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value $tailoredExperiencesValue
    $pathLocation = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"
    $locationValue = "Deny"
    if ($config.privacy.location -eq $true -or $config.privacy.location.enabled -eq $true) {
        Write-Host "Enabling location"
        $locationValue = "Allow"
    }
    Set-ItemProperty -Path $pathPrivacy -Name "Value" -Value $locationValue
    # Set telemetry
    Write-Host "Setting telemetry"
    $pathTelemetry = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    $pathTelemetry_c = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
    $telemetryValue = 0
    if ($config.privacy.telemetry -eq $true -or $config.privacy.telemetry.enabled -eq $true) {
        Write-Host "Enabling telemetry"
        $telemetryValue = 1
    }
    Set-ItemProperty -Path $pathTelemetry -Name "AllowTelemetry" -Value $telemetryValue
    Set-ItemProperty -Path $pathTelemetry_c -Name "AllowTelemetry" -Value $telemetryValue
}

# Set power plan
if ($config.power_plan) {
    Write-Host "Setting power plan"
    # Set power plan
    if ($config.power_plan.hibernation -in @($true, $false)) {
        powercfg -h $config.power_plan.hibernation
    }
    if ($config.power_plan.monitor_timeout_ac) {
        powercfg -change -monitor-timeout-ac $config.power_plan.monitor_timeout_ac
    }
    if ($config.power_plan.monitor_timeout_dc) {
        powercfg -change -monitor-timeout-dc $config.power_plan.monitor_timeout_dc
    }
    if ($config.power_plan.standby_timeout_ac) {
        powercfg -change -standby-timeout-ac $config.power_plan.standby_timeout_ac
    }
    if ($config.power_plan.standby_timeout_dc) {
        powercfg -change -standby-timeout-dc $config.power_plan.standby_timeout_dc
    }
}

# Set storage 
if ($config.storage) {
    Write-Host "Setting storage"
    if ($config.storage.disable_indexing_for_ssd -eq $true) {
        Write-Host "Disabling indexing for SSD"
        $drives = Get-WmiObject -Class Win32_Volume | Where-Object { $_.DriveType -eq 3 -and $_.DriveLetter -ne $null }
        foreach ($drive in $drives) {
            $indexing = $drive.IndexingEnabled
            if ($indexing) {
                $drive | Set-WmiInstance -Arguments @{IndexingEnabled = $false}
            }
        }
    }
}

# Windows bloatware
if ($config.bloatware) {
    Write-Host "Removing Windows bloatware"
    # Remove Windows bloatware
    Get-AppxPackage -AllUsers | where-object { $_.Name -notmatch "Microsoft" } | Remove-AppxPackage
    if ($config.bloatware.apps_to_remove) {
        foreach ($app in $config.bloatware.apps_to_remove) {
            Get-AppxPackage -AllUsers | where-object { $_.Name -match $app } | Remove-AppxPackage
        }
    }
}

# Set optional features
if ($config.optional_features) {
    Write-Host "Setting optional features"
    if ($config.optional_features.features_to_disable) {
        foreach ($feature in $config.optional_features.features_to_disable) {
            Disable-WindowsOptionalFeature -Online -FeatureName $feature
        }
    }
    if ($config.optional_features.features_to_enable) {
        foreach ($feature in $config.optional_features.features_to_enable) {
            Enable-WindowsOptionalFeature -Online -FeatureName $feature
        }
    }
}

# Set services
if ($config.services) {
    Write-Host "Setting services"
    if ($config.services.services_to_disable) {
        foreach ($service in $config.services.services_to_disable) {
            Stop-Service -Name $service -Force
            Set-Service -Name $service -StartupType Disabled
        }
    }
}

# Set Visual fx performance
if ($config.visual_effect) {
    Write-Host "Setting Visual fx performance"
    # Set Visual fx performance
    $pathVisualFx = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if ($config.visual_effect -eq $true -or $config.visual_effect.performance -eq $true) {
        $visualFxValue = 2
    } else {
        $visualFxValue = 0
    }
    Set-ItemProperty -Path $pathVisualFx -Name "VisualFXSetting" -Value $visualFxValue
}

# Install app from winget
if ($config.winget) {
    Write-Host "Installing apps from winget"
    foreach ($app in $config.winget.apps) {
        winget install --id $app -e
    }
}

# Set WSL 2
if ($config.wsl -or $config.wsl.enabled) {
    Write-Host "Setting WSL"
    # Enable Window Subsystem for Linux
    if (-not (Get-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online).State -eq "Enabled") {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    }
    # Enable Virtual Machine Platform
    if (-not (Get-WindowsOptionalFeature -FeatureName VirtualMachinePlatform -Online).State -eq "Enabled") {
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
    }
    # Set WSL 2 as default
    wsl --set-default-version 2
    if ($config.wsl.distribution) {
        # Install WSL 2 distribution
        wsl --install -d $config.wsl.distribution
    }
}


# Clear temp files
Write-Host "Clearing temp files"
Remove-Item -Path "$env:TEMP\*" -Recurse -Force
Write-Host "Done" 
oh-my-posh font install Hack