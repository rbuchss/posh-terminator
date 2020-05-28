#!/usr/bin/env pwsh

function Get-Assemblies {
  [System.AppDomain]::CurrentDomain.GetAssemblies()
}

function Find-Type {
  param (
    [regex]$Pattern
  )
  $results = (Get-Assemblies).GetTypes() | Select-String $Pattern

  if ($results.Count -eq 0) {
    throw "$($MyInvocation.MyCommand): nothing found matching: '$Pattern'"
  }

  return $results
}

function Get-TypeAssembly {
  <#
    Lookup type assembly info based on: '[PowerShell].Assembly' syntax
  #>
  param (
    [string]$TypeName
  )
  $result = $TypeName -as [type]  # only works for public methods
  if ($result) { return $result.Assembly }

  # try the fully assembly-qualified type name search
  $result = [System.Type]::GetType($TypeName)
  if ($result) { return $result.Assembly }

  # if nothing found then search based on Find-Type
  $matchingTypes = Find-Type -Pattern $TypeName

  Write-Host "No types found exactly matching: '$TypeName'; $($matchingTypes.Count) partial matches found:`n"

  for ($index = 0; $index -lt $matchingTypes.Count; $index++) {
    Write-Host "$index`: $($matchingTypes[$index])"
  }

  $selected = Read-Host -Prompt "`nEnter selection [0-$($matchingTypes.Count)] default=0"

  try {
    $selected = [int]$selected
    if (($selected -lt 0) -or ($selected -ge $matchingTypes.Count)) {
      throw
    }
  } catch {
    throw "$($MyInvocation.MyCommand): invalid selection!"
  }

  [System.Type]::GetType($matchingTypes[$selected]).Assembly
}

function Get-TypeLocation {
  param (
    [string]$TypeName
  )
  (Get-TypeAssembly -TypeName $TypeName).Location
}

function Get-TypeLastUpdateTime {
  param (
    [string]$TypeName
  )
  Get-TypeLocation -TypeName $TypeName |
  Get-ChildItem |
  ForEach-Object LastWriteTime
}

function Get-TypeAliases {
  $tna = [PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get
  $tna.GetEnumerator() | Sort-Object Key
}
