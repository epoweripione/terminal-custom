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


# duf
# https://github.com/muesli/duf
CHECK_URL="https://api.github.com/repos/muesli/duf/releases/latest"
REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

[[ -z "$REMOTE_VERSION" ]] && exit 0

REMOTE_FILENAME=""
case "$ostype" in
    linux)
        case "$VDIS" in
            32)
                REMOTE_FILENAME=duf_${REMOTE_VERSION}_${ostype}_i386.tar.gz
                ;;
            64)
                REMOTE_FILENAME=duf_${REMOTE_VERSION}_${ostype}_x86_64.tar.gz
                ;;
            arm)
                REMOTE_FILENAME=duf_${REMOTE_VERSION}_${ostype}_armv7.tar.gz
                ;;
            arm64)
                REMOTE_FILENAME=duf_${REMOTE_VERSION}_${ostype}_arm64.tar.gz
                ;;
        esac
        ;;
    darwin)
        REMOTE_FILENAME=duf_${REMOTE_VERSION}_Darwin_x86_64.tar.gz
        ;;
    windows)
        case "$VDIS" in
            32)
                REMOTE_FILENAME=duf_${REMOTE_VERSION}_Windows_i386.zip
                ;;
            64)
                REMOTE_FILENAME=duf_${REMOTE_VERSION}_Windows_x86_64.zip
                ;;
        esac
        ;;
esac


PM_INSTALL=""
if [[ -x "$(command -v pacman)" ]]; then
    if pacman -Si duf >/dev/null 2>&1; then
        PM_INSTALL="pacman"
    fi
fi


if [[ -x "$(command -v duf)" ]]; then
    if [[ -n "${PM_INSTALL}" ]]; then
        # update by package manager
        REMOTE_FILENAME=""
    else
        CURRENT_VERSION=v$(duf -version | cut -d' ' -f2)
        if version_le $REMOTE_VERSION $CURRENT_VERSION; then
            REMOTE_FILENAME=""
        fi
    fi
else
    if [[ -n "${PM_INSTALL}" ]]; then
        sudo pacman --noconfirm -S duf
        REMOTE_FILENAME=""
    fi
fi


if [[ -n "$REMOTE_FILENAME" ]]; then
    colorEcho ${BLUE} "Installing duf..."
    if [[ -s "/usr/local/bin/duf" ]]; then
        sudo rm -f "/usr/local/bin/duf"
    fi

    if [[ -d "/usr/local/duf" ]]; then
        sudo rm -rf "/usr/local/duf"
    fi

    DOWNLOAD_URL="https://github.com/muesli/duf/releases/download/v${REMOTE_VERSION}/${REMOTE_FILENAME}"
    curl -SL -o "/tmp/duf.tar.gz" -C- "$DOWNLOAD_URL" && \
        sudo mkdir -p "/usr/local/duf" && \
        sudo tar -zxPf "/tmp/duf.tar.gz" -C "/usr/local/duf" && \
        rm -f "/tmp/duf.tar.gz" && \
        sudo cp -f "/usr/local/duf/duf" "/usr/local/bin/duf"
fi