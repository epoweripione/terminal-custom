#Requires -RunAsAdministrator

## Usage:
## 1. Install PowerShell: https://github.com/PowerShell/PowerShell
## PowerShell 7.0+ with preinstalled .NET Core 3.1 SDK:
# dotnet tool install --global PowerShell
# dotnet tool update --global PowerShell
## 2. Run pwsh as Administrator
## 3. Download pwsh_script_download.ps1
## curl -L --socks5-hostname 127.0.0.1:55880 -o ".\pwsh_script_download.ps1" https://git.io/JeQ9d"
# curl -L -o ".\pwsh_script_download.ps1" "https://git.io/JeQ9d"
## 4. Exec pwsh_script_download.ps1
# .\pwsh_script_download.ps1
## 5. Exec Powershell_init.ps1
# ~\Documents\PowerShell\Scripts\Powershell_init.ps1


# Write-Host "Script:" $PSCommandPath
# Write-Host "Path:" $PSScriptRoot

# # get & set user env
# $systemenv = [System.Environment]::GetEnvironmentVariable("Path")
# $systemenv = $systemenv.TrimEnd(';')
# [System.Environment]::SetEnvironmentVariable("PATH", $systemenv + ";C:\Users\Administrator\Ubuntu")

# $userenv = [System.Environment]::GetEnvironmentVariable("Path", "User")
# # if ($userenv.Contains(";")) { $userenv = $userenv -replace '[;]' }
# $userenv = $userenv.TrimEnd(';')
# [System.Environment]::SetEnvironmentVariable("PATH", $userenv + ";C:\Users\Administrator\Ubuntu", "User")

# Proxy settings (need admin privileges) 
# netsh winhttp show proxy
# use ie proxy settings:
# netsh winhttp import proxy source=ie
# or:
# netsh winhttp set proxy 127.0.0.1:55881
# reset:
# netsh winhttp reset proxy


# Init profile
& "$PSScriptRoot\Powershell_profile_init.ps1"


# hosts
# & "$PSScriptRoot\hosts_accelerate_cn.ps1"


# Remove built in windows 10 apps
& "$PSScriptRoot\Remove_built-in_apps.ps1"

# Chromium
[System.Environment]::SetEnvironmentVariable("GOOGLE_API_KEY", "no")
[System.Environment]::SetEnvironmentVariable("GOOGLE_DEFAULT_CLIENT_ID", "no")
[System.Environment]::SetEnvironmentVariable("GOOGLE_DEFAULT_CLIENT_SECRET", "no")


# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy
# Get-ExecutionPolicy -List
# Set-ExecutionPolicy (AllSigned, Bypass, Default, RemoteSigned, Restricted, Undefined, Unrestricted)
# Set-ExecutionPolicy Bypass -Scope (CurrentUser, LocalMachine, MachinePolicy, Process, UserPolicy)
# Set-ExecutionPolicy AllSigned


## Chocolatey
## https://chocolatey.org/install
# Write-Host "Installing chocolatey..." -ForegroundColor Blue
# Set-ExecutionPolicy Bypass -Scope Process -Force
# iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# if (-Not ((Get-Command "choco" -ErrorAction SilentlyContinue) -eq $null)) {
#     Write-Host "chocolatey install failed!"
# }

# if (Get-Command "choco" -ErrorAction SilentlyContinue) {
#     # # Use proxy for choco, ie: http://127.0.0.1:55881
#     # $HTTP_PROXY_ADDR = Read-Host 'Proxy address for chocolatey?[http://127.0.0.1:55881] '
#     # # if ($HTTP_PROXY_ADDR -eq "") {
#     # #     # choco config unset proxy
#     # #     $HTTP_PROXY_ADDR = "http://127.0.0.1:55881"
#     # # }
#     # if (-Not ($HTTP_PROXY_ADDR -eq "")) {
#     #     choco config set proxy $HTTP_PROXY_ADDR
#     # }

#     Write-Host "Installing chocolatey apps..." -ForegroundColor Blue
#     choco install -y chocolateygui
#     # choco upgrade -y all
# }


# Scoop
# https://scoop.sh/
if (-Not (Get-Command "scoop" -ErrorAction SilentlyContinue)) {
    Write-Host "Installing scoop..." -ForegroundColor Blue
 
    ## If you're behind a proxy you might need to run one or more of these commands first:
    ## If you want to use a proxy that isn't already configured in Internet Options
    # [net.webrequest]::defaultwebproxy = new-object net.webproxy "http://proxy.example.org:8080"
    ## If you want to use the Windows credentials of the logged-in user to authenticate with your proxy
    # [net.webrequest]::defaultwebproxy.credentials = [net.credentialcache]::defaultcredentials
    ## If you want to use other credentials (replace 'username' and 'password')
    # [net.webrequest]::defaultwebproxy.credentials = new-object net.networkcredential 'username', 'password'
 
    Set-ExecutionPolicy RemoteSigned -scope CurrentUser
    Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression

    # $env:SCOOP='D:\Applications\Scoop'
    # $env:SCOOP_GLOBAL='D:\Applications\Scoop\globalApps'
    # [environment]::setEnvironmentVariable('SCOOP',$env:SCOOP,'User')
    # [environment]::setEnvironmentVariable('SCOOP_GLOBAL',$env:SCOOP_GLOBAL,'Machine')
    # Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression
    # scoop install -g <app>
}

