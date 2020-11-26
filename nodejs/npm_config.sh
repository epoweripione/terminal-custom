#!/usr/bin/env zsh

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

# Set proxy or mirrors env in china
set_proxy_mirrors_env


if [[ ! -x "$(command -v npm)" ]]; then
    colorEcho ${RED} "npm is not installed! Please install node & npm first!"
    exit 0
fi

# npm config
colorEcho ${BLUE} "Setting npm config..."
npm config set user 0
npm config set unsafe-perm true

# npm global
mkdir -p $HOME/.npm-global
npm config set prefix $HOME/.npm-global
export PATH=$PATH:$HOME/.npm-global/bin

# Change npm registry to taobao
if [[ -z "$NPM_INSTALLER_NOT_USE_MIRROR" ]]; then
    colorEcho ${BLUE} "Change npm registry to taobao..."
    npm set registry https://registry.npm.taobao.org

    npm set disturl https://npm.taobao.org/dist # node-gyp
    npm set sass_binary_site https://npm.taobao.org/mirrors/node-sass # node-sass
    npm set electron_mirror https://npm.taobao.org/mirrors/electron/ # electron
    npm set puppeteer_download_host https://npm.taobao.org/mirrors # puppeteer
    npm set chromedriver_cdnurl https://npm.taobao.org/mirrors/chromedriver # chromedriver
    npm set operadriver_cdnurl https://npm.taobao.org/mirrors/operadriver # operadriver
    npm set phantomjs_cdnurl https://npm.taobao.org/mirrors/phantomjs # phantomjs
    npm set selenium_cdnurl https://npm.taobao.org/mirrors/selenium # selenium
    npm set node_inspector_cdnurl https://npm.taobao.org/mirrors/node-inspector # node-inspector
fi

## show all defaults
# npm config ls -l
npm config list

colorEcho ${GREEN} "Done!"
