Write-Host "Creating restore point"
Checkpoint-Computer -Description $config.restore_point.description -RestorePointType $config.restore_point.type
