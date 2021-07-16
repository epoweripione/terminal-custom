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

# pistol: General purpose file previewer designed for Ranger, Lf to make scope.sh redundant
# https://github.com/doronbehar/pistol
APP_INSTALL_NAME="pistol"
GITHUB_REPO_NAME="doronbehar/pistol"

EXEC_INSTALL_NAME="pistol"

colorEcho "${BLUE}Checking latest version for ${FUCHSIA}${APP_INSTALL_NAME}${BLUE}..."
CHECK_URL="https://api.github.com/repos/${GITHUB_REPO_NAME}/releases/latest"
REMOTE_VERSION=$(curl "${curl_check_opts[@]}" "${CHECK_URL}" | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

if [[ -x "$(command -v pacman)" ]]; then
    # Pre-requisite packages
    PackagesList=(
        libmagic
        libmagic-dev
        file-devel
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
CURRENT_VERSION="0.0.0"

# http://mybookworld.wikidot.com/compile-tmux-from-source
if [[ -x "$(command -v ${EXEC_INSTALL_NAME})" ]]; then
    IS_UPDATE="yes"
    VERSION_FILENAME="$(which ${EXEC_INSTALL_NAME}).version"
    [[ -s "${VERSION_FILENAME}" ]] && CURRENT_VERSION=$(head -n1 ${VERSION_FILENAME})
fi

if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
    colorEcho "${BLUE}  Installing ${FUCHSIA}${APP_INSTALL_NAME}${YELLOW}${REMOTE_VERSION}${BLUE}..."

    go install "github.com/doronbehar/pistol/cmd/pistol@latest"

    if [[ -x "$(command -v ${EXEC_INSTALL_NAME})" ]]; then
        VERSION_FILENAME="$(which ${EXEC_INSTALL_NAME}).version"
        echo ${REMOTE_VERSION} | sudo tee "${VERSION_FILENAME}" >/dev/null || true
    fi
fi


cd "${CURRENT_DIR}"