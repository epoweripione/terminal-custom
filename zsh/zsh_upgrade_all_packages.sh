#!/bin/zsh

# Load custom functions
if type 'colorEcho' 2>/dev/null | grep -q 'function'; then
    :
else
    if [[ -s "$HOME/custom_functions.sh" ]]; then
        source "$HOME/custom_functions.sh"
    else
        echo "$HOME/custom_functions.sh not exist!"
        exit 0
    fi
fi

# Set proxy or mirrors env in china
set_proxy_mirrors_env

if [[ -z "$spruce_type" ]]; then
    get_os_type
    get_arch
    get_sysArch
fi


# pacapt - An Arch's pacman-like package manager for some Unices
# https://github.com/icy/pacapt
if [[ -x "$(command -v pacapt)" ]]; then
    CHECK_URL="https://api.github.com/repos/icy/pacapt/releases/latest"

    CURRENT_VERSION=$(pacapt -V | grep 'version' | cut -d"'" -f2)
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        colorEcho ${BLUE} "Updating pacapt - An Arch's pacman-like package manager for some Unices..."
        sudo curl -SL https://github.com/icy/pacapt/raw/ng/pacapt -o /tmp/pacapt && \
            sudo mv -f /tmp/pacapt /usr/bin/pacapt && \
            sudo chmod 755 /usr/bin/pacapt && \
            sudo ln -sv /usr/bin/pacapt /usr/bin/pacman || true
    fi
else
    colorEcho ${BLUE} "Installing pacapt - An Arch's pacman-like package manager for some Unices..."
    sudo curl -SL https://github.com/icy/pacapt/raw/ng/pacapt -o /tmp/pacapt && \
        sudo mv -f /tmp/pacapt /usr/bin/pacapt && \
        sudo chmod 755 /usr/bin/pacapt && \
        sudo ln -sv /usr/bin/pacapt /usr/bin/pacman || true
fi


colorEcho ${BLUE} "Updating system packages..."
if [[ -x "$(command -v pacapt)" || -x "$(command -v pacman)" ]]; then
    if [[ $UID -ne 0 && "$(command -v yay)" ]]; then
        yay -Syu
    else
        if [[ -x "$(command -v pacapt)" ]]; then
            sudo pacapt -Syu --noconfirm
        else
            sudo pacman -Syu
        fi
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
    colorEcho ${BLUE} "Updating proxychains4..."
    cd $HOME/proxychains-ng && git pull
    # only recompile if update
    # git_latest_update=$(git log -1 --format="%at" | xargs -I{} date -d @{} +'%Y-%m-%d %H:%M:%S')
    git_latest_update=$(git log -1 --format="%at" | xargs -I{} date -d @{})
    proxychains4_date=$(date -d "$(stat --printf='%y\n' $(which proxychains4))")
    # if [[ $(date -d "$git_latest_update") > $(date --date='7 day ago') ]]; then
    if [[ $(date -d "$git_latest_update") > $(date -d "$proxychains4_date") ]]; then
        ./configure --prefix=/usr --sysconfdir=/etc/proxychains && \
            make && make install
    fi
    cd $HOME
# elif [[ "$isNewInstall" == "yes" ]]; then
#     colorEcho ${BLUE} "Installing proxychains..."
#     cd $HOME && \
#     git clone https://github.com/rofl0r/proxychains-ng.git && \
#         cd proxychains-ng && \
#         ./configure --prefix=/usr --sysconfdir=/etc/proxychains && \
#         make && make install && make install-config && \
#         cp /etc/proxychains/proxychains.conf /etc/proxychains/proxychains.conf.bak && \
#         sed -i 's/socks4/# socks4/g' /etc/proxychains/proxychains.conf && \
#         echo 'socks5 127.0.0.1 55880' >> /etc/proxychains/proxychains.conf && \
#         cd $HOME
fi


