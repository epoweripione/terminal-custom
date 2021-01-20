#Requires -RunAsAdministrator

if (-Not (Get-Command -Name "check_webservice_up" 2>$null)) {
    $CUSTOM_FUNCTION="$PSScriptRoot\ps_custom_function.ps1"
    if ((Test-Path "$CUSTOM_FUNCTION") -and ((Get-Item "$CUSTOM_FUNCTION").length -gt 0)) {
        . "$CUSTOM_FUNCTION"
    }
}

$PROXY_ADDR = "127.0.0.1:7890"
if (-Not (check_socks5_proxy_up $PROXY_ADDR)) {
    $PROXY_ADDR = ""
    if($PROMPT_VALUE = Read-Host "Proxy address for Install-Module?") {
        $PROXY_ADDR = $PROMPT_VALUE
    }
}

# Profile
if (-Not (Test-Path $PROFILE)) {
    New-Item $PROFILE –Type File –Force | Out-Null
}

@'
$PS_CUSTOM_FUNCTION = "$HOME\Documents\PowerShell\Scripts\ps_custom_function.ps1"
if ((Test-Path "$PS_CUSTOM_FUNCTION") -and ((Get-Item "$PS_CUSTOM_FUNCTION").length -gt 0)) {
    . "$PS_CUSTOM_FUNCTION"
}

'@ | Tee-Object $PROFILE -Append | Out-Null

# https://docs.microsoft.com/en-us/nuget/install-nuget-client-tools
# Get-PackageSource
# Find-PackageProvider -Name "Nuget" -AllVersions
# Install-PackageProvider -Name "NuGet" -Force

# https://www.powershellgallery.com/
Write-Host "Setting powershell repository..." -ForegroundColor Blue
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

Write-Host "Installing powershell modules..." -ForegroundColor Blue
# Find-Module, Get-InstalledModule, Update-Module, Uninstall-Module
if (-Not (Get-Module -Name "PSReadLine")) {
    if (($null -eq $PROXY_ADDR) -or ($PROXY_ADDR -eq "")) {
        Install-Module -Name "PSReadLine" -AllowPrerelease -SkipPublisherCheck -Force
    } else {
        Install-Module -Name "PSReadLine" -AllowPrerelease -SkipPublisherCheck -Force -Proxy "http://$PROXY_ADDR"
    }
}

$InstallModules = @(
    "Find-String"
    "Posh-git"
    "oh-my-posh"
    "Get-ChildItemColor"
    "PoshFunctions"
)

foreach ($TargetModule in $InstallModules) {
    if (-Not (Get-Module -Name $TargetModule)) {
        if (($null -eq $PROXY_ADDR) -or ($PROXY_ADDR -eq "")) {
            Install-Module -Name "$TargetModule" -AllowClobber -AllowPrerelease
        } else {
            Install-Module -Name "$TargetModule" -AllowClobber -AllowPrerelease -Proxy "http://$PROXY_ADDR"
        }
    }
}

## Oh my Posh 3
## https://ohmyposh.dev/
# if (($null -eq $PROXY_ADDR) -or ($PROXY_ADDR -eq "")) {
#     Update-Module -Name oh-my-posh -AllowClobber -AllowPrerelease
# } else {
#     Update-Module -Name oh-my-posh -AllowClobber -AllowPrerelease -Proxy "http://$PROXY_ADDR"
# }

$EnableModules = @(
    "Find-String"
    "Posh-git"
)

foreach ($TargetModule in $EnableModules) {
    if (-Not (Get-Module -Name $TargetModule)) {
        Add-Content $PROFILE "Import-Module $TargetModule"
    }
}

## theme
# Write-Host "Setting powershell theme..." -ForegroundColor Blue
# $THEME_DIR = "~\Documents\PowerShell\PoshThemes"
# $THEME_FILE = "$THEME_DIR\Powerlevel10k-my.psm1"
# if (-Not (Test-Path $THEME_DIR)) {New-Item -path $THEME_DIR -type Directory | Out-Null}
# # Copy-Item "$env:SystemDrive\cmder\Paradox-my.psm1" -Destination "$THEME_DIR"
# if (-Not (Test-Path $THEME_FILE)) {
#     $DOWNLOAD_URL = "https://raw.githubusercontent.com/epoweripione/terminal-custom/master/powershell/Powerlevel10k-my.psm1"
#     $p = New-Object System.Net.WebClient
#     $p.DownloadFile($DOWNLOAD_URL, $THEME_FILE)
# }

# if (Test-Path $THEME_FILE) {
#     Add-Content $PROFILE "`nSet-Theme Powerlevel10k-my"
# }

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

function UpdateScoop {
    scoop update
    scoop config aria2-enabled false
    scoop update *
    scoop config aria2-enabled true
    scoop update *
    scoop config aria2-enabled false
    scoop cleanup *
}

function  SearchScoopBucket {
    param (
        [string]$SearchCond = ""
    )

    if ($SearchCond) {
        Get-ChildItem -Path "$env:UserProfile\scoop\buckets" `
            -Recurse -Include "*$SearchCond*.json" -Depth 2 -Name
    }
}

function UpdateMyScript {
    Set-Location ~
    if (check_socks5_proxy_up $SCOOP_PROXY_ADDR) {
        curl -fsL --socks5-hostname "127.0.0.1:7890" `
            -o ".\pwsh_script_download.ps1" "https://git.io/JeQ9d" && `
        .\pwsh_script_download.ps1
    } else {
        curl -fsL -o ".\pwsh_script_download.ps1" "https://git.io/JeQ9d" && `
        .\pwsh_script_download.ps1
    }
}

function DockerPullAllImages{
    docker images --format "{{.Repository}}:{{.Tag}}" | Where-Object {$_ -NotMatch "<none>"} | %{docker pull $_}
}

function DockerList{
    docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}"
}

function DockerListAll{
    docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}\t{{.Ports}}\t{{.Networks}}\t{{.Command}}\t{{.Size}}"
}

function PrettyLS {colorls --light -A}
function GitStat {git status}
function GoBack {Set-Location ..}
function GetMyIp {curl -fsL -4 http://ip-api.com/json/ | ConvertFrom-Json}
function EditHosts {sudo notepad $env:windir\System32\drivers\etc\hosts}
function EditHistory {notepad (Get-PSReadlineOption).HistorySavePath}

## Other alias
Set-Alias open Invoke-Item
Set-Alias .. GoBack
Set-Alias glola GitLogPretty
Set-Alias gst GitStat
Set-Alias myip GetMyIp
Set-Alias pls PrettyLS
Set-Alias suu UpdateScoop
Set-Alias ssb SearchScoopBucket
Set-Alias ums UpdateMyScript
Set-Alias hosts EditHosts
Set-Alias history EditHistory

Set-Alias dockerpullall DockerPullAllImages
Set-Alias dockerps DockerList
Set-Alias dockerpsall DockerListAll

## https://starship.rs/
if (Get-Command "starship" -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
'@ | Tee-Object $PROFILE -Append | Out-Null
