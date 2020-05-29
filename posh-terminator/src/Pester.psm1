#!/usr/bin/env pwsh

using module '.\Utlity.psm1'

<#
  Resolves long standing bug of powershell classes
  not being overwritten in the cache for a given session
#>
function Invoke-PesterInCleanSession {
  [CmdletBinding()]
  param()
  DynamicParam {
    Get-BaseParameters -Base Invoke-Pester -Excludes 'NewOutputSet'
  }

  end {
    $engine = (Get-Process -id $pid | Get-Item)
    switch -regex ($engine.Name) {
      '^(pwsh|powershell)(\.exe)?$' {
        # Cannot use splat here because params are passed to another powershell process
        $parameters = if ($PSBoundParameters.Keys.Count -gt 0) {
          ConvertFrom-PSBoundParametersToString -Parameters $PSBoundParameters
        } else {
          ''
        }

        & $_ -NoProfile -NonInteractive -NoLogo `
          -Command 'Invoke-Pester' $parameters
      }
      default { throw "$($MyInvocation.MyCommand): engine: '$_' not supported!" }
    }
  }
}
