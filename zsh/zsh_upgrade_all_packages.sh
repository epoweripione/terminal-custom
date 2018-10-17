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


# pacapt - An Arch's pacman-like package manager for some Unices
# https://github.com/icy/pacapt
if [[ -x "$(command -v pacapt)" ]]; then
    CHECK_URL="https://api.github.com/repos/icy/pacapt/releases/latest"

    CURRENT_VERSION=$(pacapt -V | grep 'version' | cut -d"'" -f2)
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        colorEcho ${BLUE} "Updating pacapt - An Arch's pacman-like package manager for some Unices..."
        sudo curl -SL https://github.com/icy/pacapt/raw/ng/pacapt -o /usr/bin/pacapt && \
            sudo chmod 755 /usr/bin/pacapt && \
            sudo ln -sv /usr/bin/pacapt /usr/bin/pacman || true
    fi
else
    colorEcho ${BLUE} "Installing pacapt - An Arch's pacman-like package manager for some Unices..."
    sudo curl -SL https://github.com/icy/pacapt/raw/ng/pacapt -o /usr/bin/pacapt && \
        sudo chmod 755 /usr/bin/pacapt && \
        sudo ln -sv /usr/bin/pacapt /usr/bin/pacman || true
fi


colorEcho ${BLUE} "Updating system packages..."
if [[ -x "$(command -v pacapt)" || -x "$(command -v pacman)" ]]; then
    if [[ $UID -ne 0 && "$(command -v yay)" ]]; then
        yay -Syu
    else
        sudo pacman -Syu
    fi
else
    if check_release_package_manager packageManager yum; then
        sudo yum update -y
    elif check_release_package_manager packageManager apt; then
        sudo apt update && sudo apt upgrade -y
    elif check_release_package_manager packageManager pacman; then
        if [[ $UID -ne 0 && "$(command -v yay)" ]]; then
            yay -Syu
        else
            sudo pacman -Syu
        fi
    fi
fi


if [[ -x "$(command -v proxychains4)" && -d "$HOME/proxychains-ng" && $UID -eq 0 ]]; then isUpgrade="yes"; fi
if [[ ! -x "$(command -v proxychains4)" && ! -d "$HOME/proxychains-ng" && $UID -eq 0 ]]; then isNewInstall="yes"; fi

if [[ "$isUpgrade" == "yes" ]]; then
    cd $HOME/proxychains-ng && git pull
    # only recompile if update
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


