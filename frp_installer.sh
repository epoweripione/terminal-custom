#!/bin/bash

if [[ $UID -ne 0 ]]; then
    echo "Please run this script as root user!"
    exit 0
fi

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

if [[ -z "$spruce_type" ]]; then
    get_os_type
    get_arch
fi


# frp
# https://github.com/fatedier/frp
colorEcho ${BLUE} "Installing frp..."

CHECK_URL="https://api.github.com/repos/fatedier/frp/releases/latest"
REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
if [[ -n "$REMOTE_VERSION" ]]; then
    DOWNLOAD_URL=https://github.com/fatedier/frp/releases/download/v${REMOTE_VERSION}/frp_${REMOTE_VERSION}_${ostype}_${spruce_type}.tar.gz
    curl -SL $DOWNLOAD_URL -o frp.tar.gz && \
        tar -zxPf frp.tar.gz -C /srv/ && \
        rm frp.tar.gz && \
        mkdir -p /srv/frp && \
        cp -rf /srv/frp_*/* /srv/frp && \
        rm -rf /srv/frp_*
fi


# sed -i '/^exit 0/i\nohup /srv/frp/frps -c /srv/frp/frps.ini >/dev/null 2>&1 & disown\n' /etc/rc.local

cd $HOME
