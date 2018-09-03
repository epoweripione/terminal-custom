#!/bin/bash

# Load custom functions
source "~/custom_functions.sh"

# Install ZSH Shell
colorEcho ${BLUE} "Installing ZSH..."
if check_release_package_manager packageManager yum; then
    yum update -y && yum -y -q install git zsh
elif check_release_package_manager packageManager apt; then
    apt update && apt -y install git zsh
elif check_release_package_manager packageManager pacman; then
    pacman -Sy && pacman -S git zsh
fi


if ! command -v zsh >/dev/null 2>&1; then
    colorEcho ${RED} "Zsh is not installed! Please install zsh first!"
    exit
fi


if [[ ! $(grep "exec zsh" ~/.bashrc) ]]; then
tee -a ~/.bashrc <<-'EOF'

# Launch Zsh
if [[ "${ZSH_VERSION:-unset}" = "unset" ]]; then
    export SHELL=/bin/zsh
    exec zsh
fi
EOF
fi


## Install oh-my-zsh
if [[ -d ~/.oh-my-zsh ]]; then
    # colorEcho ${BLUE} "Updating oh-my-zsh..."
    # cd ~/.oh-my-zsh && git pull && cd ~
else
    colorEcho ${BLUE} "Installing oh-my-zsh..."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi
