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

# subconverter
# https://github.com/tindy2013/subconverter
APP_INSTALL_NAME="subconverter"
IS_INSTALL="yes"
IS_UPDATE="no"
CURRENT_VERSION="0.0.0"
CHOICE="N"

if [[ -s "/srv/subconverter/subconverter" ]]; then
    IS_UPDATE="yes"
    CURRENT_VERSION=$(head -n1 /srv/subconverter/.version)
else
    [[ "${IS_UPDATE_ONLY}" == "yes" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}Checking latest version for ${FUCHSIA}${APP_INSTALL_NAME}${BLUE}..."

    CHECK_URL="https://api.github.com/repos/tindy2013/subconverter/releases/latest"
    REMOTE_VERSION=$(curl "${curl_check_opts[@]}" "${CHECK_URL}" | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_le $REMOTE_VERSION $CURRENT_VERSION; then
        IS_INSTALL="no"
    fi
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    [[ -z "${OS_INFO_TYPE}" ]] && get_os_type
    [[ -z "${OS_INFO_VDIS}" ]] && get_sysArch

    REMOTE_FILENAME=""
    case "${OS_INFO_TYPE}" in
        linux)
            case "${OS_INFO_VDIS}" in
                arm64)
                    REMOTE_FILENAME=${APP_INSTALL_NAME}_aarch64.tar.gz
                    ;;
                arm)
                    REMOTE_FILENAME=${APP_INSTALL_NAME}_armhf.tar.gz
                    ;;
                *)
                    REMOTE_FILENAME=${APP_INSTALL_NAME}_${OS_INFO_TYPE}${OS_INFO_VDIS}.tar.gz
                    ;;
            esac
            ;;
        darwin)
            REMOTE_FILENAME=${APP_INSTALL_NAME}_darwin64.tar.gz
            ;;
        windows)
            case "${OS_INFO_VDIS}" in
                32)
                    REMOTE_FILENAME=${APP_INSTALL_NAME}_win32.zip
                    ;;
                64)
                    REMOTE_FILENAME=${APP_INSTALL_NAME}_win64.zip
                    ;;
            esac
            ;;
    esac

    [[ -z "${REMOTE_FILENAME}" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}  Installing ${FUCHSIA}${APP_INSTALL_NAME} ${YELLOW}${REMOTE_VERSION}${BLUE}..."

    DOWNLOAD_FILENAME="${WORKDIR}/subconverter.tar.gz"
    DOWNLOAD_URL="${GITHUB_DOWNLOAD_URL:-https://github.com}/tindy2013/subconverter/releases/download/v${REMOTE_VERSION}/${REMOTE_FILENAME}"
    curl "${curl_download_opts[@]}" -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}"

    curl_download_status=$?
    if [[ ${curl_download_status} -gt 0 && -n "${GITHUB_DOWNLOAD_URL}" ]]; then
        DOWNLOAD_URL=$(echo "${DOWNLOAD_URL}" | sed "s|${GITHUB_DOWNLOAD_URL}|https://github.com|")
        curl "${curl_download_opts[@]}" -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}"
        curl_download_status=$?
    fi

    if [[ ${curl_download_status} -eq 0 ]]; then
        sudo tar -xzf "${DOWNLOAD_FILENAME}" -C "/srv" && \
            echo ${REMOTE_VERSION} | sudo tee "/srv/subconverter/.version" >/dev/null
    fi

    if [[ "${IS_UPDATE}" == "no" ]]; then
        [[ ! -s "/srv/subconverter/pref.yml" ]] && cp "/srv/subconverter/pref-new.yml" "/srv/subconverter/pref.yml"

        read -s -p "Enter api access password: " API_PASSWORD
        if [[ -n "${API_PASSWORD}" ]]; then
            sed -i "s|api_access_token:.*|api_access_token: ${API_PASSWORD}|" "/srv/subconverter/pref.yml"
            # sed -i "s|api_access_token:.*|api_access_token: ${API_PASSWORD}|" "/srv/subconverter/pref-new.yml"
            # sed -i "s|api_access_token=.*|api_access_token=${API_PASSWORD}|" "/srv/subconverter/pref.ini"
        fi
    fi

    [[ $(systemctl is-enabled subconverter 2>/dev/null) ]] || {
        # [[ "${IS_UPDATE}" == "no" ]] && read -p "Install clash subconverter service?[y/N]:" CHOICE
        # [[ "$CHOICE" == 'y' || "$CHOICE" == 'Y' ]] && Install_systemd_Service "subconverter" "/srv/subconverter/subconverter"
        Install_systemd_Service "subconverter" "/srv/subconverter/subconverter"
    }

    if [[ "${IS_UPDATE}" == "yes" ]]; then
        [[ $(systemctl is-enabled subconverter 2>/dev/null) ]] && sudo systemctl restart subconverter
    fi
fi

# nohup /srv/subconverter/subconverter >/dev/null 2>&1 & disown
# http://127.0.0.1:25500/sub?target=clash&url=https%3A%2F%2Fjiang.netlify.com%2F&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fpref.ini

cd "${CURRENT_DIR}"