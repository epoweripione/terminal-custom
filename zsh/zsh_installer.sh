#!/usr/bin/env bash

## How to use
## 1. Install curl first
## 2. Install zsh and oh-my-zsh: source <(curl -fsSL https://git.io/fA8Jb)
##                               source <(curl -fsSL http://t.cn/AigJm9ut)

trap 'rm -rf "$WORKDIR"' EXIT

[[ -z "$WORKDIR" ]] && WORKDIR="$(mktemp -d)"
[[ -z "$CURRENT_DIR" ]] && CURRENT_DIR=$(pwd)

# Colors
NOCOLOR='\033[0m'
RED='\033[0;31m'        # Error message
LIGHTRED='\033[1;31m'
GREEN='\033[0;32m'      # Success message
LIGHTGREEN='\033[1;32m'
ORANGE='\033[0;33m'
YELLOW='\033[1;33m'     # Warning message
BLUE='\033[0;34m'       # Info message
LIGHTBLUE='\033[1;34m'
PURPLE='\033[0;35m'
FUCHSIA='\033[0;35m'
LIGHTPURPLE='\033[1;35m'
CYAN='\033[0;36m'
LIGHTCYAN='\033[1;36m'
DARKGRAY='\033[1;30m'
LIGHTGRAY='\033[0;37m'
WHITE='\033[1;37m'

function colorEcho() {
    if [[ $# > 1 ]]; then
        local COLOR=$1
        echo -e "${COLOR}${@:2}${NOCOLOR}"
    else
        echo -e "${@:1}${NOCOLOR}"
    fi
}

# version compare functions
function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; } # >
function version_ge() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" = "$1"; } # >=
function version_lt() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" != "$1"; } # <
function version_le() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" = "$1"; } # <=

# Check pacakge is installed
function checkPackageInstalled() {
    local PackageName=${1:-""}
    local PackageLocalFiles=""
    local PackageInstalled="no"

    [[ -n "${PackageName}" ]] || return 1
    [[ -x "$(command -v pacman)" ]] || return 1

    PackageLocalFiles=$(pacman -Ql "${PackageName}" 2>&1)
    if [[ $? -eq 0 ]]; then
        PackageInstalled="yes"
    else
        if [[ "${PackageLocalFiles}" == *"unimplemented"* ]]; then
            if pacman -Qi "${PackageName}" >/dev/null 2>&1; then
                PackageInstalled="yes"
            fi
        fi
    fi

    [[ "${PackageInstalled}" == "yes" ]] && return 0 || return 1
}

# Check pacakge exist and not installed
function checkPackageNeedInstall() {
    local PackageName=${1:-""}
    local PackageInfo=""
    local PackageExist="yes"

    [[ -n "${PackageName}" ]] || return 1
    [[ -x "$(command -v pacman)" ]] || return 1

    PackageInfo=$(pacman -Si "${PackageName}" 2>&1)
    if [[ $? -eq 0 ]]; then
        [[ "${PackageInfo}" =~ "Error:" ]] && PackageExist="no"
    else
        PackageExist="no"
    fi

    if [[ "${PackageExist}" == "yes" ]]; then
        if ! checkPackageInstalled "${PackageName}"; then
            return 0
        fi
    fi

    return 1
}

[[ -n "${INSTALLER_CHECK_CURL_OPTION}" ]] && curl_check_opts=(`echo ${INSTALLER_CHECK_CURL_OPTION}`) || curl_check_opts=(-fsL)
[[ -n "${INSTALLER_DOWNLOAD_CURL_OPTION}" ]] && curl_download_opts=(`echo ${INSTALLER_DOWNLOAD_CURL_OPTION}`) || curl_download_opts=(-fSL)

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
    REMOTE_VERSION=$(curl "${curl_check_opts[@]}" "${CHECK_URL}" | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

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
        colorEcho "${BLUE}${ECHO_TYPE} ${FUCHSIA}pacaptr - Pacman-like syntax wrapper for many package managers${BLUE}..."

        DOWNLOAD_FILENAME="${WORKDIR}/pacaptr.tar.gz"
        DOWNLOAD_URL="${GITHUB_DOWNLOAD_URL:-https://github.com}/rami3l/pacaptr/releases/download/v${REMOTE_VERSION}/pacaptr-${OS_TYPE}-amd64.tar.gz"
        curl "${curl_download_opts[@]}" -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}"

        curl_download_status=$?
        if [[ ${curl_download_status} -gt 0 && -n "${GITHUB_DOWNLOAD_URL}" ]]; then
            DOWNLOAD_URL=$(echo "${DOWNLOAD_URL}" | sed "s|${GITHUB_DOWNLOAD_URL}|https://github.com|")
            curl "${curl_download_opts[@]}" -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}"
            curl_download_status=$?
        fi

        if [[ ${curl_download_status} -eq 0 ]]; then
            sudo tar -xzf "${DOWNLOAD_FILENAME}" -C "/usr/local/bin" && \
                sudo ln -sv "/usr/local/bin/pacaptr" "/usr/bin/pacman" || true
        fi
    fi
