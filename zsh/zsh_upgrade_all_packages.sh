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


local isUpgrade isNewInstall
if [[ -x "$(command -v proxychains4)" && -d "$HOME/proxychains-ng" && $UID -eq 0 ]]; then isUpgrade="yes"; fi
if [[ ! -x "$(command -v proxychains4)" && ! -d "$HOME/proxychains-ng" && $UID -eq 0 ]]; then isNewInstall="yes"; fi

if [[ "$isUpgrade" == "yes" ]]; then
    cd $HOME/proxychains-ng && git pull
    # only recompile if update
    local git_latest_update proxychains4_date
    # git_latest_update=$(git log -1 --format="%at" | xargs -I{} date -d @{} +'%Y-%m-%d %H:%M:%S')
    git_latest_update=$(git log -1 --format="%at" | xargs -I{} date -d @{})
    proxychains4_date=$(date -d "$(stat --printf='%y\n' $(which proxychains4))")
    # if [[ $(date -d "$git_latest_update") > $(date --date='7 day ago') ]]; then
    if [[ $(date -d "$git_latest_update") > $(date -d "$proxychains4_date") ]]; then
        colorEcho ${BLUE} "Updating proxychains4..."
        ./configure --prefix=/usr --sysconfdir=/etc/proxychains && \
            make && make install
    fi
    cd $HOME
elif [[ "$isNewInstall" == "yes" ]]; then
    colorEcho ${BLUE} "Installing proxychains..."
    cd $HOME && \
    git clone https://github.com/rofl0r/proxychains-ng.git && \
        cd proxychains-ng && \
        ./configure --prefix=/usr --sysconfdir=/etc/proxychains && \
        make && make install && make install-config && \
        cp /etc/proxychains/proxychains.conf /etc/proxychains/proxychains.conf.bak && \
        sed -i 's/socks4/# socks4/g' /etc/proxychains/proxychains.conf && \
        echo 'socks5 127.0.0.1 55880' >> /etc/proxychains/proxychains.conf
fi


local CHECK_URL DOWNLOAD_URL CURRENT_VERSION REMOTE_VERSION
if [[ $UID -eq 0 && -x "$(command -v docker-compose)" ]]; then
    colorEcho ${BLUE} "Updating docker-compose..."

    CHECK_URL="https://api.github.com/repos/docker/compose/releases/latest"

    CURRENT_VERSION=$(docker-compose -v | cut -d',' -f1 | cut -d' ' -f3)
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4)

    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        DOWNLOAD_URL=https://github.com/docker/compose/releases/download/$REMOTE_VERSION/docker-compose-`uname -s`-`uname -m`
        curl -SL $DOWNLOAD_URL -o /usr/local/bin/docker-compose && \
        chmod +x /usr/local/bin/docker-compose
    fi
fi


if [[ -d "$HOME/.nvm" ]]; then
    colorEcho ${BLUE} "Updating nvm & node..."
    cd "$NVM_DIR" && git pull && cd $HOME
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install node && nvm use node
fi


if [[ -d "$HOME/.gvm" ]]; then
    colorEcho ${BLUE} "Updating gvm & go..."
    REMOTE_VERSION=$(proxychains4 curl -s https://golang.org/dl/ | grep -m 1 -o 'go\([0-9]\)\+\.\([0-9]\)\+')
    if [[ "$(gvm list | grep $REMOTE_VERSION)" ]]; then
        if [[ -x "$(command -v proxychains4)" ]]; then
            proxychains4 gvm install $REMOTE_VERSION && gvm use $REMOTE_VERSION --default
        else
            gvm install $REMOTE_VERSION && gvm use $REMOTE_VERSION --default
        fi

        export GOROOT_BOOTSTRAP=$GOROOT
    fi
fi


if [[ -x "$(command -v npm-check)" ]]; then
    colorEcho ${BLUE} "Updating npm global packages..."
    npm-check -y -g
fi


if [[ $UID -eq 0 && -x "$(command -v composer)" ]]; then
    colorEcho ${BLUE} "Updating composer & composer global packages..."
    composer selfupdate && composer g update
fi


if [[ $UID -eq 0 && -x "$(command -v micro)" ]]; then
    colorEcho ${BLUE} "Updating Micro editor..."

    CHECK_URL="https://api.github.com/repos/zyedidia/micro/releases/latest"

    CURRENT_VERSION=$(micro -version | grep Version | cut -d',' -f2)
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        cd /usr/local/bin && curl https://getmic.ro | bash && cd $HOME
    fi
fi


# if [[ -x "$(command -v pear)" ]]; then
#     colorEcho ${BLUE} "Updating pear..."
#     pear upgrade --force PEAR && pear upgrade -all
#     # pecl update-channels && rm -rf /tmp/pear $HOME/.pearrc
# fi


if [[ -x "$(command -v pip)" ]]; then
    colorEcho ${BLUE} "Updating pip packages..."
    pip list -o | grep -E -v '^-|^Package' | cut -d' ' -f1 | xargs -n1 pip install -U
fi


if [[ -x "$(command -v pip3)" ]]; then
    colorEcho ${BLUE} "Updating pip3 packages..."
    pip3 list -o | grep -E -v '^-|^Package' | cut -d' ' -f1 | xargs -n1 pip3 install -U
fi


if [[ "$(command -v fuck)" && -x "$(command -v pip3)" ]]; then
    colorEcho ${BLUE} "Updating thefuck..."
    pip3 install thefuck --upgrade
fi


if [[ -d "$HOME/.sdkman" ]]; then
    if type 'sdk' 2>/dev/null | grep -q 'function'; then
        :
    else
        export SDKMAN_DIR="/root/.sdkman"
        [[ -s "/root/.sdkman/bin/sdkman-init.sh" ]] && source "/root/.sdkman/bin/sdkman-init.sh"
    fi

    colorEcho ${BLUE} "Updating sdk using sdkman..."
    sdk selfupdate && sdk update && printf "Y\n" | sdk upgrade
fi


if [[ -x "$(command -v conda)" ]]; then
    colorEcho ${BLUE} "Updating conda..."
    conda update -y --all
fi


if [[ -n "$ZSH" ]]; then
    if [[ -e "$HOME/zsh_update.sh" ]]; then
        colorEcho ${BLUE} "Updating oh-my-zsh & custom stuff..."
        source "$HOME/zsh_update.sh"
        # -i : Force shell to be interactive
        # Then, if the shell is interactive, 
        # commands are read from /etc/zshrc 
        # and then $ZDOTDIR/.zshrc (this is usually your $HOME/.zshrc)
        # -c : Run a command in this shell
        # zsh -i -c "$HOME/zsh_update.sh"
    fi
fi


colorEcho ${GREEN} "Upgarde all packages done!"
