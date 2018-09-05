# Install WSL (Windows Subsystem for Linux)
https://docs.microsoft.com/zh-cn/windows/wsl/install-win10

# Install Linux Distribution
Install **Debian** from **Microsoft Store**

# Update & Upgrade
```
sed -i 's|deb.debian.org|mirrors.ustc.edu.cn|g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org|mirrors.ustc.edu.cn|g' /etc/apt/sources.list

apt update && apt install -y apt-transport-https apt-utils ca-certificates curl lsb-release software-properties-common wget

sed -i 's|http://mirrors.ustc.edu.cn|https://mirrors.ustc.edu.cn|g' /etc/apt/sources.list

apt update && apt upgrade -y
```

# make drives mounted at /c or /e instead of /mnt/c and /mnt/e.
```
tee /etc/wsl.conf <<-'EOF'
[automount]
enabled = true
root = /
options = "metadata,umask=22,fmask=11"
mountFsTab = false
EOF
```

# Enable broadcast WINS
```
apt update && apt install -y libnss-winbind
sed -i 's/dns/wins dns/' /etc/nsswitch.conf
/etc/init.d/winbind start
```

# ZSH
## Install zsh
`apt install -y zsh`

## Install oh-my-zsh
`sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"`

## Run zsh as default shell
`chsh -s $(which zsh)`

**or**  
```
tee -a ~/.bashrc <<-'EOF'

# Launch Zsh
if [[ "${ZSH_VERSION:-unset}" = "unset" ]]; then
    export SHELL=/bin/zsh
    exec zsh
fi
EOF
```

# Install custom packages
```
apt update && apt upgrade -y
apt install -y build-essential di dnsutils git htop iproute2 nano net-tools p7zip psmisc unzip
```

# SSH
```
mkdir -p ~/.ssh && chmod 700 ~/.ssh/
# gen ssh key
# ssh-keygen -t ecdsa -b 521 -C "username@mail.com"
# ssh-keygen -t rsa -C "$(whoami)@$(hostname)-$(date -I)"
chmod 600 ~/.ssh/*
```

# Install python3
```
# add testing repo
# echo "deb https://mirrors.ustc.edu.cn/debian/ testing main" >> /etc/apt/sources.list && \
#    echo 'APT::Default-Release "stable";' | sudo tee -a /etc/apt/apt.conf.d/00local

# install python3, pip3
apt update && apt install -y python3 python3-pip

# fix pip list warning
mkdir -p ~/.pip && \
cat >> ~/.pip/pip.conf <EOF
[global]
format=columns
EOF

# fix TypeError: '>' not supported between instances of 'Version' and 'Version'
pip3 install --ignore-installed pip

# upgrade outdated packages
pip3 list -o | grep -E -v '^-|^Package' | cut -d ' ' -f 1 | xargs -n1 pip3 install -U

# fix some package install error: 
# It is a distutils installed project and thus we cannot accurately determine which files belong to it which would lead to only a partial uninstall
# pip install -I <package name>==<latest version>
# example: pip install -I pyxdg==0.26
```

# Anaconda or Miniconda
## Anaconda
1. Download Anaconda from https://www.anaconda.com/download/#linux
`curl -SL -O https://repo.anaconda.com/archive/Anaconda3-5.2.0-Linux-x86_64.sh`

2. Install Anaconda
`bash Anaconda3-5.2.0-Linux-x86_64.sh`

3. zsh: add Anaconda to PATH
`echo -e "\nexport PATH=\"/root/anaconda3/bin:\$PATH\"" >> ~/.zshrc`

## Miniconda
1. Download Miniconda from https://conda.io/miniconda.html
`curl -SL -O https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh`

2. Install Miniconda
`bash Miniconda3-latest-Linux-x86_64.sh`

3. zsh: add Miniconda to PATH
`echo -e "\nexport PATH=\"/root/miniconda3/bin:\$PATH\"" >> ~/.zshrc`

4. conda repo mirrors in china
```
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/free/ && \
    conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/main/ && \
    conda config --set show_channel_urls yes

# extra repo
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/conda-forge/ && \
    conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/msys2/ && \
    conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/bioconda/ && \
    conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/menpo/
```

## Uninstalling Anaconda or Miniconda
1. Remove the entire install directory & created hidden file and folders
```
rm -rf ~/anaconda*
rm -rf ~/miniconda*
rm -rf ~/.condarc ~/.conda ~/.continuum
```

