#!/bin/bash

## How to use
## Install zsh & oh-my-zsh first
## Init: source <(curl -sL https://git.io/fNpeJ) && ~/zsh_update.sh && ~/zsh_init.sh
## Update: source <(curl -sL https://git.io/fNpeJ) && ~/zsh_update.sh

ostype=$(uname)

if [[ -d ~/terminal-custom ]]; then
    cd ~/terminal-custom && git pull && cd -
else
    git clone https://github.com/epoweripione/terminal-custom.git ~/terminal-custom
fi


# copy shell script to HOME
cp -f ~/terminal-custom/*.sh ~
chmod +x ~/hosts_update.sh
chmod +x ~/install_fonts.sh
chmod +x ~/terminal_256colors.sh
chmod +x ~/terminal_colors.sh

cp -f ~/terminal-custom/terminal_256colors.py ~

cp -f ~/terminal-custom/zsh/*.sh ~
chmod +x ~/zsh_change_theme.sh
chmod +x ~/zsh_clean_history.sh
chmod +x ~/zsh_compinit.sh
chmod +x ~/zsh_download_custom_script.sh
chmod +x ~/zsh_init.sh
chmod +x ~/zsh_update.sh

cp -f ~/terminal-custom/git/*.sh ~
chmod +x ~/git_global_config.sh


# MSYS2
if [[ $ostype =~ "MSYS_NT" || $ostype =~ "MINGW" ]]; then
    cp -f ~/terminal-custom/msys2/*.sh ~
    chmod +x ~/chromium_download.sh
    chmod +x ~/msys2_clean_cache.sh
    chmod +x ~/msys2_git_for_windows.sh
    chmod +x ~/msys2_pacman_mirrors.sh
fi


# zsh custom plugins
[ -d ~/terminal-custom/zsh/plugins ] && cp -f ~/terminal-custom/zsh/plugins/* $ZSH/custom/plugins


# zsh custom themes
[ -d ~/terminal-custom/zsh/themes ] && cp -f ~/terminal-custom/zsh/themes/*.zsh-theme $ZSH/custom/themes
