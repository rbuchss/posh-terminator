<#
    Symlink profiles.json to windows-terminal config path

    INFO: how to add a relative path symlink:
        cmd /c mklink /d ".\home\.windows-terminal" "..\windows-terminal"
#>

$configPath = (Get-Item "~\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState")
$target = (Get-Item "~/.windows-terminal/profiles.json")

Write-Host "New-Item -ItemType HardLink -Path $configPath -Name $($target.Name) -Value $target" `
    -ForegroundColor Yellow
New-Item -ItemType HardLink -Path $configPath -Name $target.Name -Value $target -Confirm -Force