2. OPTIONAL:
Edit `~/.bashrc` or `~/.zshrc` to remove the Anaconda or Miniconda directory from your PATH environment variable.

## Use conda
https://conda.io/docs/user-guide/getting-started.html
https://conda.io/docs/_downloads/conda-cheatsheet.pdf
```
conda info
conda update conda
conda install <PackageName>
conda update <PackageName>
conda update --all

conda create -n py36 python=3.6
source activate py36
source deactivate

conda create -n py27 python=2.7
conda activate py2.7
conda deactivate
```

# Nerd Fonts Patcher
https://github.com/ryanoasis/nerd-fonts#font-patcher

```
apt install -y python-configparser fontforge

# run into fontforge built in python env
# fontforge -lang=py -script

# nerd-fonts
git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git
# cd nerd-fonts && fontforge -script font-patcher -h

# Patch Sarasa-Gothic https://github.com/be5invis/Sarasa-Gothic
cd nerd-fonts
for font in ~/Sarasa-Gothic/*.ttf; do fontforge -script font-patcher -out ~/Sarasa-Gothic/patched --careful --complete --progressbars --adjust-line-height "$font"; done
```

# Docker
## Install docker-ce in WSL
`chmod +x docker_install.sh && ./docker_install.sh`

## Docker For Windows
```
tee -a ~/.zshrc <<-'EOF'

# Docker For Windows
# In the general settings, enable option "Expose daemon on tcp://localhost:2375 without TLS"
export DOCKER_HOST=tcp://127.0.0.1:2375
EOF
```

## Docker Toolbox
```
tee -a ~/.zshrc <<-'EOF'

# Docker Toolbox
export WINDOWS_USER=$(/c/Windows/System32/cmd.exe /c 'echo %USERNAME%' | sed -e 's/\r//g')
export DOCKER_TLS_VERIFY=1
export DOCKER_HOST=tcp://192.168.99.100:2376
export DOCKER_CERT_PATH=/c/Users/$WINDOWS_USER/.docker/machine/certs
EOF
```

# nodejs
## Install nvm
https://github.com/creationix/nvm
```
nvm_ver=$(wget --no-check-certificate -qO- https://api.github.com/repos/creationix/nvm/releases/latest | grep 'tag_name' | cut -d\" -f4)
curl -o- https://raw.githubusercontent.com/creationix/nvm/$nvm_ver/install.sh | bash
tee -a ~/.zshrc <<-'EOF'

# load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
EOF
```

## list available nodejs version
`nvm ls-remote`

## Install nodejs
`nvm install stable && nvm use stable`

## Fix npm not found
`ln -s $(which node) /usr/bin/node && ln -s $(which npm) /usr/bin/npm`

## Install yarn
```
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
apt update && apt install -y yarn --no-install-recommends
```

# PHP
## Install PHP7.2
```
# wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
# echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

wget -O /etc/apt/trusted.gpg.d/php.gpg https://mirror.xtom.com.hk/sury/php/apt.gpg
echo "deb https://mirror.xtom.com.hk/sury/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

apt update && apt install -y php7.2 php7.2-fpm php7.2-curl php7.2-dev php7.2-gd php7.2-mbstring php7.2-mysql php7.2-pgsql php7.2-sqlite3 php7.2-xml php7.2-xsl php7.2-zip
```

## opcache options
```
{ \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=60'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
    echo 'opcache.file_cache=/tmp'; \
} > /etc/php/7.2/cli/conf.d/opcache-recommended.ini
```

## Install composer
```
export COMPOSER_ALLOW_SUPERUSER=1
export COMPOSER_HOME=/usr/local/share/composer
export PATH="$PATH:/usr/local/share/composer/vendor/bin"

mkdir -p /usr/local/share/composer
# curl -sS https://install.phpcomposer.com/installer | php -- --install-dir=/usr/bin/ --filename=composer

wget https://dl.laravel-china.org/composer.phar -O /usr/local/bin/composer
chmod a+x /usr/local/bin/composer

# Packagist mirror
composer config -g repo.packagist composer https://packagist.laravel-china.org

# Install packages
composer g require "hirak/prestissimo:^0.3.7"
composer g require friendsofphp/php-cs-fixer
composer g require --dev phpunit/phpunit ^7
composer g require psy/psysh:@stable
mkdir -p ~/.local/share/psysh/ && curl -SL http://psysh.org/manual/zh/php_manual.sqlite -o ~/.local/share/psysh/php_manual.sqlite
```
