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


colorEcho ${BLUE} "Installing gvm & go..."
## Install gvm
## https://github.com/moovweb/gvm
## Please turn on proxy in china (replace the IP and Port to fit your proxy server)
## Mac OS X Requirements
## Install Mercurial from https://www.mercurial-scm.org/downloads
## Install Xcode Command Line Tools from the App Store.
# xcode-select --install
# brew update
# brew install mercurial
## Linux Requirements
## Debian/Ubuntu
# sudo apt-get install curl git mercurial make binutils bison gcc build-essential
## Redhat/Centos
# sudo yum install curl git make bison gcc glibc-devel
## Install Mercurial from http://pkgs.repoforge.org/mercurial/
## FreeBSD Requirements
# sudo pkg_add -r bash git mercurial
if [[ ! -d "$HOME/.gvm" ]]; then
    sudo apt install -y bison && \
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
        if [[ -z "$GVM_INSTALLER_NOT_USE_PROXY" && -x "$(command -v proxychains4)" ]]; then
            REMOTE_VERSION=$(proxychains4 curl -s https://golang.org/dl/ \
                            | grep -Eo -m1 'go([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
            # REMOTE_VERSION=${REMOTE_VERSION%.}
            [[ -n "$REMOTE_VERSION" ]] && proxychains4 gvm install $REMOTE_VERSION
        else
            # REMOTE_VERSION=$(curl -s https://golang.org/dl/ | grep -m 1 -o 'go\([0-9]\)\+\.\([0-9]\)\+\.*\([0-9]\)*')
            REMOTE_VERSION=$(curl -s https://golang.org/dl/ \
                            | grep -Eo -m1 'go([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
            # REMOTE_VERSION=${REMOTE_VERSION%.}
            [[ -n "$REMOTE_VERSION" ]] && gvm install $REMOTE_VERSION
        fi

        # Set default go version
        if [[ -n "$REMOTE_VERSION" ]]; then
            if [[ "$(gvm list | grep "$REMOTE_VERSION")" ]]; then
                gvm use $REMOTE_VERSION --default
            fi
        fi
    fi

    # GOBIN
    if [[ -z "$GOBIN" && -n "$GOROOT" ]]; then
        export GOBIN=$GOROOT/bin
    fi

    # Go module proxy for china
    if [[ -z "$GVM_INSTALLER_NOT_USE_PROXY" && -x "$(command -v go)" ]]; then
        GO_VERSION=$(go version | cut -d' ' -f3)
        if version_ge $GO_VERSION 'go1.13'; then
            go env -w GO111MODULE=on
            go env -w GOPROXY="https://goproxy.io,direct"
            ## https://goproxy.io/zh/docs/goproxyio-private.html
            # go env -w GOPRIVATE="*.corp.example.com"
        else
            export GO111MODULE=on
            export GOPROXY="https://goproxy.io"
        fi
        # go env -w GOPROXY="https://goproxy.cn,direct"
        # go env -w GOPROXY="https://proxy.golang.org,direct"
    fi
fi


## fix ERROR: Unrecognized Go version
# cd $HOME/.gvm/archive/go && git pull


## go env: 1.13+
# go env -w GOBIN=$HOME/bin
# export GOPROXY=https://proxy.golang.org,direct
# export GONOPROXY=


## fix `gvm uninstall 1.14.2` -> ERROR: Couldn't remove pkgsets
# gvm use 1.14.2 && go clean -modcache && gvm use 1.14.3 && gvm uninstall 1.14.2
