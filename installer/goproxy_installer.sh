#!/usr/bin/env bash

if [[ $UID -ne 0 ]]; then
    echo "Please run this script as root user!"
    exit 0
fi

# Load custom functions
if type 'colorEcho' 2>/dev/null | grep -q 'function'; then
    :
else
    if [[ -s "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/custom_functions.sh" ]]; then
        source "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/custom_functions.sh"
    else
        echo "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/custom_functions.sh not exist!"
        exit 0
    fi
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
