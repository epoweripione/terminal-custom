#!/bin/bash

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


# exa
# https://github.com/ogham/exa
colorEcho ${BLUE} "Checking update for exa..."

CHECK_URL="https://api.github.com/repos/ogham/exa/releases/latest"
REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

REMOTE_FILENAME=""
case "$ostype" in
    linux)
        case "$VDIS" in
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
    colorEcho ${BLUE} "Installing exa..."
    if [[ -s "/usr/local/bin/duf" ]]; then
        sudo rm -f "/usr/local/bin/exa"
    fi

    DOWNLOAD_URL="https://github.com/ogham/exa/releases/download/v${REMOTE_VERSION}/${REMOTE_FILENAME}"
    curl -SL -o "/tmp/exa.zip" -C- "$DOWNLOAD_URL" && \
        unzip -qo "/tmp/exa.zip" -d "/tmp" && \
        sudo mv -f /tmp/exa-* "/usr/local/bin/exa" && \
        rm -f "/tmp/exa.zip"
fi