<#
    Symlink profiles.json to windows-terminal config path

    INFO: how to add a relative path symlink:
        cmd /c mklink /d ".\home\.windows-terminal" "..\windows-terminal"
#>

$configPath = Get-Item '~\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState'
$target = Get-Item '~/.posh-terminator/config/windows-terminal/settings.json'

$ESC = [char]0x1B

$color = @{
  Error = "$ESC[0;91m"
  Warning = "$ESC[0;93m"
  Information = "$ESC[0;92m"
  Off = "$ESC[0m"
}

Write-Output ('{0}{1}{2}' -f `
  $color.Information,
  "New-Item -ItemType HardLink -Path $configPath -Name $($target.Name) -Value $target",
  $color.Off)
New-Item -ItemType HardLink -Path $configPath -Name $target.Name -Value $target -Confirm -Force
