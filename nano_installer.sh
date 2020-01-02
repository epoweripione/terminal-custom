#!/bin/bash

# if [[ $UID -ne 0 ]]; then
#     echo "Please run this script as root user!"
#     exit 0
# fi

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


# https://www.nano-editor.org/dist/latest/faq.html
# http://mybookworld.wikidot.com/compile-nano-from-source
colorEcho ${BLUE} "Checking update for nano..."
if [[ -x "$(command -v pacapt)" || -x "$(command -v pacman)" ]]; then
    # Remove old version nano
    if pacman -Q nano >/dev/null 2>&1; then
        sudo pacman --noconfirm -R nano
    fi

    # Pre-requisite packages
    PackagesList=(
        ncurses
        ncurses-devel
        libncurses-dev
        libncursesw-dev
        libncurses5-dev
        libncursesw5-dev
    )
    for TargetPackage in "${PackagesList[@]}"; do
        if pacman -Si "$TargetPackage" >/dev/null 2>&1; then
            if ! pacman -Q "$TargetPackage" >/dev/null 2>&1; then
                sudo pacman --noconfirm -S "$TargetPackage"
            fi
        fi
    done
# else
#     if check_release_package_manager packageManager yum; then
#         sudo yum update -y && sudo yum -y -q install ncurses-devel
#     elif check_release_package_manager packageManager apt; then
#         sudo apt-get update && sudo apt-get -y install libncurses-dev libncursesw-dev
#         sudo apt-get update && sudo apt-get -y install libncurses5-dev libncursesw5-dev
#     elif check_release_package_manager packageManager pacman; then
#         sudo pacman -Sy && sudo pacman --noconfirm -S ncurses
#     fi
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
    # CURRENT_VERSION=$(nano -V | grep -m 1 -o 'version \([0-9]\)\+\.\([0-9]\)\+' | cut -d' ' -f2)
    CURRENT_VERSION=$(nano -V | grep -Eo -m1 '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
else
    CURRENT_VERSION=0.0
fi

REMOTE_VERSION=$(curl -s -N https://www.nano-editor.org/download.php \
    | grep -Eo -m1 'nano-([0-9]{1,}\.)+[0-9]{1,}' | head -n1 | cut -d'-' -f2)
    # | grep -m 1 -o 'nano-\([0-9]\)\+\.\([0-9]\)\+' | head -n1 | cut -d'-' -f2)
DIST_VERSION=$(echo $REMOTE_VERSION | cut -d'.' -f1)

if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
    colorEcho ${BLUE} "Installing nano from source..."
    DOWNLOAD_URL=https://www.nano-editor.org/dist/v${DIST_VERSION}/nano-${REMOTE_VERSION}.tar.gz
    # curl -SL $DOWNLOAD_URL -o nano.tar.gz
    cd /tmp && \
        wget -O nano.tar.gz $DOWNLOAD_URL && \
        sudo tar zxvf nano.tar.gz && \
        sudo mv nano-* nano && cd nano && \
        sudo ./configure --prefix=/usr --enable-utf8 && \
        sudo make && sudo make install && \
        sudo rm -rf /tmp/*
fi
