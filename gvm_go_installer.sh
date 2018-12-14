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


colorEcho ${BLUE} "Installing gvm & go..."
## Install gvm
## https://github.com/moovweb/gvm
## Please turn on proxy in china (replace the IP and Port to fit your proxy server)
if [[ ! -d "$HOME/.gvm" ]]; then
    apt install -y bison && \
        bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
fi

if [[ -d "$HOME/.gvm" ]]; then
    [[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

    ## In order to compile Go 1.5+, make sure Go 1.4 is installed first.
    if [[ -z "$GVM_INSTALLER_NOT_USE_PROXY" && -x "$(command -v proxychains4)" ]]; then
        proxychains4 gvm install go1.4 -B
    else
        gvm install go1.4 -B
    fi

    if [[ "$(gvm list | grep 'go1.4')" ]]; then
        # Set GOROOT_BOOTSTRAP to compile Go 1.5+
        gvm use go1.4
        export GOROOT_BOOTSTRAP=$GOROOT

        ## Install latest go version
        if [[ -z "$GVM_INSTALLER_NOT_USE_PROXY" && && -x "$(command -v proxychains4)" ]]; then
            REMOTE_VERSION=$(proxychains4 curl -s https://golang.org/dl/ | grep -m 1 -o 'go\([0-9]\)\+\.\([0-9]\)\+\.*\([0-9]\)*')
            proxychains4 gvm install $REMOTE_VERSION
        else
            REMOTE_VERSION=$(curl -s https://golang.org/dl/ | grep -m 1 -o 'go\([0-9]\)\+\.\([0-9]\)\+\.*\([0-9]\)*')
            gvm install $REMOTE_VERSION
        fi

        # Set default go version
        if [[ -n "$REMOTE_VERSION" ]]; then
            if [[ "$(gvm list | grep "$REMOTE_VERSION")" ]]; then
                gvm use $REMOTE_VERSION --default
            fi
        fi
    fi
fi
