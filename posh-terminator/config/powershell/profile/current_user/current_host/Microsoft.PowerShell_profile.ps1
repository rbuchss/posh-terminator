<#
  PowerShell profile docs see:
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7
    http://akuederle.com/modify-your-powershell-prompt
    https://www.howtogeek.com/50236/customizing-your-powershell-profile/
#>

Import-Module $HOME/.posh-terminator/posh-terminator.psd1

<# Enviroment Vars #>

$env:CDPATH = '.;C:\opt\sagittarius\vango;C:\opt\sagittarius;~\.homesick\repos;~\'

# dotnet settings
$env:DOTNET_CLI_TELEMETRY_OPTOUT = $true

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
Set-Alias -Name pester -Value Invoke-PesterInCleanSession
