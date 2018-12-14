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

if [[ ! "$(command -v node)" ]]; then
    if [[ -s "$HOME/nvm_node_installer.sh" ]]; then
        source "$HOME/nvm_node_installer.sh"
    else
        colorEcho ${RED} "node is not installed! Please install node first!"
        exit 0
    fi
fi

# https://hexo.io/zh-cn/docs/index.html
# https://hexo.io/zh-cn/docs/server.html
# https://hexo.io/zh-cn/docs/writing.html
# https://hexo.io/zh-cn/docs/deployment.html
# https://hexo.io/zh-cn/docs/commands.html
npm install hexo-cli -g

# init
cd /srv
hexo init hexo-blog

cd /srv/hexo-blog

# themes
git clone https://github.com/theme-next/hexo-theme-next themes/next

# install npm packages
npm install

# serve
hexo server
