#!/bin/bash

if [[ $UID -ne 0 ]]; then
    echo "Please run this script as root user!"
    exit 0
fi

# Load custom functions
if type 'colorEcho' 2>/dev/null | grep -q 'function'; then
    :
else
    if [[ -e "$HOME/custom_functions.sh" ]]; then
        source "$HOME/custom_functions.sh"
    else
        echo "$HOME/custom_functions.sh not exist!"
        exit 0
    fi
fi

if [[ -z "$spruce_type" ]]; then
    get_os_type
    get_arch
fi


# goproxy
# https://github.com/snail007/goproxy
colorEcho ${BLUE} "Installing goproxy..."
curl -SL https://raw.githubusercontent.com/snail007/goproxy/master/install_auto.sh | bash


# proxy-web
# https://github.com/yincongcyincong/proxy-web
colorEcho ${BLUE} "Installing proxy-web..."

CHECK_URL="https://api.github.com/repos/yincongcyincong/proxy-web/releases/latest"
REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4)

curl -SL -o proxy-web.tar.gz https://github.com/yincongcyincong/proxy-web/releases/download/$REMOTE_VERSION/proxy-web-$ostype-$spruce_type.tar.gz && \
    tar -zxPf proxy-web.tar.gz -C /srv/ && \
    rm -f proxy-web.tar.gz && \
    chmod +x /srv/proxy-web/proxy-web

## How to use
# sed -i 's/48080/28080/' /srv/proxy-web/config/config.ini && \
#     sed -i 's|password = admin|password = Passw0rd|' /srv/proxy-web/config/config.ini
# nohup /srv/proxy-web/proxy-web >/dev/null 2>&1 & disown


cd $HOME