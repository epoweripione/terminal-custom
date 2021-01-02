#!/usr/bin/env bash

trap 'rm -r "$WORKDIR"' EXIT

[[ -z "$WORKDIR" ]] && WORKDIR="$(mktemp -d)"
[[ -z "$CURRENT_DIR" ]] && CURRENT_DIR=$(pwd)

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

[[ -z "$OS_INFO_TYPE" ]] && get_os_type
[[ -z "$OS_INFO_ARCH" ]] && get_arch

# goproxy
# https://github.com/snail007/goproxy
INSTALL_NAME="goproxy"

IS_INSTALL="yes"
CURRENT_VERSION="0.0.0"

if [[ -d "/etc/proxy" && -x "$(command -v proxy)" ]]; then
    CURRENT_VERSION=$(proxy --version 2>&1 | cut -d'_' -f2)
else
    [[ "${IS_UPDATE_ONLY}" == "yes" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho ${BLUE} "Checking latest version for ${INSTALL_NAME}..."

    CHECK_URL="https://api.github.com/repos/snail007/goproxy/releases/latest"
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_le $REMOTE_VERSION $CURRENT_VERSION; then
        IS_INSTALL="no"
    fi
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho ${BLUE} "  Installing ${INSTALL_NAME} ${REMOTE_VERSION}..."
    # curl -SL \
    #     https://raw.githubusercontent.com/snail007/goproxy/master/install_auto.sh \
    # | sudo bash
    DOWNLOAD_URL="https://github.com/snail007/goproxy/releases/download/v${REMOTE_VERSION}/proxy-${OS_INFO_TYPE}-${OS_INFO_ARCH}.tar.gz"
    cd "${WORKDIR}" && \
        curl -SL -o proxy-linux-amd64.tar.gz -C- "$DOWNLOAD_URL" && \
        curl -SL "https://raw.githubusercontent.com/snail007/goproxy/master/install.sh" | sudo bash
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
IS_INSTALL="yes"
CURRENT_VERSION="v0.0"

if [[ -x "$(command -v proxy-admin)" ]]; then
    [[ -s "/etc/gpa/.version" ]] && CURRENT_VERSION=$(head -n1 /etc/gpa/.version)
else
    [[ "${IS_UPDATE_ONLY}" == "yes" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    CHECK_URL="https://api.github.com/repos/snail007/proxy_admin_free/releases/latest"
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4)
    if version_le $REMOTE_VERSION $CURRENT_VERSION; then
        IS_INSTALL="no"
    fi
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho ${BLUE} "Installing ProxyAdmin ${REMOTE_VERSION}..."
    curl -SL "https://raw.githubusercontent.com/snail007/proxy_admin_free/master/install_auto.sh" | sudo bash && \
        echo ${REMOTE_VERSION} | sudo tee "/etc/gpa/.version" >/dev/null
fi

cd "${CURRENT_DIR}"