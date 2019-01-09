#!/bin/bash

# Load custom functions
if type 'colorEcho' 2>/dev/null | grep -q 'function'; then
    :
else
    if [[ -s "$HOME/custom_functions.sh" ]]; then
        source "$HOME/custom_functions.sh"
    else
        echo "$HOME/custom_functions.sh not exist!"
        exit 0
    fi
fi

# Set proxy or mirrors env in china
set_proxy_mirrors_env


# nodejs
colorEcho ${BLUE} "Installing nvm & nodejs..."
## Install nvm
if [[ ! -d "$HOME/.nvm" ]]; then
    CHECK_URL="https://api.github.com/repos/creationix/nvm/releases/latest"
    REMOTE_VERSION=$(wget --no-check-certificate -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if [[ -n "$REMOTE_VERSION" ]]; then
        curl -o- https://raw.githubusercontent.com/creationix/nvm/v$REMOTE_VERSION/install.sh | bash
    fi
fi

if [[ -d "$HOME/.nvm" ]]; then
    export NVM_DIR="$HOME/.nvm"
    source "$NVM_DIR/nvm.sh"
    # export NVM_DIR="${XDG_CONFIG_HOME:-$HOME}/.nvm"
    # [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    if [[ -z "$NVM_INSTALLER_NOT_USE_MIRROR" ]]; then
        export NVM_NODEJS_ORG_MIRROR=https://npm.taobao.org/mirrors/node
    fi
fi

## Install nodejs
if type 'nvm' 2>/dev/null | grep -q 'function'; then
    if [[ ! "$(command -v node)" ]]; then
        nvm install node
        nvm install --lts

        nvm use node
        nvm alias default node
        # nvm use --lts
        # nvm alias default lts/*

        ## Fix node & npm not found
        [ -L "/usr/bin/node" ] && rm -f /usr/bin/node
        [ -L "/usr/bin/npm" ] && rm -f /usr/bin/npm
        ln -s "$(which node)" /usr/bin/node && ln -s "$(which npm)" /usr/bin/npm
    fi
fi
