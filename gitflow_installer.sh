#!/bin/bash

# if [[ $UID -ne 0 ]]; then
#     echo "Please run this script as root user!"
#     exit 0
# fi

# Load custom functions
if type 'colorEcho' 2>/dev/null | grep -q 'function'; then
    :
else
    if [[ -s "$HOME/custom_functions.sh" ]]; then
        source "$HOME/custom_functions.sh"
    else
        echo "$HOME/custom_functions.sh not exist!"
        exit 0
    fi
fi


## git-flow (AVH Edition)
# https://github.com/petervanderdoes/gitflow-avh
colorEcho ${BLUE} "Installing git-flow (AVH Edition)..."
DOWNLOAD_URL=https://raw.githubusercontent.com/petervanderdoes/gitflow-avh/develop/contrib/gitflow-installer.sh
wget --no-check-certificate -q $DOWNLOAD_URL && \
    sudo bash gitflow-installer.sh install develop && \
    sudo rm gitflow-installer.sh

## How to use
# http://danielkummer.github.io/git-flow-cheatsheet/index.zh_CN.html
# https://github.com/mylxsw/growing-up/blob/master/doc/%E7%A0%94%E5%8F%91%E5%9B%A2%E9%98%9FGIT%E5%BC%80%E5%8F%91%E6%B5%81%E7%A8%8B%E6%96%B0%E4%BA%BA%E5%AD%A6%E4%B9%A0%E6%8C%87%E5%8D%97.md
