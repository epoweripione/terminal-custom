function check_webservice_up() {
    param($webservice_url)

    if (($null -eq $webservice_url) -or ($webservice_url -eq "")) {
        $webservice_url = "www.google.com"
    }

    curl -fsL --connect-timeout 3 --max-time 5 -I "$webservice_url"
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

    curl -fsL --connect-timeout 3 --max-time 5 --socks5-hostname "$socks_proxy_url" -I "$webservice_url"
    if ($?) {
        return $true
    } else {
        return $false
    }
}


# socks proxy
$SOCKS_PROXY_ADDR = "127.0.0.1:7890"
if (-Not (check_webservice_up)) {
    if (-Not (check_socks5_proxy_up $SOCKS_PROXY_ADDR)) {
        if ($PROMPT_VALUE = Read-Host "Scoks proxy address for github download?[$($SOCKS_PROXY_ADDR)]") {
            $SOCKS_PROXY_ADDR = $PROMPT_VALUE
            if (-Not (check_socks5_proxy_up $SOCKS_PROXY_ADDR)) {
                $SOCKS_PROXY_ADDR = ""
            }
        } else {
            $SOCKS_PROXY_ADDR = ""
        }
    }
}


Set-Location ~

$DOWNLOAD_URL = "https://github.com/epoweripione/terminal-custom/archive/master.zip"
if (($null -eq $SOCKS_PROXY_ADDR) -or ($SOCKS_PROXY_ADDR -eq "")) {
    curl -fsL -o ".\terminal-custom.zip" "$DOWNLOAD_URL"
} else {
    curl -fsL --socks5-hostname "$SOCKS_PROXY_ADDR" -o ".\terminal-custom.zip" "$DOWNLOAD_URL"
}

if ($?) {
    Expand-Archive -Path ".\terminal-custom.zip" -DestinationPath .
    Rename-Item -Path ".\terminal-custom-master" -NewName ".\terminal-custom"

    $PWSH_DIR = "~\Documents\PowerShell\Scripts"
    if (-Not (Test-Path $PWSH_DIR)) {New-Item -path $PWSH_DIR -type Directory | Out-Null}
    # Copy-Item -Path ".\terminal-custom\powershell\*" -Destination $PWSH_DIR -Recurse -Force -Confirm:$false
    Copy-Item -Path ".\terminal-custom\powershell\*.ps1" -Destination $PWSH_DIR
    Copy-Item -Path ".\terminal-custom\wsl\*.ps1" -Destination $PWSH_DIR
    Copy-Item -Path ".\terminal-custom\cross\hosts_accelerate_cn.list" -Destination $PWSH_DIR

    $CONFIG_DIR = "~\.config"
    if (-Not (Test-Path $CONFIG_DIR)) {
        New-Item -path $CONFIG_DIR -type Directory | Out-Null
    }
    Copy-Item -Path ".\terminal-custom\powershell\themes\starship.toml" -Destination $CONFIG_DIR

    $THEME_DIR = "~\Documents\PowerShell\PoshThemes"
    if (-Not (Test-Path $THEME_DIR)) {New-Item -path $THEME_DIR -type Directory | Out-Null}
    Copy-Item -Path ".\terminal-custom\powershell\themes\*.psm1" -Destination $THEME_DIR

    $IMAGE_DIR = "~\Pictures"
    Copy-Item -Path ".\terminal-custom\wsl\*.jpg" -Destination $IMAGE_DIR

    Remove-Item -Path ".\terminal-custom" -Recurse -Force -Confirm:$false
    Remove-Item -Path ".\terminal-custom.zip" -Force -Confirm:$false
}
