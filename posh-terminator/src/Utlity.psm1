#!/usr/bin/env pwsh

function Pro { code $PROFILE }

function Get-CmdletAlias ($cmdletname) {
  Get-Alias `
    | Where-Object -FilterScript {$_.Definition -like "$cmdletname"} `
    | Format-Table -Property Definition, Name -AutoSize
}

function Start-ProcessAsAdmin {
  if ($args.Count -eq 0) {
    throw "$($MyInvocation.MyCommand): no arguments supplied`nUsage: $($MyInvocation.MyCommand) <command> <args>"
  }

  # requires UAC ...
  # and does not work with AppxPackages like windows-terminal :(
  if ($args.Count -eq 1) {
    Start-Process $args[0] -Verb RunAs
  } elseif ($args.Count -gt 1) {
    Start-Process $args[0] -ArgumentList $args[1..$args.Count] -Verb RunAs
  }
}
