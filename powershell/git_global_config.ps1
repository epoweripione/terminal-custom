if (-Not (Get-Command -Name "check_webservice_up" 2>$null)) {
    $CUSTOM_FUNCTION = "$PSScriptRoot\ps_custom_function.ps1"
    if ((Test-Path "$CUSTOM_FUNCTION") -and ((Get-Item "$CUSTOM_FUNCTION").length -gt 0)) {
        . "$CUSTOM_FUNCTION"
    }
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

    $GIT_PROXY_ADDR = "127.0.0.1:7891"
    if (check_socks5_proxy_up $GIT_PROXY_ADDR) {
        git config --global http.proxy "socks5://$GIT_PROXY_ADDR"
        git config --global https.proxy "socks5://$GIT_PROXY_ADDR"
    } else {
        git config --global --unset http.proxy
        git config --global --unset https.proxy
    }
}
