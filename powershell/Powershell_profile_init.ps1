#Requires -RunAsAdministrator

# Profile
if (-Not (Test-Path $PROFILE)) {
    New-Item $PROFILE –Type File –Force
}

# https://docs.microsoft.com/en-us/nuget/install-nuget-client-tools
# Get-PackageSource
# Find-PackageProvider -Name "Nuget" -AllVersions
# Install-PackageProvider -Name "NuGet" -Force

# https://www.powershellgallery.com/
Write-Host "Settings powershell repository..." -ForegroundColor Blue
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

Write-Host "Installing powershell modules..." -ForegroundColor Blue
# Find-Module, Get-InstalledModule, Update-Module, Uninstall-Module
Install-Module -Name PSReadLine -AllowPrerelease -SkipPublisherCheck -Force

Install-Module Find-String,PSColors,TabExpansionPlusPlus -AllowClobber
Add-Content $PROFILE "`nImport-Module Find-String"
Add-Content $PROFILE "Import-Module PSColors"
Add-Content $PROFILE "Import-Module TabExpansionPlusPlus"

Install-Module Posh-git,oh-my-posh
Add-Content $PROFILE "Import-Module Posh-git"
Add-Content $PROFILE "Import-Module oh-my-posh"

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
Install-Module Get-ChildItemColor

@'

## Color coding Get-ChildItem
Import-Module Get-ChildItemColor

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
function GetMyIp {curl -sL -4 https://ifconfig.co/}
function UpdateScoop {scoop update; scoop update *}

## Other alias
Set-Alias open Invoke-Item
Set-Alias .. GoBack
Set-Alias glola GitLogPretty
Set-Alias gst GitStat
Set-Alias myip GetMyIp
Set-Alias pls PrettyLS
Set-Alias suu UpdateScoop
'@ | tee $PROFILE -Append | Out-Null
