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
    if [[ -s "$HOME/nvs_node_installer.sh" ]]; then
        source "$HOME/nvs_node_installer.sh"
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
npm install -g hexo-cli

# init
hexo init hexo-blog

cd ./hexo-blog

# install npm packages
npm install

# categories & tags
# hexo new page categories && hexo new page tags


# hexo theme NexT
# NexT https://theme-next.iissnan.com/getting-started.html
git clone https://github.com/theme-next/hexo-theme-next themes/next && \
    git clone https://github.com/theme-next/theme-next-pace themes/next/source/lib/pace && \
    git clone https://github.com/theme-next/theme-next-pdf themes/next/source/lib/pdf && \
    git clone https://github.com/theme-next/theme-next-canvas-nest themes/next/source/lib/canvas-nest && \
    git clone https://github.com/theme-next/theme-next-three themes/next/source/lib/three && \
    git clone https://github.com/theme-next/theme-next-canvas-ribbon themes/next/source/lib/canvas-ribbon

# other hexo plugins
npm install hexo-tag-aplayer --save && \
    npm install hexo-tag-dplayer --save && \
    npm install hexo-filter-flowchart --save && \
    : && \
    npm uninstall hexo-renderer-marked --save && \
    npm install hexo-renderer-markdown-it --save

# Awesome NexT
# https://github.com/theme-next/awesome-next
npm install hexo-filter-emoji --save && \
    npm install hexo-filter-optimize --save && \
    npm install hexo-filter-mathjax --save && \
    npm install hexo-symbols-count-time --save && \
    : && \
    npm install hexo-generator-feed --save && \
    # npm install hexo-generator-sitemap --save && \
    npm install hexo-generator-seo-friendly-sitemap --save && \
    npm install hexo-generator-searchdb --save && \
    : && \
    npm uninstall hexo-generator-index --save && \
    # npm install hexo-generator-index-pin-top --save && \
    npm install hexo-generator-indexed --save && \
    # : && \
    # npm install hexo-renderer-njks --save && \
    : && \
    npm install theme-next/theme-next-calendar --save && \
    npm install theme-next/hexo-next-coauthor --save && \
    npm install theme-next/hexo-next-utteranc --save && \
    npm install theme-next/hexo-next-share --save && \
    npm install theme-next/hexo-next-title --save && \
    # npm install hexo-theme-next-anchor --save && \
    # npm install hexo-cake-moon-menu --save && \
    npm install 1v9/hexo-next-nightmode --save


# serve
# hexo serve
colorEcho {$BLUE} "Done!"
colorEcho {$BLUE} "Use `hexo serve` to run hexo!"
