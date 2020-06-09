#Requires -RunAsAdministrator

Param (
	[switch]$UseAria2,
	[string]$AppsInstallDir = ""
)

if (-Not (Get-Command -Name "check_webservice_up" 2>$null)) {
    $CUSTOM_FUNCTION="$PSScriptRoot\ps_custom_function.ps1"
    if ((Test-Path "$CUSTOM_FUNCTION") -and ((Get-Item "$CUSTOM_FUNCTION").length -gt 0)) {
        . "$CUSTOM_FUNCTION"
    }
}

# proxy
$SCOOP_PROXY_ADDR = "127.0.0.1:7890"
if (-Not (check_socks5_proxy_up "127.0.0.1:7891")) {
    $SCOOP_PROXY_ADDR = ""
    if($PROMPT_VALUE = Read-Host "Proxy address for scoop?") {
        $SCOOP_PROXY_ADDR = $PROMPT_VALUE
    }
}

# Scoop
# https://scoop.sh/
if (-Not (Get-Command "scoop" -ErrorAction SilentlyContinue)) {
    Write-Host "Installing scoop..." -ForegroundColor Blue

    # https://github.com/lukesampson/scoop/wiki/Quick-Start
    ## If you're behind a proxy you might need to run one or more of these commands first:
    ## If you want to use a proxy that isn't already configured in Internet Options
    # [net.webrequest]::defaultwebproxy = new-object net.webproxy "http://proxy.example.org:8080"
    ## If you want to use the Windows credentials of the logged-in user to authenticate with your proxy
    # [net.webrequest]::defaultwebproxy.credentials = [net.credentialcache]::defaultcredentials
    ## If you want to use other credentials (replace 'username' and 'password')
    # [net.webrequest]::defaultwebproxy.credentials = new-object net.networkcredential 'username', 'password'

    if (-Not (($null -eq $SCOOP_PROXY_ADDR) -or ($SCOOP_PROXY_ADDR -eq ""))) {
        [net.webrequest]::defaultwebproxy = new-object net.webproxy "http://$SCOOP_PROXY_ADDR"
    }

    Set-ExecutionPolicy RemoteSigned -scope CurrentUser

    if (-Not (($null -eq $AppsInstallDir) -or ($AppsInstallDir -eq ""))) {
        $AppsInstallDir = "$AppsInstallDir".trim("\")
        if (-Not (Test-Path "$AppsInstallDir")) {
            New-Item -path "$AppsInstallDir" -type Directory | Out-Null
        }

        $env:SCOOP = "$AppsInstallDir"
        $env:SCOOP_GLOBAL = "$AppsInstallDir\globalApps"
        [environment]::setEnvironmentVariable('SCOOP',$env:SCOOP,'User')
        [environment]::setEnvironmentVariable('SCOOP_GLOBAL',$env:SCOOP_GLOBAL,'Machine')
    }

    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
    # Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression
    
    # scoop install -g <app>
}

if (Get-Command "scoop" -ErrorAction SilentlyContinue) {
    Write-Host "Installing apps using scoop..." -ForegroundColor Blue

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

    if (-Not (($null -eq $SCOOP_PROXY_ADDR) -or ($SCOOP_PROXY_ADDR -eq ""))) {
        scoop config proxy $SCOOP_PROXY_ADDR
    }

    if (-Not (Get-Command "git" -ErrorAction SilentlyContinue)) {
        Write-Host "Installing git..." -ForegroundColor Blue
        scoop install git
    }

    # git global config
    if (Get-Command "git" -ErrorAction SilentlyContinue) {
        Write-Host "Setting git global config..." -ForegroundColor Blue
        & "$PSScriptRoot\git_global_config.ps1"
    }

    if (-Not (scoop info aria2 6>$null)) {
        Write-Host "Installing aria2..." -ForegroundColor Blue
        scoop install aria2
    }

    if ($UseAria2) {
        scoop config aria2-enabled true
    } else {
        scoop config aria2-enabled false
    }

    if (-Not (scoop info sudo 6>$null)) {
        Write-Host "Installing sudo..." -ForegroundColor Blue
        scoop install sudo
    }

    Write-Host "Adding scoop buckets..." -ForegroundColor Blue
    # list all known buckets
    # scoop bucket known

    # Scoop buckets by Github score
    # https://rasa.github.io/scoop-directory/by-score
    $Buckets = @(
        "extras"
        "versions"
        "nerd-fonts"
        "java"
        "nirsoft"
        "dorado"
        # "dodorz"
        "epower"
        "nonportable"
        "jetbrains"
        # "php"
        # "games"
    )

    $BucketsURL = @(
        ""
        ""
        ""
        ""
        ""
        "https://github.com/h404bi/dorado"
        # "https://github.com/dodorz/scoop-bucket"
        "https://github.com/epoweripione/scoop-bucket"
        ""
        ""
        # ""
        # ""
    )

    $AddedBuckets = scoop bucket list 6>&1 | Out-String
    for ($i = 0; $i -lt $Buckets.Count; $i++) {
        $TargetBucket = $Buckets[$i]
        $TargetBucketURL = $BucketsURL[$i]
        if (-Not ($AddedBuckets -match "$TargetBucket")) {
            Write-Host "Adding $TargetBucket..." -ForegroundColor Blue
            if (($null -eq $TargetBucketURL) -or ($TargetBucketURL -eq "")) {
                scoop bucket add $TargetBucket
            } else {
                scoop bucket add $TargetBucket $TargetBucketURL
            }
        }
    }

    Write-Host "Updating scoop..." -ForegroundColor Blue
    scoop update
    # scoop update *

    $Apps = @(
        "vcredist"
        "googlechrome-dev"
        # "chromium"
        # "chromium-dev-nosync"
        "firefox-zh-cn"
        "go"
        "nodejs-lts"
        # "dotnet-sdk"
        "zulu8"
        "python"
        "php"
        "composer"
        "cacert"
        "dbeaver"
        # "vscode"
        "wireshark"
        "colortool"
        # "windowsterminal"
        "clash-for-windows"
        # "trojan"
        "frp"
        # "v2rayn"
        # "lxrunoffline"
        "freedownloadmanager"
        "snipaste-beta"
        "ffmpeg"
        "screentogif"
        "cpu-z"
        "diffinity"
        # "everything"
        "filezilla"
        "freedownloadmanager"
        "hashcheck"
        "motrix"
        # "powertoys"
        "q-dir"
        "syncbackfree"
        # "syncthing"
        # "sysinternals"
        # "utools"
        "xnviewmp"
        # "draw.io"
        # "yed"
        # "telegram"
        # "vncviewer"
        ## markdown editor
        "pandoc"
        "marktext"
        ## epower
        "chromium-marmaduke-dev-sync"
        # "chromium-robrich-dev"
        # "ExplorerPlusPlus"
        # "TablacusExplorer"
        # "HBuilderXFull"
        # "GoldenDictOnline"
        "NewFileTime"
        # "WiseCare365"
        "WiseDataRecovery"
        "WiseDiskCleaner"
        "WiseProgramUninstaller"
        "WiseRegistryCleaner"
        ## https://github.com/lukesampson/scoop/wiki/Theming-Powershell
        # "concfg"
    )

    $sudoApps = @(
        "Cascadia-Code"
        ## epower
        "FiraCode-Mono-NF"
        "Sarasa-Gothic-SC"
        ## nerd-fonts
        # "FiraCode-NF"
        # "FiraMono-NF"
        # "SarasaGothic-SC"
        "JetBrainsMono-NF"
        "CascadiaCode-NF"
        # "Noto-NF"
    )

    # Remove failed installed apps
    $InstalledApps = scoop list 6>&1 | Out-String
    $InstalledApps = $InstalledApps -replace "`r`n"," " -replace "    "," " -replace "   "," " -replace "  "," "
    foreach ($TargetApp in $Apps) {
        if ($InstalledApps -match "$TargetApp \*failed\*") {
            Write-Host "Uninstalling $TargetApp..." -ForegroundColor Blue
            scoop uninstall $TargetApp
            scoop cache rm $TargetApp
        }
    }

    $InstalledApps = scoop list 6>&1 | Out-String
    $InstalledApps = $InstalledApps -replace "`r`n"," " -replace "    "," " -replace "   "," " -replace "  "," "

    foreach ($TargetApp in $Apps) {
        if (-Not ($InstalledApps -match "$TargetApp")) {
            Write-Host "Installing $TargetApp..." -ForegroundColor Blue
            scoop install $TargetApp
        }
    }

    foreach ($TargetApp in $sudoApps) {
        if (-Not ($InstalledApps -match "$TargetApp")) {
            Write-Host "Installing $TargetApp..." -ForegroundColor Blue
            sudo scoop install $TargetApp
        }
    }

    # scoop install zulu11
    # scoop install openedfilesview
    # scoop install python27
    # scoop install dorado/miniconda3

    # if (-Not (($null -eq $SCOOP_PROXY_ADDR) -or ($SCOOP_PROXY_ADDR -eq ""))) {
    #     scoop config rm proxy
    # }

    scoop config aria2-enabled true
} else {
    Write-Host "Install apps using scoop failed!"
}


# https://github.com/lukesampson/scoop/wiki/Custom-PHP-configuration
if (Get-Command "php" -ErrorAction SilentlyContinue) {
    
}


if (-Not (check_webservice_up)) {
    if (Get-Command "go" -ErrorAction SilentlyContinue) {
        go env -w GO111MODULE=on
        go env -w GOPROXY="https://goproxy.io,direct"
    }

    if (Get-Command "npm" -ErrorAction SilentlyContinue) {
        & "$PSScriptRoot\npm_config.ps1"
    }
}


# Write-Host "Done." -ForegroundColor Blue