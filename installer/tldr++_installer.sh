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

# tldr++: fast and interactive tldr client written with go
# https://github.com/isacikgoz/tldr
APP_INSTALL_NAME="tldr++"
GITHUB_REPO_NAME="isacikgoz/tldr"

ARCHIVE_EXT="tar.gz"
ARCHIVE_EXEC_NAME="tldr"

EXEC_INSTALL_PATH="/usr/local/bin"
EXEC_INSTALL_NAME="tldr"

[[ -z "${ARCHIVE_EXEC_NAME}" ]] && ARCHIVE_EXEC_NAME="${EXEC_INSTALL_NAME}"

DOWNLOAD_FILENAME="${WORKDIR}/${EXEC_INSTALL_NAME}"
[[ -n "${ARCHIVE_EXT}" ]] && DOWNLOAD_FILENAME="${DOWNLOAD_FILENAME}.${ARCHIVE_EXT}"

REMOTE_SUFFIX=""
REMOTE_FILENAME=""

IS_INSTALL="yes"
IS_UPDATE="no"

CURRENT_VERSION="0.0.0"
VERSION_FILENAME=""
# VERSION_FILENAME="${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}.version"

if [[ -x "$(command -v ${EXEC_INSTALL_NAME})" ]]; then
    IS_UPDATE="yes"
    [[ -n "${VERSION_FILENAME}" ]] && CURRENT_VERSION=$(head -n1 ${VERSION_FILENAME})
    # CURRENT_VERSION=$(${EXEC_INSTALL_NAME} --version 2>&1 | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
    CURRENT_VERSION=$(${EXEC_INSTALL_NAME} --version 2>&1 | cut -d' ' -f3)
else
    [[ "${IS_UPDATE_ONLY}" == "yes" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}Checking latest version for ${FUCHSIA}${APP_INSTALL_NAME}${BLUE}..."

    CHECK_URL="https://api.github.com/repos/${GITHUB_REPO_NAME}/releases/latest"
    REMOTE_VERSION=$(curl -fsL $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_le $REMOTE_VERSION $CURRENT_VERSION; then
        IS_INSTALL="no"
    fi
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    [[ -z "${OS_INFO_TYPE}" ]] && get_os_type
    [[ -z "${OS_INFO_ARCH}" ]] && get_arch

    [[ "${OS_INFO_TYPE}" == "windows" ]] && ARCHIVE_EXT="zip"
    REMOTE_FILENAME="${EXEC_INSTALL_NAME}_${REMOTE_VERSION}_${OS_INFO_TYPE}_${OS_INFO_ARCH}.${ARCHIVE_EXT}"

    [[ -z "${REMOTE_FILENAME}" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}  Installing ${FUCHSIA}${APP_INSTALL_NAME} ${YELLOW}${REMOTE_VERSION}${BLUE}..."

    if [[ -s "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" ]]; then
        sudo rm -f "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}"
    fi

    # Download file
    DOWNLOAD_URL="https://github.com/${GITHUB_REPO_NAME}/releases/download/v${REMOTE_VERSION}/${REMOTE_FILENAME}"
    curl -fSL -o "${DOWNLOAD_FILENAME}" -C- "${DOWNLOAD_URL}"

    # Extract file
    if [[ $? -eq 0 ]]; then
        case "${ARCHIVE_EXT}" in
            "zip")
                unzip -qo "${DOWNLOAD_FILENAME}" -d "${WORKDIR}"
                ;;
            "tar.bz2")
                tar -xjPf "${DOWNLOAD_FILENAME}" -C "${WORKDIR}"
                ;;
            "tar.gz")
                tar -xzPf "${DOWNLOAD_FILENAME}" -C "${WORKDIR}"
                ;;
            "tar.xz")
                tar -xJPf "${DOWNLOAD_FILENAME}" -C "${WORKDIR}"
                ;;
            "gz")
                gzip -d -f "${DOWNLOAD_FILENAME}"
                ;;
        esac
    fi

    # Install
    if [[ $? -eq 0 ]]; then
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