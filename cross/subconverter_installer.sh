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

# subconverter
# https://github.com/tindy2013/subconverter
INSTALL_NAME="subconverter"
IS_INSTALL="yes"
IS_UPDATE="no"
CURRENT_VERSION="0.0.0"
CHOICE="N"

if [[ -s "/srv/subconverter/subconverter" ]]; then
    IS_UPDATE="yes"
    CURRENT_VERSION=$(head -n1 /srv/subconverter/.version)
else
    [[ "${IS_UPDATE_ONLY}" == "yes" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]] then
    colorEcho ${BLUE} "Checking latest version for ${INSTALL_NAME}..."

    CHECK_URL="https://api.github.com/repos/tindy2013/subconverter/releases/latest"
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_le $REMOTE_VERSION $CURRENT_VERSION; then
        IS_INSTALL="no"
    fi
fi

if [[ "${IS_INSTALL}" == "yes" ]] then
    colorEcho ${BLUE} "  Installing ${INSTALL_NAME} ${REMOTE_VERSION}..."

    [[ -z "$OS_INFO_TYPE" ]] && get_os_type
    [[ -z "$OS_INFO_VDIS" ]] && get_sysArch

    DOWNLOAD_URL="https://github.com/tindy2013/subconverter/releases/download/v${REMOTE_VERSION}/subconverter_${OS_INFO_TYPE}${OS_INFO_VDIS}.tar.gz"

    curl -SL -o "${WORKDIR}/subconverter.tar.gz" -C- "$DOWNLOAD_URL" && \
        sudo tar -zxPf "${WORKDIR}/subconverter.tar.gz" -C "/srv" && \
        echo ${REMOTE_VERSION} | sudo tee "/srv/subconverter/.version" >/dev/null

    [[ $(systemctl is-enabled subconverter 2>/dev/null) ]] || {
        # [[ "${IS_UPDATE}" == "no" ]] && read -p "Install clash subconverter service?[y/N]:" CHOICE
        # [[ "$CHOICE" == 'y' || "$CHOICE" == 'Y' ]] && Install_systemd_Service "subconverter" "/srv/subconverter/subconverter"
        Install_systemd_Service "subconverter" "/srv/subconverter/subconverter"
    }

    if [[ "${IS_UPDATE}" == "yes" ]] then
        [[ $(systemctl is-enabled subconverter 2>/dev/null) ]] && sudo systemctl restart subconverter
    fi
fi

# nohup /srv/subconverter/subconverter >/dev/null 2>&1 & disown
# http://127.0.0.1:25500/sub?target=clash&url=https%3A%2F%2Fjiang.netlify.com%2F&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fpref.ini

cd "${CURRENT_DIR}"