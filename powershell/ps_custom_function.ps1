# New PSObject Template
$DismObjT = New-Object –TypeName PSObject -Property @{
    "Feature" = ""
    "State" = ""
    "ComputerName" = ""
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