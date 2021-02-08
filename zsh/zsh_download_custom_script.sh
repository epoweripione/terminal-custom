#!/usr/bin/env bash

## How to use
## 1. Install `curl`
## 2. Clone repo: source <(curl -fsSL https://git.io/fNpeJ)
## 3. Install zsh and oh-my-zsh: $HOME/terminal-custom/zsh/zsh_installer.sh
## 4. Init: $HOME/terminal-custom/zsh/zsh_upgrade_all_packages.sh && $HOME/terminal-custom/zsh/zsh_init.sh
## 5. Update: source <(curl -fsSL https://git.io/fNpeJ) && $HOME/terminal-custom/zsh/zsh_upgrade_all_packages.sh
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


if [[ ! "$(command -v git)" ]]; then
    colorEcho "${RED}git is not installed! Please install git first!"
    exit
fi


MY_SHELL_SCRIPTS="${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}"

colorEcho "${BLUE}Cloning custom shell scripts repository to $HOME/terminal-custom..."
if [[ -d "${MY_SHELL_SCRIPTS}" ]]; then
    cd "${MY_SHELL_SCRIPTS}" && \
        BRANCH=$(git symbolic-ref --short HEAD) && \
        git pull --rebase --stat origin "${BRANCH:-master}"
else
    REPOREMOTE="https://github.com/epoweripione/terminal-custom.git"
    BRANCH=$(git ls-remote --symref "$REPOREMOTE" HEAD \
                | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}')
    git clone -c core.autocrlf=false -c core.filemode=false \
        -c fsck.zeroPaddedFilemode=ignore \
        -c fetch.fsck.zeroPaddedFilemode=ignore \
        -c receive.fsck.zeroPaddedFilemode=ignore \
        --depth=1 --branch "${BRANCH:-master}" "$REPOREMOTE" "${MY_SHELL_SCRIPTS}"
fi

# starship config
if [[ -x "$(command -v starship)" ]]; then
    cp -f "${MY_SHELL_SCRIPTS}/zsh/themes/starship.toml" "$HOME/.config"
fi

# make *.sh executable
find "${MY_SHELL_SCRIPTS}" -type f -iname "*.sh" -exec chmod +x {} \;

## git global config
# if [[ -s "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/git/git_global_config.sh" ]]; then
#     source "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/git/git_global_config.sh"
# fi

# fix zsh_custom_conf.sh location in .zshrc
if [[ -s "$HOME/.zshrc" ]]; then
    sed -i "s|^source ~/zsh_custom_conf.sh|source ~/terminal-custom/zsh/zsh_custom_conf.sh|" "$HOME/.zshrc"
fi

if [[ -d "$ZSH/custom" ]]; then
    colorEcho "${BLUE}copy zsh custom plugins & theme to $ZSH/custom..."
    # zsh custom plugins
    [ -d "$HOME/terminal-custom/zsh/plugins" ] && cp -f $HOME/terminal-custom/zsh/plugins/* "$ZSH/custom/plugins"

    # zsh custom themes
    [ -d "$HOME/terminal-custom/zsh/themes" ] && cp -f $HOME/terminal-custom/zsh/themes/*.zsh-theme "$ZSH/custom/themes"
fi


cd ${CURRENT_DIR}
colorEcho "${GREEN}Custom shell script download finished!"