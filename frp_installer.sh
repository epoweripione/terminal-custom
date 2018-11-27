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


# frp
# https://github.com/fatedier
colorEcho ${BLUE} "Installing frp..."

CHECK_URL="https://api.github.com/repos/fatedier/frp/releases/latest"
REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

cd /srv && \
curl -SL -o frp.tar.gz https://github.com/fatedier/frp/releases/download/v$REMOTE_VERSION/frp_$REMOTE_VERSION_$ostype_$spruce_type.tar.gz && \
tar -zxPf frp.tar.gz -C /srv/ && \
rm frp.tar.gz && \
mv /srv/frp_* /srv/frp


cd $HOME
