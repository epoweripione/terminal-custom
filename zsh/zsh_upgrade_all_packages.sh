#!/bin/zsh

CURRENT_DIR=$(pwd)

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

# Github & Gitlab proxy
CURL_SOCKS5_CONFIG="$HOME/.curl_socks5"
if [[ -z "$GITHUB_NOT_USE_PROXY" ]]; then
    [[ -s "$HOME/cross_gfw_config.sh" ]] && bash "$HOME/cross_gfw_config.sh"

    set_git_socks5_proxy github.com,gitlab.com 127.0.0.1:55880

    [[ -n "$GIT_SOCKS5_PROXY_URL" ]] && \
        echo "--socks5-hostname \"${GIT_SOCKS5_PROXY_URL}\"" > ${CURL_SOCKS5_CONFIG} || \
        cat /dev/null > ${CURL_SOCKS5_CONFIG}
else
    set_git_socks5_proxy github.com,gitlab.com
    cat /dev/null > ${CURL_SOCKS5_CONFIG}
fi

# ostype: darwin, windows, linux, bsd, solaris
# spruce_type: amd64, 386
# VDIS: 64, 32, arm, arm64, mips64le, mips64, mipsle, mips, s390x, ppc64le, ppc64
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
        sudo curl -SL -o /tmp/pacapt https://github.com/icy/pacapt/raw/ng/pacapt && \
            sudo mv -f /tmp/pacapt /usr/bin/pacapt && \
            sudo chmod 755 /usr/bin/pacapt && \
            sudo ln -sv /usr/bin/pacapt /usr/bin/pacman || true
    fi
else
    colorEcho ${BLUE} "Installing pacapt - An Arch's pacman-like package manager for some Unices..."
    sudo curl -SL -o /tmp/pacapt https://github.com/icy/pacapt/raw/ng/pacapt && \
        sudo mv -f /tmp/pacapt /usr/bin/pacapt && \
        sudo chmod 755 /usr/bin/pacapt && \
        sudo ln -sv /usr/bin/pacapt /usr/bin/pacman || true
fi


colorEcho ${BLUE} "Updating system packages..."
if [[ -x "$(command -v pacapt)" || -x "$(command -v pacman)" ]]; then
    if [[ $UID -ne 0 && "$(command -v yay)" ]]; then
        yay --noconfirm -Syu
    else
        sudo pacman --noconfirm -Syu
    fi
else
    if check_release_package_manager packageManager yum; then
        sudo yum update -y
    elif check_release_package_manager packageManager apt; then
        sudo apt update && sudo apt upgrade -y
    elif check_release_package_manager packageManager pacman; then
        if [[ $UID -ne 0 && "$(command -v yay)" ]]; then
            yay --noconfirm -Syu
        else
            sudo pacman --noconfirm -Syu
        fi
    fi
fi


if [[ -x "$(command -v docker-compose)" ]]; then
    colorEcho ${BLUE} "Updating docker-compose..."

    CHECK_URL="https://api.github.com/repos/docker/compose/releases/latest"

    CURRENT_VERSION=$(docker-compose -v | cut -d',' -f1 | cut -d' ' -f3)
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        DOWNLOAD_URL=https://github.com/docker/compose/releases/download/$REMOTE_VERSION/docker-compose-`uname -s`-`uname -m`
        curl -SL --config ${CURL_SOCKS5_CONFIG} -o /tmp/docker-compose -C- $DOWNLOAD_URL && \
            sudo mv -f /tmp/docker-compose /usr/local/bin/docker-compose && \
            sudo chmod +x /usr/local/bin/docker-compose
    fi
fi


