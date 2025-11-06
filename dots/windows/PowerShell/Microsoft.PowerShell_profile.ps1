# Helper: adicionar a PATH se a pasta existe e ainda não está presente
function Add-PathIfExists {
  param([Parameter(Mandatory)][string]$Dir)
  if (Test-Path $Dir) {
    if (-not ($Env:PATH -split ';' | Where-Object { $_ -ieq $Dir })) {
      $Env:PATH = "$Dir;$Env:PATH"
    }
  }
}

# Helper: import condicional de módulo
function Import-IfAvailable {
  param([Parameter(Mandatory)][string]$Name)
  if (Get-Module -ListAvailable $Name) {
    Import-Module $Name -ErrorAction SilentlyContinue
  }
}

$Modules = @(
    'PSReadLine',
    'PSFzf',
    'ZLocation',
    'Terminal-Icons',
    'posh-git',
    'PSScriptAnalyzer',
    'PSWindowsUpdate',
    'BurntToast'
)

foreach ($m in $Modules) {
    Import-IfAvailable -Name $m
}

# Enable PSReadLine Predictive IntelliSense if available
if (Get-Module -ListAvailable -Name PSReadLine) {
  Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle InlineView
  Set-PSReadLineOption -HistoryNoDuplicates -EditMode Windows
  Set-PSReadLineKeyHandler -Chord Ctrl+r -Function HistorySearchBackward
  Set-PSReadLineKeyHandler -Chord Ctrl+f -ScriptBlock { Invoke-FzfFileAndOpen }
}

# PSFzf: integra fzf com PSReadLine (requer binário fzf instalado)
if (Get-Module -ListAvailable PSFzf) {
  Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+y'
  function Invoke-FzfFileAndOpen { fzf | ForEach-Object { if ($_){ ii $_ } } }
}

# Oh My Posh: prompt tematizado (requer Nerd Font)
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
  # Use um tema padrão; substitua --config por seu tema.json se desejar
  oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/themes/1_shell.omp.json' | Invoke-Expression
  # oh-my-posh font install
}

# Notificações rápidas (BurntToast)
function Notify {
  param([Parameter(Mandatory)][string]$Text, [string]$Title="PowerShell")
  if (Get-Module -ListAvailable BurntToast) { New-BurntToastNotification -Text $Title, $Text } else { Write-Host $Text }
}

# PATHs: Go, Rust, Node (nvm-windows), Bun, PNPM, fzf
# Go: GOPATH\bin e fallback %USERPROFILE%\go\bin
if ($Env:GOPATH) { Add-PathIfExists "$Env:GOPATH\bin" } else { Add-PathIfExists "$Env:USERPROFILE\go\bin" }

# Rust: Cargo bin
Add-PathIfExists "$Env:USERPROFILE\.cargo\bin"

# Node via nvm-windows: symlink do node atual + diretório do nvm
if ($Env:NVM_SYMLINK) { Add-PathIfExists $Env:NVM_SYMLINK }
if ($Env:NVM_HOME)    { Add-PathIfExists $Env:NVM_HOME }

# Bun
Add-PathIfExists "$Env:USERPROFILE\.bun\bin"

# PNPM (instaladores recentes exportam PNPM_HOME)
if ($Env:PNPM_HOME) { Add-PathIfExists $Env:PNPM_HOME }

# fzf (se instalado por gerenciador que coloca em uma pasta padrão do usuário)
Add-PathIfExists "$Env:USERPROFILE\.local\bin"
Add-PathIfExists "$Env:USERPROFILE\scoop\shims"
Add-PathIfExists "$Env:ProgramFiles\Git\usr\bin"  # fzf também pode vir com Git em alguns setups

# Windows PowerShell/PowerShell 7 (executar uma vez para persistir no perfil de usuário)
setx GOPATH "%USERPROFILE%\go"
setx PNPM_HOME "%USERPROFILE%\AppData\Local\pnpm"

# Acrescenta ao WSLENV com conversão de path (/p) e mantém valores existentes
setx WSLENV "$($Env:WSLENV):GOPATH/p:PNPM_HOME/p"

# Utilidades

Set-Alias ll Get-ChildItem
function la { Get-ChildItem -Force }
function which { param([Parameter(Mandatory)][string]$Name) (Get-Command $Name -ErrorAction SilentlyContinue) | Format-Table -Auto }
function grep { param([Parameter(Mandatory)][string]$Pattern) if (Get-Command rg -ErrorAction SilentlyContinue) { rg $Pattern } else { Select-String -Pattern $Pattern } }

