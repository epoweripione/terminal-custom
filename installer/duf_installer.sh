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

[[ -z "${OS_INFO_TYPE}" ]] && get_os_type
[[ -z "${OS_INFO_VDIS}" ]] && get_sysArch

# duf
# https://github.com/muesli/duf
APP_INSTALL_NAME="duf"

colorEcho "${BLUE}Checking latest version for ${FUCHSIA}${APP_INSTALL_NAME}${BLUE}..."

CHECK_URL="https://api.github.com/repos/muesli/duf/releases/latest"
REMOTE_VERSION=$(curl "${curl_check_opts[@]}" "${CHECK_URL}" | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

REMOTE_FILENAME=""
case "${OS_INFO_TYPE}" in
    linux | bsd)
        case "${OS_INFO_VDIS}" in
            32)
                REMOTE_FILENAME=duf_${REMOTE_VERSION}_$(uname | sed 's/.*/\L&/')_i386.tar.gz
                ;;
            64)
                REMOTE_FILENAME=duf_${REMOTE_VERSION}_$(uname | sed 's/.*/\L&/')_x86_64.tar.gz
                ;;
            arm)
                REMOTE_FILENAME=duf_${REMOTE_VERSION}_$(uname | sed 's/.*/\L&/')_armv7.tar.gz
                ;;
            *)
                REMOTE_FILENAME=duf_${REMOTE_VERSION}_$(uname | sed 's/.*/\L&/')_${OS_INFO_VDIS}.tar.gz
                ;;
        esac
        ;;
    darwin)
        REMOTE_FILENAME=duf_${REMOTE_VERSION}_Darwin_x86_64.tar.gz
        ;;
    windows)
        case "${OS_INFO_VDIS}" in
            32)
                REMOTE_FILENAME=duf_${REMOTE_VERSION}_Windows_i386.zip
                ;;
            64)
                REMOTE_FILENAME=duf_${REMOTE_VERSION}_Windows_x86_64.zip
                ;;
        esac
        ;;
esac

if [[ -x "$(command -v duf)" ]]; then
    CURRENT_VERSION=$(duf -version | cut -d' ' -f2)
    if version_le $REMOTE_VERSION $CURRENT_VERSION; then
        REMOTE_FILENAME=""
    fi
fi

if [[ -n "$REMOTE_VERSION" && -n "$REMOTE_FILENAME" ]]; then
    colorEcho "${BLUE} Installing ${FUCHSIA}${APP_INSTALL_NAME} ${YELLOW}${REMOTE_VERSION}${BLUE}..."
    if [[ -s "/usr/local/bin/duf" ]]; then
        sudo rm -f "/usr/local/bin/duf"
    fi

    if [[ -d "/usr/local/duf" ]]; then
        sudo rm -rf "/usr/local/duf"
    fi

    DOWNLOAD_FILENAME="${WORKDIR}/duf.tar.gz"
    DOWNLOAD_URL="${GITHUB_DOWNLOAD_URL:-https://github.com}/muesli/duf/releases/download/v${REMOTE_VERSION}/${REMOTE_FILENAME}"
    curl "${curl_download_opts[@]}" -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}"

    curl_download_status=$?
    if [[ ${curl_download_status} -gt 0 && -n "${GITHUB_DOWNLOAD_URL}" ]]; then
        DOWNLOAD_URL=$(echo "${DOWNLOAD_URL}" | sed "s|${GITHUB_DOWNLOAD_URL}|https://github.com|")
        curl "${curl_download_opts[@]}" -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}"
        curl_download_status=$?
    fi

    if [[ ${curl_download_status} -eq 0 ]]; then
        sudo mkdir -p "/usr/local/duf" && \
            sudo tar -xzf "${DOWNLOAD_FILENAME}" -C "/usr/local/duf" && \
            sudo cp -f "/usr/local/duf/duf" "/usr/local/bin/duf"
    fi
fi