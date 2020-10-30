#!/bin/bash

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

[[ -z "$ostype" ]] && get_os_type && get_arch && get_sysArch

# Set proxy or mirrors env in china
set_proxy_mirrors_env

# https://brew.sh/index_zh-cn
colorEcho ${BLUE} "Installing homebrew..."

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# https://docs.brew.sh/Homebrew-on-Linux
if [[ "$ostype" == "linux" && -s "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    echo 'eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >> "$HOME/.zprofile"
    # eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
fi

## offical
# cd "$(brew --repo)"
# git remote set-url origin https://github.com/Homebrew/brew.git

# cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
# git remote set-url origin https://github.com/Homebrew/homebrew-core

# cd "$(brew --repo)/Library/Taps/homebrew/homebrew-cask"
# git remote set-url origin https://github.com/Homebrew/homebrew-cask

## mirrors
if [[ -z "$BREW_NOT_USE_PROXY" ]]; then
    cd "$(brew --repo)" && \
        git remote set-url origin https://mirrors.ustc.edu.cn/brew.git

    cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core" && \
        git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-core.git

    cd "$(brew --repo)/Library/Taps/homebrew/homebrew-cask" && \
        git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-cask.git
fi

## Bottles (Binary Packages)
## https://docs.brew.sh/Bottles
# if [[ ! $(grep "HOMEBREW_BOTTLE_DOMAIN" ~/.zshrc) ]]; then
#     echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.zshrc
#     # source ~/.zshrc
# fi
