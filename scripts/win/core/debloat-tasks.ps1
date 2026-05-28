# core/debloat-tasks.ps1 - disable telemetry / CEIP scheduled tasks.

#Requires -Version 7
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\..\lib\common.ps1"
Require-Admin
Log-Banner 'core' 'debloat-tasks'

$tasks = @(
    @{ Path = '\Microsoft\Windows\Application Experience\';                  Name = 'Microsoft Compatibility Appraiser' }
    @{ Path = '\Microsoft\Windows\Application Experience\';                  Name = 'ProgramDataUpdater' }
    @{ Path = '\Microsoft\Windows\Application Experience\';                  Name = 'StartupAppTask' }
    @{ Path = '\Microsoft\Windows\Application Experience\';                  Name = 'PcaPatchDbTask' }
    @{ Path = '\Microsoft\Windows\Autochk\';                                 Name = 'Proxy' }
    @{ Path = '\Microsoft\Windows\Customer Experience Improvement Program\'; Name = 'Consolidator' }
    @{ Path = '\Microsoft\Windows\Customer Experience Improvement Program\'; Name = 'KernelCeipTask' }
    @{ Path = '\Microsoft\Windows\Customer Experience Improvement Program\'; Name = 'UsbCeip' }
    @{ Path = '\Microsoft\Office\';                                          Name = 'OfficeTelemetryAgentLogOn' }
    @{ Path = '\Microsoft\Office\';                                          Name = 'OfficeTelemetryAgentFallBack' }
    @{ Path = '\Microsoft\Windows\DiskDiagnostic\';                          Name = 'Microsoft-Windows-DiskDiagnosticDataCollector' }
    @{ Path = '\Microsoft\Windows\Maintenance\';                             Name = 'WinSAT' }
    @{ Path = '\Microsoft\Windows\PI\';                                      Name = 'Sqm-Tasks' }
    @{ Path = '\Microsoft\Windows\Windows Error Reporting\';                 Name = 'QueueReporting' }
    @{ Path = '\Microsoft\Windows\Feedback\Siuf\';                           Name = 'DmClient' }
    @{ Path = '\Microsoft\Windows\Feedback\Siuf\';                           Name = 'DmClientOnScenarioDownload' }
    @{ Path = '\Microsoft\Windows\Power Efficiency Diagnostics\';            Name = 'AnalyzeSystem' }
)

foreach ($t in $tasks) { Disable-ScheduledTaskSafe -TaskPath $t.Path -TaskName $t.Name }

Log-Ok 'debloat-tasks done'
