#!/usr/bin/env pwsh

function Set-CDPathLocation {
  [CmdletBinding()]
  param(
    [Parameter(
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true,
      Position = 0
    )]
    [ArgumentCompleter( {
      param($commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameters)

      if ($wordToComplete -match '^([a-zA-Z]{1}:|)(\\|/)') {
        return Find-Subdirectories -Path "$wordToComplete*" -Sanitized
      }

      if (-not $env:CDPATH) {
        return Find-Subdirectories -Path . -Pattern "$wordToComplete*" -Relative -Sanitized
      }

      $results = @()

      Get-CDPaths -Unique | ForEach-Object {
        if (Test-Path $_) {
          $result = Find-Subdirectories -Path "$_" -Pattern "$wordToComplete*" -Relative:("$_" -eq '.') -Sanitized
          if ($result) { $results += $result }
        }
      }

      if ($results.count -eq 0) { return '' }

      $results
    } )]
    [string]$Path
  )

  if (-not $Path) {
    Set-Location $env:HOME
    return
  }

  if (($Path -eq '-') -or ($Path -eq '+') -or (Test-Path $Path) -or (-not $env:CDPATH)) {
    Set-Location $Path
    return
  }

  $validChangePath = $null

  foreach ($cdPath in Get-CDPaths -Unique) {
    $changePath = Join-Path $cdPath $Path

    if (Test-Path $changePath) {
      $validChangePath = $changePath
      break
    }
  }

  if ($validChangePath) {
    Set-Location $validChangePath
    return
  }

  Set-Location $Path
}

function Get-CDPaths {
  [CmdletBinding()]
  param (
    [Parameter()]
    [switch]$Unique
  )

  if (-not $env:CDPATH) { return @() }

  $paths = $env:CDPATH.split(';') | ForEach-Object { $ExecutionContext.InvokeCommand.ExpandString($_) }

  if (-not $Unique) { return $paths }

  $results = [ordered]@{ }

  $paths | ForEach-Object {
    $resolvedPath = (Get-Item $_ | Resolve-Path).Path

    if (-not $results[$resolvedPath]) {
      $results[$resolvedPath] = $_
    }
  }

  $results.Values
}

function Find-Subdirectories {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [string]$Path,

    [string]$Pattern,

    [switch]$Relative,

    [switch]$Sanitized
  )

  $matchedDirs = if ($Pattern) {
    Get-ChildItem "$Path\$Pattern" -Directory
  } else {
    Get-ChildItem "$Path" -Directory
  }

  if (-not $matchedDirs) { return $null }

  $results = if ($Relative) {
    $matchedDirs | Resolve-Path -Relative
  } else {
    $matchedDirs | Select-Object -ExpandProperty FullName
  }

  if (-not $Sanitized) { return $results }

  $results | ForEach-Object {
    $tmp = $_ -replace "^(?!\.\\|[a-zA-Z]:\\)", ".\" -replace '$', '\'
    if ($tmp -match '\s') {
      $tmp -replace '^(.+)$', "'$tmp'"
    } else {
      $tmp
    }
  }
}
