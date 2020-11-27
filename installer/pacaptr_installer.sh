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

# pacaptr - Pacman-like syntax wrapper for many package managers
# https://github.com/rami3l/pacaptr
colorEcho ${BLUE} "Checking latest version for pacaptr..."

case $(uname) in
    Darwin)
        OS_TYPE='macos'
        ;;
    Linux)
        OS_TYPE='linux'
        ;;
    *)
        OS_TYPE=''
        ;;
esac

OS_ARCH=$(uname -m)
if [[ -n "$OS_TYPE" && ("$OS_ARCH" == "amd64" || "$OS_ARCH" == "x86_64") ]]; then
    CHECK_URL="https://api.github.com/repos/rami3l/pacaptr/releases/latest"
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

    if [[ -x "$(command -v pacaptr)" ]]; then
        ECHO_TYPE="Updating"
        CURRENT_VERSION=$(pacaptr -V | cut -d" " -f2)
        [[ -s "/root/.config/pacaptr/pacaptr.toml" ]] && \
            sudo sed -i "s/needed.*/needed = true/" "/root/.config/pacaptr/pacaptr.toml"
    else
        CURRENT_VERSION="0.0.0"
        ECHO_TYPE="Installing"
        # pacaptr config   
        sudo mkdir -p "/root/.config/pacaptr/"
        echo -e "dry_run = false\nneeded = true\nno_confirm = false\nforce_cask = false\nno_cache = false" \
            | sudo tee "/root/.config/pacaptr/pacaptr.toml" >/dev/null
    fi

    [[ "$(readlink -f /usr/bin/pacman)" == "/usr/bin/pacapt" ]] && \
        sudo rm -f "/usr/bin/pacman" && sudo rm -f "/usr/bin/pacapt"

    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        colorEcho ${BLUE} "  ${ECHO_TYPE} pacaptr ${REMOTE_VERSION}..."
        DOWNLOAD_URL="https://github.com/rami3l/pacaptr/releases/download/v${REMOTE_VERSION}/pacaptr-${OS_TYPE}-amd64.tar.gz"
        curl -SL -o "${WORKDIR}/pacaptr.tar.gz" -C- "$DOWNLOAD_URL" && \
            sudo tar -zxPf "${WORKDIR}/pacaptr.tar.gz" -C "/usr/local/bin" && \
            sudo ln -sv "/usr/local/bin/pacaptr" "/usr/bin/pacman" || true
    fi
fi