if [[ -x "$(command -v ctop)" ]]; then
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
        curl -SL --config ${CURL_SOCKS5_CONFIG} -o /tmp/ctop -C- $DOWNLOAD_URL && \
            sudo mv -f /tmp/ctop /usr/local/bin/ctop && \
            sudo chmod +x /usr/local/bin/ctop
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
            REMOTE_VERSION=$(proxychains4 curl -s https://golang.org/dl/ \
                            | grep -Eo -m1 'go([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
        else
            REMOTE_VERSION=$(curl -s https://golang.org/dl/ \
                            | grep -Eo -m1 'go([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
        fi
        # REMOTE_VERSION=${REMOTE_VERSION%.}

        if [[ -n "$REMOTE_VERSION" ]] && [[ ! "$(gvm list | grep "$REMOTE_VERSION")" ]]; then
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

        # GOBIN
        if [[ -z "$GOBIN" && -n "$GOROOT" ]]; then
            export GOBIN=$GOROOT/bin
        fi

        # Go module proxy for china
        if [[ -z "$GVM_INSTALLER_NOT_USE_PROXY" && -x "$(command -v go)" ]]; then
            GO_VERSION=$(go version | cut -d' ' -f3)
            if version_ge $GO_VERSION 'go1.13'; then
                go env -w GOPROXY=https://goproxy.cn,direct
            else
                export GOPROXY=https://goproxy.cn
            fi
            # go env -w GOPROXY=https://proxy.golang.org,direct
        fi
    fi
fi


if [[ -x "$(command -v php)" && -x "$(command -v composer)" ]]; then
    colorEcho ${BLUE} "Updating composer & composer global packages..."
    composer selfupdate && composer g update
fi


if [[ -x "$(command -v micro)" ]]; then
    colorEcho ${BLUE} "Updating Micro editor..."

    CHECK_URL="https://api.github.com/repos/zyedidia/micro/releases/latest"

    CURRENT_VERSION=$(micro -version | grep Version | cut -d',' -f2)
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        cd /usr/local/bin && curl https://getmic.ro | sudo bash && cd $HOME
    fi
fi


# if [[ -x "$(command -v pear)" ]]; then
#     colorEcho ${BLUE} "Updating pear..."
#     pear upgrade --force PEAR && pear upgrade -all
#     # pecl update-channels && rm -rf /tmp/pear $HOME/.pearrc
# fi


# if [[ -x "$(command -v pip)" ]]; then
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

    # [[ -z "$SDKMAN_NOT_USE_PROXY" && -n "$GIT_SOCKS5_PROXY_URL" ]] && \
    #     set_proxy "socks5h://${GIT_SOCKS5_PROXY_URL}"
    sdk selfupdate && sdk update && printf "Y\n" | sdk upgrade
    # [[ -z "$SDKMAN_NOT_USE_PROXY" && -n "$GIT_SOCKS5_PROXY_URL" ]] && clear_proxy
fi


if [[ -d "/etc/proxy" && -x "$(command -v proxy)" ]]; then
    colorEcho ${BLUE} "Updating goproxy..."
    # https://github.com/snail007/goproxy

    CHECK_URL="https://api.github.com/repos/snail007/goproxy/releases/latest"

    CURRENT_VERSION=$(proxy --version 2>&1 | cut -d'_' -f2)
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        curl -SL https://raw.githubusercontent.com/snail007/goproxy/master/install_auto.sh | sudo bash
    fi
fi


if [[ -x "$(command -v proxy-admin)" ]]; then
    # https://github.com/snail007/proxy_admin_free
    colorEcho ${BLUE} "Updating ProxyAdmin..."

    if [[ -s "/etc/gpa/.version" ]]; then
        # CURRENT_VERSION=$(cat /etc/gpa/.version 2>&1)
        CURRENT_VERSION=$(head -n1 /etc/gpa/.version)
    else
        CURRENT_VERSION="v0.0"
    fi

    CHECK_URL="https://api.github.com/repos/snail007/proxy_admin_free/releases/latest"
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        curl -SL \
            https://raw.githubusercontent.com/snail007/proxy_admin_free/master/install_auto.sh \
        | sudo bash

        echo ${REMOTE_VERSION} | sudo tee /etc/gpa/.version >/dev/null
    fi
fi


if [[ -d "/srv/proxy-web" ]]; then
    # https://github.com/yincongcyincong/proxy-web
    colorEcho ${BLUE} "Updating proxy-web..."

    if [[ -s "/srv/proxy-web/.version" ]]; then
        # CURRENT_VERSION=$(cat /srv/proxy-web/.version 2>&1)
        CURRENT_VERSION=$(head -n1 /srv/proxy-web/.version)
    else
        CURRENT_VERSION="v0.0"
    fi

    CHECK_URL="https://api.github.com/repos/yincongcyincong/proxy-web/releases/latest"
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4)

    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        if pgrep -f "proxy-web" 2>&1; then
            pkill -f "proxy-web"
        fi

        DOWNLOAD_URL=https://github.com/yincongcyincong/proxy-web/releases/download/${REMOTE_VERSION}/proxy-web-${ostype}-${spruce_type}.tar.gz
        curl -SL --config ${CURL_SOCKS5_CONFIG} -o proxy-web.tar.gz -C- $DOWNLOAD_URL && \
            mkdir -p /srv/backup_proxy-web && \
            cp -f /srv/proxy-web/config/*.ini /srv/backup_proxy-web/ && \
            tar -zxPf proxy-web.tar.gz -C /srv/ && \
            rm -f proxy-web.tar.gz && \
            chmod +x /srv/proxy-web/proxy-web && \
            rm -f /srv/proxy-web/config/*.ini && \
            cp -f /srv/backup_proxy-web/*.ini /srv/proxy-web/config/ && \
            echo ${REMOTE_VERSION} > /srv/proxy-web/.version

        nohup /srv/proxy-web/proxy-web >/dev/null 2>&1 & disown
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
        curl -SL --config ${CURL_SOCKS5_CONFIG} -o frp.tar.gz -C- $DOWNLOAD_URL && \
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
    # if v2ray --version 2>&1 | grep -q 'multi-v2ray'; then
    if [[ -x "$(command -v v2ray-util)" ]]; then
        colorEcho ${BLUE} "Updating multi-v2ray..."
        # https://github.com/Jrohy/multi-v2ray
        v2ray update.sh >/dev/null && v2ray update && v2ray restart

        # CHECK_URL="https://api.github.com/repos/Jrohy/multi-v2ray/releases/latest"

        # CURRENT_VERSION=$(v2ray-util -v | grep 'v2ray_util' | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}')
        # # CURRENT_VERSION=$(v2ray-util -v | grep 'v2ray_util' | cut -d' ' -f2)
        # # # trim color code: \033[32m \033[0m
        # # CURRENT_VERSION=$(echo $CURRENT_VERSION | sed -e 's/'$(echo "\033")'//g' | awk -F'[' '{print $2}' | awk -F'm' '{print $2}')

        # REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
        # if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        #     source <(curl -sL https://git.io/fNgqx) -k
        # fi
    elif [[ $(systemctl is-enabled v2ray 2>/dev/null) ]]; then
        V2RAYCORE="yes"
    fi
elif [[ $(systemctl is-enabled v2ray 2>/dev/null) ]]; then
    V2RAYCORE="yes"
fi

if [[ -n "$V2RAYCORE" ]]; then
    colorEcho ${BLUE} "Updating v2ray-core..."
    # https://www.v2ray.com/chapter_00/install.html

    CHECK_URL="https://api.github.com/repos/v2ray/v2ray-core/releases/latest"

    CURRENT_VERSION=$(v2ray --version | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
    # CURRENT_VERSION=$(v2ray --version | grep 'V2Ray' | cut -d' ' -f2)
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        # bash <(curl -L -s https://install.direct/go.sh)
        DOWNLOAD_URL=https://github.com/v2ray/v2ray-core/releases/download/v${REMOTE_VERSION}/v2ray-${ostype}-${VDIS}.zip
        curl -SL --config ${CURL_SOCKS5_CONFIG} -o v2ray-core.zip -C- $DOWNLOAD_URL && \
            curl -sL https://install.direct/go.sh | sudo bash -s -- --local ./v2ray-core.zip && \
            rm -f ./v2ray-core.zip && \
            sudo ln -sv /usr/bin/v2ray/v2ray /usr/local/bin/v2ray || true
    fi
fi


# [[ -s "$HOME/proxychains_installer.sh" ]] && source "$HOME/proxychains_installer.sh"

[[ -s "$HOME/nano_installer.sh" ]] && source "$HOME/nano_installer.sh"

[[ -s "$HOME/bat_installer.sh" ]] && source "$HOME/bat_installer.sh"


if [[ -x "$(command -v conda)" ]]; then
    # colorEcho ${BLUE} "Updating conda..."
    # conda update -y conda

    colorEcho ${BLUE} "Updating all installed conda packages..."
    conda update -y --all
fi


if [[ -d "$HOME/.nvm" && -s "$HOME/nvm_node_update.sh" ]]; then
    source "$HOME/nvm_node_update.sh"
fi


if [[ -d "$HOME/.nvs" && -s "$HOME/nvs_node_update.sh" ]]; then
    source "$HOME/nvs_node_update.sh"
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


cd "${CURRENT_DIR}"
colorEcho ${GREEN} "Upgarde all packages done!"
