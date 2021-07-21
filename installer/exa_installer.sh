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

## fix: /lib64/libc.so.6: version `GLIBC_2.18' not found (required by exa)
## ldd $(which exa)
## https://github.com/japaric/rust-cross#how-do-i-compile-a-fully-statically-linked-rust-binaries
# FILE_LIBC=$(find /usr /lib -name "libc.so.6" | head -n1)
# if [[ -n "${FILE_LIBC}" ]]; then
#     if strings "${FILE_LIBC}" | grep GLIBC_2.18 >/dev/null; then
#         :
#     else
#         colorEcho "${BLUE}  Installing ${FUCHSIA}GLIBC 2.18 ${BLUE}(required by exa)..."
#         curl "${curl_download_opts[@]}" -o "${WORKDIR}/glibc.tar.gz" "http://ftp.gnu.org/gnu/glibc/glibc-2.18.tar.gz" && \
#             tar -xzf "${WORKDIR}/glibc.tar.gz" -C "${WORKDIR}" && \
#                 mv ${WORKDIR}/glibc-* "${WORKDIR}/glibc" && \
#                 mkdir "${WORKDIR}/glibc/build" && \
#                 cd "${WORKDIR}/glibc/build" && \
#                 ../configure --prefix=/usr >/dev/null && \
#                 make -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) >/dev/null && \
#                 sudo make install >/dev/null
#     fi
# fi

# exa
# https://github.com/ogham/exa
APP_INSTALL_NAME="exa"

colorEcho "${BLUE}Checking latest version for ${FUCHSIA}${APP_INSTALL_NAME}${BLUE}..."

CHECK_URL="https://api.github.com/repos/ogham/exa/releases/latest"
REMOTE_VERSION=$(curl "${curl_check_opts[@]}" "${CHECK_URL}" | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

REMOTE_FILENAME=""
case "${OS_INFO_TYPE}" in
    linux)
        case "${OS_INFO_VDIS}" in
            64)
                REMOTE_FILENAME=exa-linux-x86_64-musl-v${REMOTE_VERSION}.zip
                ;;
            arm)
                REMOTE_FILENAME=exa-linux-armv7-v${REMOTE_VERSION}.zip
                ;;
        esac
        ;;
    darwin)
        REMOTE_FILENAME=exa-macos-x86_64-v${REMOTE_VERSION}.zip
        ;;
esac


if [[ -x "$(command -v exa)" ]]; then
    CURRENT_VERSION=$(exa -v | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
    if version_le $REMOTE_VERSION $CURRENT_VERSION; then
        REMOTE_FILENAME=""
    fi
fi


if [[ -n "$REMOTE_VERSION" && -n "$REMOTE_FILENAME" ]]; then
    colorEcho "${BLUE}  Installing ${FUCHSIA}${APP_INSTALL_NAME} ${YELLOW}${REMOTE_VERSION}${BLUE}..."
    if [[ -s "/usr/local/bin/exa" ]]; then
        sudo rm -f "/usr/local/bin/exa"
    fi

    DOWNLOAD_FILENAME="${WORKDIR}/exa.zip"
    DOWNLOAD_URL="${GITHUB_DOWNLOAD_URL:-https://github.com}/ogham/exa/releases/download/v${REMOTE_VERSION}/${REMOTE_FILENAME}"
    curl "${curl_download_opts[@]}" -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}"

    curl_download_status=$?
    if [[ ${curl_download_status} -gt 0 && -n "${GITHUB_DOWNLOAD_URL}" ]]; then
        DOWNLOAD_URL=$(echo "${DOWNLOAD_URL}" | sed "s|${GITHUB_DOWNLOAD_URL}|https://github.com|")
        curl "${curl_download_opts[@]}" -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}"
        curl_download_status=$?
    fi

    if [[ ${curl_download_status} -eq 0 ]]; then
        unzip -qo "${DOWNLOAD_FILENAME}" -d "${WORKDIR}" && \
            sudo mv -f "${WORKDIR}/bin/exa" "/usr/local/bin/exa" && \
            sudo mv -f ${WORKDIR}/man/exa* "/usr/share/man/man1" && \
            sudo mv -f "${WORKDIR}/completions/exa.zsh" "/usr/local/share/zsh/site-functions" && \
            sudo chmod 644 "/usr/local/share/zsh/site-functions/exa.zsh" && \
            sudo chown $(id -u):$(id -g) "/usr/local/share/zsh/site-functions/exa.zsh"
    fi
fi

cd "${CURRENT_DIR}"