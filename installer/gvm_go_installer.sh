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

[[ -z "$OS_INFO_TYPE" ]] && get_os_type

# Use proxy or mirror when some sites were blocked or low speed
set_proxy_mirrors_env

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
INSTALL_NAME="gvm & go"
IS_INSTALL="yes"
IS_UPDATE="no"
CURRENT_VERSION="go0.0.0"

if [[ -d "$HOME/.gvm" ]]; then
    IS_UPDATE="yes"
else
    [[ "${IS_UPDATE_ONLY}" == "yes" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho ${BLUE} "Checking latest version for ${INSTALL_NAME}..."
fi

# new install
if [[ "${IS_INSTALL}" == "yes" && "${IS_UPDATE}" == "no" ]]; then
    if [[ -x "$(command -v pacman)" ]]; then
        PackagesList=(
            bash
            curl
            git
            mercurial
            make
            binutils
            bison
            gcc
            build-essential
            glibc-devel
        )
        for TargetPackage in "${PackagesList[@]}"; do
            if pacman -Si "$TargetPackage" >/dev/null 2>&1; then
                if ! pacman -Q "$TargetPackage" >/dev/null 2>&1; then
                    sudo pacman --noconfirm -S "$TargetPackage"
                fi
            fi
        done
    fi

    if [[ "$OS_INFO_TYPE" == "darwin" && -x "$(command -v brew)" ]]; then
        xcode-select --install
        brew update
        brew install mercurial
    fi

    bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
fi


if [[ "${IS_INSTALL}" == "yes" && -z "$GVM_INSTALLER_NOT_USE_PROXY" ]]; then
    if [[ ! -x "$(command -v proxychains4)" ]]; then
        [[ -s "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/installer/proxychains_installer.sh" ]] && \
            source "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/installer/proxychains_installer.sh"
    fi
fi


if [[ "${IS_INSTALL}" == "yes" && -d "$HOME/.gvm" ]]; then
    if type 'gvm' 2>/dev/null | grep -q 'function'; then
        :
    else
        [[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
    fi

    ## In order to compile Go 1.5+, make sure Go 1.4 is installed first.
    if [[ ! "$(gvm list | grep 'go1.4')" ]]; then
        if [[ -z "$GVM_INSTALLER_NOT_USE_PROXY" && -x "$(command -v proxychains4)" ]]; then
            proxychains4 gvm install go1.4 -B
        else
            gvm install go1.4 -B
        fi
    fi

    CURRENT_VERSION=$(gvm list | grep '=>' | cut -d' ' -f2)
    if [[ "$(gvm list | grep 'go1.4')" ]]; then
        # Set GOROOT_BOOTSTRAP to compile Go 1.5+
        gvm use go1.4
        GOROOT_BOOTSTRAP=$GOROOT

        # Install latest go version
        REMOTE_VERSION=$(curl -s https://golang.org/dl/ | grep -Eo -m1 'go([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
        # REMOTE_VERSION=${REMOTE_VERSION%.}

        if [[ -n "$REMOTE_VERSION" ]] && [[ ! "$(gvm list | grep "$REMOTE_VERSION")" ]]; then
            if [[ -z "$GVM_INSTALLER_NOT_USE_PROXY" && -x "$(command -v proxychains4)" ]]; then
                proxychains4 gvm install $REMOTE_VERSION
            else
                gvm install $REMOTE_VERSION
            fi
        fi

        # Set default go version
        if [[ -n "$REMOTE_VERSION" ]]; then
            if [[ "$(gvm list | grep "$REMOTE_VERSION")" ]]; then
                gvm use $REMOTE_VERSION --default
            fi
        elif [[ -n "$CURRENT_VERSION" ]]; then
            gvm use $CURRENT_VERSION --default
        fi
    fi
fi


# go env
if [[ -d "$HOME/.gvm" ]]; then
    if type 'gvm' 2>/dev/null | grep -q 'function'; then
        :
    else
        [[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
    fi

    if [[ "$(gvm list | grep 'go1.4')" ]]; then
        CURRENT_VERSION=$(gvm list | grep '=>' | cut -d' ' -f2)

        # Set GOROOT_BOOTSTRAP to compile Go 1.5+
        gvm use go1.4 >/dev/null 2>&1
        export GOROOT_BOOTSTRAP=$GOROOT

        # Set default go version
        if [[ -n "$CURRENT_VERSION" ]]; then
            gvm use $CURRENT_VERSION --default >/dev/null 2>&1
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
            # go env -w GOPROXY="https://goproxy.cn,direct"
            # go env -w GOPROXY="https://proxy.golang.org,direct"
            ## https://goproxy.io/zh/docs/goproxyio-private.html
            # go env -w GOPRIVATE="*.corp.example.com"
        else
            export GO111MODULE=on
            export GOPROXY="https://goproxy.io"
        fi
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
