#!/usr/bin/env bash

trap 'rm -rf "$WORKDIR"' EXIT

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

[[ -n "${INSTALLER_CHECK_CURL_OPTION}" ]] && curl_check_opts=(`echo ${INSTALLER_CHECK_CURL_OPTION}`) || curl_check_opts=(-fsL)
[[ -n "${INSTALLER_DOWNLOAD_CURL_OPTION}" ]] && curl_download_opts=(`echo ${INSTALLER_DOWNLOAD_CURL_OPTION}`) || curl_download_opts=(-fSL)

# v2ray
# https://github.com/v2fly/v2ray-core
# https://github.com/v2fly/fhs-install-v2ray
# /usr/local/etc/v2ray/config.json
# /var/log/v2ray/
# UUID: v2ray uuid
APP_INSTALL_NAME="v2ray"
IS_INSTALL="yes"
IS_UPDATE="no"
CURRENT_VERSION="0.0.0"

if [[ -s "/usr/local/bin/v2ray" ]]; then
    IS_UPDATE="yes"
    CURRENT_VERSION=$(v2ray -version | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
else
    [[ "${IS_UPDATE_ONLY}" == "yes" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}Checking latest version for ${FUCHSIA}${APP_INSTALL_NAME}${BLUE}..."

    CHECK_URL="https://api.github.com/repos/v2fly/v2ray-core/releases/latest"
    REMOTE_VERSION=$(curl "${curl_check_opts[@]}" "${CHECK_URL}" | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_le $REMOTE_VERSION $CURRENT_VERSION; then
        IS_INSTALL="no"
    fi
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}  Installing ${FUCHSIA}${APP_INSTALL_NAME} ${YELLOW}${REMOTE_VERSION}${BLUE}..."
    # https://github.com/v2fly/fhs-install-v2ray/wiki/Migrate-from-the-old-script-to-this
    if [[ -d "/usr/bin/v2ray/" ]]; then
        sudo systemctl disable v2ray.service --now
        sudo rm -rf /usr/bin/v2ray/ /etc/v2ray/
        sudo rm -f /etc/systemd/system/v2ray.service
        sudo rm -f /lib/systemd/system/v2ray.service
        sudo rm -f /etc/init.d/v2ray
    fi

    bash <(curl -fsSL https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)

    if [[ "${IS_UPDATE}" == "yes" ]]; then
        bash <(curl -fsSL https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-dat-release.sh)
    fi
fi

cd "${CURRENT_DIR}"