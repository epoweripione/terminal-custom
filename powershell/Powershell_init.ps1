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
& "$PSScriptRoot\scoop_install_apps.ps1"


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