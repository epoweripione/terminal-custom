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
[[ -z "$OS_INFO_VDIS" ]] && get_sysArch


# exa
# https://github.com/ogham/exa
INSTALL_NAME="exa"

colorEcho ${BLUE} "Checking latest version for ${INSTALL_NAME}..."

CHECK_URL="https://api.github.com/repos/ogham/exa/releases/latest"
REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

REMOTE_FILENAME=""
case "$OS_INFO_TYPE" in
    linux)
        case "$OS_INFO_VDIS" in
            64)
                REMOTE_FILENAME=exa-linux-x86_64-${REMOTE_VERSION}.zip
                ;;
        esac
        ;;
    darwin)
        REMOTE_FILENAME=exa-macos-x86_64-${REMOTE_VERSION}.zip
        ;;
esac


if [[ -x "$(command -v exa)" ]]; then
    CURRENT_VERSION=v$(exa -v | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
    if version_le $REMOTE_VERSION $CURRENT_VERSION; then
        REMOTE_FILENAME=""
    fi
fi


if [[ -n "$REMOTE_VERSION" && -n "$REMOTE_FILENAME" ]]; then
    colorEcho ${BLUE} "  Installing ${INSTALL_NAME} ${REMOTE_VERSION}..."
    if [[ -s "/usr/local/bin/duf" ]]; then
        sudo rm -f "/usr/local/bin/exa"
    fi

    DOWNLOAD_URL="https://github.com/ogham/exa/releases/download/v${REMOTE_VERSION}/${REMOTE_FILENAME}"
    curl -SL -o "${WORKDIR}/exa.zip" -C- "$DOWNLOAD_URL" && \
        unzip -qo "${WORKDIR}/exa.zip" -d "${WORKDIR}" && \
        sudo mv -f ${WORKDIR}/exa-* "/usr/local/bin/exa"
fi