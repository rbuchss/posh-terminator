#!/usr/bin/env pwsh -NoProfile -NonInteractive -NoLogo

if (Get-Module -Name 'posh-terminator') {
  Remove-Module -Name posh-terminator *>$null
}

Write-Output 'Invoke-Pester test/ -EnableExit'
Invoke-Pester test/ -EnableExit
