#Requires -RunAsAdministrator

# Profile
if (-Not (Test-Path $PROFILE)) {
    New-Item $PROFILE –Type File –Force | Out-Null
}

# https://docs.microsoft.com/en-us/nuget/install-nuget-client-tools
# Get-PackageSource
# Find-PackageProvider -Name "Nuget" -AllVersions
# Install-PackageProvider -Name "NuGet" -Force

# https://www.powershellgallery.com/
Write-Host "Setting powershell repository..." -ForegroundColor Blue
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

Write-Host "Installing powershell modules..." -ForegroundColor Blue
# Find-Module, Get-InstalledModule, Update-Module, Uninstall-Module
if (-Not (Get-Module -ListAvailable -Name "PSReadLine")) {
    Install-Module -Name "PSReadLine" -AllowPrerelease -SkipPublisherCheck -Force
}

$ModuleNames = @(
    "Find-String"
    "Posh-git"
    "oh-my-posh"
    "Get-ChildItemColor"
)

foreach ($TargetModule in $ModuleNames) {
    if (-Not (Get-Module -ListAvailable -Name $TargetModule)) {
        Install-Module -Name $TargetModule -AllowClobber
    }
}

foreach ($TargetModule in $ModuleNames) {
    if (Get-Module -ListAvailable -Name $TargetModule) {
        if (-Not (Get-Module -Name $TargetModule)) {
            Add-Content $PROFILE "Import-Module $TargetModule"
        }
    }
}

# theme
Write-Host "Setting powershell theme..." -ForegroundColor Blue
$THEME_DIR = "~\Documents\PowerShell\PoshThemes"
$THEME_FILE = "$THEME_DIR\Paradox-my.psm1"
if (-Not (Test-Path $THEME_DIR)) {New-Item -path $THEME_DIR -type Directory | Out-Null}
# Copy-Item "$env:SystemDrive\cmder\Paradox-my.psm1" -Destination "$THEME_DIR"
if (-Not (Test-Path $THEME_FILE)) {
    $DOWNLOAD_URL = "https://raw.githubusercontent.com/epoweripione/terminal-custom/master/powershell/Paradox-my.psm1"
    $p = New-Object System.Net.WebClient
    $p.DownloadFile($DOWNLOAD_URL, $THEME_FILE)
}

if (Test-Path $THEME_FILE) {
    Add-Content $PROFILE "`nSet-Theme Paradox-my"
} 

# Custom
Write-Host "Other powershell settings..." -ForegroundColor Blue
@'

## Color coding Get-ChildItem
# Import-Module Get-ChildItemColor

Set-Alias l Get-ChildItemColor -option AllScope
Set-Alias ls Get-ChildItemColorFormatWide -option AllScope

## PSReadLine
# With these settings, I can press up and down arrows for history substring search, and the tab completion shows me available candidates.
# You can also use CTRL + r for incremental history search.
# Import-Module PSReadLine

Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
Set-PSReadLineOption -MaximumHistoryCount 4000

# history substring search
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

# Tab completion
Set-PSReadlineKeyHandler -Chord 'Shift+Tab' -Function Complete
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

## cddash
# You can use the following to have the "dash" functionality - namely, you can go back to the previous location by typing cd -. It is from http://goo.gl/xRbYbk.
function cddash {
    if ($args[0] -eq '-') {
        $pwd = $OLDPWD;
    } else {
        $pwd = $args[0];
    }
    $tmp = pwd;

    if ($pwd) {
        Set-Location $pwd;
    }
    Set-Variable -Name OLDPWD -Value $tmp -Scope global;
}

Set-Alias -Name cd -value cddash -Option AllScope

## python encoding
$env:PYTHONIOENCODING="utf-8"

function GitLogPretty {
    git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --all
}

function PrettyLS {colorls --light -A}
function GitStat {git status}
function GoBack {Set-Location ..}
function GetMyIp {curl -sL -4 http://ip-api.com/json/ | ConvertFrom-Json}
function UpdateScoop {scoop update; scoop update *; scoop cleanup *}
function EditHosts {notepad $env:windir\System32\drivers\etc\hosts}
function EditHistory {notepad (Get-PSReadlineOption).HistorySavePath}

## Other alias
Set-Alias open Invoke-Item
Set-Alias .. GoBack
Set-Alias glola GitLogPretty
Set-Alias gst GitStat
Set-Alias myip GetMyIp
Set-Alias pls PrettyLS
Set-Alias suu UpdateScoop
Set-Alias hosts EditHosts
Set-Alias history EditHistory
'@ | Tee-Object $PROFILE -Append | Out-Null
