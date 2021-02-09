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

# yq
# https://github.com/mikefarah/yq
APP_INSTALL_NAME="yq"
IS_INSTALL="yes"
IS_UPDATE="no"
CURRENT_VERSION="0.0.0"

if [[ -x "$(command -v yq)" ]]; then
    IS_UPDATE="yes"
    CURRENT_VERSION=$(yq -V | grep -Eo -m1 '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
else
    [[ "${IS_UPDATE_ONLY}" == "yes" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}Checking latest version for ${FUCHSIA}${APP_INSTALL_NAME}${BLUE}..."

    CHECK_URL="https://api.github.com/repos/mikefarah/yq/releases/latest"
    REMOTE_VERSION=$(curl -fsL $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_le $REMOTE_VERSION $CURRENT_VERSION; then
        IS_INSTALL="no"
    fi
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}  Installing ${FUCHSIA}${APP_INSTALL_NAME} ${YELLOW}${REMOTE_VERSION}${BLUE}..."

    OS_TYPE=$(uname | sed 's/.*/\L&/')
    [[ -z "$OS_INFO_ARCH" ]] && get_arch

    DOWNLOAD_URL="https://github.com/mikefarah/yq/releases/download/v${REMOTE_VERSION}/yq_${OS_TYPE}_${OS_INFO_ARCH}.tar.gz"

    curl -fSL -o "${WORKDIR}/yq.tar.gz" -C- "$DOWNLOAD_URL" && \
        sudo tar -xzPf "${WORKDIR}/yq.tar.gz" -C "${WORKDIR}" && \
        sudo mv -f ${WORKDIR}/yq_* "/usr/local/bin/yq"
        sudo chmod +x "/usr/local/bin/yq"
fi

cd "${CURRENT_DIR}"