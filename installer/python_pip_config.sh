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


set_proxy_mirrors_env


# pip.conf
mkdir -p "$HOME/.pip"
PIP_CONFIG="$HOME/.pip/pip.conf"

# fix `pip list` warning
if [[ ! $(grep "format=columns" "${PIP_CONFIG}") ]]; then
    echo -e "[global]\nformat=columns" >> "${PIP_CONFIG}"
fi

# pip mirror
# alias pip="pip --proxy 127.0.0.1:8080"
# alias pipinstall='pip install -i https://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com'
PIP_MIRROR_URL=https://mirrors.aliyun.com/pypi/simple/
PIP_MIRROR_HOST=mirrors.aliyun.com
if [[ -z "$PIP_NOT_USE_MIRROR" && ! $(grep "${PIP_MIRROR_HOST}" "${PIP_CONFIG}") ]]; then
    if [[ $(grep "index-url=" "${PIP_CONFIG}") ]]; then
        sed -i "s|index-url=.*|index-url=${PIP_MIRROR_URL}|" "${PIP_CONFIG}"
    else
        sed -i "/^\[global\]/a\index-url=${PIP_MIRROR_URL}" "${PIP_CONFIG}"
    fi

    if [[ $(grep "trusted-host=" "${PIP_CONFIG}") ]]; then
        sed -i "s|trusted-host=.*|trusted-host=${PIP_MIRROR_HOST}|" "${PIP_CONFIG}"
    else
        [[ ! $(grep "[install]" "${PIP_CONFIG}") ]] && \
            echo -e "\n[install]" | tee -a "${PIP_CONFIG}" >/dev/null
        sed -i "/^\[install\]/a\trusted-host=${PIP_MIRROR_HOST}" "${PIP_CONFIG}"
    fi
fi

cat "${PIP_CONFIG}"

colorEcho "${BLUE}  Done!"