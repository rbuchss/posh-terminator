#!/usr/bin/env pwsh

function Test-IsWindows {
  $IsLinuxEnv = (Get-Variable -Name 'IsLinux' -ErrorAction Ignore) -and $IsLinux
  $IsMacOSEnv = (Get-Variable -Name 'IsMacOS' -ErrorAction Ignore) -and $IsMacOS
  return (-not $IsLinuxEnv -and -not $IsMacOSEnv)
}

function Get-WindowsReleaseId {
  if (-not (Test-IsWindows)) {
    throw "$($MyInvocation.MyCommand): OS is not supported; windows only!"
  }

  # [System.Environment]::OSVersion.Version
  (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
}
