#!/usr/bin/env pwsh

function Get-HistoryAllSessions {
  Get-Content (Get-PSReadlineOption).HistorySavePath
}

function Find-HistoryAllSessions {
  if ($args.Count -gt 1) {
    throw "$($MyInvocation.MyCommand): multiple arguments supplied`nUsage: $($MyInvocation.MyCommand) <regexp pattern>"
  }

  $find = $args[0]

  if ($null -eq $find) {
    throw "$($MyInvocation.MyCommand): No find pattern supplied"
  }

  Get-HistoryAllSessions | Select-String -Pattern "$find" | Get-Unique
}