fi

if [[ ! -x "$(command -v pacaptr)" ]]; then
    colorEcho "${FUCHSIA}pacaptr${RED} is not installed!"
    exit 1
fi

# Install ZSH Shell
if [[ -x "$(command -v pacman)" ]]; then
    colorEcho "${BLUE}Updating ${FUCHSIA}installed packages${BLUE}..."
    sudo pacman --noconfirm -Syu

    colorEcho "${BLUE}Installing ${FUCHSIA}pre-requisite packages${BLUE}..."
    ## Install Latest Git ( Git 2.x ) on CentOS 7
    ## https://computingforgeeks.com/how-to-install-latest-version-of-git-git-2-x-on-centos-7/
    # sudo dnf -y remove git
    # sudo dnf -y install https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm
    # sudo dnf -y install git

    # GeoIP binary and database
    # http://kbeezie.com/geoiplookup-command-line/
    # autojump
    # https://github.com/wting/autojump
    # jq
    # https://stedolan.github.io/jq/

    # Pre-requisite packages
    PackagesList=(
        curl
        wget
        git
        zip
        unzip
        autojump
        autojump-zsh
        bind-utils
        binutils
        build-essential
        connect-proxy
        dnsutils
        autoconf
        g++
        gcc
        geoip
        geoip-bin
        geoip-data
        geoip-database
        GeoIP
        GeoIP-data
        glibc-langpack-en
        glibc-locale-source
        bc
        htop
        jq
        lsof
        make
        man
        man-pages-zh-CN
        man-pages-zh_cn
        manpages-zh
        netcat-openbsd
        nmap
        python3
        recode
        rlwrap
        rsync
        screen
        strace
        tmux
        xsel
    )
    for TargetPackage in "${PackagesList[@]}"; do
        if checkPackageNeedInstall "${TargetPackage}"; then
            colorEcho "${BLUE}  Installing ${FUCHSIA}${TargetPackage}${BLUE}..."
            sudo pacman --noconfirm -S "${TargetPackage}"
        fi
    done
fi

# tmux
# https://github.com/tmux/tmux
if [[ ! -x "$(command -v tmux)" ]]; then
    colorEcho "${BLUE}Compiling ${FUCHSIA}tmux${BLUE}..."
    Git_Clone_Update "tmux/tmux" "${WORKDIR}/tmux"
    if [[ -d "${WORKDIR}/tmux" ]]; then
        PackagesList=(
            automake
            byacc
            gcc
            make
            libevent-dev
            libncurses5-dev
            libevent-devel
            ncurses-devel
            pkg-config
        )
        for TargetPackage in "${PackagesList[@]}"; do
            if checkPackageNeedInstall "${TargetPackage}"; then
                colorEcho "${BLUE}  Installing ${FUCHSIA}${TargetPackage}${BLUE}..."
                sudo pacman --noconfirm -S "${TargetPackage}"
            fi
        done

        cd "${WORKDIR}/tmux" && \
            sudo sh autogen.sh && \
            sudo ./configure >/dev/null && \
            sudo make >/dev/null && \
            sudo make install >/dev/null
    fi
fi

## https://github.com/man-pages-zh/manpages-zh
sudo localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8
# alias man="LC_MESSAGES=zh_CN.UTF-8 man"
# alias man="man -Lzh_CN"

