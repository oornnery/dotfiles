if (-not (Get-Module -Name PSReadLine)) {
    Import-Module PSReadLine
}
Set-PSReadLineOption -EditMode Windows

oh-my-posh init pwsh --config https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/amro.omp.json | Invoke-Expression

$Env:PATH += ";$HOME\.local\bin"