if (Get-Command "scoop" -ErrorAction SilentlyContinue) {
    # scoop config proxy 127.0.0.1:55881
    # scoop config rm proxy
    Write-Host "Installing scoop apps..." -ForegroundColor Blue

    ## scoop config proxy [username:password@]host:port
    ## Use your Windows credentials with the default proxy configured in Internet Options
    # scoop config proxy currentuser@default
    ## Use hard-coded credentials with the default proxy configured in Internet Options
    # scoop config proxy user:password@default
    ## Use a proxy that isn't configured in Internet Options
    # scoop config proxy proxy.example.org:8080
    # scoop config proxy username:password@proxy.example.org:8080
    ## Bypassing the proxy configured in Internet Options
    # scoop config rm proxy

    # list all known buckets
    # scoop bucket known

    # Scoop buckets by Github score
    # https://github.com/rasa/scoop-directory/blob/master/by-score.md

    # main
    # https://github.com/ScoopInstaller/Main
    # extras
    # https://github.com/lukesampson/scoop-extras
    scoop bucket add extras
    # nerd-fonts
    # https://github.com/matthewjberger/scoop-nerd-fonts
    scoop bucket add nerd-fonts
    # java
    # https://github.com/ScoopInstaller/Java
    scoop bucket add java
    # nirsoft http://www.nirsoft.net/
    # https://github.com/kodybrown/scoop-nirsoft
    scoop bucket add nirsoft
    # vesion
    # https://github.com/ScoopInstaller/Versions
    scoop bucket add versions
    # other
    scoop bucket add dorado https://github.com/h404bi/dorado
    scoop bucket add dodorz https://github.com/dodorz/scoop-bucket

    if (-Not (scoop info aria2 6>$null)) {
        Write-Host "Installing aria2..." -ForegroundColor Blue
        scoop install aria2
        scoop config aria2-enabled true
    }

    Write-Host "Installing sudo..." -ForegroundColor Blue
    if (-Not (scoop info sudo 6>$null)) {scoop install sudo}

    Write-Host "Installing git..." -ForegroundColor Blue
    if (-Not (scoop info git 6>$null)) {scoop install git}

    Write-Host "Updating scoop..." -ForegroundColor Blue
    scoop update
    # scoop update *

    $Apps = @(
        "firefox-zh-cn"
        "nodejs-lts"
        "zulu8"
        "python"
        "php"
        "composer"
        "cacert"
        "windowsterminal"
        "lxrunoffline"
        "freedownloadmanager"
        "snipaste-beta"
        "ffmpeg"
        "screentogif"
    )

    $InstalledApps = scoop list 6>&1 | Out-String
    $InstalledApps = $InstalledApps -replace "`r`n"," " -replace "    "," " -replace "   "," " -replace "  "," "
    # $InstalledApps = $InstalledApps -replace "`r`n"," " -replace "    ","`n"
    # $InstalledApps = $InstalledApps -replace "  "," " -replace "`n\*"," *"
    foreach ($TargetApp in $Apps) {
        if (-Not ($InstalledApps -match "$TargetApp \*failed\*")) {
            Write-Host "Uninstalling $TargetApp..." -ForegroundColor Blue
            scoop uninstall $TargetApp
            scoop cache rm $TargetApp
        }
    }

    foreach ($TargetApp in $Apps) {
        if (-Not ($InstalledApps -match "$TargetApp")) {
            Write-Host "Installing $TargetApp..." -ForegroundColor Blue
            scoop install $TargetApp
        }
    }

    # scoop install FiraCode
    # scoop install SarasaGothic-SC
    # scoop install zulu11
    # scoop install openedfilesview
    # scoop install python27
    # scoop install dorado/miniconda3
    # netsh winhttp reset proxy
} else {
    Write-Host "scoop install failed!"
}


# https://github.com/lukesampson/scoop/wiki/Custom-PHP-configuration
if (Get-Command "php" -ErrorAction SilentlyContinue) {
    
}


## ColorTool
## https://github.com/microsoft/terminal/tree/master/src/tools/ColorTool
# Write-Host "Installing ColorTool..." -ForegroundColor Blue
# $HTTP_PROXY_ADDR = Read-Host 'Proxy address for github download?[127.0.0.1:55881] '
# if (-Not ($HTTP_PROXY_ADDR -eq "")) {
#     netsh winhttp set proxy $HTTP_PROXY_ADDR
# }
# $DST_DIR = "~\tools"
# if (-Not (Test-Path $DST_DIR)) {
#     # mkdir -p $DST_DIR
#     New-Item -path $DST_DIR -type Directory | Out-Null
# }
# cd ~\tools; `
#     curl -L -o ColorTool.zip `
#         https://github.com/microsoft/terminal/releases/download/1904.29002/ColorTool.zip; `
#     Expand-Archive -LiteralPath ~\tools\ColorTool.zip `
#         -DestinationPath ~\tools\ColorTool -Verbose; `
#     Remove-Item ~\tools\ColorTool.zip
# if (-Not ($HTTP_PROXY_ADDR -eq "")) {
#     netsh winhttp reset proxy
# }
# ~\tools\ColorTool\ColorTool.exe -b OneHalfDark.itermcolors


Write-Host "Done." -ForegroundColor Blue