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

function get_os_type() {
    os=$(uname)
    os_wsl=$(uname -r)
    if [[ $os == "Darwin" ]]; then
        ostype="darwin"
    elif [[ $os_wsl =~ "Microsoft" || $os =~ "MSYS_NT" || $os =~ "MINGW" || $os =~ "CYGWIN_NT" ]]; then
        ostype="windows"
    else
        ostype=$(echo "$os" | sed 's/.*/\L&/')
    fi
}

function check_release_package_manager() {
    local checkType=$1
    local value=$2

    local release=''
    local systemPackage=''

    os=$(uname)
    if [[ -f /etc/redhat-release ]]; then
        release="centos"
        systemPackage="yum"
    elif [[ -f /etc/alpine-release ]]; then
        release="alpine"
        systemPackage="apk"
    elif [[ -f /etc/arch-release ]]; then
        release="arch"
        systemPackage="pacman"
    elif [[ $os =~ "MSYS_NT" || $os =~ "MINGW" ]]; then
        release="MSYS"
        systemPackage="pacman"
    elif [[ $os =~ "CYGWIN_NT" ]]; then
        release="CYGWIN"
        systemPackage="apt-cyg"
    elif cat /etc/issue | grep -Eqi "debian"; then
        release="debian"
        systemPackage="apt"
    elif cat /etc/issue | grep -Eqi "ubuntu"; then
        release="ubuntu"
        systemPackage="apt"
    elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
        release="centos"
        systemPackage="yum"
    elif cat /proc/version | grep -Eqi "debian"; then
        release="debian"
        systemPackage="apt"
    elif cat /proc/version | grep -Eqi "ubuntu"; then
        release="ubuntu"
        systemPackage="apt"
    elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
        release="centos"
        systemPackage="yum"
    fi

    if [[ ${checkType} == "sysRelease" ]]; then
        if [[ "$value" == "$release" ]]; then
            return 0
        else
            return 1
        fi
    elif [[ ${checkType} == "packageManager" ]]; then
        if [[ "$value" == "$systemPackage" ]]; then
            return 0
        else
            return 1
        fi
    fi
}

function get_arch() {
	architecture=$(uname -m)
	case "$architecture" in
		amd64|x86_64)
			spruce_type='amd64'
			;;
		i386|i486|i586|i686|x86)
			spruce_type='386'
			;;
		*)
			cat 1>&2 <<-EOF
			This script only support 32bit and 64bit architecture!
			Your OS is: $architecture.
			EOF
			exit 1
			;;
	esac
}

# Install ZSH Shell
colorEcho ${BLUE} "Installing ZSH..."
if [[ -x "$(command -v pacapt)" || -x "$(command -v pacman)" ]]; then
    pacman -Sy && pacman -S git zsh
else
    if check_release_package_manager packageManager yum; then
        yum update -y && yum -y -q install git zsh
    elif check_release_package_manager packageManager apt; then
        apt update && apt -y install git zsh
    elif check_release_package_manager packageManager pacman; then
        pacman -Sy && pacman -S git zsh
    fi
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
