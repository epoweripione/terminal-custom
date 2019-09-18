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
colorEcho ${BLUE} "Installing pre-request packages..."
if [[ -x "$(command -v pacapt)" || -x "$(command -v pacman)" ]]; then
    pacman -Syu

    # install pre-request packages
    pacman -S git curl wget g++ gcc make zip unzip

    # GeoIP binary and database
    # http://kbeezie.com/geoiplookup-command-line/
    if pacman -Si geoip-bin >/dev/null 2>&1; then
        pacman -S geoip-bin geoip-database
    else
        if pacman -Si GeoIP >/dev/null 2>&1; then
            pacman -S GeoIP GeoIP-data
        else
            pacman -S geoip geoip-data
        fi
    fi

    # autojump
    # https://github.com/wting/autojump
    if pacman -Si autojump-zsh >/dev/null 2>&1; then
        pacman -S autojump-zsh
    else
        pacman -S autojump
    fi
fi

colorEcho ${BLUE} "Installing ZSH Shell..."
# pacman -S zsh
if [[ -f /etc/redhat-release ]]; then
    # install latest zsh for readhat & centos
    # yum -y remove zsh
    yum -y update && \
        yum -y install ncurses-devel gcc make

    cd /tmp && \
        curl -SL -o zsh.tar.xz https://nchc.dl.sourceforge.net/project/zsh/zsh/5.7.1/zsh-5.7.1.tar.xz && \
        tar -xvJf zsh.tar.xz && \
        mv zsh-* zsh && \
        cd zsh && \
        ./configure && make && make install && \
        cd - && \
        rm -rf /tmp/*
    
    if [[ ! -x "$(command -v zsh)" ]]; then
        if [[ -s "/usr/local/bin/zsh" ]]; then
            ln -sv /usr/local/bin/zsh /bin/zsh
        fi
    fi

    if [[ -x "$(command -v zsh)" ]]; then
        if [[ ! -f "/bin/zsh" ]]; then
            ln -sv $(command -v zsh) /bin/zsh
        fi

        command -v zsh | tee -a /etc/shells
    fi
else
    pacman -S zsh
fi

# change default shell to zsh
# chsh -s $(which zsh)


if [[ ! -x "$(command -v zsh)" ]]; then
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
