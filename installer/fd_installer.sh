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

# fd: A simple, fast and user-friendly alternative to 'find'
# https://github.com/sharkdp/fd
APP_INSTALL_NAME="fd"
GITHUB_REPO_NAME="sharkdp/fd"

ARCHIVE_EXT="tar.gz"
ARCHIVE_EXEC_DIR="fd-*"
ARCHIVE_EXEC_NAME="fd"

EXEC_INSTALL_PATH="/usr/local/bin"
EXEC_INSTALL_NAME="fd"

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
    [[ -s "${VERSION_FILENAME}" ]] && CURRENT_VERSION=$(head -n1 ${VERSION_FILENAME})
    CURRENT_VERSION=$(${EXEC_INSTALL_NAME} -V 2>&1 | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
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
    [[ -z "${OS_INFO_TYPE}" ]] && get_os_type
    [[ -z "${OS_INFO_ARCH}" ]] && get_arch

    case "$OS_INFO_TYPE" in
        linux)
            case "$OS_INFO_ARCH" in
                amd64)
                    REMOTE_FILENAME="${EXEC_INSTALL_NAME}-v${REMOTE_VERSION}-x86_64-unknown-linux-musl.${ARCHIVE_EXT}"
                    ;;
                386)
                    REMOTE_FILENAME="${EXEC_INSTALL_NAME}-v${REMOTE_VERSION}-i686-unknown-linux-musl.${ARCHIVE_EXT}"
                    ;;
                arm | arm64)
                    REMOTE_FILENAME="${EXEC_INSTALL_NAME}-v${REMOTE_VERSION}-arm-unknown-linux-musleabihf.${ARCHIVE_EXT}"
                    ;;
            esac
            ;;
        darwin)
            REMOTE_FILENAME="${EXEC_INSTALL_NAME}-v${REMOTE_VERSION}-x86_64-apple-darwin.${ARCHIVE_EXT}"
            ;;
    esac

    [[ -z "${REMOTE_FILENAME}" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}  Installing ${FUCHSIA}${APP_INSTALL_NAME} ${YELLOW}${REMOTE_VERSION}${BLUE}..."

    if [[ -s "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" ]]; then
        sudo rm -f "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}"
    fi

    # Download file
    DOWNLOAD_URL="${GITHUB_DOWNLOAD_URL:-https://github.com}/${GITHUB_REPO_NAME}/releases/download/v${REMOTE_VERSION}/${REMOTE_FILENAME}"
    curl -fSL ${GITHUB_DOWNLOAD_CURL_OPTION:-""} -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}"

    if [[ $? -eq 0 ]]; then
        # Extract file
        case "${ARCHIVE_EXT}" in
            "zip")
                unzip -qo "${DOWNLOAD_FILENAME}" -d "${WORKDIR}"
                ;;
            "tar.bz2")
                tar -xjf "${DOWNLOAD_FILENAME}" -C "${WORKDIR}"
                ;;
            "tar.gz")
                tar -xzf "${DOWNLOAD_FILENAME}" -C "${WORKDIR}"
                ;;
            "tar.xz")
                tar -xJf "${DOWNLOAD_FILENAME}" -C "${WORKDIR}"
                ;;
            "gz")
                gzip -d -f "${DOWNLOAD_FILENAME}"
                ;;
        esac

        # Install
        if [[ $? -eq 0 ]]; then
            [[ -n "${ARCHIVE_EXEC_DIR}" ]] && \
                ARCHIVE_EXEC_DIR=$(find ${WORKDIR} -type d -name ${ARCHIVE_EXEC_DIR})

            [[ -z "${ARCHIVE_EXEC_DIR}" || ! -d "${ARCHIVE_EXEC_DIR}" ]] && ARCHIVE_EXEC_DIR=${WORKDIR}

            sudo mv -f ${ARCHIVE_EXEC_DIR}/${ARCHIVE_EXEC_NAME} "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" && \
                sudo chmod +x "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" && \
                sudo mv -f ${ARCHIVE_EXEC_DIR}/${ARCHIVE_EXEC_NAME}.1 "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}.1"
                sudo mv -f "${ARCHIVE_EXEC_DIR}/autocomplete/_fd" "/usr/local/share/zsh/site-functions" && \
                sudo chmod 644 "/usr/local/share/zsh/site-functions/_fd" && \
                sudo chown $(id -u):$(id -g) "/usr/local/share/zsh/site-functions/_fd" && \
                [[ -n "${VERSION_FILENAME}" ]] && echo ${REMOTE_VERSION} | sudo tee "${VERSION_FILENAME}" >/dev/null || true
        fi
    fi
fi

cd "${CURRENT_DIR}"