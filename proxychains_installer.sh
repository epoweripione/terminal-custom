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


# proxychains
if [[ ! -x "$(command -v proxychains4)" ]]; then
    colorEcho ${BLUE} "Installing proxychains..."
    cd $HOME && \
        git clone https://github.com/rofl0r/proxychains-ng && \
        cd proxychains-ng && \
        ./configure --prefix=/usr --sysconfdir=/etc/proxychains && \
        make && make install && make install-config && \
        cp /etc/proxychains/proxychains.conf /etc/proxychains/proxychains.conf.bak && \
        sed -i 's/socks4/# socks4/g' /etc/proxychains/proxychains.conf && \
        echo 'socks5 127.0.0.1 55880' >> /etc/proxychains/proxychains.conf
fi
