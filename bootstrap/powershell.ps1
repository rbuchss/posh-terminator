<#
  Symlink *profile.ps1 to powershell config path

  Example for powershell core in windows-terminal:
  λ $profile | select *

  AllUsersAllHosts       : C:\Program Files\PowerShell\6\profile.ps1
  AllUsersCurrentHost    : C:\Program Files\PowerShell\6\Microsoft.PowerShell_profile.ps1
  CurrentUserAllHosts    : ~\Documents\PowerShell\profile.ps1
  CurrentUserCurrentHost : ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

  INFO: how to add a relative path symlink:
    cmd /c mklink /d ".\home\.powershell" "..\powershell"
#>

$profilePaths = [ordered]@{
  CurrentUserCurrentHost = @{
    config = (Split-Path $PROFILE.CurrentUserCurrentHost -Parent)
    targets = (Get-ChildItem "~/.powershell/profile/current_user/current_host/*.ps1")
  }
  CurrentUserAllHosts = @{
    config = (Split-Path $PROFILE.CurrentUserAllHosts -Parent)
    targets = (Get-ChildItem "~/.powershell/profile/current_user/all_hosts/*.ps1")
  }
  AllUsersCurrentHost = @{
    config = (Split-Path $PROFILE.AllUsersCurrentHost -Parent)
    targets = (Get-ChildItem "~/.powershell/profile/all_users/current_host/*.ps1")
  }
  AllUsersAllHosts = @{
    config = (Split-Path $PROFILE.AllUsersAllHosts -Parent)
    targets = (Get-ChildItem "~/.powershell/profile/all_users/all_hosts/*.ps1")
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
    Write-Host "New-Item -ItemType HardLink -Path $configPath -Name $($target.Name) -Value $target"
    New-Item -ItemType HardLink -Path $configPath -Name $target.Name -Value $target -Confirm -Force
  }

  Write-Host ''
}
