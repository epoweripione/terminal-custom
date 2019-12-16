#Requires -RunAsAdministrator

function check_webservice_up() {
    param($webservice_url)

    if (($webservice_url -eq $null) -or ($webservice_url -eq "")) {
        $webservice_url = "www.google.com"
    }

    curl -fsSL --connect-timeout 3 --max-time 5 -I "$webservice_url"
    if ($?) {
        return $true
    } else {
        return $false
    }
}

function check_socks5_proxy_up() {
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $socks_proxy_url,
        [Parameter(Mandatory=$false, Position=1)]
        [string] $webservice_url
    )

    if (($webservice_url -eq $null) -or ($webservice_url -eq "")) {
        $webservice_url = "www.google.com"
    }

    curl -fsSL --connect-timeout 3 --max-time 5 --socks5-hostname "$socks_proxy_url" -I "$webservice_url"
    if ($?) {
        return $true
    } else {
        return $false
    }
}


# socks proxy
if (-Not (check_webservice_up)) {
    $SOCKS_PROXY_ADDR = Read-Host 'Scoks proxy address for github download?[127.0.0.1:55881] '
    if (-Not (($SOCKS_PROXY_ADDR -eq $null) -or ($SOCKS_PROXY_ADDR -eq ""))) {
        $SOCKS_PROXY_ADDR = "127.0.0.1:55881"
    }
    if (-Not (check_socks5_proxy_up $SOCKS_PROXY_ADDR)) {
        $SOCKS_PROXY_ADDR = ""
    }
}


cd ~

$DOWNLOAD_URL = "https://github.com/epoweripione/terminal-custom/archive/master.zip"
if (($SOCKS_PROXY_ADDR -eq $null) -or ($SOCKS_PROXY_ADDR -eq "")) {
    curl -L -o "terminal-custom.zip" "$DOWNLOAD_URL"
} else {
    curl -L --socks5-hostname "$socks_proxy_url" -o "terminal-custom.zip" "$DOWNLOAD_URL"
}

Expand-Archive ".\terminal-custom.zip" .
Rename-Item ".\terminal-custom-master" ".\terminal-custom"

$PWSH_DIR = "~\Documents\PowerShell\Scripts"
if (-Not (Test-Path $PWSH_DIR)) {New-Item -path $PWSH_DIR -type Directory | Out-Null}
Copy-Item ".\terminal-custom\powershell\*.ps1" -Destination $PWSH_DIR
Copy-Item ".\terminal-custom\hosts_accelerate_cn.list" -Destination $PWSH_DIR

$THEME_DIR = "~\Documents\PowerShell\PoshThemes"
if (-Not (Test-Path $THEME_DIR)) {New-Item -path $THEME_DIR -type Directory | Out-Null}
Copy-Item ".\terminal-custom\powershell\Paradox-my.psm1" -Destination $THEME_DIR

Remove-Item ".\terminal-custom" -Recurse -Force -Confirm:$false
# Remove-Item ".\terminal-custom", ".\terminal-custom.zip" -Recurse -Force -Confirm:$false
