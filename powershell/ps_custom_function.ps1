# New PSObject Template
if (-Not ('Windows.Media.Fonts' -as [Type])) {
    Add-Type -AssemblyName 'PresentationCore'
}

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

    curl -fsL --connect-timeout 3 --max-time 5 -I "$webservice_url"
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

    curl -fsL --connect-timeout 3 --max-time 5 --socks5-hostname "$socks_proxy_url" -I "$webservice_url"
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
    Set-WinHTTP-Proxy -proxy "socks=127.0.0.1:7890" -Bypass "localhost"
    #>
    Param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string] $Proxy,

        [Parameter(Mandatory = $false, Position = 1)]
        [string] $Bypass
    )

    # netsh winhttp set proxy proxy-server="socks=127.0.0.1:7890" bypass-list="localhost"
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
        [Parameter(Mandatory = $false, Position = 0)]
        [string] $HostsURL,

        [Parameter(Mandatory = $false, Position = 1)]
        [string] $Proxy
    )

    if (-Not (isadmin)) {
        Write-Host "This script needs to be run As Admin!" -ForegroundColor Red
        return
    }

    if (($null -eq $HostsURL) -or ($HostsURL -eq "")) {
        $HostsURL = "https://raw.githubusercontent.com/googlehosts/hosts/master/hosts-files/hosts"
    }

    $Hostfile = "$env:windir\System32\drivers\etc\hosts"
    $HostOriginal = "$env:windir\System32\drivers\etc\hosts.original"
    $Hostbackup = "$env:windir\System32\drivers\etc\hosts.bak"
    $DOWNLOAD_TO = "$env:windir\System32\drivers\etc\hosts.download"

    if (-Not (Test-Path $HostOriginal)) {
        Copy-Item $Hostfile -Destination $HostOriginal
    }

    if (Test-Path $DOWNLOAD_TO) {
        Remove-Item $DOWNLOAD_TO
    }

    if (($null -eq $Proxy) -or ($Proxy -eq "")) {
        curl -fsL --connect-timeout 5 --ssl-no-revoke -o "$DOWNLOAD_TO" "$HostsURL"
    } else {
        curl -fsL --connect-timeout 5 --ssl-no-revoke --socks5-hostname "$Proxy" -o "$DOWNLOAD_TO" "$HostsURL"
    }

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

# https://www.powershellgallery.com/packages/RoughDraft/0.1/Content/Get-Font.ps1
function GetFonts() {
    <#
    .Synopsis
        Gets the fonts available
    .Description
        Gets the fonts available on the current installation
    .Example
        GetFonts
    .Example
        GetFonts -IncludeDetail
    #>
    # [OutputType([Windows.Media.FontFamily], [string])]
    param(
        # If set, finds finds with this name
        [Parameter(Position=0,ValueFromPipelineByPropertyName=$true)]
        [string]$Name,
        # If set, will include all details of the font
        [switch]$IncludeDetail,
        # If set, will sort the results
        [Switch]$Sort
    )

    begin {
        $fontList = [Windows.Media.Fonts]::SystemFontFamilies
    }

    process {
        #region Filter Font List
        if ($Name.Trim()) {

            $currentFontList = foreach ($f in $fontList) {
                if ($f.Source -like "$name*") {
                    $f
                }
            }
        } else {
            $currentFontList = $fontList
        }
        #endregion Filter Font List

        if ($IncludeDetail) {
            if ($sort) {
                $currentFontList | 
                    Sort-Object Source | 
                    Add-Member ScriptProperty Name { $this.Source } -PassThru -Force
            } else {
                $currentFontList | 
                    Add-Member ScriptProperty Name { $this.Source } -PassThru -Force
            }

        } else {
            if ($sort) {
                $currentFontList | 
                    Sort-Object Source | 
                    Select-Object -ExpandProperty Source
            } else {
                $currentFontList | 
                    Select-Object -ExpandProperty Source
            }
        }
    }
}

function CheckSetGlobalProxy() {
    param (
        [string]$ProxyAddress = "127.0.0.1",
        [string]$ProxySocksPort = "7890",
        [string]$ProxyHTTPPort = "7890",
        [string]$Msg = "Porxy address?"
    )

    $Proxy = ""
    if (-Not (check_webservice_up)) {
        $Proxy = "${ProxyAddress}:${ProxySocksPort}"
        if (-Not (check_socks5_proxy_up $Proxy)) {
            if ($PROMPT_VALUE = Read-Host "$Msg[$($Proxy)]") {
                $Proxy = $PROMPT_VALUE
                if (-Not (check_socks5_proxy_up $Proxy)) {
                    $Proxy = ""
                }
            } else {
                $Proxy = ""
            }
        }
    }

    if ($Proxy) {
        $env:GLOBAL_PROXY_IP = $ProxyAddress
        $env:GLOBAL_PROXY_SOCKS_PORT = $ProxySocksPort
        $env:GLOBAL_PROXY_HTTP_PORT = $ProxyHTTPPort

        $env:http_proxy="${ProxyAddress}:${ProxyHTTPPort}"
        $env:https_proxy="${ProxyAddress}:${ProxyHTTPPort}"

        return $true
    } else {
        $env:GLOBAL_PROXY_IP = ""
        $env:GLOBAL_PROXY_SOCKS_PORT = ""
        $env:GLOBAL_PROXY_HTTP_PORT = ""

        $env:http_proxy=""
        $env:https_proxy=""

        return $false
    }
}

