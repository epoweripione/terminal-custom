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

[[ -z "$OS_INFO_TYPE" ]] && get_os_type
[[ -z "$OS_INFO_VDIS" ]] && get_sysArch

# fix: /lib64/libc.so.6: version `GLIBC_2.18' not found (required by exa)
FILE_LIBC=$(find /usr/lib /lib -name "libc.so.6" | head -n1)
if [[ -n "${FILE_LIBC}" ]]; then
    if strings "${FILE_LIBC}" | grep GLIBC_2.18 >/dev/null; then
        :
    else
        colorEcho ${BLUE} "  Installing `GLIBC 2.18` (required by exa)..."
        curl -fSL -o "${WORKDIR}/glibc.tar.gz" "http://ftp.gnu.org/gnu/glibc/glibc-2.18.tar.gz" && \
            tar -xzPf "${WORKDIR}/glibc.tar.gz" -C "${WORKDIR}" && \
                mv ${WORKDIR}/glibc-* "${WORKDIR}/glibc" && \
                mkdir "${WORKDIR}/glibc/build" && \
                cd "${WORKDIR}/glibc/build" && \
                ../configure --prefix=/usr >/dev/null && \
                make -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) >/dev/null && \
                sudo make install >/dev/null
    fi
fi

# exa
# https://github.com/ogham/exa
INSTALL_NAME="exa"

colorEcho ${BLUE} "Checking latest version for ${INSTALL_NAME}..."

CHECK_URL="https://api.github.com/repos/ogham/exa/releases/latest"
REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

REMOTE_FILENAME=""
case "$OS_INFO_TYPE" in
    linux)
        case "$OS_INFO_VDIS" in
            64)
                REMOTE_FILENAME=exa-linux-x86_64-${REMOTE_VERSION}.zip
                ;;
        esac
        ;;
    darwin)
        REMOTE_FILENAME=exa-macos-x86_64-${REMOTE_VERSION}.zip
        ;;
esac


if [[ -x "$(command -v exa)" ]]; then
    CURRENT_VERSION=v$(exa -v | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
    if version_le $REMOTE_VERSION $CURRENT_VERSION; then
        REMOTE_FILENAME=""
    fi
fi


if [[ -n "$REMOTE_VERSION" && -n "$REMOTE_FILENAME" ]]; then
    colorEcho ${BLUE} "  Installing ${INSTALL_NAME} ${REMOTE_VERSION}..."
    if [[ -s "/usr/local/bin/exa" ]]; then
        sudo rm -f "/usr/local/bin/exa"
    fi

    DOWNLOAD_URL="https://github.com/ogham/exa/releases/download/v${REMOTE_VERSION}/${REMOTE_FILENAME}"
    curl -fSL -o "${WORKDIR}/exa.zip" -C- "$DOWNLOAD_URL" && \
        unzip -qo "${WORKDIR}/exa.zip" -d "${WORKDIR}" && \
        sudo mv -f ${WORKDIR}/exa-* "/usr/local/bin/exa"
fi

cd "${CURRENT_DIR}"