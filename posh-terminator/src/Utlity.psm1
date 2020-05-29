#!/usr/bin/env pwsh

using namespace System.Management.Automation
using namespace System.Management.Automation.Internal

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

<#
  Allows for function param inheritance
  by calling this in child function:

    DynamicParam { Get-BaseParameters -Base <Parent-Function> }
#>
function Get-BaseParameters {
  param($Base, [string[]] $Includes, [string[]] $Excludes)

  $Base = Get-Command $Base
  $common = [CommonParameters].GetProperties().name

  if ($Base) {
    $dict = [RuntimeDefinedParameterDictionary]::new()

    $Base.Parameters.GetEnumerator().foreach({
      $key = $_.Key
      $value = $_.Value

      if ($key -notin $common `
          -and $value.ParameterSets.Keys -notin $Excludes `
          -and ($Includes.Count -eq 0 `
            -or $value.ParameterSets.Keys -in $Includes)) {
        $parameter = [RuntimeDefinedParameter]::new(
            $key, $value.ParameterType, $value.Attributes)
        $dict.Add($key, $parameter)
      }
    })

    return $dict
  }
}

function ConvertFrom-PSBoundParametersToString {
  [OutputType([string])]
  [CmdletBinding()]
  param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [hashtable] $Parameters
  )

  $Parameters.GetEnumerator().foreach({
    $name = $_.Key
    $value = if ($_.Value -is [hashtable]) {
      ConvertTo-String -Hashtable $_.Value
    } elseif ($_.Value -is [switch] -or $_.Value -is [bool]) {
      if ($_.Value) { '$true' } else { '$false' }
    } else {
      '"{0}"' -f (@($_.Value) -join '", "')
    }

    '-{0}: {1}' -f $name, $value
  })
}

function ConvertTo-String {
  [OutputType([string])]
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [hashtable] $Hashtable
  )

  $array = $Hashtable.GetEnumerator().foreach({
    if ($_.Value -is [hashtable]) {
      "'$($_.Key)' = $(ConvertTo-String -Hashtable $_.Value)"
    } else {
      "'$($_.Key)' = '$($_.Value)'"
    }
  })

  '@{{ {0} }}' -f ($array -join '; ')
}