function RebuildFontCache {
    # https://eddiejackson.net/wp/?p=16137
    # https://www.isunshare.com/windows-10/how-to-delete-font-cache-in-windows-10.html
    if (-Not (isadmin)) {
        Write-Host "This script needs to be run As Admin!" -ForegroundColor Red
        return
    }

    Stop-Service -Name "FontCache"

    Remove-Item "$env:windir\ServiceProfiles\LocalService\AppData\Local\FontCache" -Recurse -Force -Confirm:$false -ErrorAction Stop
    Remove-Item "$env:windir\System32\FNTCACHE.DAT" -Force -Confirm:$false -ErrorAction Stop

    Start-Service -Name "FontCache"
}

function ConvertTo-HexString {
    <#
    .SYNOPSIS
        Convert to Hex String
    .DESCRIPTION
        Convert to Hex String
        https://www.powershellgallery.com/packages/Utility.PS/
    .EXAMPLE
        Convert string to hex byte string seperated by spaces.
        ConvertTo-HexString "What is a hex string?"
    .EXAMPLE
        Convert ASCII string to hex byte string with no seperation.
        "ASCII string to hex string" | ConvertTo-HexString -Delimiter "" -Encoding Ascii
    .INPUTS
        System.Object
    #>
    [CmdletBinding()]
    param (
        # Value to convert
        [Parameter(Mandatory=$true, Position = 0, ValueFromPipeline=$true)]
        [object] $InputObjects,
        # Delimiter between Hex pairs
        [Parameter (Mandatory=$false)]
        [string] $Delimiter = ' ',
        # Encoding to use for text strings
        [Parameter (Mandatory=$false)]
        [ValidateSet('Ascii', 'UTF32', 'UTF7', 'UTF8', 'BigEndianUnicode', 'Unicode')]
        [string] $Encoding = 'Default'
    )

    begin {
        function Transform ([byte[]]$InputBytes) {
            [string[]] $outHexString = New-Object string[] $InputBytes.Count
            for ($iByte = 0; $iByte -lt $InputBytes.Count; $iByte++) {
                $outHexString[$iByte] = $InputBytes[$iByte].ToString('X2')
            }
            return $outHexString -join $Delimiter
        }

        ## Create list to capture byte stream from piped input.
        [System.Collections.Generic.List[byte]] $listBytes = New-Object System.Collections.Generic.List[byte]
    }

    process
    {
        if ($InputObjects -is [byte[]])
        {
            Write-Output (Transform $InputObjects)
        }
        else {
            foreach ($InputObject in $InputObjects) {
                [byte[]] $InputBytes = $null
                if ($InputObject -is [byte]) {
                    ## Populate list with byte stream from piped input.
                    if ($listBytes.Count -eq 0) {
                        Write-Verbose 'Creating byte array from byte stream.'
                        Write-Warning ('For better performance when piping a single byte array, use "Write-Output $byteArray -NoEnumerate | {0}".' -f $MyInvocation.MyCommand)
                    }
                    $listBytes.Add($InputObject)
                }
                elseif ($InputObject -is [byte[]])
                {
                    $InputBytes = $InputObject
                }
                elseif ($InputObject -is [string])
                {
                    $InputBytes = [Text.Encoding]::$Encoding.GetBytes($InputObject)
                }
                elseif ($InputObject -is [bool] -or $InputObject -is [char] -or $InputObject -is [single] -or $InputObject -is [double] -or $InputObject -is [int16] -or $InputObject -is [int32] -or $InputObject -is [int64] -or $InputObject -is [uint16] -or $InputObject -is [uint32] -or $InputObject -is [uint64])
                {
                    $InputBytes = [System.BitConverter]::GetBytes($InputObject)
                }
                elseif ($InputObject -is [guid])
                {
                    $InputBytes = $InputObject.ToByteArray()
                }
                elseif ($InputObject -is [System.IO.FileSystemInfo])
                {
                    if ($PSVersionTable.PSVersion -ge [version]'6.0') {
                        $InputBytes = Get-Content $InputObject.FullName -Raw -AsByteStream
                    }
                    else {
                        $InputBytes = Get-Content $InputObject.FullName -Raw -Encoding Byte
                    }
                }
                else
                {
                    ## Non-Terminating Error
                    $Exception = New-Object ArgumentException -ArgumentList ('Cannot convert input of type {0} to Hex string.' -f $InputObject.GetType())
                    Write-Error -Exception $Exception -Category ([System.Management.Automation.ErrorCategory]::ParserError) -CategoryActivity $MyInvocation.MyCommand -ErrorId 'ConvertHexFailureTypeNotSupported' -TargetObject $InputObject
                }

                if ($null -ne $InputBytes -and $InputBytes.Count -gt 0) {
                    Write-Output (Transform $InputBytes)
                }
            }
        }
    }

    end {
        ## Output captured byte stream from piped input.
        if ($listBytes.Count -gt 0) {
            Write-Output (Transform $listBytes.ToArray())
        }
    }
}

