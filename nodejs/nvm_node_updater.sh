#!/usr/bin/env zsh

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


if [[ -x "$(command -v npm-check)" ]]; then
    colorEcho ${BLUE} "Updating npm global packages..."
    npm-check -y -g
fi


if [[ -x "$(command -v yarn)" ]]; then
    colorEcho ${BLUE} "Updating yarn global packages..."
    yarn global upgrade --latest
fi


if [[ -z "$NVM_NOT_UPDATE" && -d "$HOME/.nvm" ]]; then
    colorEcho ${BLUE} "Updating nvm..."
    if type 'nvm' 2>/dev/null | grep -q 'function'; then
        :
    else
        export NVM_DIR="$HOME/.nvm"
        source "$NVM_DIR/nvm.sh"
        # export NVM_DIR="${XDG_CONFIG_HOME:-$HOME}/.nvm"
        # [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi

    CHECK_URL="https://api.github.com/repos/creationix/nvm/releases/latest"

    CURRENT_VERSION=$(nvm --version)
    REMOTE_VERSION=$(wget --no-check-certificate -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        curl -o- https://raw.githubusercontent.com/creationix/nvm/v$REMOTE_VERSION/install.sh | bash
    fi

    if [[ -z "$NVM_INSTALLER_NOT_USE_MIRROR" ]]; then
        colorEcho ${BLUE} "Updating node LTS..."
        NVM_NODEJS_ORG_MIRROR=https://npm.taobao.org/mirrors/node nvm install --lts

        colorEcho ${BLUE} "Updating node latest..."
        NVM_NODEJS_ORG_MIRROR=https://npm.taobao.org/mirrors/node nvm install node --reinstall-packages-from=node
    else
        colorEcho ${BLUE} "Updating node LTS..."
        nvm install --lts

        colorEcho ${BLUE} "Updating node latest..."
        nvm install node --reinstall-packages-from=node
    fi

    # nvm use node
    nvm alias default node
    ## Fix node & npm not found
    [ -L "/usr/bin/node" ] && rm -f /usr/bin/node
    [ -L "/usr/bin/npm" ] && rm -f /usr/bin/npm
    ln -s "$(which node)" /usr/bin/node && ln -s "$(which npm)" /usr/bin/npm

    # colorEcho ${BLUE} "Getting node LTS version..."
    # CURRENT_VERSION=$(nvm version lts/*)
    # REMOTE_VERSION=$(nvm version-remote lts/*)

    # if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
    #     colorEcho ${BLUE} "Updating node LTS..."
    #     nvm install --lts --latest-npm
    # fi

    # colorEcho ${BLUE} "Getting node version..."
    # CURRENT_VERSION=$(nvm version)
    # REMOTE_VERSION=$(nvm version-remote)

    # if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
    #     colorEcho ${BLUE} "Updating node latest..."
    #     nvm install node --reinstall-packages-from=node --latest-npm
    #     # nvm use node
    #     nvm alias default node
    #     ## Fix node & npm not found
    #     [ -L "/usr/bin/node" ] && rm -f /usr/bin/node
    #     [ -L "/usr/bin/npm" ] && rm -f /usr/bin/npm
    #     ln -s "$(which node)" /usr/bin/node && ln -s "$(which npm)" /usr/bin/npm
    # fi
fi