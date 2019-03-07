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
npm install hexo-cli gulp -g

# init
cd /srv
hexo init hexo-blog

cd /srv/hexo-blog

# install npm packages
npm install

# categories & tags
hexo new page categories
hexo new page tags


# ref http://shaoyance.com/2018/01/26/Hexo%E5%8D%9A%E5%AE%A2Next%E4%B8%BB%E9%A2%98%E4%BC%98%E5%8C%96%E6%80%BB%E7%BB%93/
# plugins
# RSS
npm install hexo-generator-feed --save
# 本地搜索
npm install hexo-generator-searchdb --save
# 生成 sitemap.xml，利于 SEO
npm install hexo-generator-sitemap --save
# 字数统计、阅读时长
npm install hexo-symbols-count-time --save
# Github Emojis 支持 https://github.com/crimx/hexo-filter-github-emojis
npm install hexo-filter-github-emojis --save
# 音乐播放插件，支持歌词 https://github.com/MoePlayer/hexo-tag-aplayer
npm install hexo-tag-aplayer --save
# 视频播放插件，支持弹幕 https://github.com/MoePlayer/hexo-tag-dplayer
npm install hexo-tag-dplayer --save
# 注脚 https://github.com/LouisBarranqueiro/hexo-footnotes
npm install hexo-footnotes --save
# hexo-filter-flowchart https://github.com/bubkoo/hexo-filter-flowchart
npm install hexo-filter-flowchart --save
# 支持文章置顶 https://github.com/netcan/hexo-generator-index-pin-top
npm uninstall hexo-generator-index --save
npm install hexo-generator-index-pin-top --save
# 压缩代码
npm install gulp gulp-htmlclean gulp-htmlmin gulp-minify-css --save


# # Hexo-filter-cleanup https://github.com/mamboer/hexo-filter-cleanup
# npm install hexo-filter-cleanup --save
# # Hexo-img-optimization https://github.com/vkuznecovas/hexo-img-optimization
# npm install hexo-img-optimization --save

# # 顶部进度条 http://github.hubspot.com/pace/
# npm install theme-next-pace --save
# # 图片浏览
# npm install theme-next-fancybox3 --save
# # leancloud 访问计数
# npm install leancloud-visitors --save


# themes
# NexT https://theme-next.org/
git clone https://github.com/theme-next/hexo-theme-next themes/next

# theme plugins
git clone https://github.com/theme-next/theme-next-fancybox3 themes/next/source/lib/fancybox && \
    git clone https://github.com/theme-next/theme-next-fastclick themes/next/source/lib/fastclick && \
    git clone https://github.com/theme-next/theme-next-jquery-lazyload themes/next/source/lib/jquery_lazyload && \
    git clone https://github.com/theme-next/theme-next-pace themes/next/source/lib/pace && \
    git clone https://github.com/theme-next/theme-next-pdf themes/next/source/lib/pdf && \
    git clone https://github.com/theme-next/theme-next-han themes/next/source/lib/Han && \
    git clone https://github.com/theme-next/theme-next-pangu themes/next/source/lib/pangu && \
    git clone https://github.com/theme-next/theme-next-needmoreshare2 themes/next/source/lib/needsharebutton && \
    git clone https://github.com/theme-next/theme-next-bookmark themes/next/source/lib/bookmark && \
    git clone https://github.com/theme-next/theme-next-canvas-nest themes/next/source/lib/canvas-nest && \
    git clone https://github.com/theme-next/theme-next-three themes/next/source/lib/three && \
    git clone https://github.com/theme-next/theme-next-canvas-ribbon themes/next/source/lib/canvas-ribbon


# 评论系统
# NexT 6 已经集成这个功能了，可以使用和访问量同一个应用。
# 1 在云端的 leancloud https://leancloud.cn/ 应用中创建一个名为 Comment 的类，使用默认的 ACL 权限设置。
# 2 在主题配置文件中设置 app_id 和 app_key 即可。
# valine:
#   enable: true
#   appid:   # your leancloud application appid
#   appkey:  # your leancloud application appkey
#   notify: false # mail notifier , https://github.com/xCss/Valine/wiki
#   verify: false # Verification code
#   placeholder: Just go go # comment box placeholder
#   avatar: mm # gravatar style
#   guest_info: nick,mail # custom comment header
#   pageSize: 10 # pagination size


# # custom theme next
# # use custom favicon
# sed -i '/favicon:/s/^/#/' themes/next/_config.yml && \ 
#     sed -i '/  small:/s/^/#/' themes/next/_config.yml && \
#     sed -i '/  medium:/s/^/#/' themes/next/_config.yml && \
#     sed -i '/  apple_touch_icon:/s/^/#/' themes/next/_config.yml && \
#     sed -i '/  safari_pinned_tab:/s/^/#/' themes/next/_config.yml

# # use Mist Scheme
# sed -i '/scheme: Muse/s/^/#/' themes/next/_config.yml && \
#     sed -i '/#scheme: Pisces/s/^#//' themes/next/_config.yml

# serve
hexo server
