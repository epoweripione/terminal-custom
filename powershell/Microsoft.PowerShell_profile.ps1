$PS_CUSTOM_FUNCTION = "$HOME\Documents\PowerShell\Scripts\ps_custom_function.ps1"
if ((Test-Path "$PS_CUSTOM_FUNCTION") -and ((Get-Item "$PS_CUSTOM_FUNCTION").length -gt 0)) {
    . "$PS_CUSTOM_FUNCTION"
}


Import-Module Find-String
# Import-Module PSColors
# Import-Module TabExpansionPlusPlus

Import-Module Posh-git
Import-Module oh-my-posh

Set-Theme Powerlevel10k-my

## Color coding Get-ChildItem
# Import-Module Get-ChildItemColor

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
    $tmp = Get-Location;

    if ($pwd) {
        Set-Location $pwd;
    }
    Set-Variable -Name OLDPWD -Value $tmp -Scope global;
}

Set-Alias -Name cd -value cddash -Option AllScope

## python encoding
$env:PYTHONIOENCODING="utf-8"

function GitLogPretty {
    git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --all
}

function UpdateScoop {
    scoop update
    scoop update *
    scoop config aria2-enabled false
    scoop update *
    scoop config aria2-enabled true
    scoop cleanup *
}

function  SearchScoopBucket {
    param (
        [string]$SearchCond = ""
    )

    if ($SearchCond) {
        Get-ChildItem -Path "$env:UserProfile\scoop\buckets" `
            -Recurse -Include "*$SearchCond*.json" -Depth 2 -Name
    }
}

function UpdateMyScript {
    Set-Location ~
    if (check_socks5_proxy_up $SCOOP_PROXY_ADDR) {
        curl -L --socks5-hostname "127.0.0.1:7890" `
            -o ".\pwsh_script_download.ps1" "https://git.io/JeQ9d" && `
        .\pwsh_script_download.ps1
    } else {
        curl -L -o ".\pwsh_script_download.ps1" "https://git.io/JeQ9d" && `
        .\pwsh_script_download.ps1
    }
}

function PrettyLS {colorls --light -A}
function GitStat {git status}
function GoBack {Set-Location ..}
function GetMyIp {curl -sL -4 http://ip-api.com/json/ | ConvertFrom-Json}
function EditHosts {sudo notepad $env:windir\System32\drivers\etc\hosts}
function EditHistory {notepad (Get-PSReadlineOption).HistorySavePath}

## Other alias
Set-Alias open Invoke-Item
Set-Alias .. GoBack
Set-Alias glola GitLogPretty
Set-Alias gst GitStat
Set-Alias myip GetMyIp
Set-Alias pls PrettyLS
Set-Alias suu UpdateScoop
Set-Alias ssb SearchScoopBucket
Set-Alias ums UpdateMyScript
Set-Alias hosts EditHosts
Set-Alias history EditHistory
