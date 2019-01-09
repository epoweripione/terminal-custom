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


# 1.Install WSL (Windows Subsystem for Linux)
## https://docs.microsoft.com/zh-cn/windows/wsl/install-win10

# 2.Install Linux Distribution
## Install **Debian** from **Microsoft Store**


# 3.How to change dash to bash
# update-alternatives --install /bin/sh sh /bin/bash 100
# update-alternatives --install /bin/sh sh /bin/dash 200
# update-alternatives --config sh


if [[ $(uname -r) =~ "Microsoft" ]]; then
    if [[ $UID -ne 0 ]]; then
        colorEcho ${RED} "Please run this script as root user!"
        exit 0
    fi
else
    colorEcho ${RED} "Please run this script in WSL(Windows Subsystem for Linux)!"
    exit 0
fi

# Custom WSL settings
colorEcho ${BLUE} "Custom WSL settings..."
## make drives mounted at /c or /e instead of /mnt/c and /mnt/e.
if [[ ! $(grep "automount" /etc/wsl.conf) ]]; then
tee /etc/wsl.conf <<-'EOF'
[automount]
enabled = true
root = /
options = "metadata,umask=22,fmask=11"
mountFsTab = false
EOF
fi

## SSH
if [[ ! -d $HOME/.ssh ]]; then
    mkdir -p $HOME/.ssh && chmod 700 $HOME/.ssh/ # && chmod 600 $HOME/.ssh/*
fi


# Install packages
## Use USTC mirror & Install prerequest packages
if [[ -z "$APT_NOT_USE_MIRRORS" ]]; then
    colorEcho ${BLUE} "Use USTC mirror & Install prerequest packages..."
    sed -i 's|deb.debian.org|mirrors.ustc.edu.cn|g' /etc/apt/sources.list && \
        sed -i 's|security.debian.org|mirrors.ustc.edu.cn|g' /etc/apt/sources.list
fi

apt update && \
    apt install -y apt-transport-https apt-utils ca-certificates \
        curl lsb-release software-properties-common wget


# Add custom repositories
colorEcho ${BLUE} "Add custom repositories..."
if [[ -z "$APT_NOT_USE_MIRRORS" ]]; then
    ## Use https mirror
    sed -i 's|http://mirrors.ustc.edu.cn|https://mirrors.ustc.edu.cn|g' /etc/apt/sources.list
fi

## git lfs
if [[ ! -e /etc/apt/sources.list.d/github_git-lfs.list ]]; then
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
    # Configure proxy for APT
    # echo 'Acquire::http::Proxy::packagecloud-repositories.s3.dualstack.us-west-1.amazonaws.com "http://127.0.0.1:55881/";' > /etc/apt/apt.conf.d/99proxy
fi

## docker
# if [[ ! $(grep "docker-ce" /etc/apt/sources.list) ]]; then
#     curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -
#     add-apt-repository \
#         "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/$(. /etc/os-release; echo "$ID") \
#         $(lsb_release -cs) \
#         stable"
# fi

## yarn
if [[ ! -e /etc/apt/sources.list.d/yarn.list ]]; then
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
fi

## php
if [[ ! -e /etc/apt/sources.list.d/php.list ]]; then
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://mirror.xtom.com.hk/sury/php/apt.gpg
    echo "deb https://mirror.xtom.com.hk/sury/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
fi

## .NET Core SDK
if [[ ! -e /etc/apt/sources.list.d/microsoft-prod.list ]]; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.asc.gpg && \
        mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/ && \
        wget -q https://packages.microsoft.com/config/debian/9/prod.list && \
        mv prod.list /etc/apt/sources.list.d/microsoft-prod.list && \
        chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg && \
        chown root:root /etc/apt/sources.list.d/microsoft-prod.list
fi

## Update all repositories & Upgrade
colorEcho ${BLUE} "Update all repositories & Upgrade..."
apt update && apt upgrade -y


# Install useful packages
colorEcho ${BLUE} "Install useful packages..."
apt install -y binutils build-essential di dnsutils g++ gcc \
    git htop iproute2 make net-tools p7zip psmisc tree unzip zip


