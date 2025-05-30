# TODO

## Winget

```powershell
$pkgs = Get-Content -Path "" | Where-Object { $_ -notmatch '^\s*#' }
foreach ($pkg in $pkgs) {
    winget install -e --id $_ --silent
}
```

## Property

### Text Services and Input Languages

![](C:\Users\fabio\AppData\Roaming\marktext\images\2025-01-11-12-45-26-image.png)

```powershell
Get-ItemProperty -Path "HKCU:\Keyboard Layout\Toggle" -Name "Language Hotkey"

Language Hotkey : 3
PSPath          : Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\Keyboard Layout\Toggle
PSParentPath    : Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\Keyboard Layout
PSChildName     : Toggle
PSDrive         : HKCU
PSProvider      : Microsoft.PowerShell.Core\Registry
```

```powershell
Set-ItemProperty -Path "HKCU:\Keyboard Layout\Toggle" -Name "Language Hotkey" -Value 3
```



## Taskbar

![](C:\Users\fabio\AppData\Roaming\marktext\images\2025-01-11-12-55-44-image.png)

**Search**

```powershell
Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchBoxTaskbarMode"

SearchboxTaskbarMode : 0
PSPath               : Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search
PSParentPath         : Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion
PSChildName          : Search
PSDrive              : HKCU
PSProvider           : Microsoft.PowerShell.Core\Registry
```

```powershell
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchBoxTaskbarMode" -Value 0 -Type DWord -Force
```

**Task Viwer**

```powershell
Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton"

ShowTaskViewButton : 0
PSPath             : Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advance
                     d
PSParentPath       : Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer
PSChildName        : Advanced
PSDrive            : HKCU
PSProvider         : Microsoft.PowerShell.Core\Registry
```

```powershell
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -PropertyType DWord -Value 0 -Force
```

**Widgets**

```powershell
Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa"

TaskbarDa    : 0
PSPath       : Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
PSParentPath : Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer
PSChildName  : Advanced
PSDrive      : HKCU
PSProvider   : Microsoft.PowerShell.Core\Registry
```

```powershell
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -PropertyType DWord -Value 0 -Force
```



## For Developers

![](C:\Users\fabio\AppData\Roaming\marktext\images\2025-01-11-13-05-49-image.png)



**Developer Mode**

```powershell
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense"

AllowDevelopmentWithoutDevLicense : 0
PSPath                            : Microsoft.PowerShell.Core\Reg
                                    istry::HKEY_LOCAL_MACHINE\SOF
                                    TWARE\Microsoft\Windows\Curre
                                    ntVersion\AppModelUnlock
PSParentPath                      : Microsoft.PowerShell.Core\Reg
                                    istry::HKEY_LOCAL_MACHINE\SOF
                                    TWARE\Microsoft\Windows\Curre
                                    ntVersion
PSChildName                       : AppModelUnlock
PSDrive                           : HKLM
PSProvider                        : Microsoft.PowerShell.Core\Reg
                                    istrya
```

```powershell
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -PropertyType DWord -Value 0 -Force
```

**End Task**

```powershell
Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" -Name "TaskbarEndTask"

TaskbarEndTask : 1
PSPath         : Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\Curre
                 ntVersion\Explorer\Advanced\TaskbarDeveloperSettings
PSParentPath   : Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\Curre
                 ntVersion\Explorer\Advanced
PSChildName    : TaskbarDeveloperSettings
PSDrive        : HKCU
PSProvider     : Microsoft.PowerShell.Core\Registry\Registry
```

```powershell
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" -Name "TaskbarEndTask" -Value 1
```













Remover pacotes

- [ ] xpto

- [ ] Instalar WSL
  
  - [ ] Copiar configuracao do WSL

- [ ] Habilitar features
  
  - [ ] dev mode
  - [ ] sudo
  - [ ] endtask

- [ ] Rede
  
  - [ ] Desativar ipv6
  - [ ] Definir DNS
  - [ ] Ativar firewall

## Git

- [] Configurar git
