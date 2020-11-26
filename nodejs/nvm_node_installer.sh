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


colorEcho ${BLUE} "Installing nvm & nodejs..."
## Install nvm
# https://github.com/creationix/nvm
if [[ ! -d "$HOME/.nvm" ]]; then
    CHECK_URL="https://api.github.com/repos/creationix/nvm/releases/latest"
    REMOTE_VERSION=$(wget --no-check-certificate -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if [[ -n "$REMOTE_VERSION" ]]; then
        curl -o- https://raw.githubusercontent.com/creationix/nvm/v$REMOTE_VERSION/install.sh | bash
    fi
fi

if [[ -d "$HOME/.nvm" ]]; then
    if type 'nvm' 2>/dev/null | grep -q 'function'; then
        :
    else
        export NVM_DIR="$HOME/.nvm"
        source "$NVM_DIR/nvm.sh"
        # export NVM_DIR="${XDG_CONFIG_HOME:-$HOME}/.nvm"
        # [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi
fi

## Install nodejs
if type 'nvm' 2>/dev/null | grep -q 'function'; then
    if [[ ! "$(command -v node)" ]]; then
        if [[ -z "$NVM_INSTALLER_NOT_USE_MIRROR" ]]; then
            colorEcho ${BLUE} "Installing node LTS..."
            NVM_NODEJS_ORG_MIRROR=https://npm.taobao.org/mirrors/node nvm install --lts

            colorEcho ${BLUE} "Installing node latest..."
            NVM_NODEJS_ORG_MIRROR=https://npm.taobao.org/mirrors/node nvm install node
        else
            colorEcho ${BLUE} "Installing node LTS..."
            nvm install --lts

            colorEcho ${BLUE} "Installing node latest..."
            nvm install node
        fi

        # nvm use node
        # nvm alias default node

        nvm use --lts
        nvm alias default lts/*

        ## Fix node & npm not found
        [ -L "/usr/bin/node" ] && rm -f /usr/bin/node
        [ -L "/usr/bin/npm" ] && rm -f /usr/bin/npm
        ln -s "$(which node)" /usr/bin/node && ln -s "$(which npm)" /usr/bin/npm
    fi
fi

if [[ -x "$(command -v npm)" ]]; then
    [[ -s "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/nodejs/npm_config.sh" ]] && \
        source "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/nodejs/npm_config.sh"
fi