# Install dev packages
colorEcho ${BLUE} "Install dev packages..."
apt install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev libicu-dev \
    libxml2-dev libxslt-dev libbz2-dev libpspell-dev aspell-en \
    libcurl3 libcurl4-openssl-dev libssl-dev libc-client-dev libkrb5-dev \
    libpcre3 libpcre3-dev libmagickwand-dev libmemcached-dev zlib1g-dev \
    libgirepository1.0-dev libpq-dev nghttp2 libnghttp2-dev --no-install-recommends


# Enable broadcast WINS
colorEcho ${BLUE} "Enable broadcast WINS..."
apt install -y libnss-winbind

if [[ ! $(grep "wins" /etc/nsswitch.conf) ]]; then
    sed -i 's/dns/wins dns/' /etc/nsswitch.conf
fi
service winbind start # /etc/init.d/winbind start


# Install git lfs
## https://github.com/git-lfs/git-lfs/wiki/Tutorial
colorEcho ${BLUE} "Install git lfs..."
apt install -y git-lfs && git lfs install

## setting a track pattern
## find ./ -size +100M

# git lfs track "name_of_a_giant_file"
# git lfs track "*.exe"
# git lfs track "Framework/*"

## add .gitattributes to repository
# git add .gitattributes


# git-flow (AVH Edition)
## https://github.com/petervanderdoes/gitflow-avh
## How to use
## http://danielkummer.github.io/git-flow-cheatsheet/index.zh_CN.html
## https://github.com/mylxsw/growing-up/blob/master/doc/%E7%A0%94%E5%8F%91%E5%9B%A2%E9%98%9FGIT%E5%BC%80%E5%8F%91%E6%B5%81%E7%A8%8B%E6%96%B0%E4%BA%BA%E5%AD%A6%E4%B9%A0%E6%8C%87%E5%8D%97.md
colorEcho ${BLUE} "Installing git-flow (AVH Edition)..."
DOWNLOAD_URL=https://raw.githubusercontent.com/petervanderdoes/gitflow-avh/develop/contrib/gitflow-installer.sh
wget --no-check-certificate -q $DOWNLOAD_URL && \
    sudo bash gitflow-installer.sh install develop; rm gitflow-installer.sh


# nano editor
if [[ -s "$HOME/nano_installer.sh" ]]; then
    source "$HOME/nano_installer.sh"
else
    colorEcho ${BLUE} "Installing nano..."
    apt install -y nano
fi


# Micro editor
## https://micro-editor.github.io/index.html
# colorEcho ${BLUE} "Installing Micro editor..."
# apt install -y xclip && cd /usr/local/bin && curl https://getmic.ro | bash && cd $HOME

## Install Micro Plugins
## open micro from your CLI, press [Crtl + E] then run the command line below. Once you are done, restart micro.
## plugin install vcs comment editorconfig go snippets wc gotham-colors fmt filemanager manipulator monokai-dark
## set colorscheme monokai-dark


# proxychains
if [[ -s "$HOME/proxychains_installer.sh" ]]; then
    source "$HOME/proxychains_installer.sh"
fi


# Docker
if [[ -s "$HOME/docker_installer.sh" ]]; then
    source "$HOME/docker_installer.sh"
fi


# nvm & nodejs
if [[ -s "$HOME/nvm_node_installer.sh" ]]; then
    source "$HOME/nvm_node_installer.sh"
fi


## Install yarn
colorEcho ${BLUE} "Installing yarn..."
apt install -y yarn --no-install-recommends


# .NET Core SDK
## https://www.microsoft.com/net/download/linux-package-manager/debian9/sdk-current
## How to use: dotnet --help
colorEcho ${BLUE} "Installing .NET Core SDK..."
apt install -y dotnet-sdk-2.2


# jabba & JDK
if [[ -s "$HOME/jabba_jdk_installer.sh" ]]; then
    source "$HOME/jabba_jdk_installer.sh"
fi


# sdkman
if [[ -s "$HOME/sdkman_installer.sh" ]]; then
    source "$HOME/sdkman_installer.sh"
fi


# gvm & go
if [[ -s "$HOME/gvm_go_installer.sh" ]]; then
    source "$HOME/gvm_go_installer.sh"
fi


# PHP
## Install PHP7.2
colorEcho ${BLUE} "Installing PHP7.2..."
apt install -y pkg-config php7.2 php7.2-fpm php7.2-curl php7.2-dev \
    php7.2-gd php7.2-mbstring php7.2-mysql php7.2-pgsql \
    php7.2-sqlite3 php7.2-xml php7.2-xsl php7.2-zip

