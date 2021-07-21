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

# trojan
# https://github.com/trojan-gfw/trojan
APP_INSTALL_NAME="trojan"
IS_INSTALL="yes"
IS_UPDATE="no"
CURRENT_VERSION="0.0.0"
CHOICE="N"

if [[ -s "/srv/trojan/trojan" ]]; then
    IS_UPDATE="yes"
    CURRENT_VERSION=$(/srv/trojan/trojan --version 2>&1 | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
else
    [[ "${IS_UPDATE_ONLY}" == "yes" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}Checking latest version for ${FUCHSIA}${APP_INSTALL_NAME}${BLUE}..."

    CHECK_URL="https://api.github.com/repos/trojan-gfw/trojan/releases/latest"
    REMOTE_VERSION=$(curl "${curl_check_opts[@]}" "${CHECK_URL}" | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_le $REMOTE_VERSION $CURRENT_VERSION; then
        IS_INSTALL="no"
    fi
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}  Installing ${FUCHSIA}${APP_INSTALL_NAME} ${YELLOW}${REMOTE_VERSION}${BLUE}..."

    [[ -z "${OS_INFO_TYPE}" ]] && get_os_type
    [[ -z "${OS_INFO_ARCH}" ]] && get_arch

    [[ $(systemctl is-enabled trojan 2>/dev/null) ]] && sudo systemctl stop trojan

    DOWNLOAD_FILENAME="${WORKDIR}/trojan.tar.xz"
    DOWNLOAD_URL="${GITHUB_DOWNLOAD_URL:-https://github.com}/trojan-gfw/trojan/releases/download/v${REMOTE_VERSION}/trojan-${REMOTE_VERSION}-${OS_INFO_TYPE}-${OS_INFO_ARCH}.tar.xz"
    curl "${curl_download_opts[@]}" -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}"

    curl_download_status=$?
    if [[ ${curl_download_status} -gt 0 && -n "${GITHUB_DOWNLOAD_URL}" ]]; then
        DOWNLOAD_URL=$(echo "${DOWNLOAD_URL}" | sed "s|${GITHUB_DOWNLOAD_URL}|https://github.com|")
        curl "${curl_download_opts[@]}" -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}"
        curl_download_status=$?
    fi

    if [[ ${curl_download_status} -eq 0 ]]; then
        sudo tar -xJf "${DOWNLOAD_FILENAME}" -C "/srv/"
    fi

    if [[ ! -s "/etc/systemd/system/trojan.service" ]]; then
        [[ "${IS_UPDATE}" == "no" ]] && read -p "Install trojan systemd service?[y/N]:" CHOICE
        if [[ "$CHOICE" == 'y' || "$CHOICE" == 'Y' ]]; then
            sudo cp -f /srv/trojan/examples/trojan.service-example /etc/systemd/system/trojan.service
            sudo sed -i "s|ExecStart=.*|ExecStart=/srv/trojan/trojan -c /etc/trojan/trojan.json|" /etc/systemd/system/trojan.service
        fi
    fi

    if [[ ! -s "/etc/trojan/trojan.json" ]]; then
        sudo mkdir -p "/etc/trojan" && \
            sudo cp -f "/srv/trojan/examples/server.json-example" "/etc/trojan/trojan.json"
    fi

    # nohup /srv/trojan/trojan -c /etc/trojan/trojan.json >/dev/null 2>&1 & disown
    [[ $(systemctl is-enabled trojan 2>/dev/null) ]] || sudo systemctl enable trojan
    [[ $(systemctl is-enabled trojan 2>/dev/null) ]] && sudo systemctl restart trojan
fi

cd "${CURRENT_DIR}"