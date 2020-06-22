#!/usr/bin/env pwsh -NoProfile -NonInteractive -NoLogo

Write-Output 'Invoke-Pester test/ -EnableExit'
Invoke-Pester test/ -EnableExit
