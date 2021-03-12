Param (
	[string]$Proxy = ""
)

if (-Not (Get-Command -Name "check_webservice_up" 2>$null)) {
    $CUSTOM_FUNCTION = "$PSScriptRoot\ps_custom_function.ps1"
    if ((Test-Path "$CUSTOM_FUNCTION") -and ((Get-Item "$CUSTOM_FUNCTION").length -gt 0)) {
        . "$CUSTOM_FUNCTION"
    }
}

if (($null -eq $Proxy) -or ($Proxy -eq "")) {
    $Proxy = "127.0.0.1:7890"
}

if (Get-Command "git" -ErrorAction SilentlyContinue) {
    git config --global core.autocrlf false
    git config --global core.safecrlf true
    git config --global core.filemode false

    git config --global color.ui true
    git config --global color.status auto
    git config --global color.diff auto
    git config --global color.branch auto
    git config --global color.interactive auto

    git config --global alias.st status
    git config --global alias.co checkout
    git config --global alias.ci commit
    git config --global alias.br branch
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

    if (check_socks5_proxy_up $Proxy) {
        git config --global http.proxy "socks5://$Proxy"
        git config --global https.proxy "socks5://$Proxy"
    } else {
        git config --global --unset http.proxy
        git config --global --unset https.proxy
    }

    if (Get-Command "delta" -ErrorAction SilentlyContinue) {
        git config --global core.pager delta

        git config --global delta.features "side-by-side line-numbers decorations"
        git config --global delta.plus-style "syntax #003800"
        git config --global delta.minus-style "syntax #3f0001"
        git config --global delta.syntax-theme Dracula

        git config --global delta.decorations.commit-decoration-style "bold yellow box ul"
        git config --global delta.decorations.file-style "bold yellow ul"
        git config --global delta.decorations.file-decoration-style none
        git config --global delta.decorations.hunk-header-decoration-style "cyan box ul"

        git config --global delta.line-numbers.line-numbers-left-style cyan
        git config --global delta.line-numbers.line-numbers-right-style cyan
        git config --global delta.line-numbers.line-numbers-minus-style 124
        git config --global delta.line-numbers.line-numbers-plus-style 28

        git config --global interactive.diffFilter "delta --color-only"
    }
}