# Lint: PSScriptAnalyzer helpers
function pslint {
  param([string]$Path='.')
  if (!(Get-Module -ListAvailable PSScriptAnalyzer)) { Write-Host "PSScriptAnalyzer não instalado"; return }
  Invoke-ScriptAnalyzer -Path $Path -Recurse -Severity Warning,Error
}

# Windows Update helpers (alguns cmdlets requerem PowerShell elevado)
function wu-list   { if (Get-Module -ListAvailable PSWindowsUpdate) { Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot } else { Write-Host "PSWindowsUpdate não instalado" } }
function wu-install{ if (Get-Module -ListAvailable PSWindowsUpdate) { Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot } else { Write-Host "PSWindowsUpdate não instalado" } }

# Extrair apenas IDs do winget de uma listagem tabular
function winget-ids { param([string]$Filter) winget search $Filter | rg -o '^[^\s].*?\s{2,}([^\s]+)\s{2,}.*$' -r '$1' }

# Atualizar módulos com PSResourceGet se disponível
function psupdate {
  if (Get-Command Update-PSResource -ErrorAction SilentlyContinue) {
    Get-InstalledPSResource | ForEach-Object { try { Update-PSResource -Name $_.Name -TrustRepository -ErrorAction Stop } catch { Write-Warning $_ } }
  } elseif (Get-Command Update-Module -ErrorAction SilentlyContinue) {
    Get-InstalledModule | ForEach-Object { try { Update-Module -Name $_.Name -ErrorAction Stop } catch { Write-Warning $_ } }
  } else {
    Write-Host "Nem PSResourceGet nem PowerShellGet disponíveis"
  }
}

# --- WSL Helpers: detecção, distros, paths, UNC e execução ---

function Test-WSL { !!(Get-Command wsl.exe -ErrorAction SilentlyContinue) }

function Get-WslDistros {
  if (-not (Test-WSL)) { return @() }
  wsl.exe -l -q | Where-Object { $_ -and $_.Trim() -ne "" }
}

function Get-WslDefaultDistro {
  if (-not (Test-WSL)) { return $null }
  # Procura a distro marcada com "*" em "wsl -l -v"
  $line = wsl.exe -l -v 2>$null | Select-String '^\* '
  if ($line) {
    ($line.ToString() -replace '^\*\s+','').Split()[0]
  } else {
    $null
  }
}

# Converter caminho Windows -> WSL (usa wslpath dentro da distro)
function WinToWsl {
  param([Parameter(Mandatory)][string]$Path, [string]$Distro)
  if (-not (Test-WSL)) { throw "WSL não disponível" }
  $args = @('wslpath','-a','-u',"$Path")
  if ($Distro) { wsl.exe -d $Distro -e @args } else { wsl.exe -e @args }
}

# Converter caminho WSL -> Windows
function WslToWin {
  param([Parameter(Mandatory)][string]$Path, [string]$Distro)
  if (-not (Test-WSL)) { throw "WSL não disponível" }
  $args = @('wslpath','-a','-w',"$Path")
  if ($Distro) { wsl.exe -d $Distro -e @args } else { wsl.exe -e @args }
}

# UNC para acessar arquivos Linux via Explorer/WinAPI: \\wsl.localhost\<Distro>\...
function WslUncPath {
  param([Parameter(Mandatory)][string]$Distro, [string]$LinuxPath='/')
  $sub = ($LinuxPath -replace '^/','').Replace('/','\')
  "\\wsl.localhost\$Distro\$sub"
}

# Executar comando dentro da distro (bash -lc para expansão/shell)
function WslRun {
  param([Parameter(Mandatory)][string]$Command, [string]$Distro)
  if (-not (Test-WSL)) { throw "WSL não disponível" }
  if ($Distro) { wsl.exe -d $Distro -- bash -lc "$Command" } else { wsl.exe -- bash -lc "$Command" }
}

# Atalhos práticos
Set-Alias wdistros Get-WslDistros
Set-Alias wdef     Get-WslDefaultDistro
Set-Alias w2w      WslToWin
Set-Alias w2l      WinToWsl
# Qualidade de vida
$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"
