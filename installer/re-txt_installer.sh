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

# re-txt
# https://github.com/alash3al/re-txt
APP_INSTALL_NAME="re-txt"
GITHUB_REPO_NAME="alash3al/re-txt"

EXEC_INSTALL_PATH="/usr/local/bin"
EXEC_INSTALL_NAME="re-txt"

IS_INSTALL="yes"
IS_UPDATE="no"
CURRENT_VERSION="0.0.0"

REMOTE_FILENAME=""
VERSION_FILENAME="${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}.version"

if [[ -x "$(command -v ${EXEC_INSTALL_NAME})" ]]; then
    IS_UPDATE="yes"
    CURRENT_VERSION=$(head -n1 ${VERSION_FILENAME})
else
    [[ "${IS_UPDATE_ONLY}" == "yes" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}Checking latest version for ${FUCHSIA}${APP_INSTALL_NAME}${BLUE}..."

    CHECK_URL="https://api.github.com/repos/${GITHUB_REPO_NAME}/releases/latest"
    REMOTE_VERSION=$(curl "${curl_check_opts[@]}" "${CHECK_URL}" | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_le $REMOTE_VERSION $CURRENT_VERSION; then
        IS_INSTALL="no"
    fi
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    [[ -z "$OS_INFO_TYPE" ]] && get_os_type
    [[ -z "$OS_INFO_VDIS" ]] && get_sysArch

    case "$OS_INFO_VDIS" in
        64)
            case "$OS_INFO_TYPE" in
                linux | darwin | windows)
                    REMOTE_FILENAME="${EXEC_INSTALL_NAME}_${OS_INFO_TYPE}_amd64.zip"
                    ;;
            esac
            ;;
    esac
fi

if [[ -n "$REMOTE_FILENAME" && "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}  Installing ${FUCHSIA}${APP_INSTALL_NAME} ${YELLOW}${REMOTE_VERSION}${BLUE}..."

    if [[ -s "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" ]]; then
        sudo rm -f "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}"
    fi

    DOWNLOAD_URL="${GITHUB_DOWNLOAD_URL:-https://github.com}/${GITHUB_REPO_NAME}/releases/download/v${REMOTE_VERSION}/${REMOTE_FILENAME}"

    curl "${curl_download_opts[@]}" -o "${WORKDIR}/${EXEC_INSTALL_NAME}.zip" "$DOWNLOAD_URL" && \
        unzip -qo "${WORKDIR}/${EXEC_INSTALL_NAME}.zip" -d "${WORKDIR}" && \
        sudo mv -f ${WORKDIR}/${EXEC_INSTALL_NAME}_* "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" && \
        echo ${REMOTE_VERSION} | sudo tee "${VERSION_FILENAME}" >/dev/null || true

fi

cd "${CURRENT_DIR}"