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


# pacapt - An Arch's pacman-like package manager for some Unices
# https://github.com/icy/pacapt
CHECK_URL="https://api.github.com/repos/icy/pacapt/releases/latest"
REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

if [[ -x "$(command -v pacapt)" ]]; then
    ECHO_TYPE="Updating"
    CURRENT_VERSION=$(pacapt -V | grep 'version' | cut -d"'" -f2)
else
    CURRENT_VERSION="0.0.0"
    ECHO_TYPE="Installing"
fi

if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
    colorEcho ${BLUE} "${ECHO_TYPE} pacapt - An Arch's pacman-like package manager for some Unices..."
    sudo curl -SL -o /tmp/pacapt https://github.com/icy/pacapt/raw/ng/pacapt && \
        sudo mv -f /tmp/pacapt /usr/bin/pacapt && \
        sudo chmod 755 /usr/bin/pacapt && \
        sudo ln -sv /usr/bin/pacapt /usr/bin/pacman || true
fi