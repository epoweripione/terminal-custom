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

# inlets: Cloud Native Tunnel for APIs
# https://github.com/inlets/inlets
APP_INSTALL_NAME="inlets"
GITHUB_REPO_NAME="inlets/inlets"

ARCHIVE_EXT=""
ARCHIVE_EXEC_NAME=""

EXEC_INSTALL_PATH="/usr/local/bin"
EXEC_INSTALL_NAME="inlets"

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
    CURRENT_VERSION=$(${EXEC_INSTALL_NAME} version 2>&1 | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
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
    [[ -z "$OS_INFO_TYPE" ]] && get_os_type
    [[ -z "$OS_INFO_ARCH" ]] && get_arch

    case "$OS_INFO_TYPE" in
        darwin)
            REMOTE_SUFFIX="-darwin"
            ;;
        windows)
            REMOTE_SUFFIX=".exe"
            ;;
        linux)
            case "$OS_INFO_ARCH" in
                arm64)
                    REMOTE_SUFFIX="-arm64"
                    ;;
                arm)
                    REMOTE_SUFFIX="-armhf"
                    ;;
            esac
    esac
    REMOTE_FILENAME="${EXEC_INSTALL_NAME}${REMOTE_SUFFIX}"

    [[ -z "${REMOTE_FILENAME}" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}  Installing ${FUCHSIA}${APP_INSTALL_NAME} ${YELLOW}${REMOTE_VERSION}${BLUE}..."

    if [[ -s "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" ]]; then
        sudo rm -f "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}"
    fi

    DOWNLOAD_URL="${GITHUB_DOWNLOAD_URL:-https://github.com}/${GITHUB_REPO_NAME}/releases/download/${REMOTE_VERSION}/${REMOTE_FILENAME}"

    curl "${curl_download_opts[@]}" -o "${WORKDIR}/${EXEC_INSTALL_NAME}" "$DOWNLOAD_URL" && \
        sudo mv -f ${WORKDIR}/${EXEC_INSTALL_NAME} "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" && \
        sudo chmod +x "${EXEC_INSTALL_PATH}/${EXEC_INSTALL_NAME}" && \
        [[ -n "${VERSION_FILENAME}" ]] && echo ${REMOTE_VERSION} | sudo tee "${VERSION_FILENAME}" >/dev/null || true
fi


## Usage:
## 1. On the exit-server (or server)
## Start the tunnel server on a machine with a publicly-accessible IPv4 IP address such as a VPS.
## Example with a token for client authentication:
# export INLETS_TOKEN=$(head -c 16 /dev/urandom | shasum | cut -d" " -f1)
# inlets server --port=8090 --token="${INLETS_TOKEN}"

## 2. Head over to your machine where you are running a sample service, or something you want to expose.
## For example:
## Python's built-in HTTP server:
# mkdir -p /tmp/inlets-test/ && cd /tmp/inlets-test/ && touch hello-world && python -m SimpleHTTPServer 3000

## 3. Start the tunnel client
# export INLETS_REMOTE="127.0.0.1:8090"    # for testing inlets on your laptop, replace with the public IPv4
# export INLETS_TOKEN="CLIENT-TOKEN-HERE"  # the client token is found on your VPS or on start-up of "inlets server"
# export INLETS_UPSTREAM="http://127.0.0.1:3000"
# inlets client --remote="${INLETS_REMOTE}" --token="${INLETS_TOKEN}" --upstream="${INLETS_UPSTREAM}"


## Run behind nginx
## https://github.com/inlets/inlets/blob/master/contrib/nginx.md
# # If you already have an existing nginx webserver running, 
## you can proxy your inlets server through nginx. Simply create a new site configuration file.
## This example assumes inlets is running port 8000, the default port, 
## but you can use any port number you'd like via --port= when starting the server:
# server {
#     listen 80;

#     # Replace *.inlets.example.com with your own wildcard domain.
#     server_name *.inlets.example.com;

#     #Inlets proxy
#     location / {
#         proxy_pass http://127.0.0.1:8000;
#         proxy_http_version 1.1;
#         proxy_read_timeout 120s;
#         proxy_connect_timeout 120s;
#         proxy_set_header Host $host;
#         proxy_set_header Upgrade $http_upgrade;
#         proxy_set_header Connection "upgrade";
#     }
# }
## You can even secure your connection with SSL via your own certificate, or use Letsencrypt.

## Start the tunnel client with wss
# export INLETS_REMOTE="wss://inlets.inlets.example.com"
# export INLETS_TOKEN="CLIENT-TOKEN-HERE"
# export INLETS_UPSTREAM="web1.inlets.example.com=http://127.0.0.1:3000,web2.inlets.example.com=http://127.0.0.1:3001"
# inlets client --remote="${INLETS_REMOTE}" --token="${INLETS_TOKEN}" --upstream="${INLETS_UPSTREAM}"


cd "${CURRENT_DIR}"