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

# Use proxy or mirror when some sites were blocked or low speed
set_proxy_mirrors_env

## goup (pronounced Go Up) is an elegant Go version manager
## https://github.com/owenthereal/goup
[[ -z "$GO_INSTALLER_NOT_USE_PROXY" ]] && export GOUP_GO_HOST=golang.google.cn

curl -sSf https://raw.githubusercontent.com/owenthereal/goup/master/install.sh | sh -s -- '--skip-prompt'


# How it works
# install.sh: downloads the latest Goup release for your platform and appends Goup's bin directory ($HOME/.go/bin) & 
#   Go's bin directory ($HOME/.go/current/bin) to your PATH environment variable.
# goup: switches to selected Go version.
# goup install: downloads specified version of Go to$HOME/.go/VERSION and symlinks it to $HOME/.go/current.
# goup show: shows the activated Go version located at $HOME/.go/current.
# goup remove: removes the specified Go version.
# goup ls-ver: lists all available Go versions from https://golang.org/dl.
# goup upgrade: upgrades goup.


# Go module proxy
if [[ -z "$GO_INSTALLER_NOT_USE_PROXY" && -x "$(command -v go)" ]]; then
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