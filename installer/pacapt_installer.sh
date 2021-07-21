#!/usr/local/bin/env bash

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

# pacapt - An Arch's pacman-like package manager for some Unices
# https://github.com/icy/pacapt
colorEcho "${BLUE}Checking latest version for ${FUCHSIA}pacapt${BLUE}..."

CHECK_URL="https://api.github.com/repos/icy/pacapt/releases/latest"
REMOTE_VERSION=$(curl "${curl_check_opts[@]}" "${CHECK_URL}" | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

if [[ -x "$(command -v pacapt)" ]]; then
    ECHO_TYPE="Updating"
    CURRENT_VERSION=$(pacapt -V | grep 'version' | cut -d"'" -f2)
else
    CURRENT_VERSION="0.0.0"
    ECHO_TYPE="Installing"
fi

# termux: PREFIX="/data/data/com.termux/files/usr"
if [[ -z "${PREFIX}" ]]; then
    PREFIX="/usr/local"
    INSTALL_PACMAN_TO="/usr/bin"
else
    INSTALL_PACMAN_TO="${PREFIX}/bin"
fi

[[ "$(readlink -f /usr/bin/pacman)" == "/usr/bin/pacapt" ]] && \
    sudo rm -f "/usr/bin/pacman" && sudo rm -f "/usr/bin/pacapt"

if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
    colorEcho "${BLUE}  ${ECHO_TYPE} ${FUCHSIA}pacapt ${YELLOW}${REMOTE_VERSION}${BLUE}..."

    DOWNLOAD_FILENAME="${WORKDIR}/pacapt"
    DOWNLOAD_URL="${GITHUB_DOWNLOAD_URL:-https://github.com}/icy/pacapt/raw/ng/pacapt"
    sudo curl "${curl_download_opts[@]}" -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}"

    curl_download_status=$?
    if [[ ${curl_download_status} -gt 0 && -n "${GITHUB_DOWNLOAD_URL}" ]]; then
        DOWNLOAD_URL=$(echo "${DOWNLOAD_URL}" | sed "s|${GITHUB_DOWNLOAD_URL}|https://github.com|")
        curl "${curl_download_opts[@]}" -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}"
        curl_download_status=$?
    fi

    if [[ ${curl_download_status} -eq 0 ]]; then
        sudo mv -f "${DOWNLOAD_FILENAME}" "${PREFIX}/bin/pacapt" && \
            sudo chmod 755 "${PREFIX}/bin/pacapt" && \
            sudo ln -sv "${PREFIX}/bin/pacapt" "${INSTALL_PACMAN_TO}/pacman" || true
    fi
fi