## keep SSH env when using `sudo -i`
## https://mwl.io/archives/1000
## sudo visudo -f /etc/sudoers.d/keep_env_via_ssh
# echo 'Defaults env_keep += "SSH_CLIENT SSH_CONNECTION SSH_TTY SSH_AUTH_SOCK"' \
#     | sudo tee "/etc/sudoers.d/keep_env_via_ssh" >/dev/null

colorEcho "${BLUE}Installing ${FUCHSIA}ZSH ${BLUE}Shell..."
# http://zsh.sourceforge.net/
if [[ ! -x "$(command -v zsh)" ]]; then
    RHEL_VERSION=$(cat /etc/os-release | grep "^VERSION=" | cut -d'"' -f2)
    if [[ "${RHEL_VERSION}" == "7" ]]; then
        ## install latest zsh for readhat 7 & centos 7
        ## sudo dnf -y remove zsh
        # if checkPackageInstalled "zsh"; then
        #     CURRENT_VERSION=$(zsh --version | grep -Eo -m1 '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
        #     colorEcho "${BLUE}  Removing ${FUCHSIA}zsh ${YELLOW}${CURRENT_VERSION}${BLUE}..."
        #     sudo pacman --noconfirm -R zsh
        # fi

        # sudo dnf -y update && sudo dnf -y install ncurses-devel gcc make
        PackagesList=(
            ncurses-devel
            gcc
            make
        )
        for TargetPackage in "${PackagesList[@]}"; do
            if checkPackageNeedInstall "${TargetPackage}"; then
                colorEcho "${BLUE}  Installing ${FUCHSIA}${TargetPackage}${BLUE}..."
                sudo pacman --noconfirm -S "${TargetPackage}"
            fi
        done

        # ZSH_REPO_VERSION=$(dnf info zsh | grep -E "[Vv]ersion" | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}')

        REMOTE_VERSION=$(curl "${curl_check_opts[@]}" http://zsh.sourceforge.net/News/ \
                            | grep -Eo -m1 'Release ([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
        REMOTE_VERSION=$(echo $REMOTE_VERSION | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}')

        if [[ -n "$REMOTE_VERSION" ]]; then
            DOWNLOAD_URL="https://nchc.dl.sourceforge.net/project/zsh/zsh/${REMOTE_VERSION}/zsh-${REMOTE_VERSION}.tar.xz"
            curl "${curl_download_opts[@]}" -o "${WORKDIR}/zsh.tar.xz" "${DOWNLOAD_URL}" && \
                tar -xJf "${WORKDIR}/zsh.tar.xz" -C "${WORKDIR}" && \
                mv ${WORKDIR}/zsh-* "${WORKDIR}/zsh" && \
                cd "${WORKDIR}/zsh" && \
                sudo ./configure >/dev/null && \
                sudo make >/dev/null && \
                sudo make install >/dev/null
        fi

        if [[ ! -x "$(command -v zsh)" ]] && [[ -s "/usr/local/bin/zsh" ]]; then
            sudo ln -sv /usr/local/bin/zsh /bin/zsh
        fi

        if [[ -x "$(command -v zsh)" ]]; then
            if [[ ! -f "/bin/zsh" ]]; then
                sudo ln -sv $(command -v zsh) /bin/zsh
            fi

            command -v zsh | sudo tee -a /etc/shells
        fi
    else
        if checkPackageNeedInstall "zsh"; then
            sudo pacman --noconfirm -S zsh
        fi
    fi
fi


if [[ ! -x "$(command -v zsh)" ]]; then
    colorEcho "${FUCHSIA}ZSH${RED} is not installed! Please manual install ${FUCHSIA}ZSH${RED}!"
    exit
fi


if [[ -s "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/git/git_global_config.sh" ]]; then
    source "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/git/git_global_config.sh"
fi


# change default shell to zsh
# chsh -s $(which zsh)

sudo mkdir -p "/usr/local/share/zsh/site-functions"

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
    colorEcho "${BLUE}Updating ${FUCHSIA}oh-my-zsh${BLUE}..."
    cd "$HOME/.oh-my-zsh" && git pull
else
    colorEcho "${BLUE}Installing ${FUCHSIA}oh-my-zsh${BLUE}..."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

cd "${CURRENT_DIR}"