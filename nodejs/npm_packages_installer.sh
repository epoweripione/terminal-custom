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

# # npm config
# colorEcho ${BLUE} "Setting npm config..."
# npm config set user 0
# npm config set unsafe-perm true

# # npm global
# mkdir -p $HOME/.npm-global
# npm config set prefix $HOME/.npm-global
# export PATH=$PATH:$HOME/.npm-global/bin

# # Change npm registry to taobao
# if [[ -z "$NPM_INSTALLER_NOT_USE_MIRROR" ]]; then
#     colorEcho ${BLUE} "Change npm registry to taobao..."
#     npm set registry https://registry.npm.taobao.org

#     npm set disturl https://npm.taobao.org/dist # node-gyp
#     npm set sass_binary_site https://npm.taobao.org/mirrors/node-sass # node-sass
#     npm set electron_mirror https://npm.taobao.org/mirrors/electron/ # electron
#     npm set puppeteer_download_host https://npm.taobao.org/mirrors # puppeteer
#     npm set chromedriver_cdnurl https://npm.taobao.org/mirrors/chromedriver # chromedriver
#     npm set operadriver_cdnurl https://npm.taobao.org/mirrors/operadriver # operadriver
#     npm set phantomjs_cdnurl https://npm.taobao.org/mirrors/phantomjs # phantomjs
#     npm set selenium_cdnurl https://npm.taobao.org/mirrors/selenium # selenium
#     npm set node_inspector_cdnurl https://npm.taobao.org/mirrors/node-inspector # node-inspector
# fi

# npm install -g nrm
# nrm use taobao

# Install global packages with binaries
colorEcho ${BLUE} "Installing cnpm..."
npm install -g cnpm

colorEcho ${BLUE} "Installing npm-check es-checker eslint tslint jslint jshint standard..."
npm install -g npm-check es-checker eslint tslint jslint jshint standard

colorEcho ${BLUE} "Installing babel webpack traceur..."
npm install -g @babel/core @babel/cli webpack webpack-cli traceur

colorEcho ${BLUE} "Installing typescript..."
npm install -g typescript

colorEcho ${BLUE} "Installing angular/cli..."
npm install -g @angular/cli

colorEcho ${BLUE} "Installing vue/cli..."
npm install -g @vue/cli

colorEcho ${BLUE} "Installing quasar/cli..."
npm install -g @quasar/cli

colorEcho ${BLUE} "Installing storybook/cli..."
npm install -g react react-dom
npm install -g @storybook/cli

colorEcho ${BLUE} "Installing parcel-bundler..."
npm install -g parcel-bundler

colorEcho ${BLUE} "Installing cordova ionic..."
npm install -g cordova ionic

colorEcho ${BLUE} "Installing electron..."
npm install -g electron

# https://ice.work/iceworks
colorEcho ${BLUE} "Installing iceworks..."
npm install -g iceworks

colorEcho ${BLUE} "Installing express-generator..."
npm install -g express-generator

colorEcho ${BLUE} "Installing tldr..."
npm install -g tldr

# https://github.com/cnwhy/lib-qqwry/
colorEcho ${BLUE} "Installing lib-qqwry..."
npm install -g lib-qqwry

# colorEcho ${BLUE} "Installing arch-wiki-man..."
# # arch-wiki-man
# ## https://github.com/greg-js/arch-wiki-man
# npm install -g arch-wiki-man

# Install global packages without binaries
colorEcho ${BLUE} "Installing puppeteer..."
npm install -g puppeteer

# colorEcho ${BLUE} "Installing jquery popper.js bootstrap..."
# npm install -g jquery popper.js bootstrap

# colorEcho ${BLUE} "Installing mdbootstrap..."
# npm install -g mdbootstrap

# colorEcho ${BLUE} "Installing echarts echarts-gl..."
# npm install -g echarts echarts-gl

# Clean npm cache
# npm cache clean --force
# npm cache verify

# List Installed packages
colorEcho ${BLUE} "List Installed packages..."
npm list --depth=0 -g

colorEcho ${GREEN} "Install npm package finished!"
