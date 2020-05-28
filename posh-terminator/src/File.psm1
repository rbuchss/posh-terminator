#!/usr/bin/env pwsh

function Update-File {
  if ($args.Count -eq 0) {
    throw "$($MyInvocation.MyCommand): no arguments supplied`nUsage: $($MyInvocation.MyCommand) <file_0> ... <file_n>"
  }

  foreach ($file in $args) {
    if (Test-Path $file) {
      (Get-ChildItem $file).LastWriteTime = Get-Date
    } else {
      New-Item -ItemType file $file
    }
  }
}

function Set-NewLocation {
  if ($args.Count -gt 1) {
    throw "$($MyInvocation.MyCommand): multiple arguments supplied`nUsage: $($MyInvocation.MyCommand) <new-directory>"
  }

  $dir = $args[0]

  if ($null -eq $dir) {
    throw "$($MyInvocation.MyCommand): No directory name supplied"
  }

  mkdir $dir
  Set-Location $dir
}

function Test-PathsEqual {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    $Path,

    [Parameter(Mandatory)]
    $OtherPath
  )

  (Get-Item $Path | Resolve-Path).Path -eq (Get-Item $OtherPath | Resolve-Path).Path
}
