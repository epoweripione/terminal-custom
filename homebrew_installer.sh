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

# Set proxy or mirrors env in china
set_proxy_mirrors_env

# https://brew.sh/index_zh-cn
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

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
