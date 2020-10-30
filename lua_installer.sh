#!/bin/bash

# if [[ $UID -ne 0 ]]; then
#     echo "Please run this script as root user!"
#     exit 0
# fi

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


colorEcho ${BLUE} "Checking update for Lua & LuaRocks..."

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
    colorEcho ${BLUE} "Installing lua from source..."
    DOWNLOAD_URL="http://www.lua.org/ftp/lua-${REMOTE_VERSION}.tar.gz"
    wget -O "/tmp/lua.tar.gz" "$DOWNLOAD_URL" && \
        tar xzvf "/tmp/lua.tar.gz" -C "/tmp" && \
        mv /tmp/lua-* "/tmp/lua" && \
        cd "/tmp/lua" && \
        make all test && \
        sudo make install && \
        rm -f "/tmp/lua.tar.gz" && \
        rm -rf "/tmp/lua"
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
    colorEcho ${BLUE} "Installing luarocks from source..."
    DOWNLOAD_URL="https://luarocks.org/releases/luarocks-${REMOTE_VERSION}.tar.gz"
    wget -O "/tmp/luarocks.tar.gz" "$DOWNLOAD_URL" && \
        tar xzvf "/tmp/luarocks.tar.gz" -C "/tmp" && \
        mv /tmp/luarocks-* "/tmp/luarocks" && \
        cd "/tmp/luarocks" && \
        ./configure --with-lua-include=/usr/local/include && \
        make && \
        sudo make install && \
        rm -f "/tmp/luarocks.tar.gz" && \
        rm -rf "/tmp/luarocks"
fi
