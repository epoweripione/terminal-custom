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

# Use proxy or mirror when some sites were blocked or low speed
set_proxy_mirrors_env


if [[ ! -x "$(command -v npm)" ]]; then
    colorEcho "${RED}npm is not installed! Please install node & npm first!"
    exit 0
fi

# # npm config
# colorEcho "${BLUE}Setting npm config.."
# npm config set user 0
# npm config set unsafe-perm true

# # npm global
# mkdir -p $HOME/.npm-global
# npm config set prefix $HOME/.npm-global
# export PATH=$PATH:$HOME/.npm-global/bin

# # Change npm registry to taobao
# if [[ -z "$NPM_INSTALLER_NOT_USE_MIRROR" ]]; then
#     colorEcho "${BLUE}Change npm registry to ${FUCHSIA}taobao${BLUE}..."
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
colorEcho "${BLUE}Installing ${FUCHSIA}cnpm${BLUE}..."
npm install -g cnpm

colorEcho "${BLUE}Installing ${FUCHSIA}npm-check es-checker eslint tslint jslint jshint standard${BLUE}..."
npm install -g npm-check es-checker eslint tslint jslint jshint standard

colorEcho "${BLUE}Installing ${FUCHSIA}babel webpack traceur${BLUE}..."
npm install -g @babel/core @babel/cli webpack webpack-cli traceur

colorEcho "${BLUE}Installing ${FUCHSIA}typescript${BLUE}..."
npm install -g typescript

colorEcho "${BLUE}Installing ${FUCHSIA}angular/cli${BLUE}..."
npm install -g @angular/cli

colorEcho "${BLUE}Installing ${FUCHSIA}vue/cli${BLUE}..."
npm install -g @vue/cli

colorEcho "${BLUE}Installing ${FUCHSIA}quasar/cli${BLUE}..."
npm install -g @quasar/cli

colorEcho "${BLUE}Installing ${FUCHSIA}storybook/cli${BLUE}..."
npm install -g react react-dom
npm install -g @storybook/cli

colorEcho "${BLUE}Installing ${FUCHSIA}parcel-bundler${BLUE}..."
npm install -g parcel-bundler

colorEcho "${BLUE}Installing ${FUCHSIA}cordova ionic${BLUE}..."
npm install -g cordova ionic

colorEcho "${BLUE}Installing ${FUCHSIA}electron${BLUE}..."
npm install -g electron

# https://ice.work/iceworks
colorEcho "${BLUE}Installing ${FUCHSIA}iceworks${BLUE}..."
npm install -g iceworks

colorEcho "${BLUE}Installing ${FUCHSIA}express-generator${BLUE}..."
npm install -g express-generator

colorEcho "${BLUE}Installing ${FUCHSIA}tldr${BLUE}..."
npm install -g tldr

# https://github.com/cnwhy/lib-qqwry/
colorEcho "${BLUE}Installing ${FUCHSIA}lib-qqwry${BLUE}..."
npm install -g lib-qqwry

# colorEcho "${BLUE}Installing ${FUCHSIA}arch-wiki-man${BLUE}..."
# # arch-wiki-man
# ## https://github.com/greg-js/arch-wiki-man
# npm install -g arch-wiki-man

# Install global packages without binaries
colorEcho "${BLUE}Installing ${FUCHSIA}puppeteer${BLUE}..."
npm install -g puppeteer

# colorEcho "${BLUE}Installing ${FUCHSIA}jquery popper.js bootstrap${BLUE}..."
# npm install -g jquery popper.js bootstrap

# colorEcho "${BLUE}Installing ${FUCHSIA}mdbootstrap${BLUE}..."
# npm install -g mdbootstrap

# colorEcho "${BLUE}Installing ${FUCHSIA}echarts echarts-gl${BLUE}..."
# npm install -g echarts echarts-gl

# Clean npm cache
# npm cache clean --force
# npm cache verify

# List Installed packages
colorEcho "${BLUE}List Installed packages..."
npm list --depth=0 -g

colorEcho "${GREEN}Install npm package finished!"
