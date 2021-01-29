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

# Use proxy or mirror when some sites were blocked or low speed
# set_proxy_mirrors_env


if [[ -d "$HOME/.nvs" ]]; then
    colorEcho "${BLUE}Updating ${FUCHSIA}nvs${BLUE}..."
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

    colorEcho "${BLUE}Updating ${FUCHSIA}node LTS${BLUE}..."
    nvs upgrade lts

    colorEcho "${BLUE}Updating ${FUCHSIA}node latest${BLUE}..."
    nvs upgrade latest
fi


if [[ -x "$(command -v npm-check)" ]]; then
    colorEcho "${BLUE}Updating ${FUCHSIA}npm global packages${BLUE}..."
    npm-check -y -g
fi


if [[ -x "$(command -v yarn)" ]]; then
    colorEcho "${BLUE}Updating ${FUCHSIA}yarn global packages${BLUE}..."
    yarn global upgrade --latest
fi
