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

if [[ -n "$TMUX" ]]; then
    colorEcho "${RED}Can't build & install ${FUCHSIA}tmux${RED} in a ${YELLOW}tmux${RED} session!"
    exit 1
fi

# https://github.com/tmux/tmux
APP_INSTALL_NAME="tmux"
GITHUB_REPO_NAME="tmux/tmux"

EXEC_INSTALL_NAME="tmux"

colorEcho "${BLUE}Checking latest version for ${FUCHSIA}${APP_INSTALL_NAME}${BLUE}..."
CHECK_URL="https://api.github.com/repos/${GITHUB_REPO_NAME}/releases/latest"
REMOTE_VERSION=$(curl -fsL $CHECK_URL | grep 'tag_name' | cut -d\" -f4)

if [[ -x "$(command -v pacman)" ]]; then
    # Remove installed old version
    if checkPackageInstalled "${APP_INSTALL_NAME}"; then
        CURRENT_VERSION=$(${EXEC_INSTALL_NAME} -V | grep -Eo '([0-9]{1,}\.)+[0-9a-zA-Z]{1,}' | head -n1)
        if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
            colorEcho "${BLUE}  Removing ${FUCHSIA}${APP_INSTALL_NAME}${YELLOW}${CURRENT_VERSION}${BLUE}..."
            sudo pacman --noconfirm -R "${APP_INSTALL_NAME}"
            sudo pacman --noconfirm -Rn "${APP_INSTALL_NAME}" || true
        fi
    fi

    # Pre-requisite packages
    PackagesList=(
        build-essential
        gcc
        make
        bison
        pkg-config
        libevent
        libevent-dev
        libevent-devel
        ncurses
        libncurses-dev
        libncursesw-dev
        libncurses5-dev
        libncursesw5-dev
        ncurses-devel
    )
    for TargetPackage in "${PackagesList[@]}"; do
        if checkPackageNeedInstall "${TargetPackage}"; then
            colorEcho "${BLUE}  Installing ${FUCHSIA}${TargetPackage}${BLUE}..."
            sudo pacman --noconfirm -S "${TargetPackage}"
        fi
    done
fi

IS_INSTALL="yes"
IS_UPDATE="no"
CURRENT_VERSION="0.0"

# http://mybookworld.wikidot.com/compile-tmux-from-source
if [[ -x "$(command -v ${EXEC_INSTALL_NAME})" ]]; then
    IS_UPDATE="yes"
    CURRENT_VERSION=$(${EXEC_INSTALL_NAME} -V | grep -Eo '([0-9]{1,}\.)+[0-90-9a-zA-Z]{1,}' | head -n1)
fi

if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
    colorEcho "${BLUE}  Installing ${FUCHSIA}${APP_INSTALL_NAME}${YELLOW}${REMOTE_VERSION}${BLUE} from source..."

    REMOTE_FILENAME="${APP_INSTALL_NAME}-${REMOTE_VERSION}.tar.gz"
    DOWNLOAD_FILENAME="${WORKDIR}/${APP_INSTALL_NAME}.tar.gz"

    DOWNLOAD_URL="https://github.com/${GITHUB_REPO_NAME}/releases/download/${REMOTE_VERSION}/${REMOTE_FILENAME}"

    curl -fSL -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}" && \
        tar -xzf "${DOWNLOAD_FILENAME}" -C "${WORKDIR}" && \
        mv ${WORKDIR}/${APP_INSTALL_NAME}-* "${WORKDIR}/${APP_INSTALL_NAME}"

    if [[ -d "${WORKDIR}/${APP_INSTALL_NAME}" ]]; then
        colorEcho "${BLUE}  Compiling ${FUCHSIA}${APP_INSTALL_NAME}${BLUE}..."
        cd "${WORKDIR}/${APP_INSTALL_NAME}" && \
        ./configure --prefix=/usr >/dev/null && \
        make >/dev/null && \
        sudo make install >/dev/null
    fi
fi


cd "${CURRENT_DIR}"