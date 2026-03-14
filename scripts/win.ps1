winget install MartiCliment.UniGetUI flick9000.WinScript astral-sh.uv Git.Git GitHub.cli Microsoft.PowerShell

uv python install
uv python update-shell

$userProfile = [Environment]::GetFolderPath("UserProfile")
$oneDriveRoot = Join-Path $userProfile "OneDrive"

function Set-KnownFolderPath {
	param(
		[Parameter(Mandatory = $true)][string]$Name,
		[Parameter(Mandatory = $true)][string]$RelativePath
	)

	$target = Join-Path $userProfile $RelativePath
	New-Item -ItemType Directory -Path $target -Force | Out-Null

	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name $Name -Value "%USERPROFILE%\$RelativePath"
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -Name $Name -Value $target

	return $target
}

$knownFolders = @(
	@{ Name = "Desktop"; RelativePath = "Desktop" },
	@{ Name = "Personal"; RelativePath = "Documents" },
	@{ Name = "{374DE290-123F-4565-9164-39C4925E467B}"; RelativePath = "Downloads" },
	@{ Name = "My Pictures"; RelativePath = "Pictures" },
	@{ Name = "My Music"; RelativePath = "Music" },
	@{ Name = "My Video"; RelativePath = "Videos" },
	@{ Name = "Favorites"; RelativePath = "Favorites" },
	@{ Name = "Links"; RelativePath = "Links" },
	@{ Name = "Searches"; RelativePath = "Searches" },
	@{ Name = "Contacts"; RelativePath = "Contacts" },
	@{ Name = "{4C5C32FF-BB9D-43B0-BF5C-BAEC0C46B74A}"; RelativePath = "Saved Games" }
)

foreach ($folder in $knownFolders) {
	$current = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -Name $folder.Name -ErrorAction SilentlyContinue).$($folder.Name)
	$target = Set-KnownFolderPath -Name $folder.Name -RelativePath $folder.RelativePath

	if ($current -and $current -like "$oneDriveRoot*" -and ($current -ne $target)) {
		if (Test-Path $current) {
			Get-ChildItem -Path $current -Force -ErrorAction SilentlyContinue | ForEach-Object {
				Move-Item -Path $_.FullName -Destination $target -Force -ErrorAction SilentlyContinue
			}
		}
	}
}

New-Item -ItemType Directory -Path "$HOME/Documents/PowerShell" -Force | Out-Null
Copy-Item "$HOME/dotfiles/windows/PowerShell/Microsoft.PowerShell_profile.ps1" "$HOME/Documents/PowerShell/Microsoft.PowerShell_profile.ps1" -Force

# Apply folder location updates without reboot.
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Process explorer