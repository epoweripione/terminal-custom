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

# proxypool
# https://github.com/Sansui233/proxypool
APP_INSTALL_NAME="proxypool"
GITHUB_REPO_NAME="Sansui233/proxypool"

ARCHIVE_EXT="gz"
ARCHIVE_EXEC_NAME="proxypool"

EXEC_INSTALL_PATH="/usr/local/bin"
EXEC_INSTALL_NAME="proxypool"

[[ -z "${ARCHIVE_EXEC_NAME}" ]] && ARCHIVE_EXEC_NAME="${EXEC_INSTALL_NAME}"

DOWNLOAD_FILENAME="${WORKDIR}/${EXEC_INSTALL_NAME}"
[[ -n "${ARCHIVE_EXT}" ]] && DOWNLOAD_FILENAME="${DOWNLOAD_FILENAME}.${ARCHIVE_EXT}"

REMOTE_SUFFIX=""
REMOTE_FILENAME=""

IS_INSTALL="yes"
IS_UPDATE="no"

CURRENT_VERSION="0.0.0"
# VERSION_FILENAME=""
VERSION_FILENAME="${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}.version"

if [[ -x "$(command -v ${EXEC_INSTALL_NAME})" ]]; then
    IS_UPDATE="yes"
    [[ -n "${VERSION_FILENAME}" ]] && CURRENT_VERSION=v$(head -n1 ${VERSION_FILENAME})
    # CURRENT_VERSION=v$(${EXEC_INSTALL_NAME} --version 2>&1 | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
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

    REMOTE_FILENAME="${EXEC_INSTALL_NAME}-${OS_INFO_TYPE}-${OS_INFO_ARCH}-v${REMOTE_VERSION}.${ARCHIVE_EXT}"
    case "${OS_INFO_ARCH}" in
        arm64)
            REMOTE_FILENAME="${EXEC_INSTALL_NAME}-${OS_INFO_TYPE}-armv8-v${REMOTE_VERSION}.${ARCHIVE_EXT}"
            ;;
        arm)
            REMOTE_FILENAME="${EXEC_INSTALL_NAME}-${OS_INFO_TYPE}-armv7-v${REMOTE_VERSION}.${ARCHIVE_EXT}"
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
        [[ -z "${ARCHIVE_EXEC_NAME}" ]] && ARCHIVE_EXEC_NAME="${EXEC_INSTALL_NAME}"
        sudo mv -f ${WORKDIR}/${ARCHIVE_EXEC_NAME} "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" && \
            sudo chmod +x "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" && \
            [[ -n "${VERSION_FILENAME}" ]] && echo ${REMOTE_VERSION} | sudo tee "${VERSION_FILENAME}" >/dev/null
    fi
fi


# config
if [[ ! -s "/etc/proxypool/config.yaml" ]]; then
    mkdir -p "/etc/proxypool" && \
        curl -fSL -o "${WORKDIR}/source.yaml" \
            "https://raw.githubusercontent.com/Sansui233/proxypool/master/config/source.yaml" && \
        curl -fSL -o "${WORKDIR}/config.yaml" \
            "https://raw.githubusercontent.com/Sansui233/proxypool/master/config/config.yaml" && \
        sudo mv -f "${WORKDIR}/source.yaml" "/etc/proxypool/source.yaml" && \
        sudo mv -f "${WORKDIR}/config.yaml" "/etc/proxypool/config.yaml" && \
        sudo sed -i "s|./config/source.yaml|/etc/proxypool/source.yaml|" "/etc/proxypool/config.yaml"
fi

# sudo sed -i "s|domain:.*|domain: pool.example.com|" "/etc/proxypool/config.yaml"
# Install_systemd_Service "proxypool" "/usr/local/bin/proxypool -c /etc/proxypool/config.yaml"

## nginx
# proxy_pass http://127.0.0.1:12580/;


cd "${CURRENT_DIR}"