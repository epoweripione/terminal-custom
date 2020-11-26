#!/usr/bin/env zsh

trap 'rm -r "$WORKDIR"' EXIT

[[ -z "$WORKDIR" ]] && WORKDIR="$(mktemp -d)"
[[ -z "$CURRENT_DIR" ]] && CURRENT_DIR=$(pwd)

[[ -z "$MY_SHELL_SCRIPTS" ]] && MY_SHELL_SCRIPTS="$HOME/terminal-custom"

# Load custom functions
if type 'colorEcho' 2>/dev/null | grep -q 'function'; then
    :
else
    if [[ -s "${MY_SHELL_SCRIPTS}/custom_functions.sh" ]]; then
        source "${MY_SHELL_SCRIPTS}/custom_functions.sh"
    else
        echo "${MY_SHELL_SCRIPTS}/custom_functions.sh not exist!"
        exit 0
    fi
fi

## Setting by pass gfw proxy
[[ -s "${MY_SHELL_SCRIPTS}/cross/cross_gfw_config.sh" ]] && source "${MY_SHELL_SCRIPTS}/cross/cross_gfw_config.sh"
CURL_SPECIAL_CONFIG=${CURL_SPECIAL_CONFIG:-"$HOME/.curl_socks5"}

# OS Type: darwin, windows, linux, bsd, solaris
# Arch(spruce_type): amd64, 386, arm, arm64, mips64le, mips64, mipsle, mips, s390x, ppc64le, ppc64, riscv64
# VDIS: 64, 32, arm, arm64, mips64le, mips64, mipsle, mips, s390x, ppc64le, ppc64, riscv64
[[ -z "$OS_INFO_TYPE" ]] && get_os_type
[[ -z "$OS_INFO_ARCH" ]] && get_arch
[[ -z "$OS_INFO_VDIS" ]] && get_sysArch

# [[ -s "${MY_SHELL_SCRIPTS}/installer/pacapt_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/pacapt_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/pacaptr_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/pacaptr_installer.sh"


colorEcho ${BLUE} "Updating system packages..."
if [[ -x "$(command -v pacman)" ]]; then
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
        DOWNLOAD_URL="https://github.com/docker/compose/releases/download/$REMOTE_VERSION/docker-compose-`uname -s`-`uname -m`"
        curl -SL --config ${CURL_SPECIAL_CONFIG} -o "${WORKDIR}/docker-compose" -C- $DOWNLOAD_URL && \
            sudo mv -f "${WORKDIR}/docker-compose" "/usr/local/bin/docker-compose" && \
            sudo chmod +x "/usr/local/bin/docker-compose"
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
        DOWNLOAD_URL="https://github.com/bcicen/ctop/releases/download/v$REMOTE_VERSION/ctop-${REMOTE_VERSION}-${DOWNLOAD_FILE_SUFFIX}"
        curl -SL --config ${CURL_SPECIAL_CONFIG} -o "${WORKDIR}/ctop" -C- $DOWNLOAD_URL && \
            sudo mv -f "${WORKDIR}/ctop" "/usr/local/bin/ctop" && \
            sudo chmod +x "/usr/local/bin/ctop"
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
        # curl -SL \
        #     https://raw.githubusercontent.com/snail007/goproxy/master/install_auto.sh \
        # | sudo bash
        DOWNLOAD_URL="https://github.com/snail007/goproxy/releases/download/v${REMOTE_VERSION}/proxy-${OS_INFO_TYPE}-${OS_INFO_ARCH}.tar.gz"
        curl -SL --config ${CURL_SPECIAL_CONFIG} -o proxy-linux-amd64.tar.gz -C- $DOWNLOAD_URL && \
            curl -SL "https://raw.githubusercontent.com/snail007/goproxy/master/install.sh" | sudo bash && \
            rm -f proxy-linux-amd64.tar.gz
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
        curl -SL "https://raw.githubusercontent.com/snail007/proxy_admin_free/master/install_auto.sh" | sudo bash
        echo ${REMOTE_VERSION} | sudo tee "/etc/gpa/.version" >/dev/null
    fi
fi


if [[ -x "$(command -v v2ray)" ]]; then
    if [[ -x "$(command -v v2ray-util)" ]]; then
        colorEcho ${BLUE} "Updating multi-v2ray..."
        # https://github.com/Jrohy/multi-v2ray
        v2ray update.sh >/dev/null && v2ray restart
    elif [[ $(systemctl is-enabled v2ray 2>/dev/null) ]]; then
        V2RAYCORE="yes"
    fi
elif [[ $(systemctl is-enabled v2ray 2>/dev/null) ]]; then
    V2RAYCORE="yes"
