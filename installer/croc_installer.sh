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


# croc - Easily and securely send things from one computer to another
# https://github.com/schollz/croc
colorEcho ${BLUE} "Checking update for croc..."

CHECK_URL="https://api.github.com/repos/schollz/croc/releases/latest"
REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

REMOTE_FILENAME="croc"


PM_INSTALL=""
if [[ -x "$(command -v pacman)" ]]; then
    if pacman -Si croc >/dev/null 2>&1; then
        PM_INSTALL="pacman"
    fi
fi

if [[ -x "$(command -v croc)" ]]; then
    if [[ -n "${PM_INSTALL}" ]]; then
        # update by package manager
        REMOTE_FILENAME=""
    else
        CURRENT_VERSION=v$(croc -v | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
        if version_le $REMOTE_VERSION $CURRENT_VERSION; then
            REMOTE_FILENAME=""
        fi
    fi
else
    if [[ -n "${PM_INSTALL}" ]]; then
        sudo pacman --noconfirm -S croc
        REMOTE_FILENAME=""
    fi
fi


if [[ -n "$REMOTE_VERSION" && -n "$REMOTE_FILENAME" ]]; then
    colorEcho ${BLUE} "Installing croc ${REMOTE_VERSION}..."
    curl https://getcroc.schollz.com | bash
fi