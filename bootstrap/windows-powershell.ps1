<#
  Symlink *profile.ps1 to windows-powershell config path

  Example for windows-powershell core in windows-terminal:
  λ $profile | select *

  AllUsersAllHosts       : C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1
  AllUsersCurrentHost    : C:\Windows\System32\WindowsPowerShell\v1.0\Microsoft.PowerShell_profile.ps1
  CurrentUserAllHosts    : ~\Documents\WindowsPowerShell\profile.ps1
  CurrentUserCurrentHost : ~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

  INFO: how to add a relative path symlink:
    cmd /c mklink /d ".\home\.windows-powershell" "..\windows-powershell"

    New-Item -ItemType SymbolicLink `
      -Path .\windows-powershell\profile\current_user\current_host `
      -Name Microsoft.PowerShell_profile.ps1 `
      -Value ..\..\..\..\powershell\profile\current_user\current_host\Microsoft.PowerShell_profile.ps1 `
      -Force
#>

if ($PSVersionTable.PSVersion.Major -gt 5) {
  throw "This bootstrap is intended only for the built-in Windows PowerShell! (PowerShell 5)`nExit and run from there!"
}

$profilePaths = [ordered]@{
  CurrentUserCurrentHost = @{
    config = (Split-Path $PROFILE.CurrentUserCurrentHost -Parent)
    targets = (Get-ChildItem "~/.windows-powershell/profile/current_user/current_host/*.ps1")
  }
  CurrentUserAllHosts = @{
    config = (Split-Path $PROFILE.CurrentUserAllHosts -Parent)
    targets = (Get-ChildItem "~/.windows-powershell/profile/current_user/all_hosts/*.ps1")
  }
  AllUsersCurrentHost = @{
    config = (Split-Path $PROFILE.AllUsersCurrentHost -Parent)
    targets = (Get-ChildItem "~/.windows-powershell/profile/all_users/current_host/*.ps1")
  }
  AllUsersAllHosts = @{
    config = (Split-Path $PROFILE.AllUsersAllHosts -Parent)
    targets = (Get-ChildItem "~/.windows-powershell/profile/all_users/all_hosts/*.ps1")
  }
}

foreach ($profilePath in $profilePaths.GetEnumerator()) {
  $profileName = $profilePath.Name
  $configPath = (Get-Item $profilePath.Value.config)
  $targets = $profilePath.Value.targets

  Write-Host "Linking `$PROFILE.$profileName files ..." `
    -ForegroundColor Green

  if ($targets.count -eq 0) {
    Write-Host "No targets found for linking!`n" `
      -ForegroundColor Yellow
    continue
  }

  foreach ($target in $profilePath.Value.targets) {
    Write-Output "-> '$target'"
    # Powershell appears to not allow a hard-link to a symbolic one...
    Write-Host "New-Item -ItemType SymbolicLink -Path $configPath -Name $($target.Name) -Value $target"
    New-Item -ItemType SymbolicLink -Path $configPath -Name $target.Name -Value $target -Confirm -Force
  }

  Write-Host ''
}
