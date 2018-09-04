#!/bin/bash

#######color code########
RED="31m"      # Error message
GREEN="32m"    # Success message
YELLOW="33m"   # Warning message
BLUE="36m"     # Info message

colorEcho() {
    COLOR=$1
    echo -e "\033[${COLOR}${@:2}\033[0m"
}


if [[ $(uname -r) =~ "Microsoft" ]]; then
    if [[ $UID -ne 0 ]]; then
        colorEcho ${RED} "Please run this script as root user!"
        exit 0
    fi
else
    colorEcho ${RED} "Please run this script in WSL(Windows Subsystem for Linux)!"
    exit 0
fi


# Install WSL (Windows Subsystem for Linux)
# https://docs.microsoft.com/zh-cn/windows/wsl/install-win10

# Install Linux Distribution
# Install **Debian** from **Microsoft Store**

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
if [[ ! -d ~/.ssh ]]; then
    mkdir -p ~/.ssh && chmod 700 ~/.ssh/ # && chmod 600 ~/.ssh/*
fi


# Install packages
## Use USTC mirror & Install prerequest packages
colorEcho ${BLUE} "Use USTC mirror & Install prerequest packages..."
sed -i 's|deb.debian.org|mirrors.ustc.edu.cn|g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org|mirrors.ustc.edu.cn|g' /etc/apt/sources.list

apt update && apt install -y apt-transport-https apt-utils ca-certificates curl lsb-release software-properties-common wget


# Add custom repositories
colorEcho ${BLUE} "Add custom repositories..."
## Use https mirror
sed -i 's|http://mirrors.ustc.edu.cn|https://mirrors.ustc.edu.cn|g' /etc/apt/sources.list

## docker
if [[ ! $(grep "docker-ce" /etc/apt/sources.list) ]]; then
    curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -
    add-apt-repository \
        "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/$(. /etc/os-release; echo "$ID") \
        $(lsb_release -cs) \
        stable"
fi

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

## Update all repositories & Upgrade
colorEcho ${BLUE} "Update all repositories & Upgrade..."
apt update && apt upgrade -y


# Install useful packages
colorEcho ${BLUE} "Install useful packages..."
apt install -y binutils build-essential di dnsutils g++ gcc git htop iproute2 make nano net-tools p7zip psmisc unzip zip


# Enable broadcast WINS
colorEcho ${BLUE} "Enable broadcast WINS..."
apt install -y libnss-winbind

if [[ ! $(grep "wins" /etc/nsswitch.conf) ]]; then
    sed -i 's/dns/wins dns/' /etc/nsswitch.conf
fi
service winbind start # /etc/init.d/winbind start


# proxychains
if [[ ! -x "$(command -v proxychains4)" ]]; then
    colorEcho ${BLUE} "Install proxychains..."
    git clone https://github.com/rofl0r/proxychains-ng.git && \
        cd proxychains-ng && \
        ./configure --prefix=/usr --sysconfdir=/etc/proxychains && \
        make && make install && make install-config && \
        cp /etc/proxychains/proxychains.conf /etc/proxychains/proxychains.conf.bak && \
        sed -i 's/socks4/# socks4/g' /etc/proxychains/proxychains.conf && \
        echo 'socks5 127.0.0.1 55880' >> /etc/proxychains/proxychains.conf && \
        cd ~
fi

# Docker
colorEcho ${BLUE} "Installing Docker..."
apt install -y docker-ce