function ConvertFrom-HexString {
    <#
    .SYNOPSIS
        Convert from Hex String
    .DESCRIPTION
        Convert from Hex String
        https://www.powershellgallery.com/packages/Utility.PS/
    .EXAMPLE
        ConvertFrom-HexString "68 65 6C 6C 6F 20 77 6F 72 6C 64" # hello world
    #>
    [CmdletBinding()]
    param (
        # Value to convert
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [string[]] $InputObject,
        # Delimiter between Hex pairs
        [Parameter (Mandatory=$false)]
        [string] $Delimiter = " ",
        # Output raw byte array
        [Parameter (Mandatory=$false)]
        [switch] $RawBytes,
        # Encoding to use for text strings
        [Parameter (Mandatory=$false)]
        [ValidateSet("Ascii", "UTF32", "UTF7", "UTF8", "BigEndianUnicode", "Unicode")]
        [string] $Encoding = "Default"
    )

    process
    {
        $listBytes = New-Object object[] $InputObject.Count
        for ($iString = 0; $iString -lt $InputObject.Count; $iString++) {
            [string] $strHex = $InputObject[$iString]
            if ($strHex.Substring(2,1) -eq $Delimiter) {
                [string[]] $listHex = $strHex -split $Delimiter
            }
            else {
                [string[]] $listHex = New-Object string[] ($strHex.Length/2)
                for ($iByte = 0; $iByte -lt $strHex.Length; $iByte += 2) {
                    $listHex[[System.Math]::Truncate($iByte/2)] = $strHex.Substring($iByte, 2)
                }
            }

            [byte[]] $outBytes = New-Object byte[] $listHex.Count
            for ($iByte = 0; $iByte -lt $listHex.Count; $iByte++)
            {
                $outBytes[$iByte] = [byte]::Parse($listHex[$iByte],[System.Globalization.NumberStyles]::HexNumber)
            }

            if ($RawBytes) { $listBytes[$iString] = $outBytes }
            else {
                $outString = ([Text.Encoding]::$Encoding.GetString($outBytes))
                Write-Output $outString
            }
        }
        if ($RawBytes) {
            return $listBytes
        }
    }
}

# unix like `cut` command
function cut() {
    param (
        [Parameter(ValueFromPipeline = $True)]
        [string]$inputobject,

        [string]$delimiter='\s+',

        [string[]]$field
    )

    process {
        if ($null -eq $field) {
            $inputobject -split $delimiter
        } else {
            ($inputobject -split $delimiter)[$field]
        }
    }
}

# Finding Illegal Characters in Path
function findIllegalCharsInPath() {
    param (
        [string]$pathToCheck
    )

    # get invalid characters and escape them for use with RegEx
    $illegal = [Regex]::Escape(-join [Io.Path]::GetInvalidPathChars())
    $pattern = "[$illegal]"

    # find illegal characters
    $invalid = [regex]::Matches($pathToCheck, $pattern, 'IgnoreCase').Value | Sort-Object -Unique
    # $invalid | Format-Hex

    if ($null -ne $invalid) {
        Write-Host "Don't use these characters in path: $invalid" -ForegroundColor Red
    } else {
        Write-Host "No invalid path characters in: $pathToCheck" -ForegroundColor Blue
    }
}

# Finding Illegal Characters in Filename
function findIllegalCharsInFilename() {
    param (
        [string]$fileToCheck
    )

    # get invalid characters and escape them for use with RegEx
    $illegal = [Regex]::Escape(-join [Io.Path]::GetInvalidFileNameChars())
    $pattern = "[$illegal]"

    # find illegal characters
    $invalid = [regex]::Matches($fileToCheck, $pattern, 'IgnoreCase').Value | Sort-Object -Unique

    if ($null -ne $invalid) {
        Write-Host "Don't use these characters in path: $invalid" -ForegroundColor Red
    } else {
        Write-Host "No invalid file characters in: $fileToCheck" -ForegroundColor Blue
    }
}