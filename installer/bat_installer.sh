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

[[ -z "$OS_INFO_TYPE" ]] && get_os_type
[[ -z "$OS_INFO_VDIS" ]] && get_sysArch


# bat
# https://github.com/sharkdp/bat
APP_INSTALL_NAME="bat"

colorEcho "${BLUE}Checking latest version for ${FUCHSIA}${APP_INSTALL_NAME}${BLUE}..."

CHECK_URL="https://api.github.com/repos/sharkdp/bat/releases/latest"
REMOTE_VERSION=$(curl -fsL ${GITHUB_CHECK_CURL_OPTION:-""} "${CHECK_URL}" | grep 'tag_name' | cut -d\" -f4)

REMOTE_FILENAME=""
case "$OS_INFO_TYPE" in
    linux)
        case "$OS_INFO_VDIS" in
            32)
                REMOTE_FILENAME=bat-${REMOTE_VERSION}-i686-unknown-linux-gnu.tar.gz
                ;;
            64)
                REMOTE_FILENAME=bat-${REMOTE_VERSION}-x86_64-unknown-linux-musl.tar.gz
                ;;
            arm)
                REMOTE_FILENAME=bat-${REMOTE_VERSION}-arm-unknown-linux-gnueabihf.tar.gz
                ;;
            arm64)
                REMOTE_FILENAME=bat-${REMOTE_VERSION}-aarch64-unknown-linux-gnu.tar.gz
                ;;
        esac
        ;;
    darwin)
        REMOTE_FILENAME=bat-${REMOTE_VERSION}-x86_64-apple-darwin.tar.gz
        ;;
    windows)
        REMOTE_FILENAME=bat-${REMOTE_VERSION}-x86_64-pc-windows-msvc.zip
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
    if [[ -s "/usr/bin/bat" ]]; then
        sudo rm -f "/usr/bin/bat"
    fi

    if [[ -d "/usr/local/bat" ]]; then
        sudo rm -rf "/usr/local/bat"
    fi

    DOWNLOAD_URL="${GITHUB_DOWNLOAD_URL:-https://github.com}/sharkdp/bat/releases/download/${REMOTE_VERSION}/${REMOTE_FILENAME}"
    curl -fSL ${GITHUB_DOWNLOAD_CURL_OPTION:-""} -o "${WORKDIR}/bat.tar.gz" "${DOWNLOAD_URL}" && \
        sudo tar -xzf "${WORKDIR}/bat.tar.gz" -C "/usr/local" && \
        cd "/usr/local" && \
        sudo mv bat-* bat && \
        sudo ln -sv "/usr/local/bat/bat" "/usr/bin/bat" || true
fi

cd "${CURRENT_DIR}"