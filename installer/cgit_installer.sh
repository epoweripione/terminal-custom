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


# cgit: github.com.cnpmjs.org
# https://github.com/killf/cgit
APP_INSTALL_NAME="cgit"
GITHUB_REPO_NAME="killf/cgit"

EXEC_INSTALL_PATH="/usr/local/bin"
EXEC_INSTALL_NAME="cgit"

REMOTE_FILENAME=""

IS_INSTALL="yes"
IS_UPDATE="no"

DOWNLOAD_FILENAME="${WORKDIR}/${EXEC_INSTALL_NAME}"

CURRENT_VERSION="0.0.0"
VERSION_FILENAME="${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}.version"

if [[ -x "$(command -v ${EXEC_INSTALL_NAME})" ]]; then
    IS_UPDATE="yes"
    [[ -s "${VERSION_FILENAME}" ]] && CURRENT_VERSION=$(head -n1 ${VERSION_FILENAME})
else
    [[ "${IS_UPDATE_ONLY}" == "yes" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}Checking latest version for ${FUCHSIA}${APP_INSTALL_NAME}${BLUE}..."

    CHECK_URL="https://api.github.com/repos/${GITHUB_REPO_NAME}/releases/latest"
    REMOTE_VERSION=$(curl -fsL ${GITHUB_CHECK_CURL_OPTION:-""} "${CHECK_URL}" | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_le $REMOTE_VERSION $CURRENT_VERSION; then
        IS_INSTALL="no"
    fi
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    [[ -z "$OS_INFO_TYPE" ]] && get_os_type
    [[ -z "${OS_INFO_ARCH}" ]] && get_arch

    case "$OS_INFO_TYPE" in
        linux)
            case "$OS_INFO_ARCH" in
                arm | arm64)
                    REMOTE_FILENAME="http://cgit.killf.info/cgit_arm_latest"
                    ;;
                *)
                    REMOTE_FILENAME="http://cgit.killf.info/cgit_linux_latest"
                    ;;
            esac
            ;;
        darwin)
            REMOTE_FILENAME="http://cgit.killf.info/cgit_mac_latest"
            ;;
        windows)
            REMOTE_FILENAME="http://cgit.killf.info/cgit.exe"
            ;;
    esac

    [[ -z "${REMOTE_FILENAME}" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    DOWNLOAD_URL="${REMOTE_FILENAME}"
    curl -fSL ${GITHUB_DOWNLOAD_CURL_OPTION:-""} -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}" && \
        sudo mv -f "${DOWNLOAD_FILENAME}" "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" && \
        sudo chmod +x "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" && \
        [[ -n "${VERSION_FILENAME}" ]] && echo ${REMOTE_VERSION} | sudo tee "${VERSION_FILENAME}" >/dev/null || true
fi


cd "${CURRENT_DIR}"