#!/usr/bin/env pwsh

Import-Module posh-git

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
