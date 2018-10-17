#!/bin/zsh

#######color code########
RED="31m"      # Error message
GREEN="32m"    # Success message
YELLOW="33m"   # Warning message
BLUE="36m"     # Info message

colorEcho() {
    COLOR=$1
    echo -e "\033[${COLOR}${@:2}\033[0m"
}

if [[ ! -x "$(command -v yarn)" ]]; then
    colorEcho ${RED} "yarn is not installed! Please install yarn first!"
    exit 0
fi

# yarn config
yarn config set emoji true

# if [[ -x "$(command -v npm)" ]]; then
#     # Change npm registry to taobao
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

# Change yarn registry to taobao
# colorEcho ${BLUE} "Change yarn registry to taobao..."
# yarn config set registry https://registry.npm.taobao.org

# yarn config set disturl https://npm.taobao.org/dist # node-gyp
# yarn config set sass_binary_site https://npm.taobao.org/mirrors/node-sass # node-sass
# yarn config set electron_mirror https://npm.taobao.org/mirrors/electron/ # electron
# yarn config set puppeteer_download_host https://npm.taobao.org/mirrors # puppeteer
# yarn config set chromedriver_cdnurl https://npm.taobao.org/mirrors/chromedriver # chromedriver
# yarn config set operadriver_cdnurl https://npm.taobao.org/mirrors/operadriver # operadriver
# yarn config set phantomjs_cdnurl https://npm.taobao.org/mirrors/phantomjs # phantomjs
# yarn config set selenium_cdnurl https://npm.taobao.org/mirrors/selenium # selenium
# yarn config set node_inspector_cdnurl https://npm.taobao.org/mirrors/node-inspector # node-inspector

# Custom global packages install location
# `yarn global bin` will output the location where Yarn will install symlinks to your installed executables
# mkdir -p ~/.yarn && yarn config set prefix ~/.yarn

# Install global packages with binaries
colorEcho ${BLUE} "Installing es-checker eslint tslint jslint jshint standard..."
yarn global add es-checker eslint tslint jslint jshint standard

colorEcho ${BLUE} "Installing typescript..."
yarn global add typescript

colorEcho ${BLUE} "Installing angular/cli..."
yarn global add @angular/cli

colorEcho ${BLUE} "Installing parcel-bundler..."
yarn global add parcel-bundler

colorEcho ${BLUE} "Installing cordova ionic..."
yarn global add cordova ionic

colorEcho ${BLUE} "Installing electron..."
yarn global add electron

# Install global packages without binaries
# colorEcho ${BLUE} "Installing puppeteer..."
# yarn global add puppeteer

# colorEcho ${BLUE} "Installing jquery popper.js bootstrap..."
# yarn global add jquery popper.js bootstrap

# colorEcho ${BLUE} "Installing mdbootstrap..."
# yarn global add mdbootstrap

# colorEcho ${BLUE} "Installing echarts echarts-gl..."
# yarn global add echarts echarts-gl

# Clean yarn cache
# yarn cache clean --force
# yarn cache verify

# List Installed packages
colorEcho ${BLUE} "List Installed packages..."
yarn global list

colorEcho ${GREEN} "Install yarn package finished!"