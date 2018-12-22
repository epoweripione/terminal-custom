#!/bin/bash

## How to use
## 1. Install curl first
## 2. Install zsh and oh-my-zsh: source <(curl -sL https://git.io/fA8Jb)
## 3. Init: source <(curl -sL https://git.io/fNpeJ) && ~/zsh_update.sh && ~/zsh_init.sh
## 4. Update: source <(curl -sL https://git.io/fNpeJ) && ~/zsh_update.sh

#######color code########
RED="31m"      # Error message
GREEN="32m"    # Success message
YELLOW="33m"   # Warning message
BLUE="36m"     # Info message

colorEcho() {
    COLOR=$1
    echo -e "\033[${COLOR}${@:2}\033[0m"
}


if [[ ! "$(command -v git)" ]]; then
    colorEcho ${RED} "git is not installed! Please install git first!"
    exit
fi


ostype=$(uname)

# pacapt - An Arch's pacman-like package manager for some Unices
# https://github.com/icy/pacapt
# if [[ ! -x "$(command -v pacapt)" ]]; then
#     colorEcho ${BLUE} "Installing pacapt..."
#     sudo curl -SL https://github.com/icy/pacapt/raw/ng/pacapt -o /usr/bin/pacapt && \
#         sudo chmod 755 /usr/bin/pacapt && \
#         sudo ln -sv /usr/bin/pacapt /usr/bin/pacman || true
# fi


colorEcho ${BLUE} "Cloning custom shell script repository to HOME..."
if [[ -d ~/terminal-custom ]]; then
    cd ~/terminal-custom && git pull
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

chmod +x ~/ssl-cert-info.sh
chmod +x ~/ssl-check-expire-date.sh

chmod +x ~/conda_python_installer.sh
chmod +x ~/cross_gfw_installer.sh
chmod +x ~/docker_installer.sh
chmod +x ~/geoip_installer.sh
chmod +x ~/gvm_go_installer.sh
chmod +x ~/hexo_installer.sh
chmod +x ~/jabba_jdk_installer.sh
chmod +x ~/nano_installer.sh
chmod +x ~/proxychains_installer.sh
chmod +x ~/sdkman_installer.sh

chmod +x ~/speedtest.sh

chmod +x ~/pecl_install_php_extensions.sh

chmod +x ~/frp_installer.sh
chmod +x ~/goproxy_installer.sh

cp -f ~/terminal-custom/terminal_256colors.py ~

cp -f ~/terminal-custom/zsh/*.sh ~
chmod +x ~/zsh_change_theme.sh
chmod +x ~/zsh_clean_history.sh
chmod +x ~/zsh_compinit.sh
chmod +x ~/zsh_download_custom_script.sh
chmod +x ~/zsh_init.sh
chmod +x ~/zsh_installer.sh
chmod +x ~/zsh_update.sh
chmod +x ~/zsh_upgrade_all_packages.sh

cp -f ~/terminal-custom/git/*.sh ~
chmod +x ~/git_global_config.sh

cp -f ~/terminal-custom/nodejs/*.sh ~
chmod +x ~/nvm_node_installer.sh
chmod +x ~/nvm_node_update.sh
chmod +x ~/npm_packages_installer.sh
chmod +x ~/yarn_packages_installer.sh


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
if [[ -d $ZSH/custom ]]; then
    # zsh custom plugins
    [ -d ~/terminal-custom/zsh/plugins ] && cp -f ~/terminal-custom/zsh/plugins/* $ZSH/custom/plugins

    # zsh custom themes
    [ -d ~/terminal-custom/zsh/themes ] && cp -f ~/terminal-custom/zsh/themes/*.zsh-theme $ZSH/custom/themes
fi


cd -
colorEcho ${GREEN} "Custom shell script download finished!"