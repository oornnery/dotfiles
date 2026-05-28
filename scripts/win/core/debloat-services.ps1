# core/debloat-services.ps1 - disable telemetry / unused services.

#Requires -Version 7
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot\..\lib\common.ps1"
Require-Admin
Log-Banner 'core' 'debloat-services'

$services = @(
    'DiagTrack'             # Connected User Experiences and Telemetry
    'dmwappushservice'      # WAP push messaging
    'RetailDemo'            # Retail demo
    'MapsBroker'            # Downloaded Maps Manager
    'WMPNetworkSvc'         # WMP network sharing
    'WerSvc'                # Windows Error Reporting
    'Fax'                   # Fax
    'RemoteRegistry'        # Remote Registry
    'WSearch'               # Windows Search (only disable if you do not use Start search)
    'PcaSvc'                # Program Compatibility Assistant
    'SharedAccess'          # ICS
    'lfsvc'                 # Geolocation
    'WbioSrvc'              # Biometrics (unless you use fingerprint/face)
)

foreach ($s in $services) { Disable-ServiceSafe -Name $s }

Log-Ok 'debloat-services done'
