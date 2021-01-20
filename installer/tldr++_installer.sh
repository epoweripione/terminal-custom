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

# tldr++: fast and interactive tldr client written with go
# https://github.com/isacikgoz/tldr
INSTALL_NAME="tldr"
GITHUB_REPO_NAME="isacikgoz/tldr"

ARCHIVE_EXEC_NAME="tldr"

EXEC_INSTALL_PATH="/usr/local/bin"
EXEC_INSTALL_NAME="tldr"

IS_INSTALL="yes"
IS_UPDATE="no"
CURRENT_VERSION="0.0.0"

REMOTE_FILEEXT="tar.gz"
REMOTE_FILENAME=""
VERSION_FILENAME=""
# VERSION_FILENAME="${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}.version"

if [[ -x "$(command -v ${EXEC_INSTALL_NAME})" ]]; then
    IS_UPDATE="yes"
    [[ -n "${VERSION_FILENAME}" ]] && CURRENT_VERSION=v$(head -n1 ${VERSION_FILENAME})
    CURRENT_VERSION=v$(${EXEC_INSTALL_NAME} --version 2>&1 | cut -d' ' -f3)
else
    [[ "${IS_UPDATE_ONLY}" == "yes" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho ${BLUE} "Checking latest version for ${INSTALL_NAME}..."

    CHECK_URL="https://api.github.com/repos/${GITHUB_REPO_NAME}/releases/latest"
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_le $REMOTE_VERSION $CURRENT_VERSION; then
        IS_INSTALL="no"
    fi
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    [[ -z "$OS_INFO_TYPE" ]] && get_os_type
    [[ -z "$OS_INFO_ARCH" ]] && get_arch

    [[ "$OS_INFO_TYPE" == "windows" ]] && REMOTE_FILEEXT="zip"
    REMOTE_FILENAME="${EXEC_INSTALL_NAME}_${REMOTE_VERSION}_${OS_INFO_TYPE}_${OS_INFO_ARCH}.${REMOTE_FILEEXT}"

    [[ -z "${REMOTE_FILENAME}" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho ${BLUE} "  Installing ${INSTALL_NAME} ${REMOTE_VERSION}..."

    if [[ -s "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" ]]; then
        sudo rm -f "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}"
    fi

    DOWNLOAD_URL="https://github.com/${GITHUB_REPO_NAME}/releases/download/v${REMOTE_VERSION}/${REMOTE_FILENAME}"
    if [[ "${REMOTE_FILEEXT}" == "zip" ]]; then
        curl -fSL -o "${WORKDIR}/${EXEC_INSTALL_NAME}.${REMOTE_FILEEXT}" -C- "$DOWNLOAD_URL" && \
            unzip -qo "${WORKDIR}/${EXEC_INSTALL_NAME}.${REMOTE_FILEEXT}" -d "${WORKDIR}" && \
            sudo mv -f ${WORKDIR}/${ARCHIVE_EXEC_NAME} "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" && \
            sudo chmod +x "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" && \
            [[ -n "${VERSION_FILENAME}" ]] && echo ${REMOTE_VERSION} | sudo tee "${VERSION_FILENAME}" >/dev/null
    else
        curl -fSL -o "${WORKDIR}/${EXEC_INSTALL_NAME}.${REMOTE_FILEEXT}" -C- "$DOWNLOAD_URL" && \
            tar -xzPf "${WORKDIR}/${EXEC_INSTALL_NAME}.${REMOTE_FILEEXT}" -C "${WORKDIR}" && \
            sudo mv -f ${WORKDIR}/${ARCHIVE_EXEC_NAME} "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" && \
            sudo chmod +x "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" && \
            [[ -n "${VERSION_FILENAME}" ]] && echo ${REMOTE_VERSION} | sudo tee "${VERSION_FILENAME}" >/dev/null
    fi
fi


# Pulls the github.com/tldr-pages/tldr repository
if [[ "${IS_INSTALL}" == "yes" || "${IS_UPDATE}" == "yes" ]]; then
    [[ -z "$OS_INFO_TYPE" ]] && get_os_type
    case "$OS_INFO_TYPE" in
        darwin)
            TLDR_PAGES="$HOME/Library/Application Support/tldr"
            ;;
        windows)
            # TLDR_PAGES="$HOME/AppData/Roaming/tldr"
            TLDR_PAGES=""
            ;;
        *)
            TLDR_PAGES="$HOME/.local/share/tldr"
            ;;
    esac
    [[ -n "${TLDR_PAGES}" ]] && Git_Clone_Update "tldr-pages/tldr" "${TLDR_PAGES}"
fi


cd "${CURRENT_DIR}"