if [[ -d "$HOME/.gvm" ]]; then
    colorEcho ${BLUE} "Updating gvm & go..."
    if type 'gvm' 2>/dev/null | grep -q 'function'; then
        :
    else
        [[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
    fi

    ## In order to compile Go 1.5+, make sure Go 1.4 is installed first.
    if [[ ! "$(gvm list | grep 'go1.4')" ]]; then
        if [[ -z "$GVM_NOT_USE_PROXY" && -x "$(command -v proxychains4)" ]]; then
            proxychains4 gvm install go1.4 -B
        else
            gvm install go1.4 -B
        fi
    fi

    CURRENT_VERSION=$(gvm list | grep '=>' | cut -d' ' -f2)
    if [[ "$(gvm list | grep 'go1.4')" ]]; then
        # Set GOROOT_BOOTSTRAP to compile Go 1.5+
        gvm use go1.4
        export GOROOT_BOOTSTRAP=$GOROOT

        # Install latest go version
        if [[ -z "$GVM_NOT_USE_PROXY" && -x "$(command -v proxychains4)" ]]; then
            REMOTE_VERSION=$(proxychains4 curl -s https://golang.org/dl/ | grep -m 1 -o 'go\([0-9]\)\+\.\([0-9]\)\+\.*\([0-9]\)*')
        else
            REMOTE_VERSION=$(curl -s https://golang.org/dl/ | grep -m 1 -o 'go\([0-9]\)\+\.\([0-9]\)\+\.*\([0-9]\)*')
        fi

        if [[ ! "$(gvm list | grep "$REMOTE_VERSION")" ]]; then
            if [[ -z "$GVM_NOT_USE_PROXY" && -x "$(command -v proxychains4)" ]]; then
                proxychains4 gvm install $REMOTE_VERSION
            else
                gvm install $REMOTE_VERSION
            fi
        fi

        # Set default go version
        if [[ -n "$REMOTE_VERSION" ]]; then
            if [[ "$(gvm list | grep "$REMOTE_VERSION")" ]]; then
                gvm use $REMOTE_VERSION --default
            fi
        elif [[ -n "$CURRENT_VERSION" ]]; then
            gvm use $CURRENT_VERSION --default
        fi
    fi
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


# fix `pip list` warning
if [[ ! $(grep "format=columns" $HOME/.pip/pip.conf) ]]; then
mkdir -p $HOME/.pip && \
tee $HOME/.pip/pip.conf <<-'EOF'
[global]
format=columns
EOF
fi


if [[ -x "$(command -v pip3)" ]]; then
    colorEcho ${BLUE} "Updating pip3 packages..."
    sudo pip3 list -o | grep -E -v '^-|^Package' | cut -d' ' -f1 | sudo xargs -n1 pip3 install -U
elif [[ -x "$(command -v pip)" ]]; then
    colorEcho ${BLUE} "Updating pip packages..."
    sudo pip list -o | grep -E -v '^-|^Package' | cut -d' ' -f1 | sudo xargs -n1 pip install -U
fi


if [[ "$(command -v fuck)" && -x "$(command -v pip3)" ]]; then
    colorEcho ${BLUE} "Updating thefuck..."
    sudo pip3 install thefuck --upgrade
fi


if [[ -d "$HOME/.jabba" ]]; then
    colorEcho ${BLUE} "Updating jabba..."
    if type 'jabba' 2>/dev/null | grep -q 'function'; then
        :
    else
        [[ -s "$HOME/.jabba/jabba.sh" ]] && source "$HOME/.jabba/jabba.sh"
    fi

    CHECK_URL="https://api.github.com/repos/shyiko/jabba/releases/latest"

    CURRENT_VERSION=$(jabba --version | cut -d' ' -f2)
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        curl -sL https://github.com/shyiko/jabba/raw/master/install.sh | bash && \
            . ~/.jabba/jabba.sh && \
            sed -i "/jabba.sh/d" ~/.zshrc && \
            cd $HOME
    fi
fi


if [[ -d "$HOME/.sdkman" ]]; then
    colorEcho ${BLUE} "Updating sdk using sdkman..."
    if type 'sdk' 2>/dev/null | grep -q 'function'; then
        :
    else
        export SDKMAN_DIR="/root/.sdkman"
        [[ -s "/root/.sdkman/bin/sdkman-init.sh" ]] && source "/root/.sdkman/bin/sdkman-init.sh"
    fi

    sdk selfupdate && sdk update && printf "Y\n" | sdk upgrade
fi


if [[ -x "$(command -v conda)" ]]; then
    colorEcho ${BLUE} "Updating conda..."
    conda update -y conda

    colorEcho ${BLUE} "Updating all installed conda packages..."
    conda update -y --all
fi


if [[ -d "$HOME/.nvm" ]]; then
    colorEcho ${BLUE} "Updating nvm..."
    if type 'nvm' 2>/dev/null | grep -q 'function'; then
        :
    else
        export NVM_DIR="$HOME/.nvm"
        [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    fi
    
    cd "$NVM_DIR" && git pull && cd $HOME

    colorEcho ${BLUE} "Getting node version..."
    CURRENT_VERSION=$(nvm version)
    REMOTE_VERSION=$(nvm version-remote)
    
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        colorEcho ${BLUE} "Updating node..."
        nvm install node --reinstall-packages-from=node
        # nvm use node
        nvm alias default node
        ## Fix node & npm not found
        [ -L "/usr/bin/node" ] && rm -f /usr/bin/node
        [ -L "/usr/bin/npm" ] && rm -f /usr/bin/npm
        ln -s "$(which node)" /usr/bin/node && ln -s "$(which npm)" /usr/bin/npm
    fi
fi


if [[ -x "$(command -v npm-check)" ]]; then
    colorEcho ${BLUE} "Updating npm global packages..."
    npm-check -y -g
fi


if [[ -x "$(command -v yarn)" ]]; then
    colorEcho ${BLUE} "Updating yarn global packages..."
    yarn global upgrade # yarn global upgrade --latest
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
