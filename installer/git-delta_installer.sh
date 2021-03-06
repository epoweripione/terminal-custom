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

# git-delta
# https://github.com/dandavison/delta
APP_INSTALL_NAME="delta"
GITHUB_REPO_NAME="dandavison/delta"

ARCHIVE_EXT="tar.gz"
ARCHIVE_EXEC_DIR="delta-*"
ARCHIVE_EXEC_NAME="delta"

EXEC_INSTALL_PATH="/usr/local/bin"
EXEC_INSTALL_NAME="delta"

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
    CURRENT_VERSION=$(${EXEC_INSTALL_NAME} --version 2>&1 | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
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
    [[ -z "${OS_INFO_TYPE}" ]] && get_os_type
    [[ -z "${OS_INFO_ARCH}" ]] && get_arch

    case "${OS_INFO_TYPE}" in
        linux)
            case "${OS_INFO_ARCH}" in
                amd64)
                    REMOTE_FILENAME="${EXEC_INSTALL_NAME}-${REMOTE_VERSION}-x86_64-unknown-linux-gnu.${ARCHIVE_EXT}"
                    ;;
                arm64)
                    REMOTE_FILENAME="${EXEC_INSTALL_NAME}-${REMOTE_VERSION}-aarch64-unknown-linux-gnu.${ARCHIVE_EXT}"
                    ;;
                386)
                    REMOTE_FILENAME="${EXEC_INSTALL_NAME}-${REMOTE_VERSION}-i686-unknown-linux-gnu.${ARCHIVE_EXT}"
                    ;;
                arm)
                    REMOTE_FILENAME="${EXEC_INSTALL_NAME}-${REMOTE_VERSION}-arm-unknown-linux-gnueabihf.${ARCHIVE_EXT}"
                    ;;
            esac
            ;;
        darwin)
            REMOTE_FILENAME="${EXEC_INSTALL_NAME}-${REMOTE_VERSION}-x86_64-apple-darwin.${ARCHIVE_EXT}"
            ;;
    esac

    [[ -z "${REMOTE_FILENAME}" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}  Installing ${FUCHSIA}${APP_INSTALL_NAME} ${YELLOW}${REMOTE_VERSION}${BLUE}..."

    # Download file
    DOWNLOAD_URL="${GITHUB_DOWNLOAD_URL:-https://github.com}/${GITHUB_REPO_NAME}/releases/download/${REMOTE_VERSION}/${REMOTE_FILENAME}"
    curl "${curl_download_opts[@]}" -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}"

    curl_download_status=$?
    if [[ ${curl_download_status} -gt 0 && -n "${GITHUB_DOWNLOAD_URL}" ]]; then
        DOWNLOAD_URL=$(echo "${DOWNLOAD_URL}" | sed "s|${GITHUB_DOWNLOAD_URL}|https://github.com|")
        curl "${curl_download_opts[@]}" -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}"
        curl_download_status=$?
    fi

    if [[ ${curl_download_status} -eq 0 ]]; then
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
                cd "${WORKDIR}" && gzip -df "${DOWNLOAD_FILENAME}"
                ;;
            "bz")
                cd "${WORKDIR}" && bzip2 -df "${DOWNLOAD_FILENAME}"
                ;;
            "7z")
                7z e "${DOWNLOAD_FILENAME}" -o"${WORKDIR}"
                ;;
        esac

        # Install
        if [[ $? -eq 0 ]]; then
            if [[ -s "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" ]]; then
                sudo rm -f "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}"
            fi

            [[ -n "${ARCHIVE_EXEC_DIR}" ]] && \
                ARCHIVE_EXEC_DIR=$(find ${WORKDIR} -type d -name ${ARCHIVE_EXEC_DIR})

            [[ -z "${ARCHIVE_EXEC_DIR}" || ! -d "${ARCHIVE_EXEC_DIR}" ]] && ARCHIVE_EXEC_DIR=${WORKDIR}

            sudo mv -f ${ARCHIVE_EXEC_DIR}/${ARCHIVE_EXEC_NAME} "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" && \
                sudo chmod +x "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" && \
                [[ -n "${VERSION_FILENAME}" ]] && echo ${REMOTE_VERSION} | sudo tee "${VERSION_FILENAME}" >/dev/null || true
        fi
    fi
fi

if [[ -x "$(command -v delta)" ]]; then
    git config --global core.pager delta

    git config --global delta.features "side-by-side line-numbers decorations"
    git config --global delta.plus-style "syntax #003800"
    git config --global delta.minus-style "syntax #3f0001"
    git config --global delta.syntax-theme Dracula

    git config --global delta.decorations.commit-decoration-style "bold yellow box ul"
    git config --global delta.decorations.file-style "bold yellow ul"
    git config --global delta.decorations.file-decoration-style none
    git config --global delta.decorations.hunk-header-decoration-style "cyan box ul"

    git config --global delta.line-numbers.line-numbers-left-style cyan
    git config --global delta.line-numbers.line-numbers-right-style cyan
    git config --global delta.line-numbers.line-numbers-minus-style 124
    git config --global delta.line-numbers.line-numbers-plus-style 28

    git config --global interactive.diffFilter "delta --color-only"
fi

cd "${CURRENT_DIR}"