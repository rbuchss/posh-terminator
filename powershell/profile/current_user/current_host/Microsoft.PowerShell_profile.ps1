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
  # TODO support multiple files?
  $file = $args[0]
  if ($null -eq $file) {
    throw "No filename supplied"
  }

  if (Test-Path $file) {
    (Get-ChildItem $file).LastWriteTime = Get-Date
  } else {
    New-Item -ItemType file $file
  }
}

<# Aliases #>

Set-Alias -Name g -Value git
Set-Alias -Name touch -Value Update-File

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
