# Proxy settings (need admin privileges) 
# netsh winhttp show proxy
# use ie proxy settings:
# netsh winhttp import proxy source=ie
# or:
# netsh winhttp set proxy 127.0.0.1:55881
# reset:
# netsh winhttp reset proxy


Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted


# https://docs.microsoft.com/en-us/nuget/install-nuget-client-tools
# Find-PackageProvider -Name "Nuget" -AllVersions
# Install-PackageProvider -Name "NuGet" -Force


if (-Not (Test-Path $PROFILE)) {
    New-Item $PROFILE –Type File –Force
}

Install-Module -Name PSReadLine -AllowPrerelease -SkipPublisherCheck -Force

Install-Module Find-String,PSColors,TabExpansionPlusPlus -AllowClobber
Add-Content $PROFILE "`nImport-Module Find-String"
Add-Content $PROFILE "Import-Module PSColors"
Add-Content $PROFILE "Import-Module TabExpansionPlusPlus"

Install-Module Posh-git,oh-my-posh
Add-Content $PROFILE "Import-Module Posh-git"
Add-Content $PROFILE "Import-Module oh-my-posh"

# my theme
mkdir -p ~\Documents\PowerShell\PoshThemes
# Copy-Item $env:SystemDrive\cmder\Paradox-my.psm1  ~\Documents\PowerShell\PoshThemes
$p = New-Object System.Net.WebClient
$p.DownloadFile("https://raw.githubusercontent.com/epoweripione/shellstuff/master/Paradox-my.psm1","~\Documents\PowerShell\PoshThemes\Paradox-my.psm1")

Add-Content $PROFILE "`nSet-Theme Paradox-my"

# Custom
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
'@ | tee $PROFILE -Append
