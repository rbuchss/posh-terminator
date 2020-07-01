<#
  PowerShell profile docs see:
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7
    http://akuederle.com/modify-your-powershell-prompt
    https://www.howtogeek.com/50236/customizing-your-powershell-profile/
#>

using namespace System.Diagnostics.CodeAnalysis

Import-Module $HOME/.posh-terminator/posh-terminator.psd1

<# Enviroment Vars #>

$env:CDPATH = if (Test-IsWindows) {
  '.;C:\opt\sagittarius\vango;C:\opt\sagittarius;~\.homesick\repos;~\'
} else {
  '.;/opt/sagittarius/vango;/opt/sagittarius;~/.homesick/repos;~/'
}

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
$GitPromptSettings.DefaultPromptDebug.Text = ''
$GitPromptSettings.DefaultPromptSuffix.Text = ''

<#
  Remove overwritten AllScope aliases
  and flush PSReadLine cache
  to fix ArgumentCompleter issues
  see:
    https://github.com/PowerShell/PowerShell/issues/12165
    https://github.com/PowerShell/PSReadLine/issues/453#issuecomment-341629310
#>

Remove-Alias cd

if (Get-Module PSReadLine) {
  Remove-Module -Force PsReadLine
  Import-Module -Force PSReadLine
}

<# Key Bindings #>

# Bash like chords for backward/forward line deletion
Set-PSReadLineKeyHandler -Chord Ctrl+u -Function BackwardDeleteLine
Set-PSReadLineKeyHandler -Chord Ctrl+k -Function ForwardDeleteLine

Set-PSReadLineKeyHandler -Chord Ctrl+LeftArrow -Function BackwardWord
Set-PSReadLineKeyHandler -Chord Ctrl+RightArrow -Function ForwardWord

# Bash like exit
Set-PSReadLineKeyHandler -Chord Ctrl+d -Function DeleteCharOrExit

# Bash like tab completion
Set-PSReadLineKeyHandler -Chord Tab -Function Complete
Set-PSReadLineKeyHandler -Chord Shift+Tab -Function MenuComplete

<# ReadLine Options #>

Set-PSReadLineOption -BellStyle None

<# Auto-Completion #>

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
  Complete-DotnetCommand @args
}

# NOTE: PSScriptAnalyzer SuppressMessage does not work in bare block
# need to move this to a function to suppress
function Complete-DotnetCommand {
  [SuppressMessage('PSReviewUnusedParameter', 'wordToComplete')]
  param($wordToComplete, $commandAst, $cursorPosition)
  dotnet complete --position $cursorPosition $commandAst.ToString() | ForEach-Object {
    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
  }
}

<# Aliases #>

Set-Alias -Name g -Value git
Set-Alias -Name touch -Value Update-File
Set-Alias -Name mkcd -Value Set-NewLocation
Set-Alias -Name hack -Value Find-HistoryAllSessions
Set-Alias -Name sudo -Value Start-ProcessAsAdmin
Set-Alias -Name cd -Value Set-CDPathLocation # -Option AllScope
Set-Alias -Name pester -Value Invoke-PesterInCleanSession
