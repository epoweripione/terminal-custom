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

# bat
# https://github.com/sharkdp/bat
APP_INSTALL_NAME="bat"
ARCHIVE_EXT="tar.gz"

colorEcho "${BLUE}Checking latest version for ${FUCHSIA}${APP_INSTALL_NAME}${BLUE}..."

CHECK_URL="https://api.github.com/repos/sharkdp/bat/releases/latest"
REMOTE_VERSION=$(curl "${curl_check_opts[@]}" "${CHECK_URL}" | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

REMOTE_FILENAME=""
case "${OS_INFO_TYPE}" in
    linux)
        case "${OS_INFO_VDIS}" in
            32)
                REMOTE_FILENAME=bat-v${REMOTE_VERSION}-i686-unknown-linux-musl.${ARCHIVE_EXT}
                ;;
            64)
                REMOTE_FILENAME=bat-v${REMOTE_VERSION}-x86_64-unknown-linux-musl.${ARCHIVE_EXT}
                ;;
            arm)
                REMOTE_FILENAME=bat-v${REMOTE_VERSION}-arm-unknown-linux-gnueabihf.${ARCHIVE_EXT}
                ;;
            arm64)
                REMOTE_FILENAME=bat-v${REMOTE_VERSION}-aarch64-unknown-linux-gnu.${ARCHIVE_EXT}
                ;;
        esac
        ;;
    darwin)
        REMOTE_FILENAME=bat-v${REMOTE_VERSION}-x86_64-apple-darwin.${ARCHIVE_EXT}
        ;;
    windows)
        ARCHIVE_EXT="zip"
        REMOTE_FILENAME=bat-v${REMOTE_VERSION}-x86_64-pc-windows-msvc.${ARCHIVE_EXT}
        ;;
esac

if [[ -x "$(command -v bat)" ]]; then
    CURRENT_VERSION=v$(bat --version | cut -d' ' -f2)
    if version_le $REMOTE_VERSION $CURRENT_VERSION; then
        REMOTE_FILENAME=""
    fi
fi

if [[ -n "$REMOTE_VERSION" && -n "$REMOTE_FILENAME" ]]; then
    colorEcho "${BLUE}  Installing ${FUCHSIA}${APP_INSTALL_NAME} ${YELLOW}${REMOTE_VERSION}${BLUE}..."

    DOWNLOAD_FILENAME="${WORKDIR}/bat.${ARCHIVE_EXT}"
    DOWNLOAD_URL="${GITHUB_DOWNLOAD_URL:-https://github.com}/sharkdp/bat/releases/download/v${REMOTE_VERSION}/${REMOTE_FILENAME}"
    curl "${curl_download_opts[@]}" -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}"

    curl_download_status=$?
    if [[ ${curl_download_status} -gt 0 && -n "${GITHUB_DOWNLOAD_URL}" ]]; then
        DOWNLOAD_URL=$(echo "${DOWNLOAD_URL}" | sed "s|${GITHUB_DOWNLOAD_URL}|https://github.com|")
        curl "${curl_download_opts[@]}" -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}"
        curl_download_status=$?
    fi

    if [[ ${curl_download_status} -eq 0 ]]; then
        [[ -s "/usr/bin/bat" ]] && sudo rm -f "/usr/bin/bat"
        [[ -d "/usr/local/bat" ]] && sudo rm -rf "/usr/local/bat"

        sudo tar -xzf "${DOWNLOAD_FILENAME}" -C "/usr/local" && \
            cd "/usr/local" && \
            sudo mv bat-v* bat && \
            sudo ln -sv "/usr/local/bat/bat" "/usr/bin/bat" || true
    fi
fi

cd "${CURRENT_DIR}"