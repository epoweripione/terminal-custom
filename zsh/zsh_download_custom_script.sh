#!/bin/bash

## How to use
## Install zsh & oh-my-zsh first
## Init: source <(curl -sL https://git.io/fNpeJ) && ~/zsh_update.sh && ~/zsh_init.sh
## Update: source <(curl -sL https://git.io/fNpeJ) && ~/zsh_update.sh

#######color code########
RED="31m"      # Error message
GREEN="32m"    # Success message
YELLOW="33m"   # Warning message
BLUE="36m"     # Info message

colorEcho() {
    COLOR=$1
    echo -e "\033[${COLOR}${@:2}\033[0m"
}

ostype=$(uname)

colorEcho ${BLUE} "Cloning custom shell script repository to HOME..."
if [[ -d ~/terminal-custom ]]; then
    cd ~/terminal-custom && git pull && cd -
else
    git clone https://github.com/epoweripione/terminal-custom.git ~/terminal-custom
fi


# copy shell script to HOME
colorEcho ${BLUE} "Copying shell script to HOME..."
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

cp -f ~/terminal-custom/nodejs/*.sh ~
chmod +x ~/npm_packages_installer.sh


# WSL
if [[ $(uname -r) =~ "Microsoft" ]]; then
    cp -f ~/terminal-custom/wsl/wsl_init.sh ~
    chmod +x ~/wsl_init.sh
fi


# MSYS2
if [[ $ostype =~ "MSYS_NT" || $ostype =~ "MINGW" ]]; then
    cp -f ~/terminal-custom/msys2/*.sh ~
    chmod +x ~/chromium_download.sh
    chmod +x ~/msys2_clean_cache.sh
    chmod +x ~/msys2_git_for_windows.sh
    chmod +x ~/msys2_pacman_mirrors.sh
fi


colorEcho ${BLUE} "copy zsh custom plugins & theme to ZSH/custom..."
# zsh custom plugins
[ -d ~/terminal-custom/zsh/plugins ] && cp -f ~/terminal-custom/zsh/plugins/* $ZSH/custom/plugins

# zsh custom themes
[ -d ~/terminal-custom/zsh/themes ] && cp -f ~/terminal-custom/zsh/themes/*.zsh-theme $ZSH/custom/themes

cd $HOME
colorEcho ${GREEN} "Custom shell script download finished!"