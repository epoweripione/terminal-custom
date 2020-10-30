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

[[ -z "$spruce_type" ]] && get_os_type && get_sysArch


# goproxy
# https://github.com/snail007/goproxy
colorEcho ${BLUE} "Installing goproxy..."
curl -SL https://raw.githubusercontent.com/snail007/goproxy/master/install_auto.sh | bash


# shadowtunnel
# https://github.com/snail007/shadowtunnel
colorEcho ${BLUE} "Checking update for shadowtunnel..."

CHECK_URL="https://api.github.com/repos/snail007/shadowtunnel/releases/latest"
REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4)

if [[ -n "$REMOTE_VERSION" ]]; then
    DOWNLOAD_URL="https://github.com/snail007/shadowtunnel/releases/download/$REMOTE_VERSION/shadowtunnel-$ostype-$spruce_type.tar.gz"
    curl -SL -o "/tmp/shadowtunnel.tar.gz" "$DOWNLOAD_URL" && \
        tar zxfv "/tmp/shadowtunnel.tar.gz" -C "/usr/local/bin" && \
        rm -f "/tmp/shadowtunnel.tar.gz" && \
        chmod +x "/usr/bin/shadowtunnel"
fi

# How to use
## start a http proxy on vps listening on :38080
# proxy http -p "127.0.0.1:38080" --daemon

## start a tunnel on vps listening on :50000 and forward to 127.0.0.1:38080
# shadowtunnel -e -f "127.0.0.1:38080" -l :50000 -p "your-password" -daemon -forever -log "/var/log/shadowtunnel.log"

## start a tunnel on local machine listening on tcp :50000 and forward to udp :50000
# shadowtunnel -U -E -f "[Reomte-IP]:50000" -l :50000 -p "your-password"

## set http proxy configuration in chrome
## setting local chrome's http proxy configuration as below：
# ip: 127.0.0.1 port: 50000

cd $HOME
