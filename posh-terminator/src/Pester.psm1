#!/usr/bin/env pwsh

<#
  Resolves long standing bug of powershell classes
  not being overwritten in the cache for a given session
#>
function Invoke-PesterClean {
  # TODO add passthru flags
  $engine = (Get-Process -id $pid | Get-Item)
  switch ($engine.Name) {
    'pwsh.exe' { pwsh.exe { Invoke-Pester } }
    'powershell.exe' { powershell.exe { Invoke-Pester } }
    default { throw "$($MyInvocation.MyCommand): process engine: '$_' for Invoke-Pester not supported!" }
  }
}
