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

# npm config
colorEcho ${BLUE} "Setting npm config..."
npm config set user 0
npm config set unsafe-perm true

# Change npm registry to taobao
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

# npm install -g nrm
# nrm use taobao

# Install custom packages
colorEcho ${BLUE} "Installing nrm npm-check es-checker eslint tslint jslint jshint standard..."
npm install -g nrm npm-check es-checker eslint tslint jslint jshint standard

colorEcho ${BLUE} "Installing typescript..."
npm install -g typescript

colorEcho ${BLUE} "Installing angular/cli..."
npm install -g @angular/cli

colorEcho ${BLUE} "Installing puppeteer..."
npm install -g puppeteer

colorEcho ${BLUE} "Installing jquery popper.js bootstrap..."
npm install -g jquery popper.js bootstrap

colorEcho ${BLUE} "Installing mdbootstrap..."
npm install -g mdbootstrap

colorEcho ${BLUE} "Installing echarts echarts-gl..."
npm install -g echarts echarts-gl

colorEcho ${BLUE} "Installing parcel-bundler..."
npm install -g parcel-bundler

colorEcho ${BLUE} "Installing cordova ionic..."
npm install -g cordova ionic

colorEcho ${BLUE} "Installing electron..."
npm install -g electron

# Clean npm cache
# npm cache clean --force
# npm cache verify

# List Installed packages
colorEcho ${BLUE} "List Installed packages..."
npm list --depth=0 -g

colorEcho ${GREEN} "Install npm package finished!"
