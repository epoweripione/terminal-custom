#!/usr/bin/env bash

## How to use
## 1. Install curl first
## 2. Install zsh and oh-my-zsh: source <(curl -sL https://git.io/fA8Jb)
##                               source <(curl -sL http://t.cn/AigJm9ut)

trap 'rm -r "$WORKDIR"' EXIT

[[ -z "$WORKDIR" ]] && WORKDIR="$(mktemp -d)"
[[ -z "$CURRENT_DIR" ]] && CURRENT_DIR=$(pwd)

#######color code########
RED="31m"      # Error message
GREEN="32m"    # Success message
YELLOW="33m"   # Warning message
BLUE="36m"     # Info message

function colorEcho() {
    COLOR=$1
    echo -e "\033[${COLOR}${@:2}\033[0m"
}


# pacaptr - Pacman-like syntax wrapper for many package managers
# https://github.com/rami3l/pacaptr
case $(uname) in
    Darwin)
        OS_TYPE='macos'
        ;;
    Linux)
        OS_TYPE='linux'
        ;;
    *)
        OS_TYPE=''
        ;;
esac

OS_ARCH=$(uname -m)
if [[ -n "$OS_TYPE" && ("$OS_ARCH" == "amd64" || "$OS_ARCH" == "x86_64") ]]; then
    CHECK_URL="https://api.github.com/repos/rami3l/pacaptr/releases/latest"
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

    if [[ -x "$(command -v pacaptr)" ]]; then
        ECHO_TYPE="Updating"
        CURRENT_VERSION=$(pacaptr -V | cut -d" " -f2)
        [[ -s "/root/.config/pacaptr/pacaptr.toml" ]] && \
            sudo sed -i "s/needed.*/needed = true/" "/root/.config/pacaptr/pacaptr.toml"
    else
        CURRENT_VERSION="0.0.0"
        ECHO_TYPE="Installing" 
        # pacaptr config   
        sudo mkdir -p "/root/.config/pacaptr/"
        echo -e "dry_run = false\nneeded = true\nno_confirm = false\nforce_cask = false\nno_cache = false" \
            | sudo tee "/root/.config/pacaptr/pacaptr.toml" >/dev/null
    fi

    [[ "$(readlink -f /usr/bin/pacman)" == "/usr/bin/pacapt" ]] && \
        sudo rm -f "/usr/bin/pacman" && sudo rm -f "/usr/bin/pacapt"

    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        colorEcho ${BLUE} "${ECHO_TYPE} pacaptr - Pacman-like syntax wrapper for many package managers..."
        DOWNLOAD_URL="https://github.com/rami3l/pacaptr/releases/download/v${REMOTE_VERSION}/pacaptr-${OS_TYPE}-amd64.tar.gz"
        curl -SL -o "${WORKDIR}/pacaptr.tar.gz" -C- "$DOWNLOAD_URL" && \
            sudo tar -xzPf "${WORKDIR}/pacaptr.tar.gz" -C "/usr/local/bin" && \
            sudo ln -sv "/usr/local/bin/pacaptr" "/usr/bin/pacman" || true
    fi
fi


# Install ZSH Shell
if [[ -x "$(command -v pacman)" ]]; then
    colorEcho ${BLUE} "Updating installed packages..."
    sudo pacman --noconfirm -Syu

    colorEcho ${BLUE} "Installing pre-requisite packages..."
    sudo pacman --noconfirm -S git curl wget g++ gcc make zip unzip

    ## Install Latest Git ( Git 2.x ) on CentOS 7
    ## https://computingforgeeks.com/how-to-install-latest-version-of-git-git-2-x-on-centos-7/
    # sudo yum -y remove git
    # sudo yum -y install https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm
    # sudo yum -y install git

    # GeoIP binary and database
    # http://kbeezie.com/geoiplookup-command-line/
    # autojump
    # https://github.com/wting/autojump
    # jq
    # https://stedolan.github.io/jq/

    ## https://github.com/man-pages-zh/manpages-zh
    sudo localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8
    # alias man="LC_MESSAGES=zh_CN.UTF-8 man"
    # alias man="man -Lzh_CN"

    # Pre-requisite packages
    PackagesList=(
        rsync
        geoip
        GeoIP
        geoip-bin
        geoip-database
        geoip-data
        GeoIP-data
        autojump
        autojump-zsh
        screen
        jq
        connect-proxy
        netcat-openbsd
        man
        manpages-zh
        man-pages-zh_cn
        man-pages-zh-CN
    )
    for TargetPackage in "${PackagesList[@]}"; do
        if pacman -Si "$TargetPackage" >/dev/null 2>&1; then
            if ! pacman -Q "$TargetPackage" >/dev/null 2>&1; then
                sudo pacman --noconfirm -S "$TargetPackage"
            fi
        fi
    done

    # tmux
    # https://github.com/tmux/tmux
    colorEcho ${BLUE} "Installing tmux..."
    if pacman -Si tmux >/dev/null 2>&1; then
        sudo pacman --noconfirm -S tmux
    else
        git clone https://github.com/tmux/tmux && \
            cd tmux && \
            sudo sh autogen.sh && \
            sudo ./configure >/dev/null && sudo make >/dev/null
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

        if [[ -n "$REMOTE_VERSION" ]]; then
            DOWNLOAD_URL="https://nchc.dl.sourceforge.net/project/zsh/zsh/${REMOTE_VERSION}/zsh-${REMOTE_VERSION}.tar.xz"
            sudo curl -SL -o "${WORKDIR}/zsh.tar.xz" "$DOWNLOAD_URL" && \
                sudo tar xJvf "${WORKDIR}/zsh.tar.xz" -C "${WORKDIR}" && \
                sudo mv ${WORKDIR}/zsh-* "${WORKDIR}/zsh" && \
                cd "${WORKDIR}/zsh" && \
                sudo ./configure >/dev/null && \
                sudo make >/dev/null && \
                sudo make install >/dev/null
        fi

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


if [[ -x "$(command -v git)" && -s "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/git/git_global_config.sh" ]]; then
    source "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/git/git_global_config.sh"
fi


# change default shell to zsh
# chsh -s $(which zsh)


# Launch ZSH in BASH
OS_WSL=$(uname -r)

# WSL1 & WSL2
if [[ "$OS_WSL" =~ "Microsoft" || "$OS_WSL" =~ "microsoft" ]]; then
    if [[ ! $(grep "exec zsh" ~/.bashrc) ]]; then
        tee -a ~/.bashrc >/dev/null <<-'EOF'

# Launch ZSH
if [[ "${ZSH_VERSION:-unset}" = "unset" ]]; then
    export SHELL=$(which zsh)
    exec zsh
fi
EOF
    fi
fi

## Install oh-my-zsh
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    colorEcho ${BLUE} "Updating oh-my-zsh..."
    cd "$HOME/.oh-my-zsh" && git pull
else
    colorEcho ${BLUE} "Installing oh-my-zsh..."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

cd "${CURRENT_DIR}"