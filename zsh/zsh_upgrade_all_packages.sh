#!/usr/bin/env zsh

trap 'rm -rf "$WORKDIR"' EXIT

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

[[ -n "${INSTALLER_CHECK_CURL_OPTION}" ]] && curl_check_opts=(`echo ${INSTALLER_CHECK_CURL_OPTION}`) || curl_check_opts=(-fsL)
[[ -n "${INSTALLER_DOWNLOAD_CURL_OPTION}" ]] && curl_download_opts=(`echo ${INSTALLER_DOWNLOAD_CURL_OPTION}`) || curl_download_opts=(-fSL)

## Setting by pass gfw proxy
[[ -s "${MY_SHELL_SCRIPTS}/cross/cross_gfw_config.sh" ]] && source "${MY_SHELL_SCRIPTS}/cross/cross_gfw_config.sh"

# WSL2: map host ip to localhost
if [[ "$(uname -r)" =~ "microsoft" ]]; then
    [[ -s "$HOME/terminal-custom/wsl/wsl2-map-win-localhost.sh" ]] && \
        source "$HOME/terminal-custom/wsl/wsl2-map-win-localhost.sh"
fi

# OS Type: darwin, windows, linux, bsd, solaris
# Arch(spruce_type): amd64, 386, arm, arm64, mips64le, mips64, mipsle, mips, s390x, ppc64le, ppc64, riscv64
# VDIS: 64, 32, arm, arm64, mips64le, mips64, mipsle, mips, s390x, ppc64le, ppc64, riscv64
[[ -z "${OS_INFO_TYPE}" ]] && get_os_type
[[ -z "${OS_INFO_ARCH}" ]] && get_arch
[[ -z "${OS_INFO_VDIS}" ]] && get_sysArch

# [[ -s "${MY_SHELL_SCRIPTS}/installer/pacapt_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/pacapt_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/pacaptr_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/pacaptr_installer.sh"


colorEcho "${BLUE}Updating ${FUCHSIA}system packages${BLUE}..."
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


if [[ -x "$(command -v docker)" ]]; then
    [[ -s "${MY_SHELL_SCRIPTS}/installer/docker_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/docker_installer.sh"
fi


if [[ -x "$(command -v php)" && -x "$(command -v composer)" ]]; then
    colorEcho "${BLUE}Updating ${FUCHSIA}composer & composer global packages${BLUE}..."
    composer selfupdate && composer g update
fi


# https://github.com/zyedidia/micro
if [[ -x "$(command -v micro)" ]]; then
    colorEcho "${BLUE}Checking latest version for ${FUCHSIA}Micro editor${BLUE}..."

    CHECK_URL="https://api.github.com/repos/zyedidia/micro/releases/latest"

    CURRENT_VERSION=$(micro -version | grep Version | cut -d',' -f2)
    REMOTE_VERSION=$(curl "${curl_check_opts[@]}" "${CHECK_URL}" | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        colorEcho "${BLUE}  Installing ${FUCHSIA}micro ${YELLOW}${REMOTE_VERSION}${BLUE}..."
        curl https://getmic.ro | bash && sudo mv micro "/usr/local/bin"
    fi
fi


# if [[ -x "$(command -v pear)" ]]; then
#     colorEcho "${BLUE}Updating ${FUCHSIA}pear${BLUE}..."
#     pear upgrade --force PEAR && pear upgrade -all
#     # pecl update-channels && rm -rf /tmp/pear $HOME/.pearrc
# fi


# if [[ -x "$(command -v pip)" ]]; then
#     colorEcho "${BLUE}Updating ${FUCHSIA}pip packages${BLUE}..."
#     sudo pip list -o | grep -E -v '^-|^Package' | cut -d' ' -f1 | sudo xargs -n1 pip install -U
# fi


# if [[ "$(command -v fuck)" && -x "$(command -v pip)" ]]; then
#     colorEcho "${BLUE}Updating ${FUCHSIA}thefuck${BLUE}..."
#     sudo pip install thefuck --upgrade
# fi


if [[ -d "$HOME/.jabba" ]]; then
    colorEcho "${BLUE}Checking latest version for ${FUCHSIA}jabba${BLUE}..."
    if type 'jabba' 2>/dev/null | grep -q 'function'; then
        :
    else
        [[ -s "$HOME/.jabba/jabba.sh" ]] && source "$HOME/.jabba/jabba.sh"
    fi

    CHECK_URL="https://api.github.com/repos/shyiko/jabba/releases/latest"

    CURRENT_VERSION=$(jabba --version | cut -d' ' -f2)
    REMOTE_VERSION=$(curl "${curl_check_opts[@]}" "${CHECK_URL}" | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        colorEcho "${BLUE}  Installing ${FUCHSIA}jabba ${YELLOW}${REMOTE_VERSION}${BLUE}..."
        curl -fsSL https://github.com/shyiko/jabba/raw/master/install.sh | bash && \
            . ~/.jabba/jabba.sh && \
            sed -i "/jabba.sh/d" ~/.zshrc && \
            cd $HOME
    fi
fi


if [[ -d "$HOME/.sdkman" ]]; then
    colorEcho "${BLUE}Updating ${FUCHSIA}sdk ${BLUE}using sdkman..."
    if type 'sdk' 2>/dev/null | grep -q 'function'; then
        :
    else
        export SDKMAN_DIR="$HOME/.sdkman"
        [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
    fi

    sdk selfupdate && sdk update && printf "Y\n" | sdk upgrade
fi


# Install & Update
# [[ -s "${MY_SHELL_SCRIPTS}/installer/proxychains_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/proxychains_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/nano_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/nano_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/bat_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/bat_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/git-delta_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/git-delta_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/croc_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/croc_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/duf_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/duf_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/dust_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/dust_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/exa_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/exa_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/fd_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/fd_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/as-tree_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/as-tree_installer.sh"


# Update only(manual install)
IS_UPDATE_ONLY="yes"

[[ -s "${MY_SHELL_SCRIPTS}/installer/asdf_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/asdf_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/lsd_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/lsd_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/nnn_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/nnn_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/safe-rm_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/safe-rm_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/starship_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/starship_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/cgit_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/cgit_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/git-lfs_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/git-lfs_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/onefetch_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/onefetch_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/re-txt_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/re-txt_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/navi_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/navi_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/pup_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/pup_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/gvm_go_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/gvm_go_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/frp_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/frp_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/viu_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/frp_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/goproxy_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/goproxy_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/inlets_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/viu_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/cross/xray_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/cross/xray_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/cross/v2ray_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/cross/v2ray_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/cross/trojan_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/cross/trojan_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/cross/clash_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/cross/clash_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/cross/subconverter_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/cross/subconverter_installer.sh"

unset IS_UPDATE_ONLY


if [[ -x "$(command -v conda)" ]]; then
    # colorEcho "${BLUE}Updating ${FUCHSIA}conda${BLUE}..."
    # conda update -y conda

    colorEcho "${BLUE}Updating ${FUCHSIA}all installed conda packages${BLUE}..."
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
        colorEcho "${BLUE}Updating ${FUCHSIA}oh-my-zsh & custom stuff${BLUE}..."
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
colorEcho "${GREEN}Upgarde all packages done!"
