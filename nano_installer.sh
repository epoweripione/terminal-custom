#!/bin/bash

if [[ $UID -ne 0 ]]; then
    echo "Please run this script as root user!"
    exit 0
fi

# https://www.nano-editor.org/dist/v1.2/faq.html#1.3
# http://mybookworld.wikidot.com/compile-nano-from-source
# install nano
if [[ ! -x "$(command -v nano)" ]]; then
    cd /tmp && \
        curl -SL http://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.1.tar.gz -o ncurses.tar.gz && \
        tar zxvf ncurses.tar.gz && \
        mv ncurses-* ncurses && cd ncurses && \
        ./configure && \
        make && make install && \
        : && \
        cd /tmp && \
        curl -SL https://www.nano-editor.org/dist/v3/nano-3.0.tar.gz -o nano.tar.gz && \
        tar zxvf nano.tar.gz && \
        mv nano-* nano && cd nano && \
        ./configure --prefix=/usr --enable-all && \
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

if [[ -d ~/.nano ]]; then
    if [[ ! $(grep "\~/.local/share/nano/\*\.nanorc" ~/.nanorc) ]]; then
        # echo "include \"/usr/share/nano/nano-syntax-highlighting/*.nanorc\"" >> ~/.nanorc
        echo "include \"~/.local/share/nano/*.nanorc\"" >> ~/.nanorc
    fi
fi
