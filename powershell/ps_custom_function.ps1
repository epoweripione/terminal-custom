# New PSObject Template
$DismObjT = New-Object –TypeName PSObject -Property @{
    "Feature" = ""
    "State" = ""
    "ComputerName" = ""
}

function isadmin() {
    # Returns true/false
    ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

function CheckDownloadPWSHNewVersion {
    [Version]$ReleaseVersion = (Invoke-RestMethod 'https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/metadata.json').ReleaseTag -replace '^v'
    if ($PSVersionTable.PSEdition -like "Core" -and $ReleaseVersion -gt $PSVersionTable.PSVersion) {
        $latest = Invoke-RestMethod -Uri "https://api.github.com/repos/PowerShell/PowerShell/releases" | Where-Object { $_.tag_name -eq "v$ReleaseVersion" }
        $downloadUrl = $latest.assets | Where-Object Name -like "*win-x64.msi" | Select-Object -ExpandProperty 'browser_download_url'
        Invoke-WebRequest -Uri $downloadUrl -OutFile "$PSScriptRoot\$(Split-Path $downloadUrl -Leaf)"
    }
    ## another method
    # $latest = Invoke-RestMethod 'https://api.github.com/repos/PowerShell/PowerShell/releases/latest'
    # $downloadUrl = $latest.assets | Where-Object Name -like "*win-x64.msi" | Select-Object -ExpandProperty 'browser_download_url'
    # $fileName = Split-Path $downloadUrl -Leaf
    # $webClient = New-Object System.Net.WebClient
    # try {
    #     $webClient.DownloadFile($downloadUrl, "$PSScriptRoot\$fileName")
    # }
    # finally {
    #     $webClient.Dispose()
    # }
}

# https://gallery.technet.microsoft.com/scriptcenter/Parse-DISM-Get-Features-d25dde0a
# Must enable PSremoting on remote PC
# Enable-PSRemoting
function  GetDISMOnlineFeatures() {
    Param (
        # Set one or multiple computernames, also used for refering the logfile names with -UseLog. Default target is localhost computername, looks for\creates dism_<localhostname>.log
        [string[]]$Computers = $env:COMPUTERNAME
    )

    # Creating Blank array for holding the result
    $objResult = @()
    foreach ($Computer in $Computers) {
        # Read current values
        $List = Invoke-Command -ComputerName $Computer {Dism /online /English /Get-Features}
        # Use this if you get WinRM errors for above line, making the script local only
        # $List = Dism /online /Get-Features

        #Counter for getting alternate values
        $i = 1
        #Parsing the data
        #$List | Where-Object { $_.StartsWith("Feature Name :") -OR $_.StartsWith("State :") }| # where(43ms) is slower than Select-String(20ms)
        $List | Select-String -pattern "Feature Name :", "State :" | ForEach-Object {
            if ($i%2) {
                #Creating new object\Resetting for every item using template
                $TempObj = $DismObjT | Select-Object *
                #Assigning Value1
                $TempObj.Feature = ([string]$_).split(":")[1].trim() ;$i=0
            } else {
                #Assigning Value2
                $TempObj.State = ([string]$_).split(":")[1].trim() ;$i=1
                $TempObj.ComputerName = $Computer
                #Incrementing the object once both values filled
                $objResult+=$TempObj
            } 
        }
    }

    return $objResult
}

function  GetDISMOnlineCapabilities() {
    Param (
        # Set one or multiple computernames, also used for refering the logfile names with -UseLog. Default target is localhost computername, looks for\creates dism_<localhostname>.log
        [string[]]$Computers = $env:COMPUTERNAME
    )

    # Creating Blank array for holding the result
    $objResult = @()
    foreach ($Computer in $Computers) {
        # Read current values
        $List = Invoke-Command -ComputerName $Computer {Dism /online /English /Get-Capabilities}

        #Counter for getting alternate values
        $i = 1
        #Parsing the data
        #$List | Where-Object { $_.StartsWith("Feature Name :") -OR $_.StartsWith("State :") }| # where(43ms) is slower than Select-String(20ms)
        $List | Select-String -pattern "Capability Identity :", "State :" | ForEach-Object {
            if ($i%2) {
                #Creating new object\Resetting for every item using template
                $TempObj = $DismObjT | Select-Object *
                #Assigning Value1
                $TempObj.Feature = ([string]$_).split(":")[1].trim() ;$i=0
            } else {
                #Assigning Value2
                $TempObj.State = ([string]$_).split(":")[1].trim() ;$i=1
                $TempObj.ComputerName = $Computer
                #Incrementing the object once both values filled
                $objResult+=$TempObj
            } 
        }
    }

    return $objResult
}

function GetIPGeolocation() {

    param($ipaddress)

    $resource = "http://ip-api.com/json/$ipaddress"
    try {
        $geoip = Invoke-RestMethod -Method Get -URI $resource
    } catch {
        Write-Verbose -Message "Catched an error"
        $PSCmdlet.ThrowTerminatingError($PSitem)
    }

    # $geoip | Get-Member
    $hash = @{
        IP = $geoip.query
        CountryCode = $geoip.countryCode
        Country = $geoip.country
        Region = $geoip.region
        RegionName = $geoip.regionName
        AS = $geoip.as
        ISP = $geoip.isp
        ORG = $geoip.org
        City = $geoip.city
        ZipCode = $geoip.zip
        TimeZone = $geoip.timezone
        Latitude = $geoip.lat
        Longitude = $geoip.lon
        }

    $result = New-Object PSObject -Property $hash

    return $result
}
function check_webservice_up() {
    param($webservice_url)

    if (($null -eq $webservice_url) -or ($webservice_url -eq "")) {
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
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $socks_proxy_url,

        [Parameter(Mandatory = $false, Position = 1)]
        [string] $webservice_url
    )

    if (($null -eq $webservice_url) -or ($webservice_url -eq "")) {
        $webservice_url = "www.google.com"
    }

    curl -fsSL --connect-timeout 3 --max-time 5 --socks5-hostname "$socks_proxy_url" -I "$webservice_url"
    if ($?) {
        return $true
    } else {
        return $false
    }
}

function Set-WinHTTP-Proxy {
    <#
    .Description
    This function will set the proxy server using netsh.
    .Example
    Setting proxy information
    Set-WinHTTP-Proxy -proxy "127.0.0.1:7890"
    Set-WinHTTP-Proxy -proxy "socks=127.0.0.1:7891" -Bypass "localhost"
    #>
    Param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string] $Proxy,

        [Parameter(Mandatory = $false, Position = 1)]
        [string] $Bypass
    )

    # netsh winhttp set proxy proxy-server="socks=127.0.0.1:7891" bypass-list="localhost"
    if (($null -eq $Proxy) -or ($Proxy -eq "")) {
        netsh winhttp reset proxy
    } else {
        if ($Proxy -eq "ie") {
            netsh winhttp import proxy source=ie
        } else {
            if ($Bypass) {
                netsh winhttp set proxy proxy-server="$Proxy" bypass-list="$Bypass"
            } else {
                netsh winhttp set proxy "$Proxy"
            }
        }
    }
}