## Install Docker Compose
if [[ ! -x "$(command -v docker-compose)" ]]; then
    colorEcho ${BLUE} "Installing Docker Compose..."
    docker_compose_ver=$(wget --no-check-certificate -qO- https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    if [[ -n "$docker_compose_ver" ]]; then
        curl -SL https://github.com/docker/compose/releases/download/$docker_compose_ver/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && \
        chmod +x /usr/local/bin/docker-compose
    fi
fi


# nodejs
colorEcho ${BLUE} "Installing nvm & nodejs..."
## Install nvm
if [[ ! -d "$HOME/.nvm" ]]; then
    nvm_ver=$(wget --no-check-certificate -qO- https://api.github.com/repos/creationix/nvm/releases/latest | grep 'tag_name' | cut -d\" -f4)
    if [[ -n "$nvm_ver" ]]; then
        curl -o- https://raw.githubusercontent.com/creationix/nvm/$nvm_ver/install.sh | bash
    fi
fi

if [[ -d "$HOME/.nvm" ]]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    export NVM_NODEJS_ORG_MIRROR=http://npm.taobao.org/mirrors/node
fi

## Install nodejs
if [[ "$(command -v nvm)" ]]; then
    if [[ ! "$(command -v node)" ]]; then
        nvm install node && nvm use node
        ## Fix npm not found
        ln -s $(which node) /usr/bin/node && ln -s $(which npm) /usr/bin/npm
    fi
fi

## Install yarn
colorEcho ${BLUE} "Installing yarn..."
apt install -y yarn --no-install-recommends


# Java
## OpenJDK
colorEcho ${BLUE} "Installing OpenJDK..."
apt install -y default-jdk default-jre

## Oracle jdk
## http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
# colorEcho ${BLUE} "Installing Oracle JDK..."
# mkdir -p /usr/lib/jvm && cd /usr/lib/jvm && \
#     wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.tar.gz && \
#     tar -zxvf jdk-8u181-linux-x64.tar.gz && \
#     ln -s /usr/lib/jvm/jdk1.8.0_181/ /usr/lib/jvm/oracle-jdk8 && \
#     rm -f jdk-8u181-linux-x64.tar.gz && cd ~

# ## Install new JDK alternatives
# update-alternatives --install /usr/bin/java java /usr/lib/jvm/oracle-jdk8/bin/java 100
# update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/oracle-jdk8/bin/javac 100

# ## Remove the existing alternatives
# # update-alternatives --remove java /usr/lib/jvm/oracle-jdk8/bin/java
# # update-alternatives --remove javac /usr/lib/jvm/oracle-jdk8/bin/javac

# ## Change the default Java versions using the update-alternatives system:
# # update-alternatives --config java
# # update-alternatives --config javac

export JAVA_HOME=$(readlink -f $(which java) | sed "s:/jre/bin/java::" | sed "s:/bin/java::")
export JRE_HOME=$JAVA_HOME/jre
export CLASSPATH=$JAVA_HOME/lib
export PATH=$PATH:$JAVA_HOME/bin

## Install Software Development Kits for the JVM such as Java, Groovy, Scala, Kotlin and Ceylon. Ant, Gradle, Grails, Maven, SBT, Spark, Spring Boot, Vert.x and many others also supported.
## https://sdkman.io/
## To get a listing of available Candidates: sdk list
## To see what is currently in use for all Candidates: sdk current
colorEcho ${BLUE} "Installing sdkman..."
if [[ ! -d "$HOME/.sdkman" ]]; then
    curl -s "https://get.sdkman.io" | bash
fi

colorEcho ${BLUE} "Installing maven gradle kotlin using sdkman..."
sdk install maven && sdk install gradle && sdk install kotlin


# go
colorEcho ${BLUE} "Installing gvm & go..."
## Install gvm
## https://github.com/moovweb/gvm
## Please turn on proxy in china (replace the IP and Port to fit your proxy server)
if [[ ! -d "$HOME/.gvm" ]]; then
    apt install -y bison && \
        bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
    source ~/.gvm/scripts/gvm

    ## In order to compile Go 1.5+, make sure Go 1.4 is installed first.
    ## gvm install go1.4 -B && gvm use go1.4
    proxychains4 gvm install go1.4 -B && gvm use go1.4

    ## Install latest go version
    ## go_ver=$(proxychains4 curl -s https://golang.org/dl/ | grep -m 1 -o 'go\([0-9]\)\+\.\([0-9]\)\+')
    ## gvm install $go_ver && gvm use $go_ver --default
    go_ver=$(proxychains4 curl -s https://golang.org/dl/ | grep -m 1 -o 'go\([0-9]\)\+\.\([0-9]\)\+')
    proxychains4 gvm install $go_ver && gvm use $go_ver --default

    export GOROOT_BOOTSTRAP=$GOROOT
fi


# PHP
## Install PHP7.2
colorEcho ${BLUE} "Installing PHP7.2..."
apt install -y php7.2 php7.2-fpm php7.2-curl php7.2-dev php7.2-gd php7.2-mbstring php7.2-mysql php7.2-pgsql php7.2-sqlite3 php7.2-xml php7.2-xsl php7.2-zip

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
    composer g require "hirak/prestissimo:^0.3.7" && \
        composer g require friendsofphp/php-cs-fixer && \
        composer g require --dev phpunit/phpunit ^7 && \
        composer g require psy/psysh:@stable

    mkdir -p ~/.local/share/psysh/ && \
        curl -SL http://psysh.org/manual/zh/php_manual.sqlite -o ~/.local/share/psysh/php_manual.sqlite
fi

## Install pear
apt install -y pkg-config && pecl update-channels && rm -rf /tmp/pear ~/.pearrc

### fix PHP Fatal error: Cannot use result of built-in function in write context in /usr/share/php/Archive/Tar.php on line 639
### https://www.dotkernel.com/php-troubleshooting/fix-installing-pear-packages-with-php-7-2/
sed -i 's/& func_get_args/func_get_args/' /usr/share/php/Archive/Tar.php
### pear install Archive_Tar

## Install extension using pecl
colorEcho ${BLUE} "Installing php extension using pecl..."
## pecl install imagick memcached mongodb oauth xdebug
if [[ ! -e /etc/php/7.2/cli/conf.d/90-imagick.ini ]]; then
    apt install -y libmagickwand-dev libmemcached-dev zlib1g-dev --no-install-recommends && \
        cd /tmp && \
        curl -SL http://pecl.php.net/get/imagick -o imagick.tgz && \
        curl -SL http://pecl.php.net/get/memcached -o memcached.tgz && \
        curl -SL http://pecl.php.net/get/mongodb -o mongodb.tgz && \
        curl -SL http://pecl.php.net/get/redis -o redis.tgz && \
        curl -SL http://pecl.php.net/get/oauth -o oauth.tgz && \
        curl -SL http://pecl.php.net/get/xdebug -o xdebug.tgz && \
        printf "\n" | pecl install imagick.tgz && \
        printf "\n" | pecl install memcached.tgz && \
        printf "\n" | pecl install mongodb.tgz && \
        printf "\n" | pecl install redis.tgz && \
        printf "\n" | pecl install oauth.tgz && \
        printf "\n" | pecl install xdebug.tgz && \
        echo 'extension=imagick.so' > /etc/php/7.2/cli/conf.d/90-imagick.ini && \
        echo 'extension=memcached.so' > /etc/php/7.2/cli/conf.d/90-memcached.ini && \
        echo 'extension=mongodb.so' > /etc/php/7.2/cli/conf.d/90-mongodb.ini && \
        echo 'extension=redis.so' > /etc/php/7.2/cli/conf.d/90-redis.ini && \
        echo 'extension=oauth.so' > /etc/php/7.2/cli/conf.d/90-oauth.ini && \
        echo 'zend_extension=/usr/lib/php/20170718/xdebug.so' > /etc/php/7.2/cli/conf.d/90-xdebug.ini && \
        rm -rf /tmp/* && cd ~
fi

## Install swoole
## https://github.com/swoole/swoole-src
## hiredis( for swoole )
## https://github.com/redis/hiredis
colorEcho ${BLUE} "Installing php extension swoole..."
if [[ ! -e /etc/php/7.2/cli/conf.d/90-swoole.ini ]]; then
    apt install -y libpq-dev nghttp2 libnghttp2-dev --no-install-recommends && \
        mkdir -p /tmp/downloads && cd /tmp && \
        curl -o ./downloads/hiredis.tar.gz https://github.com/redis/hiredis/archive/master.tar.gz -L && \
        tar zxvf ./downloads/hiredis.tar.gz && \
        mv hiredis* hiredis && cd hiredis && \
        make -j && make install && ldconfig && \
        cd /tmp && \
        curl -o ./downloads/swoole.tar.gz https://github.com/swoole/swoole-src/archive/master.tar.gz -L && \
        tar zxvf ./downloads/swoole.tar.gz && \
        mv swoole-src* swoole-src && cd swoole-src && \
        phpize && \
        ./configure \
            --enable-openssl \
            --enable-http2  \
            --enable-async-redis \
            --enable-sockets \
            --enable-mysqlnd \
            --enable-coroutine-postgresql && \
        make clean && make && make install && \
        echo 'extension=swoole.so' > /etc/php/7.2/cli/conf.d/90-swoole.ini && \
        rm -rf /tmp/*
fi


# Miniconda
colorEcho ${BLUE} "Installing Miniconda3..."
if [[ ! -d "$HOME/miniconda3" ]]; then
    curl -SL -O https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash ./Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3

    export PATH=$PATH:$HOME/miniconda3/bin
    # source $HOME/miniconda3/bin/activate

    conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/free/ && \
        conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/main/ && \
        conda config --set show_channel_urls yes

    conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/conda-forge/ && \
        conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/msys2/ && \
        conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/bioconda/ && \
        conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/menpo/
    
    conda update -y --all
fi


colorEcho ${GREEN} "WSL init done, please restart WSL!"
