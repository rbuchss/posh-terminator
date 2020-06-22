#!/usr/bin/env pwsh

using namespace System.Diagnostics.CodeAnalysis

function Set-CDPathLocation {
  [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
  param(
    [Parameter(
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true,
      Position = 0
    )]
    [ArgumentCompleter({ Complete-CDPathLocation @args })]
    [string] $Path,
    [switch] $PassThru,
    [switch] $Force
  )

  process {
    if ($null -ne $Path `
        -and $Path -match "^'(?<bare>.+)'$") {
      $Path = $matches.bare
    }

    $location = if (-not $Path) {
      $HOME
    } elseif (($Path -eq '-') `
        -or ($Path -eq '+') `
        -or (Test-Path $Path) `
        -or (-not (Get-CDPathVariable))) {
      $Path
    } else {
      $validatedPath = $null

      foreach ($directory in Get-CDPaths -Unique) {
        $subdirectory = Join-Path -Path $directory -ChildPath $Path

        if (Test-Path $subdirectory) {
          $validatedPath = $subdirectory
          break
        }
      }

      if ($validatedPath) {
        $validatedPath
      } else {
        $Path
      }
    }
  }

  end {
    if ($Force -and -not $Confirm){
      $ConfirmPreference = 'None'
    }

    if ($PSCmdlet.ShouldProcess($location, 'Set-Location')) {
      try {
        $location = Set-Location -Path $location -PassThru -ErrorAction Stop

        if ($PassThru) {
          $location
        } else {
          Write-Output $location.Path
        }
      } catch {
        $PSCmdlet.WriteError($_)
      }
    }
  }
}

function Get-CDPathVariable {
  $env:CDPATH
}

function Get-CDPaths {
  [OutputType([string[]])]
  param([switch] $Unique)

  if (-not (Get-CDPathVariable)) { return @() }

  $paths = (Get-CDPathVariable).split(';') | ForEach-Object {
    $ExecutionContext.InvokeCommand.ExpandString($_)
  }

  if (-not $Unique) { return $paths }

  $results = [ordered]@{}

  $paths | ForEach-Object {
    $resolvedPath = (Get-Item $_ | Resolve-Path).Path

    if (-not $results.Contains($resolvedPath)) {
      $results[$resolvedPath] = $_
    }
  }

  $results.Values
}

function Find-Subdirectories {
  [CmdletBinding()]
  [OutputType([System.IO.DirectoryInfo])]
  [SuppressMessage('PSReviewUnusedParameter', 'FullName')]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string[]] $Path,
    [string] $Pattern,
    [switch] $FullName
  )

  begin {
    $output = @()

    if ($Pattern -match "^'(?<bare>.+)'$") {
      $Pattern = $matches.bare
    }

    $basePath = if (-not [string]::IsNullOrEmpty($Pattern)) {
      Split-Path -Path "$Pattern*" -Parent
    }
  }

  process {
    # loop required here for non-pipeline input
    foreach ($directory in $Path) {
      $output += if ([string]::IsNullOrEmpty($Pattern)) {
        if ($directory -match "^'(?<bare>.+)'$") {
          $directory = $matches.bare
        }

        $basePath = Split-Path -Path "$directory*" -Parent

        @(Get-ChildItem -Path "$directory*" -Directory -ErrorAction Ignore -Force | ForEach-Object {
          $completionText = if (-not [string]::IsNullOrEmpty($basePath)) {
            Join-Path -Path $basePath -ChildPath $_.Name
          }
          $_ | Add-Member -NotePropertyName PathCompletionText -NotePropertyValue $completionText -PassThru
        })
      } else {
        $searchPath = Join-Path -Path $directory -ChildPath "$Pattern*"
        @(Get-ChildItem -Path $searchPath -Directory -ErrorAction Ignore -Force)
      }
    }
  }

  end {
    if ($output.Count -eq 0) { return $null }

    $output | ForEach-Object {
      $completionText = if ($FullName) {
        $_.FullName
      } elseif ([string]::IsNullOrEmpty($Pattern) `
          -and -not [string]::IsNullOrEmpty($_.PathCompletionText)) {
        $_.PathCompletionText
      } elseif (-not [string]::IsNullOrEmpty($basePath)) {
        Join-Path -Path $basePath -ChildPath $_.Name
      } else {
        $_.Name
      }

      $completionText = Join-Path -Path $completionText -ChildPath ''

      if ($completionText -match '\s') {
        $completionText = "'$completionText'"
      }

      $_ `
        | Add-Member -NotePropertyName CompletionText -NotePropertyValue $completionText -PassThru `
        | Add-Member -NotePropertyName ListItemText -NotePropertyValue $_.Name -PassThru `
        | Add-Member -NotePropertyName ToolTip -NotePropertyValue $_.FullName -PassThru
    }
  }
}

function Complete-CDPathLocation {
  [OutputType([System.Management.Automation.CompletionResult])]
  [SuppressMessage('PSReviewUnusedParameter', 'CommandName')]
  [SuppressMessage('PSReviewUnusedParameter', 'ParameterName')]
  [SuppressMessage('PSReviewUnusedParameter', 'CommandAst')]
  [SuppressMessage('PSReviewUnusedParameter', 'FakeBoundParameters')]
  param(
    $CommandName,
    $ParameterName,
    $WordToComplete,
    $CommandAst,
    $FakeBoundParameters
  )

  $results = if ($WordToComplete -match "^(')?([a-zA-Z]{1}:|~)?(\\|/)") {
    Find-Subdirectories -Path "$WordToComplete" -FullName
  } elseif (-not (Get-CDPathVariable) `
        -or $WordToComplete -match "^(')?\.{1,2}(\\|/)") {
    Find-Subdirectories -Path . -Pattern "$WordToComplete"
  } else {
    Get-CDPaths -Unique `
      | Find-Subdirectories -Pattern "$WordToComplete"
  }

  if ($null -eq $results) {
    return $WordToComplete
  }

  $results | ForEach-Object {
    [System.Management.Automation.CompletionResult]::new(
      $_.CompletionText,
      $_.ListItemText,
      'ParameterValue',
      $_.ToolTip
    )
  }
}
