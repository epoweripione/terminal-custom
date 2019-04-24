#!/bin/zsh

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
# set_proxy_mirrors_env


if [[ -d "$HOME/.nvs" ]]; then
    colorEcho ${BLUE} "Updating nvs..."
    if type 'nvs' 2>/dev/null | grep -q 'function'; then
        :
    else
        export NVS_HOME="$HOME/.nvs"
        [ -s "$NVS_HOME/nvs.sh" ] && . "$NVS_HOME/nvs.sh"
    fi

    CHECK_URL="https://api.github.com/repos/jasongin/nvs/releases/latest"

    CURRENT_VERSION=$(nvs --version)
    REMOTE_VERSION=$(wget --no-check-certificate -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        cd $NVS_HOME && git pull && cd -
    fi

    colorEcho ${BLUE} "Updating node LTS..."
    nvs upgrade lts

    colorEcho ${BLUE} "Updating node latest..."
    nvs upgrade latest
fi


if [[ -x "$(command -v npm-check)" ]]; then
    colorEcho ${BLUE} "Updating npm global packages..."
    npm-check -y -g
fi


if [[ -x "$(command -v yarn)" ]]; then
    colorEcho ${BLUE} "Updating yarn global packages..."
    yarn global upgrade --latest
fi