function Set-InternetProxy {
    <#
    .Description
    This function will set the proxy server and (optinal) Automatic configuration script.
    .Example
    Setting proxy information
    Set-InternetProxy -proxy "127.0.0.1:7890"
    .Example
    Setting proxy information and (optinal) Automatic Configuration Script
    Set-InternetProxy -proxy "127.0.0.1:7890" -acs "http://127.0.0.1:7892"
    #>
    Param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String[]] $Proxy,

        [Parameter(Mandatory = $False, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [AllowEmptyString()]
        [String[]] $acs
    )

    Begin {
        $regKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    }

    # Get-ItemProperty -Path $regKey | Select-Object ProxyServer, ProxyEnable, ProxyOverride
    Process {
        Set-ItemProperty -path $regKey -Name ProxyEnable -value 1
        Set-ItemProperty -path $regKey -Name ProxyServer -value $proxy
        Set-ItemProperty -Path $regKey -Name ProxyOverride -Value '<local>'
        if ($acs) {            
            Set-ItemProperty -path $regKey -Name AutoConfigURL -Value $acs          
        }

        [System.Environment]::SetEnvironmentVariable('http_proxy', $proxy, 'User')
        [System.Environment]::SetEnvironmentVariable('https_proxy', $proxy, 'User')
        [System.Environment]::SetEnvironmentVariable('HTTP_PROXY', $proxy, 'User')
        [System.Environment]::SetEnvironmentVariable('HTTPS_PROXY', $proxy, 'User')
    } 

    End {
        Write-Output "Proxy is now enabled, Proxy Server: $proxy"
        if ($acs) {
            Write-Output "Automatic Configuration Script: $acs"
        } else {
            Write-Output "Automatic Configuration Script: Not Defined"
        }
    }
}

function Clear-InternetProxy {
    Begin {
        $regKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    }

    Process {
        Set-ItemProperty -path $regKey -Name ProxyEnable -value 0
        Set-ItemProperty -path $regKey -Name ProxyServer -value ''
        Set-ItemProperty -Path $regKey -Name ProxyOverride -Value ''
        Set-ItemProperty -path $regKey -Name AutoConfigURL -Value ''

        [System.Environment]::SetEnvironmentVariable('http_proxy', $null, 'User')
        [System.Environment]::SetEnvironmentVariable('https_proxy', $null, 'User')
        [System.Environment]::SetEnvironmentVariable('HTTP_PROXY', $null, 'User')
        [System.Environment]::SetEnvironmentVariable('HTTPS_PROXY', $null, 'User')
    } 

    End {
        Write-Output "Proxy is now disabled!"
    }
}

function DownloadHosts() {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $HostsURL
    )

    if (-Not (isadmin)) {
        Write-Host "This script needs to be run As Admin!" -ForegroundColor Red
        return
    }

    $Hostfile = "$env:windir\System32\drivers\etc\hosts"
    $Hostbackup = "$env:windir\System32\drivers\etc\hosts.bak"
    $DOWNLOAD_TO = "$env:windir\System32\drivers\etc\hosts.download"
    if (Test-Path $DOWNLOAD_TO) {
        Remove-Item $DOWNLOAD_TO
    }

    curl -L --connect-timeout 5 -o "$DOWNLOAD_TO" "$HostsURL"
    if ($?) {
        if ((Test-Path $DOWNLOAD_TO) -and ((Get-Item $DOWNLOAD_TO).length -gt 0)) {
            Copy-Item $Hostfile -Destination $Hostbackup
            Copy-Item $DOWNLOAD_TO -Destination $Hostfile
        }
        # flush dns
        ipconfig -flushdns | Out-Null
    }
}

function RestartWSL {
    if (-Not (isadmin)) {
        Write-Host "This script needs to be run As Admin!" -ForegroundColor Red
        return
    }

    Stop-Service -Name "LxssManager"
    Start-Service -Name "LxssManager"
}
