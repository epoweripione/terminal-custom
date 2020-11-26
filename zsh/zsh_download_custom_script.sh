#!/usr/bin/env bash

## How to use
## 1. Install curl first
## 2. Install zsh and oh-my-zsh: source <(curl -sL https://git.io/fA8Jb)
##                               source <(curl -sL http://t.cn/AigJm9ut)
## 3. Init: source <(curl -sL https://git.io/fNpeJ) && $HOME/terminal-custom/zsh/zsh_upgrade_all_packages.sh && $HOME/terminal-custom/zsh/zsh_init.sh
##          source <(curl -sL http://t.cn/AigJuOCW) && $HOME/terminal-custom/zsh/zsh_upgrade_all_packages.sh && $HOME/terminal-custom/zsh/zsh_init.sh
## 4. Update: source <(curl -sL https://git.io/fNpeJ) && $HOME/terminal-custom/zsh/zsh_upgrade_all_packages.sh
##            source <(curl -sL http://t.cn/AigJuOCW) && $HOME/terminal-custom/zsh/zsh_upgrade_all_packages.sh
[[ -z "$CURRENT_DIR" ]] && CURRENT_DIR=$(pwd)

#######color code########
RED="31m"      # Error message
GREEN="32m"    # Success message
YELLOW="33m"   # Warning message
BLUE="36m"     # Info message

colorEcho() {
    COLOR=$1
    echo -e "\033[${COLOR}${@:2}\033[0m"
}


if [[ ! "$(command -v git)" ]]; then
    colorEcho ${RED} "git is not installed! Please install git first!"
    exit
fi


MY_SHELL_SCRIPTS="${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}"

colorEcho ${BLUE} "Cloning custom shell scripts repository to $HOME/terminal-custom..."
if [[ -d "${MY_SHELL_SCRIPTS}" ]]; then
    cd "${MY_SHELL_SCRIPTS}" && git pull --rebase --stat origin master
else
    git clone -c core.eol=lf -c core.autocrlf=false \
        -c fsck.zeroPaddedFilemode=ignore \
        -c fetch.fsck.zeroPaddedFilemode=ignore \
        -c receive.fsck.zeroPaddedFilemode=ignore \
        --depth=1 --branch master \
        https://github.com/epoweripione/terminal-custom.git "${MY_SHELL_SCRIPTS}"
fi


# make *.sh executable
find "${MY_SHELL_SCRIPTS}" -type f -iname "*.sh" -exec chmod +x {} \;


colorEcho ${BLUE} "copy zsh custom plugins & theme to $ZSH/custom..."
if [[ -d "$ZSH/custom" ]]; then
    # zsh custom plugins
    [ -d "$HOME/terminal-custom/zsh/plugins" ] && cp -f $HOME/terminal-custom/zsh/plugins/* "$ZSH/custom/plugins"

    # zsh custom themes
    [ -d "$HOME/terminal-custom/zsh/themes" ] && cp -f $HOME/terminal-custom/zsh/themes/*.zsh-theme "$ZSH/custom/themes"
fi


cd ${CURRENT_DIR}
colorEcho ${GREEN} "Custom shell script download finished!"