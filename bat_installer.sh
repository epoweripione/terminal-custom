#!/bin/bash

# if [[ $UID -ne 0 ]]; then
#     echo "Please run this script as root user!"
#     exit 0
# fi

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

if [[ -z "$spruce_type" ]]; then
    get_os_type
    get_sysArch
fi


# bat
# https://github.com/sharkdp/bat
CHECK_URL="https://api.github.com/repos/sharkdp/bat/releases/latest"
REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4)

BAT_FILENAME=""
case "$ostype" in
    linux)
        case "$VDIS" in
            32)
                BAT_FILENAME=bat-${REMOTE_VERSION}-i686-unknown-linux-gnu.tar.gz
                ;;
            64)
                BAT_FILENAME=bat-${REMOTE_VERSION}-x86_64-unknown-linux-musl.tar.gz
                ;;
            arm)
                BAT_FILENAME=bat-${REMOTE_VERSION}-arm-unknown-linux-gnueabihf.tar.gz
                ;;
            arm64)
                BAT_FILENAME=bat-${REMOTE_VERSION}-aarch64-unknown-linux-gnu.tar.gz
                ;;
        esac
        ;;
    darwin)
        BAT_FILENAME=bat-${REMOTE_VERSION}-x86_64-apple-darwin.tar.gz
        ;;
    windows)
        BAT_FILENAME=bat-${REMOTE_VERSION}-x86_64-pc-windows-msvc.zip
        ;;
esac


if [[ -x "$(command -v bat)" ]]; then
    CURRENT_VERSION=v$(bat --version | cut -d' ' -f2)
    if version_le $REMOTE_VERSION $CURRENT_VERSION; then
        BAT_FILENAME=""
    fi
fi


if [[ -n "$BAT_FILENAME" ]]; then
    colorEcho ${BLUE} "Installing bat..."
    if [[ -s "/usr/bin/bat" ]]; then
        sudo rm -f /usr/bin/bat
    fi

    if [[ -s "/usr/local/bat/bat" ]]; then
        sudo rm -rf /usr/local/bat
    fi

    DOWNLOAD_URL=https://github.com/sharkdp/bat/releases/download/${REMOTE_VERSION}/${BAT_FILENAME}
    curl -SL -o bat.tar.gz $DOWNLOAD_URL && \
        sudo tar -zxPf bat.tar.gz -C /usr/local && \
        rm -f bat.tar.gz && \
        cd /usr/local && \
        sudo mv bat-* bat && \
        sudo ln -sv /usr/local/bat/bat /usr/bin/bat || true
fi