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

# Install WSL
# https://docs.microsoft.com/zh-cn/windows/wsl/install-win10

# Install Linux Distribution
# Install **Debian** from **Microsoft Store**

# Update & Upgrade
colorEcho ${BLUE} "Update & Upgrade..."
sed -i 's|deb.debian.org|mirrors.ustc.edu.cn|g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org|mirrors.ustc.edu.cn|g' /etc/apt/sources.list
apt update && apt install -y dialog apt-utils apt-transport-https ca-certificates lsb-release
sed -i 's|http://mirrors.ustc.edu.cn|https://mirrors.ustc.edu.cn|g' /etc/apt/sources.list
apt update && apt upgrade -y

# make drives mounted at /c or /e instead of /mnt/c and /mnt/e.
tee /etc/wsl.conf <<-'EOF'
[automount]
enabled = true
root = /
options = "metadata,umask=22,fmask=11"
mountFsTab = false
EOF

# SSH
mkdir ~/.ssh && chmod 700 ~/.ssh/


# Install custom packages
colorEcho ${BLUE} "Install custom packages..."
apt update && apt install -y build-essential curl di dnsutils gcc g++ git htop iproute2 lrzsz make nano net-tools p7zip psmisc unzip


# Enable broadcast WINS
colorEcho ${BLUE} "Enable broadcast WINS..."
apt install -y libnss-winbind
sed -i 's/dns/wins dns/' /etc/nsswitch.conf
/etc/init.d/winbind start


# Miniconda
colorEcho ${BLUE} "Installing Miniconda3..."
curl -SL -O https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh && ./Miniconda3-latest-Linux-x86_64.sh

conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/free/ && \
    conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/main/ && \
    conda config --set show_channel_urls yes

conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/conda-forge/ && \
    conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/msys2/ && \
    conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/bioconda/ && \
    conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/menpo/


# Docker
colorEcho ${BLUE} "Installing Docker..."
curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -
add-apt-repository \
    "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/$(. /etc/os-release; echo "$ID") \
    $(lsb_release -cs) \
    stable"
apt update && apt install -y docker-ce

## Install Docker Compose
colorEcho ${BLUE} "Installing Docker Compose..."
docker_compose_ver=$(wget --no-check-certificate -qO- https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
if [[ -n "$docker_compose_ver" ]]; then
    curl -SL https://github.com/docker/compose/releases/download/$docker_compose_ver/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose
fi


# nodejs
## Install nvm
colorEcho ${BLUE} "Installing nvm & nodejs..."
nvm_ver=$(wget --no-check-certificate -qO- https://api.github.com/repos/creationix/nvm/releases/latest | grep 'tag_name' | cut -d\" -f4)
curl -o- https://raw.githubusercontent.com/creationix/nvm/$nvm_ver/install.sh | bash

## Install nodejs
nvm install stable && nvm use stable

## Fix npm not found
ln -s $(which node) /usr/bin/node && ln -s $(which npm) /usr/bin/npm

## Install yarn
colorEcho ${BLUE} "Installing yarn..."
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
apt update && apt install -y yarn


# PHP
## Install PHP7.2
colorEcho ${BLUE} "Installing PHP7.2..."
wget -O /etc/apt/trusted.gpg.d/php.gpg https://mirror.xtom.com.hk/sury/php/apt.gpg
echo "deb https://mirror.xtom.com.hk/sury/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

apt update && apt install -y php7.2

## Installing Some Additional Packages
apt install -y php7.2-fpm php7.2-curl php7.2-gd php7.2-mbstring php7.2-mysql php7.2-pgsql php7.2-sqlite3 php7.2-xml php7.2-xsl

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

## Install composer
colorEcho ${BLUE} "Installing composer..."
export COMPOSER_ALLOW_SUPERUSER=1
export COMPOSER_HOME=/usr/local/share/composer

mkdir -p /usr/local/share/composer
wget https://dl.laravel-china.org/composer.phar -O /usr/local/bin/composer
chmod a+x /usr/local/bin/composer

## Packagist mirror
composer config -g repo.packagist composer https://packagist.laravel-china.org

## Install composer packages
colorEcho ${BLUE} "Installing composer packages..."
composer g require "hirak/prestissimo:^0.3.7"
composer g require friendsofphp/php-cs-fixer
composer g require --dev phpunit/phpunit ^7
composer g require psy/psysh:@stable
mkdir -p ~/.local/share/psysh/ && curl -SL http://psysh.org/manual/zh/php_manual.sqlite -o ~/.local/share/psysh/php_manual.sqlite


# ZSH
## Install zsh
colorEcho ${BLUE} "Installing ZSH..."
apt install -y zsh

tee -a ~/.bashrc <<-'EOF'

# Launch Zsh
if [[ "${ZSH_VERSION:-unset}" = "unset" ]]; then
    export SHELL=/bin/zsh
    exec zsh
fi
EOF

## Install oh-my-zsh
colorEcho ${BLUE} "Installing oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"


colorEcho ${GREEN} "WSL init done, please restart WSL!"
