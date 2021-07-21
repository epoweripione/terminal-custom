#!/usr/bin/env bash

trap 'rm -rf "$WORKDIR"' EXIT

[[ -z "$WORKDIR" ]] && WORKDIR="$(mktemp -d)"
[[ -z "$CURRENT_DIR" ]] && CURRENT_DIR=$(pwd)

# Load custom functions
if type 'colorEcho' 2>/dev/null | grep -q 'function'; then
    :
else
    if [[ -s "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/custom_functions.sh" ]]; then
        source "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/custom_functions.sh"
    else
        echo "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/custom_functions.sh not exist!"
        exit 0
    fi
fi

[[ -n "${INSTALLER_CHECK_CURL_OPTION}" ]] && curl_check_opts=(`echo ${INSTALLER_CHECK_CURL_OPTION}`) || curl_check_opts=(-fsL)
[[ -n "${INSTALLER_DOWNLOAD_CURL_OPTION}" ]] && curl_download_opts=(`echo ${INSTALLER_DOWNLOAD_CURL_OPTION}`) || curl_download_opts=(-fSL)

[[ ! "$(command -v asdf)" ]] && colorEcho "${FUCHSIA}$asdf${RED} is not installed!" && exit 0

asdf plugin add neovim
asdf install neovim stable
asdf global neovim stable

# alias update-nvim-stable='asdf uninstall neovim stable && asdf install neovim stable'


if [[ -x "$(command -v nvim)" ]]; then
    ## vim-plug: Minimalist Vim Plugin Manager
    # sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    #     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'


    # Install NeoVim config and Plugin config
    NEOVIM_CUSTOM="$HOME/.config/nvim"
    NEOVIM_BACKUP="$HOME/.local/share/nvim/backup"
    mkdir -p ${NEOVIM_CUSTOM}
    mkdir -p ${NEOVIM_BACKUP}

    wget "https://raw.githubusercontent.com/mkinoshi/dotfiles/master/nvim/init.vim" -O init.vim && \
        wget "https://raw.githubusercontent.com/mkinoshi/dotfiles/master/nvim/plugins.vim" -O plugins.vim && \
        mv init.vim "${NEOVIM_CUSTOM}" && \
        mv plugins.vim "${NEOVIM_CUSTOM}" && \
        sed -i '/^Plug.*coc\.nvim/ s/^/" /' "${NEOVIM_CUSTOM}/plugins.vim" && \
        sed -i '/^Plug.*new-denite/ s/^/" /' "${NEOVIM_CUSTOM}/plugins.vim" && \
        sed -i '/^"\s*Plug.*denite.nvim/ s/"\s*//' "${NEOVIM_CUSTOM}/plugins.vim" && \
        nvim +PlugInstall +qall # This script assumes that you are using vim-plug for plugin management 


    # Enable python3 support for NeoVim
    # sudo apt install -y python3-pip
    [[ -x "$(command -v pip)" ]] && pip install --user -U neovim
    [[ -x "$(command -v pip3)" ]] && pip3 install --user -U neovim
fi


cd "${CURRENT_DIR}"