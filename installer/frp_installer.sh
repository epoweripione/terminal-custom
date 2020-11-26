#!/usr/bin/env bash

trap 'rm -r "$WORKDIR"' EXIT

[[ -z "$WORKDIR" ]] && WORKDIR="$(mktemp -d)"
[[ -z "$CURRENT_DIR" ]] && CURRENT_DIR=$(pwd)

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


[[ -z "$OS_INFO_TYPE" ]] && get_os_type
[[ -z "$OS_INFO_ARCH" ]] && get_arch


# frp
# https://github.com/fatedier/frp
colorEcho ${BLUE} "Checking update for frp..."

CHECK_URL="https://api.github.com/repos/fatedier/frp/releases/latest"
REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

if [[ -d "/srv/frp" ]]; then
    CURRENT_VERSION=$(/srv/frp/frps --version 2>&1)
    # backup ini files
    mkdir -p "/srv/backup_frp" && \
        cp -f /srv/frp/*.ini "/srv/backup_frp" && \
        rm -f "/srv/backup_frp/frpc_full.ini" && \
        rm -f "/srv/backup_frp/frps_full.ini"
else
    CURRENT_VERSION="0.0.0"
fi

if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
    colorEcho ${BLUE} "Installing frp..."

    if pgrep -f "frps" >/dev/null 2>&1; then
        pkill -f "frps"
    fi

    DOWNLOAD_URL="https://github.com/fatedier/frp/releases/download/v${REMOTE_VERSION}/frp_${REMOTE_VERSION}_${OS_INFO_TYPE}_${OS_INFO_ARCH}.tar.gz"
    wget -O "${WORKDIR}/frp.tar.gz" "$DOWNLOAD_URL" && \
        tar -zxPf "${WORKDIR}/frp.tar.gz" -C "${WORKDIR}" && \
        sudo mkdir -p "/srv/frp" && \
        sudo cp -rf ${WORKDIR}/frp_*/* "/srv/frp"

    [[ -d "/srv/backup_frp" ]] && cp -f /srv/backup_frp/*.ini "/srv/frp"

    if [[ -s "/srv/frp/frps.ini" ]]; then
        nohup /srv/frp/frps -c /srv/frp/frps.ini >/dev/null 2>&1 & disown
    fi
fi


# sed -i '/^exit 0/i\nohup /srv/frp/frps -c /srv/frp/frps.ini >/dev/null 2>&1 & disown\n' /etc/rc.local
