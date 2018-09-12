#!/bin/zsh

# Load custom functions
if [[ -e "$HOME/custom_functions.sh" ]]; then
    source "$HOME/custom_functions.sh"
else
    echo "$HOME/custom_functions.sh not exist!"
    exit 0
fi

# if [[ -z "$spruce_type" ]]; then
#     get_os_type
#     get_arch
# fi


colorEcho ${BLUE} "Updating system packages..."
if check_release_package_manager packageManager yum; then
    sudo yum update -y
elif check_release_package_manager packageManager apt; then
    sudo apt update && sudo apt upgrade -y
elif check_release_package_manager packageManager pacman; then
    if [[ $UID -ne 0 && "$(command -v yay)" ]]; then
        yay -Syu
    else
        sudo pacman -Syyu
    fi
fi


if [[ -d "$HOME/proxychains-ng" ]]; then
    colorEcho ${BLUE} "Updating proxychains4..."
    cd proxychains-ng && git pull && \
        ./configure --prefix=/usr --sysconfdir=/etc/proxychains && \
        make && make install && \
        cd $HOME
fi


if [[ $UID -eq 0 && -x "$(command -v docker-compose)" ]]; then
    colorEcho ${BLUE} "Updating docker-compose..."
    CURRENT_VERSION=$(docker-compose -v | cut -d',' -f1 | cut -d' ' -f3)
    REMOTE_VERSION=$(wget --no-check-certificate -qO- https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        curl -SL https://github.com/docker/compose/releases/download/$REMOTE_VERSION/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && \
        chmod +x /usr/local/bin/docker-compose
    fi
fi


if [[ -d "$HOME/.nvm" ]]; then
    colorEcho ${BLUE} "Updating nvm & node..."
    cd "$NVM_DIR" && git pull && cd $HOME
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install node && nvm use node
fi


if [[ "$(command -v npm-check)" ]]; then
    colorEcho ${BLUE} "Updating npm global packages..."
    npm-check -y -g
fi


if [[ $UID -eq 0 && -x "$(command -v composer)" ]]; then
    colorEcho ${BLUE} "Updating composer & composer global packages..."
    composer selfupdate && composer g update
fi


if [[ "$(command -v sdk)" ]]; then
    colorEcho ${BLUE} "Updating sdk using sdkman..."
    sdk selfupdate && sdk update
fi


if [[ "$(command -v conda)" ]]; then
    colorEcho ${BLUE} "Updating conda..."
    conda update -y --all
fi


if [[ $UID -eq 0 && "$(command -v micro)" ]]; then
    colorEcho ${BLUE} "Updating Micro editor..."
    CURRENT_VERSION=$(micro -version | grep Version | cut -d',' -f2)
    REMOTE_VERSION=$(wget --no-check-certificate -qO- https://api.github.com/repos/zyedidia/micro/releases/latest | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        cd /usr/local/bin && curl https://getmic.ro | bash && cd $HOME
    fi
fi


# if [[ "$(command -v pear)" ]]; then
#     colorEcho ${BLUE} "Updating pear..."
#     pear upgrade --force PEAR && pear upgrade -all
#     # pecl update-channels && rm -rf /tmp/pear ~/.pearrc
# fi


if [[ "$(command -v fuck)" ]]; then
    colorEcho ${BLUE} "Updating thefuck..."
    pip3 install thefuck --upgrade
fi


if [[ -n "$ZSH" ]]; then
    if [[ -e "$HOME/zsh_update.sh" ]]; then
        colorEcho ${BLUE} "Updating oh-my-zsh & custom stuff..."
        source "$HOME/zsh_update.sh"
        # -i : Force shell to be interactive
        # Then, if the shell is interactive, commands are read from /etc/zshrc and then $ZDOTDIR/.zshrc (this is usually your $HOME/.zshrc)
        # -c : Run a command in this shell
        # zsh -i -c "$HOME/zsh_update.sh"
    fi
fi


colorEcho ${GREEN} "Upgarde all packages done!"
