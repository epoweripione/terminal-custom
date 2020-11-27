#!/usr/bin/env bash

trap 'rm -r "$WORKDIR"' EXIT

[[ -z "$WORKDIR" ]] && WORKDIR="$(mktemp -d)"
[[ -z "$CURRENT_DIR" ]] && CURRENT_DIR=$(pwd)

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


colorEcho ${BLUE} "Checking latest version for Lua & LuaRocks..."

if [[ -x "$(command -v apt)" ]]; then
    sudo apt -y install build-essential libreadline-dev
fi

if [[ -x "$(command -v dnf)" ]]; then
    sudo dnf -y groupinstall "Development Tools" readline
fi


# compile & install lua
# http://www.lua.org/
if [[ -x "$(command -v lua)" ]]; then
    CURRENT_VERSION=$(lua -v | grep -Eo -m1 '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
else
    CURRENT_VERSION=0.0
fi

REMOTE_VERSION=$(curl -s -N http://www.lua.org/download.html \
    | grep -Eo -m1 'lua-([0-9]{1,}\.)+[0-9]{1,}' | head -n1 | cut -d'-' -f2)

if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
    colorEcho ${BLUE} "  Installing lua ${REMOTE_VERSION} from source..."
    DOWNLOAD_URL="http://www.lua.org/ftp/lua-${REMOTE_VERSION}.tar.gz"
    wget -O "${WORKDIR}/lua.tar.gz" "$DOWNLOAD_URL" && \
        tar xzvf "${WORKDIR}/lua.tar.gz" -C "${WORKDIR}" && \
        mv ${WORKDIR}/lua-* "${WORKDIR}/lua" && \
        cd "${WORKDIR}/lua" && \
        make all test && \
        sudo make install
fi


# compile & install LuaRocks
# https://luarocks.org/
if [[ -x "$(command -v luarocks)" ]]; then
    CURRENT_VERSION=$(luarocks --version | grep -Eo -m1 '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
else
    CURRENT_VERSION=0.0
fi

REMOTE_VERSION=$(curl -s -N https://luarocks.org/ \
    | grep -Eo -m1 'luarocks-([0-9]{1,}\.)+[0-9]{1,}' | head -n1 | cut -d'-' -f2)

if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
    colorEcho ${BLUE} "  Installing luarocks ${REMOTE_VERSION} from source..."
    DOWNLOAD_URL="https://luarocks.org/releases/luarocks-${REMOTE_VERSION}.tar.gz"
    wget -O "${WORKDIR}/luarocks.tar.gz" "$DOWNLOAD_URL" && \
        tar xzvf "${WORKDIR}/luarocks.tar.gz" -C "${WORKDIR}" && \
        mv ${WORKDIR}/luarocks-* "${WORKDIR}/luarocks" && \
        cd "${WORKDIR}/luarocks" && \
        ./configure --with-lua-include=/usr/local/include && \
        make && \
        sudo make install
fi

cd "${CURRENT_DIR}"