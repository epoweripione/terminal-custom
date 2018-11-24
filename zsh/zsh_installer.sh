#!/bin/bash

## How to use
## 1. Install curl first
## 2. Install zsh and oh-my-zsh: source <(curl -sL https://git.io/fA8Jb)

#######color code########
RED="31m"      # Error message
GREEN="32m"    # Success message
YELLOW="33m"   # Warning message
BLUE="36m"     # Info message

function colorEcho() {
    COLOR=$1
    echo -e "\033[${COLOR}${@:2}\033[0m"
}


# pacapt - An Arch's pacman-like package manager for some Unices
# https://github.com/icy/pacapt
if [[ ! -x "$(command -v pacapt)" ]]; then
    colorEcho ${BLUE} "Installing pacapt - An Arch's pacman-like package manager for some Unices..."
    sudo curl -SL https://github.com/icy/pacapt/raw/ng/pacapt -o /usr/bin/pacapt && \
        sudo chmod 755 /usr/bin/pacapt && \
        sudo ln -sv /usr/bin/pacapt /usr/bin/pacman || true
fi

# Install ZSH Shell
colorEcho ${BLUE} "Installing Git & ZSH..."
if [[ -x "$(command -v pacapt)" || -x "$(command -v pacman)" ]]; then
    pacman -Sy && pacman -S git zsh
fi


if ! command -v zsh >/dev/null 2>&1; then
    colorEcho ${RED} "ZSH is not installed! Please manual install ZSH!"
    exit
fi


# Launch ZSH in BASH
# if [[ ! $(grep "exec zsh" ~/.bashrc) ]]; then
# tee -a ~/.bashrc <<-'EOF'

# # Launch ZSH
# if [[ "${ZSH_VERSION:-unset}" = "unset" ]]; then
#     export SHELL=$(which zsh)
#     exec zsh
# fi
# EOF
# fi


## Install oh-my-zsh
if [[ -d ~/.oh-my-zsh ]]; then
    colorEcho ${BLUE} "Updating oh-my-zsh..."
    cd ~/.oh-my-zsh && git pull && cd ~
else
    colorEcho ${BLUE} "Installing oh-my-zsh..."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi
