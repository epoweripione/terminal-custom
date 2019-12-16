#Requires -RunAsAdministrator

## get a list of installed apps
# Get-AppXProvisionedPackage -Online | Select-object DisplayName | Out-File online_apps.txt
# Get-AppxPackage | Select Name, PackageFullName | Format-Table -AutoSize
# Get-AppxPackage | Select-object name | Out-File pre_installed_apps.txt

## remove pre-installed apps
# Get-AppXPackage –Name *solitairecollection* | Remove-AppXPackage


# Remove built in windows 10 apps
# https://adamtheautomator.com/remove-built-in-windows-10-apps-powershell/
Write-Host "Removing built in windows 10 apps..." -ForegroundColor Blue
$ProvisionedAppPackageNames = @(
    "Microsoft.BingFinance"
    "Microsoft.BingNews"
    "Microsoft.BingSports"
    "Microsoft.BingWeather"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.SkypeApp"
    "Microsoft.XboxApp"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.Messaging"
    "Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.Wallet"
    "microsoft.windowscommunicationsapps"
    "Microsoft.WindowsMaps"
)
# "Microsoft.GetHelp"
# "Microsoft.Getstarted"
# "Microsoft.Microsoft3DViewer"
# "Microsoft.MixedReality.Portal"
# "Microsoft.MSPaint"
# "Microsoft.MicrosoftStickyNotes"
# "Microsoft.Office.OneNote"
# "Microsoft.Print3D"
# "Microsoft.ScreenSketch"
# "Microsoft.Windows.Photos"
# "Microsoft.WindowsAlarms"
# "Microsoft.WindowsCalculator"
# "Microsoft.WindowsCamera"
# "Microsoft.WindowsFeedbackHub"
# "Microsoft.WindowsSoundRecorder"
# "Microsoft.YourPhone"
# "Microsoft.ZuneMusic"
# "Microsoft.ZuneVideo"
foreach ($ProvisionedAppName in $ProvisionedAppPackageNames) {
    # Write-Output "Uninstalling $ProvisionedAppName..."
    Write-Host "Uninstalling $ProvisionedAppName..." -ForegroundColor Blue
    Get-AppxPackage -Name $ProvisionedAppName -AllUsers | Remove-AppxPackage
    # This line removes it from being installed again
    Get-AppXProvisionedPackage -Online `
        | Where-Object DisplayName -EQ $ProvisionedAppName `
        | Remove-AppxProvisionedPackage -Online `
        | Out-Null
    # Remove app dir
    $appPath = "$Env:LOCALAPPDATA\Packages\$ProvisionedAppName*"
    Remove-Item $appPath -Recurse -Force -Confirm:$false -ErrorAction 0
}