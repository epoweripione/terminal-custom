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


# goproxy
# https://github.com/snail007/goproxy
if [[ ! -d "/etc/proxy" || ! -x "$(command -v proxy)" ]]; then
    colorEcho ${BLUE} "Installing goproxy..."
    curl -SL https://raw.githubusercontent.com/snail007/goproxy/master/install_auto.sh | bash
fi

if [[ -d "/etc/proxy" && -x "$(command -v proxy)" ]]; then
    if [[ ! -e "/etc/proxy/proxy.crt" ]]; then
        cd /etc/proxy && proxy keygen -C proxy -d 365 >/dev/null 2>&1 
    fi
fi


# ProxyAdmin
# https://github.com/snail007/proxy_admin_free
# config file: /etc/gpa/app.toml
# http://127.0.0.1:32080
# user/pwd: root/123
# proxy-admin install
# proxy-admin uninstall
# proxy-admin start
# proxy-admin stop
# proxy-admin restart
if [[ ! -x "$(command -v proxy-admin)" ]]; then
    colorEcho ${BLUE} "Installing ProxyAdmin..."
    curl -L https://raw.githubusercontent.com/snail007/proxy_admin_free/master/install_auto.sh | bash

    if [[ -x "$(command -v proxy-admin)" ]]; then
        CHECK_URL="https://api.github.com/repos/snail007/proxy_admin_free/releases/latest"
        REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4)
        if [[ -n "$REMOTE_VERSION" ]]; then
            echo ${REMOTE_VERSION} > /etc/gpa/.version
        fi
    fi
fi


# # proxy-web
# # https://github.com/yincongcyincong/proxy-web
# colorEcho ${BLUE} "Installing proxy-web..."

# CHECK_URL="https://api.github.com/repos/yincongcyincong/proxy-web/releases/latest"
# REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4)

# DOWNLOAD_URL=https://github.com/yincongcyincong/proxy-web/releases/download/${REMOTE_VERSION}/proxy-web-${ostype}-${spruce_type}.tar.gz
# curl -SL $DOWNLOAD_URL -o proxy-web.tar.gz && \
#     tar -zxPf proxy-web.tar.gz -C /srv/ && \
#     rm -f proxy-web.tar.gz && \
#     chmod +x /srv/proxy-web/proxy-web && \
#     echo ${REMOTE_VERSION} > /srv/proxy-web/.version

## How to use
# sed -i 's/48080/28080/' /srv/proxy-web/config/config.ini && \
#     sed -i 's|password = admin|password = Passw0rd|' /srv/proxy-web/config/config.ini
# nohup /srv/proxy-web/proxy-web >/dev/null 2>&1 & disown