fi

if [[ -n "$V2RAYCORE" ]]; then
    colorEcho ${BLUE} "Updating v2ray-core..."
    # https://github.com/v2fly/fhs-install-v2ray
    CHECK_URL="https://api.github.com/repos/v2fly/v2ray-core/releases/latest"

    CURRENT_VERSION=$(v2ray -version | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        # https://github.com/v2fly/fhs-install-v2ray/wiki/Migrate-from-the-old-script-to-this
        if [[ -d "/usr/bin/v2ray/" ]]; then
            sudo systemctl disable v2ray.service --now
            sudo rm -rf /usr/bin/v2ray/ /etc/v2ray/
            sudo rm -f /etc/systemd/system/v2ray.service
            sudo rm -f /lib/systemd/system/v2ray.service
            sudo rm -f /etc/init.d/v2ray
        fi

        bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
        bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-dat-release.sh)
    fi
fi


if [[ -s "/srv/trojan/trojan" ]]; then
    colorEcho ${BLUE} "Updating trojan..."

    CHECK_URL="https://api.github.com/repos/trojan-gfw/trojan/releases/latest"

    CURRENT_VERSION=$(/srv/trojan/trojan --version 2>&1 | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        [[ $(systemctl is-enabled trojan 2>/dev/null) ]] && sudo systemctl stop trojan

        DOWNLOAD_URL="https://github.com/trojan-gfw/trojan/releases/download/v${REMOTE_VERSION}/trojan-${REMOTE_VERSION}-${OS_INFO_TYPE}-${OS_INFO_ARCH}.tar.xz"
        curl -SL -o "${WORKDIR}/trojan.tar.xz" -C- $DOWNLOAD_URL && \
            tar -JxPf "${WORKDIR}/trojan.tar.xz" -C "/srv/"

        if [[ ! -s "/etc/systemd/system/trojan.service" ]]; then
            sudo cp -f /srv/trojan/examples/trojan.service-example /etc/systemd/system/trojan.service
            sudo sed -i "s|ExecStart=.*|ExecStart=/srv/trojan/trojan -c /etc/trojan/trojan.json|" /etc/systemd/system/trojan.service
        fi

        if [[ -s "/etc/trojan/trojan.json" ]]; then
            # nohup /srv/trojan/trojan -c /etc/trojan/trojan.json >/dev/null 2>&1 & disown
            # sudo systemctl enable trojan && sudo systemctl start trojan
            [[ $(systemctl is-enabled trojan 2>/dev/null) ]] && sudo systemctl restart trojan
        else
            sudo mkdir -p "/etc/trojan" && \
                sudo cp -f "/srv/trojan/examples/server.json-example" "/etc/trojan/trojan.json"
        fi
    fi
fi


# [[ -s "${MY_SHELL_SCRIPTS}/installer/proxychains_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/proxychains_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/frp_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/frp_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/nano_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/nano_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/bat_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/bat_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/croc_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/croc_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/duf_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/duf_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/exa_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/exa_installer.sh"


if [[ -x "$(command -v conda)" ]]; then
    # colorEcho ${BLUE} "Updating conda..."
    # conda update -y conda

    colorEcho ${BLUE} "Updating all installed conda packages..."
    conda update -y --all
fi


if [[ -d "$HOME/.nvm" && -s "${MY_SHELL_SCRIPTS}/nodejs/nvm_node_updater.sh" ]]; then
    source "${MY_SHELL_SCRIPTS}/nodejs/nvm_node_updater.sh"
fi


if [[ -d "$HOME/.nvs" && -s "${MY_SHELL_SCRIPTS}/nodejs/nvs_node_updater.sh" ]]; then
    source "${MY_SHELL_SCRIPTS}/nodejs/nvs_node_updater.sh"
fi


if [[ -n "$ZSH" ]]; then
    if [[ -s "${MY_SHELL_SCRIPTS}/zsh/zsh_update.sh" ]]; then
        colorEcho ${BLUE} "Updating oh-my-zsh & custom stuff..."
        source "${MY_SHELL_SCRIPTS}/zsh/zsh_update.sh"
        # -i : Force shell to be interactive
        # Then, if the shell is interactive, 
        # commands are read from /etc/zshrc 
        # and then $ZDOTDIR/.zshrc (this is usually your $HOME/.zshrc)
        # -c : Run a command in this shell
        # zsh -i -c "${MY_SHELL_SCRIPTS}/zsh/zsh_update.sh"
    fi
fi


cd "${CURRENT_DIR}"
colorEcho ${GREEN} "Upgarde all packages done!"
