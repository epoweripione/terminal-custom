#!/bin/bash

if [[ $UID -ne 0 ]]; then
    echo "Please run this script as root user!"
    exit 0
fi

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


# Remove old version nano
# pacman -R nano


# https://www.nano-editor.org/dist/latest/faq.html
# http://mybookworld.wikidot.com/compile-nano-from-source
if check_release_package_manager packageManager yum; then
    yum update -y && yum -y -q install ncurses-devel
elif check_release_package_manager packageManager apt; then
    apt update && apt -y install libncurses5-dev libncursesw5-dev
elif check_release_package_manager packageManager pacman; then
    pacman -Sy && pacman -S ncurses
fi


# ncurses
# cd /tmp && \
#     curl -SL http://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.1.tar.gz -o ncurses.tar.gz && \
#     tar zxvf ncurses.tar.gz && \
#     mv ncurses-* ncurses && cd ncurses && \
#     ./configure --prefix=/opt/ncurses && \
#     make && make install && \
#     rm -rf /tmp/*


# compile & install nano
if [[ -x "$(command -v nano)" ]]; then
    CURRENT_VERSION=$(nano -V | grep -m 1 -o 'version \([0-9]\)\+\.\([0-9]\)\+' | cut -d' ' -f2)
else
    CURRENT_VERSION=0.0
fi

REMOTE_VERSION=$(curl -s -N https://www.nano-editor.org/download.php \
    | grep -m 1 -o 'nano-\([0-9]\)\+\.\([0-9]\)\+' | head -n1 | cut -d'-' -f2)
DIST_VERSION=$(echo $REMOTE_VERSION | cut -d'.' -f1)

if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
    colorEcho ${BLUE} "Installing nano from source..."
    DOWNLOAD_URL=https://www.nano-editor.org/dist/v${DIST_VERSION}/nano-${REMOTE_VERSION}.tar.gz
    # curl -SL $DOWNLOAD_URL -o nano.tar.gz
    cd /tmp && \
        wget -O nano.tar.gz $DOWNLOAD_URL && \
        tar zxvf nano.tar.gz && \
        mv nano-* nano && cd nano && \
        ./configure --prefix=/usr --enable-utf8 && \
        make && make install && \
        rm -rf /tmp/*
fi


# nano-syntax-highlighting
if [[ -d ~/.local/share/nano ]]; then
    cd ~/.local/share/nano && git pull
else
    mkdir -p ~/.local/share/nano
    git clone https://github.com/scopatz/nanorc.git ~/.local/share/nano
fi


# nano settings
if [[ ! $(grep "set titlecolor" ~/.nanorc) ]]; then
    echo "set titlecolor brightwhite,red" >> ~/.nanorc
fi

if [[ ! $(grep "set statuscolor" ~/.nanorc) ]]; then
    echo "set statuscolor brightwhite,red" >> ~/.nanorc
fi

if [[ ! $(grep "set selectedcolor" ~/.nanorc) ]]; then
    echo "set selectedcolor brightwhite,cyan" >> ~/.nanorc
fi

if [[ ! $(grep "set numbercolor" ~/.nanorc) ]]; then
    echo "set numbercolor magenta" >> ~/.nanorc
fi

if [[ ! $(grep "set keycolor" ~/.nanorc) ]]; then
    echo "set keycolor brightmagenta" >> ~/.nanorc
fi

if [[ ! $(grep "set functioncolor" ~/.nanorc) ]]; then
    echo "set functioncolor magenta" >> ~/.nanorc
fi

if [[ -d ~/.local/share/nano ]]; then
    if [[ ! $(grep "\~/.local/share/nano/\*\.nanorc" ~/.nanorc) ]]; then
        echo "include \"~/.local/share/nano/*.nanorc\"" >> ~/.nanorc
    fi
    # if [[ ! $(grep "/usr/share/nano/nano-syntax-highlighting/\*\.nanorc" ~/.nanorc) ]]; then
    #     echo "include \"/usr/share/nano/nano-syntax-highlighting/*.nanorc\"" >> ~/.nanorc
    # fi
fi

# cd $HOME
# colorEcho ${GREEN} "Done!"
