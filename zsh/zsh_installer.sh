#!/bin/bash

## How to use
## 1. Install curl first
## 2. Install zsh and oh-my-zsh: source <(curl -sL https://git.io/fA8Jb)
##                               source <(curl -sL http://t.cn/AigJm9ut)

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
    sudo curl -SL -o /tmp/pacapt https://github.com/icy/pacapt/raw/ng/pacapt && \
        sudo mv -f /tmp/pacapt /usr/bin/pacapt && \
        sudo chmod 755 /usr/bin/pacapt && \
        sudo ln -sv /usr/bin/pacapt /usr/bin/pacman || true
fi

# Install ZSH Shell
colorEcho ${BLUE} "Installing pre-request packages..."
if [[ -x "$(command -v pacapt)" || -x "$(command -v pacman)" ]]; then
    sudo pacman --noconfirm -Syu

    # install pre-request packages
    sudo pacman --noconfirm -S git curl wget g++ gcc make zip unzip

    # GeoIP binary and database
    # http://kbeezie.com/geoiplookup-command-line/
    if pacman -Si geoip-bin >/dev/null 2>&1; then
        sudo pacman --noconfirm -S geoip-bin
    else
        if pacman -Si GeoIP >/dev/null 2>&1; then
            sudo pacman --noconfirm -S GeoIP
        else
            sudo pacman --noconfirm -S geoip
        fi
    fi

    if pacman -Si geoip-database >/dev/null 2>&1; then
        sudo pacman --noconfirm -S geoip-database
    else
        if pacman -Si GeoIP-data >/dev/null 2>&1; then
            sudo pacman --noconfirm -S GeoIP-data
        else
            sudo pacman --noconfirm -S geoip-data
        fi
    fi

    # autojump
    # https://github.com/wting/autojump
    if pacman -Si autojump-zsh >/dev/null 2>&1; then
        sudo pacman --noconfirm -S autojump autojump-zsh
    else
        sudo pacman --noconfirm -S autojump
    fi
fi

colorEcho ${BLUE} "Installing ZSH Shell..."
# http://zsh.sourceforge.net/
if [[ ! -x "$(command -v zsh)" ]]; then
    if [[ -f /etc/redhat-release ]]; then
        # install latest zsh for readhat & centos
        # sudo yum -y remove zsh
        sudo yum -y update && \
            sudo yum -y install ncurses-devel gcc make

        # ZSH_REPO_VERSION=$(yum info zsh | grep -E "[Vv]ersion" | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}')

        REMOTE_VERSION=$(curl -s http://zsh.sourceforge.net/News/ \
                            | grep -Eo -m1 'Release ([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
        REMOTE_VERSION=$(echo $REMOTE_VERSION | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}')
        DOWNLOAD_URL=https://nchc.dl.sourceforge.net/project/zsh/zsh/${REMOTE_VERSION}/zsh-${REMOTE_VERSION}.tar.xz
        cd /tmp && \
            sudo curl -SL -o zsh.tar.xz $DOWNLOAD_URL && \
            sudo tar -xvJf zsh.tar.xz && \
            sudo mv zsh-* zsh && \
            cd zsh && \
            sudo ./configure && sudo make && sudo make install && \
            cd - && \
            sudo rm -rf /tmp/*

        if [[ ! -x "$(command -v zsh)" ]]; then
            if [[ -s "/usr/local/bin/zsh" ]]; then
                sudo ln -sv /usr/local/bin/zsh /bin/zsh
            fi
        fi

        if [[ -x "$(command -v zsh)" ]]; then
            if [[ ! -f "/bin/zsh" ]]; then
                sudo ln -sv $(command -v zsh) /bin/zsh
            fi

            command -v zsh | sudo tee -a /etc/shells
        fi
    else
        sudo pacman --noconfirm -S zsh
    fi
fi


if [[ ! -x "$(command -v zsh)" ]]; then
    colorEcho ${RED} "ZSH is not installed! Please manual install ZSH!"
    exit
fi


# change default shell to zsh
# chsh -s $(which zsh)


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
