<#
  PowerShell profile docs see:
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7
    http://akuederle.com/modify-your-powershell-prompt
    https://www.howtogeek.com/50236/customizing-your-powershell-profile/
#>

Import-Module posh-git

<# Enviroment Vars #>

# dotnet settings
$Env:DOTNET_CLI_TELEMETRY_OPTOUT = $true

# PoshGit settings
#   https://github.com/dahlbyk/posh-git/blob/master/src/GitPrompt.ps1#L899
$GitPromptSettings.DefaultPromptPath.Text = ''
$GitPromptSettings.DefaultPromptSuffix.Text = ''

<# Helper functions #>

function Pro { code $PROFILE }

function Get-CmdletAlias ($cmdletname) {
  Get-Alias |
    Where-Object -FilterScript {$_.Definition -like "$cmdletname"} |
      Format-Table -Property Definition, Name -AutoSize
}

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

function Get-WindowsReleaseId {
  # [System.Environment]::OSVersion.Version
  (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
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
  $tna = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get
  $tna.GetEnumerator() | Sort-Object Key
}

<# Aliases #>

Set-Alias -Name g -Value git
Set-Alias -Name touch -Value Update-File
Set-Alias -Name mkcd -Value Set-NewLocation
Set-Alias -Name hack -Value Find-HistoryAllSessions
Set-Alias -Name sudo -Value Start-ProcessAsAdmin

<# Powershell prompt #>

function Test-IsWindows {
  $IsLinuxEnv = (Get-Variable -Name "IsLinux" -ErrorAction Ignore) -and $IsLinux
  $IsMacOSEnv = (Get-Variable -Name "IsMacOS" -ErrorAction Ignore) -and $IsMacOS
  $IsWinEnv = !$IsLinuxEnv -and !$IsMacOSEnv
  return $IsWinEnv
}

function Test-Administrator {
  if (-not (Test-IsWindows)) { return $false }
  $user = [Security.Principal.WindowsIdentity]::GetCurrent();
  (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function global:prompt {
  $prompt = ''

  if (Test-Administrator) {
    $prompt += Write-Prompt("PS:") -ForegroundColor ([ConsoleColor]::Red)
    $prompt += Write-Prompt("root:") -ForegroundColor ([ConsoleColor]::Magenta)
  } else {
    $prompt += Write-Prompt("PS") -ForegroundColor ([ConsoleColor]::DarkCyan)
  }

  $prompt += Write-Prompt([char]0x222B) -ForegroundColor ([ConsoleColor]::Yellow)
  $prompt += Write-Prompt([Environment]::UserName) -ForegroundColor ([ConsoleColor]::Blue)
  $prompt += Write-Prompt("@") -ForegroundColor ([ConsoleColor]::Blue)
  $prompt += Write-Prompt([Environment]::MachineName.ToLower()) -ForegroundColor ([ConsoleColor]::Red)
  $prompt += Write-Prompt(" ")
  $prompt += Write-Prompt($pwd -Replace ($HOME).Replace('\', '\\'), '~') -ForegroundColor ([ConsoleColor]::Yellow)
  $prompt += & $GitPromptScriptBlock  # PoshGit
  $prompt += Write-Prompt "`n"
  $prompt += Write-Prompt([char]0x03BB) -ForegroundColor ([ConsoleColor]::Yellow)

  if ($prompt) { "$prompt " } else { " " }
}
