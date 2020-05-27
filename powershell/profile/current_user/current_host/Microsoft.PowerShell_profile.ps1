<#
  PowerShell profile docs see:
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7
    http://akuederle.com/modify-your-powershell-prompt
    https://www.howtogeek.com/50236/customizing-your-powershell-profile/
#>

Import-Module posh-git

<# Enviroment Vars #>

$env:CDPATH = '.;C:\opt\sagittarius\vango;C:\opt\sagittarius;~\.homesick\repos;~\'

# dotnet settings
$Env:DOTNET_CLI_TELEMETRY_OPTOUT = $true

# PoshGit settings
$GitPromptSettings.BranchColor.ForegroundColor = [byte]69
$GitPromptSettings.IndexColor.ForegroundColor = [byte]10
$GitPromptSettings.WorkingColor.ForegroundColor = [byte]9
$GitPromptSettings.StashColor.ForegroundColor = [byte]214
$GitPromptSettings.BeforeStatus.Text = '[ '
$GitPromptSettings.BeforeStatus.ForegroundColor = [byte]8
$GitPromptSettings.AfterStatus.Text = ' ]'
$GitPromptSettings.AfterStatus.ForegroundColor = [byte]8
$GitPromptSettings.BeforeStash.Text = ' #'
$GitPromptSettings.BeforeStash.ForegroundColor = [byte]214
$GitPromptSettings.AfterStash.Text = ''
$GitPromptSettings.LocalWorkingStatusSymbol.Text = ''
$GitPromptSettings.LocalStagedStatusSymbol.Text = ''
$GitPromptSettings.EnableStashStatus = $true
$GitPromptSettings.DefaultPromptPrefix.Text = ''
$GitPromptSettings.DefaultPromptPath.Text = ''
$GitPromptSettings.DefaultPromptSuffix.Text = ''

<# Key Bindings #>

# Bash like chords for backward/forward line deletion
Set-PSReadlineKeyHandler -Chord Ctrl+u -Function BackwardDeleteLine
Set-PSReadlineKeyHandler -Chord Ctrl+k -Function ForwardDeleteLine

Set-PSReadlineKeyHandler -Chord Ctrl+LeftArrow -Function BackwardWord
Set-PSReadlineKeyHandler -Chord Ctrl+RightArrow -Function ForwardWord

# Bash like exit
Set-PSReadLineKeyHandler -Chord Ctrl+d -Function DeleteCharOrExit

<# Readline Options #>

Set-PSReadLineOption -BellStyle None

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

function Test-IsWindows {
  $IsLinuxEnv = (Get-Variable -Name 'IsLinux' -ErrorAction Ignore) -and $IsLinux
  $IsMacOSEnv = (Get-Variable -Name 'IsMacOS' -ErrorAction Ignore) -and $IsMacOS
  return (-not $IsLinuxEnv -and -not $IsMacOSEnv)
}

function Get-WindowsReleaseId {
  if (-not (Test-IsWindows)) {
    throw "$($MyInvocation.MyCommand): OS is not supported; windows only!"
  }

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
  $tna = [PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get
  $tna.GetEnumerator() | Sort-Object Key
}

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

<# Auto-Completion #>

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
  param($commandName, $wordToComplete, $cursorPosition)
  dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
  }
}

<# Aliases #>

Set-Alias -Name g -Value git
Set-Alias -Name touch -Value Update-File
Set-Alias -Name mkcd -Value Set-NewLocation
Set-Alias -Name hack -Value Find-HistoryAllSessions
Set-Alias -Name sudo -Value Start-ProcessAsAdmin
<#
  TODO: find how to make this work:
    remapping cd from Set-Location to Set-CDPathLocation
    breaks the argument completer for some reason ...
#>
# Set-Alias -Name cd -Value Set-CDPathLocation -Option AllScope
Set-Alias -Name cdd -Value Set-CDPathLocation
Set-Alias -Name pester -Value Invoke-PesterClean

<# Powershell prompt #>

$PromptStyle = @{
  PoshSymbol = 'PS'
  PoshSymbolColor = [byte]81
  PoshSeparator = [char]0x222B
  PoshSeparatorColor = [byte]186
  UserName = [Environment]::UserName
  UserColor = [byte]69
  UserSeparator = '@'
  UserSeparatorColor = [byte]69
  HostName = [Environment]::MachineName.ToLower()
  HostColor = [byte]9
  PathColor = [byte]186
  CommandSymbol = [char]0x03BB
  CommandSymbolColor = [byte]186
  ErrorSymbol = [char]0x2718
  ErrorSymbolColor = [byte]9
}

$AdminPromptStyle = $PromptStyle.Clone()
$AdminPromptStyle.PoshSymbolColor = [byte]9
$AdminPromptStyle.PoshSeparatorColor = [byte]8
$AdminPromptStyle.UserName = 'root'
$AdminPromptStyle.UserColor = [byte]9
$AdminPromptStyle.UserSeparator = '#'
$AdminPromptStyle.UserSeparatorColor = [byte]9
$AdminPromptStyle.HostColor = [byte]12
$AdminPromptStyle.PathColor = [byte]12

function prompt {
  $lastCommandStatus = $?
  $style = if (Test-IsAdministrator) {
    $AdminPromptStyle
  } else {
    $PromptStyle
  }

  Format-Prompt -Style $style -Success $lastCommandStatus
}

function Test-IsAdministrator {
  # PowerShell 5.x only runs on Windows so use .NET types to determine isAdminProcess
  # Or if we are on v6 or higher, check the $IsWindows pre-defined variable.
  if (($PSVersionTable.PSVersion.Major -le 5) -or $IsWindows) {
    $currentUser = [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  }

  # Must be Linux or OSX, so use the id util. Root has userid of 0.
  return 0 -eq (id -u)
}

function Format-Prompt {
  param([hashtable] $Style, [bool] $Success)

  "{0}{1}{2}{3}{4}{5} {6}{7}`n{8} " -f `
    (Format-ErrorPrompt -Style $Style -Success $Success),
    (Write-Prompt $Style.PoshSymbol -ForegroundColor $Style.PoshSymbolColor),
    (Write-Prompt $Style.PoshSeparator -ForegroundColor $Style.PoshSeparatorColor),
    (Write-Prompt $Style.UserName -ForegroundColor $Style.UserColor),
    (Write-Prompt $Style.UserSeparator -ForegroundColor $Style.UserSeparatorColor),
    (Write-Prompt $Style.HostName -ForegroundColor $Style.HostColor),
    (Write-Prompt (Get-CurrentPromptPath) -ForegroundColor $Style.PathColor),
    (& $GitPromptScriptBlock),
    (Write-Prompt $Style.CommandSymbol -ForegroundColor $Style.CommandSymbolColor)
}

function Format-ErrorPrompt {
  param([hashtable] $Style, [bool] $Success)

  if ($Success) {
    return ''
  }

  '{0} ' -f (Write-Prompt $Style.ErrorSymbol -ForegroundColor $Style.ErrorSymbolColor)
}

function Get-CurrentPromptPath {
  $PWD -Replace $HOME.Replace('\', '\\'), '~'
}