if [[ $UID -eq 0 && -x "$(command -v docker-compose)" ]]; then
    colorEcho ${BLUE} "Updating docker-compose..."

    CHECK_URL="https://api.github.com/repos/docker/compose/releases/latest"

    CURRENT_VERSION=$(docker-compose -v | cut -d',' -f1 | cut -d' ' -f3)
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        DOWNLOAD_URL=https://github.com/docker/compose/releases/download/$REMOTE_VERSION/docker-compose-`uname -s`-`uname -m`
        curl -SL $DOWNLOAD_URL -o /tmp/docker-compose && \
            mv -f /tmp/docker-compose /usr/local/bin/docker-compose && \
            chmod +x /usr/local/bin/docker-compose
    fi
fi


if [[ $UID -eq 0 && -x "$(command -v ctop)" ]]; then
    colorEcho ${BLUE} "Updating ctop..."
    if uname -m | grep -Eqi "amd64|x86_64"; then
        DOWNLOAD_FILE_SUFFIX='linux-amd64'
    else
        DOWNLOAD_FILE_SUFFIX='linux-386'
    fi

    CHECK_URL="https://api.github.com/repos/bcicen/ctop/releases/latest"

    CURRENT_VERSION=$(ctop -v | cut -d',' -f1 | cut -d' ' -f3)
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -c2-)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        DOWNLOAD_URL=https://github.com/bcicen/ctop/releases/download/v$REMOTE_VERSION/ctop-${REMOTE_VERSION}-${DOWNLOAD_FILE_SUFFIX}
        curl -SL $DOWNLOAD_URL -o /tmp/ctop && \
            mv -f /tmp/ctop /usr/local/bin/ctop && \
            chmod +x /usr/local/bin/ctop
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
        if [[ -z "$GVM_INSTALLER_NOT_USE_PROXY" && -x "$(command -v proxychains4)" ]]; then
            proxychains4 gvm install go1.4 -B
        else
            gvm install go1.4 -B
        fi
    fi

    CURRENT_VERSION=$(gvm list | grep '=>' | cut -d' ' -f2)
    if [[ "$(gvm list | grep 'go1.4')" ]]; then
        # Set GOROOT_BOOTSTRAP to compile Go 1.5+
        gvm use go1.4
        GOROOT_BOOTSTRAP=$GOROOT

        # Install latest go version
        if [[ -z "$GVM_INSTALLER_NOT_USE_PROXY" && -x "$(command -v proxychains4)" ]]; then
            REMOTE_VERSION=$(proxychains4 curl -s https://golang.org/dl/ | grep -m 1 -o 'go\([0-9]\)\+\.\([0-9]\)\+\.*\([0-9]\)*')
        else
            REMOTE_VERSION=$(curl -s https://golang.org/dl/ | grep -m 1 -o 'go\([0-9]\)\+\.\([0-9]\)\+\.*\([0-9]\)*')
        fi

        if [[ ! "$(gvm list | grep "$REMOTE_VERSION")" ]]; then
            if [[ -z "$GVM_INSTALLER_NOT_USE_PROXY" && -x "$(command -v proxychains4)" ]]; then
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


if [[ $UID -eq 0 && -x "$(command -v php)" && -x "$(command -v composer)" ]]; then
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


# if [[ -x "$(command -v pip3)" ]]; then
#     colorEcho ${BLUE} "Updating pip3 packages..."
#     sudo pip3 list -o | grep -E -v '^-|^Package' | cut -d' ' -f1 | sudo xargs -n1 pip3 install -U
# elif [[ -x "$(command -v pip)" ]]; then
#     colorEcho ${BLUE} "Updating pip packages..."
#     sudo pip list -o | grep -E -v '^-|^Package' | cut -d' ' -f1 | sudo xargs -n1 pip install -U
# fi


# if [[ "$(command -v fuck)" && -x "$(command -v pip)" ]]; then
#     colorEcho ${BLUE} "Updating thefuck..."
#     sudo pip install thefuck --upgrade
# fi


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
        export SDKMAN_DIR="$HOME/.sdkman"
        [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
    fi

    sdk selfupdate && sdk update && printf "Y\n" | sdk upgrade
fi


if [[ -x "$(command -v proxy)" ]]; then
    colorEcho ${BLUE} "Updating goproxy..."
    # https://github.com/snail007/goproxy

    CHECK_URL="https://api.github.com/repos/snail007/goproxy/releases/latest"

    CURRENT_VERSION=$(proxy --version 2>&1 | cut -d'_' -f1)
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        curl -SL https://raw.githubusercontent.com/snail007/goproxy/master/install_auto.sh | bash
    fi
fi


if [[ -d "/srv/frp" ]]; then
    colorEcho ${BLUE} "Updating frp..."
    # https://github.com/fatedier/frp

    CHECK_URL="https://api.github.com/repos/fatedier/frp/releases/latest"

    CURRENT_VERSION=$(/srv/frp/frps --version 2>&1)
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        if pgrep -f "frps" 2>&1; then
            pkill -f "frps"
        fi

        DOWNLOAD_URL=https://github.com/fatedier/frp/releases/download/v${REMOTE_VERSION}/frp_${REMOTE_VERSION}_${ostype}_${spruce_type}.tar.gz
        curl -SL $DOWNLOAD_URL -o frp.tar.gz && \
            tar -zxPf frp.tar.gz -C /srv/ && \
            rm frp.tar.gz && \
            mkdir -p /srv/backup_frp && \
            cp -f /srv/frp/*.ini /srv/backup_frp && \
            rm -f /srv/backup_frp/frpc_full.ini && \
            rm -f /srv/backup_frp/frps_full.ini && \
            rm -rf /srv/frp && \
            mkdir -p /srv/frp && \
            cp -rf /srv/frp_*/* /srv/frp && \
            cp -f /srv/backup_frp/*.ini /srv/frp && \
            rm -rf /srv/frp_*
        
        if [[ -s "/srv/frp/frps.ini" ]]; then
            nohup /srv/frp/frps -c /srv/frp/frps.ini >/dev/null 2>&1 & disown
        fi
    fi
fi


if [[ -x "$(command -v v2ray)" ]]; then
    if v2ray --version 2>&1 | grep -q 'multi-v2ray'; then
        colorEcho ${BLUE} "Updating multi-v2ray..."
        # https://github.com/Jrohy/multi-v2ray
        v2ray update.sh && v2ray update && v2ray restart
    elif systemctl list-unit-files --type=service | grep v2ray.service | grep enabled >/dev/null 2>&1; then
        V2RAYCORE="yes"
    fi
elif systemctl list-unit-files --type=service | grep v2ray.service | grep enabled >/dev/null 2>&1; then
    V2RAYCORE="yes"
fi

if [[ $UID -ne 0 && -n "$V2RAYCORE" ]]; then
    colorEcho ${BLUE} "Updating v2ray-core..."
    # https://www.v2ray.com/chapter_00/install.html

    CHECK_URL="https://api.github.com/repos/v2ray/v2ray-core/releases/latest"

    CURRENT_VERSION=$(v2ray --version | grep 'V2Ray' | cut -d' ' -f2)
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        # bash <(curl -L -s https://install.direct/go.sh)
        DOWNLOAD_URL=https://github.com/v2ray/v2ray-core/releases/download/v${REMOTE_VERSION}/v2ray-${ostype}-${VDIS}.zip
        curl -SL $DOWNLOAD_URL -o v2ray-core.zip && \
        bash <(curl -L -s https://install.direct/go.sh) --local ./v2ray-core.zip && \
        rm -f ./v2ray-core.zip && \
        ln -sv /usr/bin/v2ray/v2ray /usr/local/bin/v2ray || true
    fi
fi


if [[ -x "$(command -v conda)" ]]; then
    colorEcho ${BLUE} "Updating conda..."
    conda update -y conda

    colorEcho ${BLUE} "Updating all installed conda packages..."
    conda update -y --all
fi


if [[ -n "$ZSH" ]]; then
    if [[ -s "$HOME/zsh_update.sh" ]]; then
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


if [[ -s "$HOME/nvm_node_update.sh" ]]; then
    source "$HOME/nvm_node_update.sh"
fi


colorEcho ${GREEN} "Upgarde all packages done!"