## opcache
{ \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=60'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
    echo 'opcache.file_cache=/tmp'; \
} > /etc/php/7.2/cli/conf.d/opcache-recommended.ini

# remove PHP version from the X-Powered-By HTTP header
# test: curl -I -H "Accept-Encoding: gzip, deflate" https://www.yourdomain.com
echo 'expose_php = off' > /etc/php/7.2/cli/conf.d/hide-header-version.ini

## Install composer
if [[ ! -x "$(command -v composer)" ]]; then
    colorEcho ${BLUE} "Installing composer..."
    export COMPOSER_ALLOW_SUPERUSER=1 && \
        export COMPOSER_HOME=/usr/local/share/composer && \
        mkdir -p /usr/local/share/composer && \
        wget https://dl.laravel-china.org/composer.phar -O /usr/local/bin/composer && \
        chmod a+x /usr/local/bin/composer

    ### Packagist mirror
    composer config -g repo.packagist composer https://packagist.laravel-china.org

    ### Install composer packages
    colorEcho ${BLUE} "Installing composer packages..."
    composer g require "hirak/prestissimo" && \
        composer g require friendsofphp/php-cs-fixer && \
        composer g require --dev phpunit/phpunit ^7 && \
        composer g require psy/psysh:@stable

    mkdir -p $HOME/.local/share/psysh/ && \
        curl -SL http://psysh.org/manual/zh/php_manual.sqlite -o $HOME/.local/share/psysh/php_manual.sqlite
fi

## pear & pecl
if [[ -x "$(command -v pecl)" ]]; then
    pecl update-channels && rm -rf /tmp/pear $HOME/.pearrc

    ### fix PHP Fatal error: Cannot use result of built-in function in write context in /usr/share/php/Archive/Tar.php on line 639
    ### https://www.dotkernel.com/php-troubleshooting/fix-installing-pear-packages-with-php-7-2/
    sed -i 's/& func_get_args/func_get_args/' /usr/share/php/Archive/Tar.php # && pear install Archive_Tar
    
    ### fix Warning: Invalid argument supplied for foreach() in Command.php on line 249
    sed -i 's/exec $PHP -C -n -q/exec $PHP -C -q/' /usr/bin/pecl
fi

## Install extension using pecl
if [[ -s "$HOME/pecl_install_php_extensions.sh" ]]; then
    colorEcho ${BLUE} "Installing php extension using pecl..."
    source "$HOME/pecl_install_php_extensions.sh"
fi


# conda & python
if [[ -s "$HOME/conda_python_installer.sh" ]]; then
    source "$HOME/conda_python_installer.sh"
fi


# pip3
## fix `pip list` warning
colorEcho ${BLUE} "Installing pip..."
if [[ ! $(grep "format=columns" $HOME/.pip/pip.conf) ]]; then
mkdir -p $HOME/.pip && \
tee $HOME/.pip/pip.conf <<-'EOF'
[global]
format=columns
EOF
fi

apt install -y python3-dev python3-pip && hash -r

# fix TypeError: '>' not supported between instances of 'Version' and 'Version'
# fix TypeError: unorderable types: Version() > SetuptoolsVersion()
pip install --ignore-installed pip && hash -r

# fix for pyxdg, pygobject, pycurl, etc.
apt install -y libgirepository1.0-dev libssl-dev libcurl4-openssl-dev libcairo2-dev --no-install-recommends
# pip install -I pygobject==3.30.1 && \
#     pip install -I pyxdg==0.26 && \
#     pip install -I python-debianbts==2.7.3 && \
#     pip install -I httplib2==0.11.3 && \
#     pip install -I pycurl==7.43.0.2


# The Fuck
## https://github.com/nvbn/thefuck
# colorEcho ${BLUE} "Installing thefuck..."
# pip install thefuck


# TLDR
## https://github.com/tldr-pages/tldr
colorEcho ${BLUE} "Installing tldr..."
if [[ -x "$(command -v npm)" ]]; then
    npm install -g tldr
else
    pip install tldr
fi


# cheat.sh
## https://github.com/chubin/cheat.sh
colorEcho ${BLUE} "Installing cheat.sh..."
apt install -y rlwrap
curl https://cht.sh/:cht.sh > /usr/local/bin/cht.sh && \
    chmod +x /usr/local/bin/cht.sh


colorEcho ${GREEN} "WSL init done, please restart WSL!"
