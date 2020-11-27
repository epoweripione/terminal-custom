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

# xray
# https://github.com/XTLS/Xray-core
# https://github.com/XTLS/Xray-install
# /usr/local/etc/xray/config.json
# /var/log/xray/
# UUID: xray uuid
colorEcho ${BLUE} "Checking update for xray..."

IS_INSTALL="yes"
IS_UPDATE="no"
CURRENT_VERSION="0.0.0"

if [[ -s "/usr/local/bin/xray" ]]; then
    IS_UPDATE="yes"
    CURRENT_VERSION=$(xray -version | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
else
    [[ "${IS_UPDATE_ONLY}" == "yes" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]] then
    CHECK_URL="https://api.github.com/repos/XTLS/Xray-core/releases/latest"
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_le $REMOTE_VERSION $CURRENT_VERSION; then
        IS_INSTALL="no"
    fi
fi

if [[ "${IS_INSTALL}" == "yes" ]] then
    colorEcho ${BLUE} "Installing xray ${REMOTE_VERSION}..."

    bash <(curl -L https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh)

    if [[ "${IS_UPDATE}" == "yes" ]] then
        bash <(curl -L https://raw.githubusercontent.com/XTLS/Xray-install/main/install-dat-release.sh)
    fi
fi

cd "${CURRENT_DIR}"