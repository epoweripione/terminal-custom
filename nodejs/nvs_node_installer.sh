#!/usr/bin/env bash

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

# Set proxy or mirrors env in china
set_proxy_mirrors_env


colorEcho ${BLUE} "Installing nvs & nodejs..."
## Install nvs
# https://github.com/jasongin/nvs
if [[ ! -d "$HOME/.nvs" ]]; then
    export NVS_HOME="$HOME/.nvs"
    git clone https://github.com/jasongin/nvs --depth=1 "$NVS_HOME"
    . "$NVS_HOME/nvs.sh" install
fi

if [[ -d "$HOME/.nvs" ]]; then
    if type 'nvs' 2>/dev/null | grep -q 'function'; then
        :
    else
        export NVS_HOME="$HOME/.nvs"
        [ -s "$NVS_HOME/nvs.sh" ] && . "$NVS_HOME/nvs.sh"
    fi

    if [[ -z "$NVS_INSTALLER_NOT_USE_MIRROR" ]]; then
        nvs remote node https://npm.taobao.org/mirrors/node/
    fi
fi

## Install nodejs
if type 'nvs' 2>/dev/null | grep -q 'function'; then
    if [[ ! "$(command -v node)" ]]; then
        colorEcho ${BLUE} "Installing node LTS..."
        nvs add lts

        colorEcho ${BLUE} "Installing node latest..."
        nvs add latest

        # nvs use latest
        # nvs link latest

        nvs use lts
        nvs link lts
    fi
fi

if [[ -x "$(command -v npm)" ]]; then
    [[ -s "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/nodejs/npm_config.sh" ]] && \
        source "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/nodejs/npm_config.sh"
fi
