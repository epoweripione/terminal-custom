#!/usr/bin/env bash

# if [[ $UID -ne 0 ]]; then
#     echo "Please run this script as root user!"
#     exit 0
# fi

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


# [[ -x "$(command -v proxychains4)" && -d "$HOME/proxychains-ng" && $UID -eq 0 ]] && \
#     isUpgrade="yes"
# [[ ! -x "$(command -v proxychains4)" && ! -d "$HOME/proxychains-ng" && $UID -eq 0 ]] && \
#     isNewInstall="yes"
# if [[ "$isUpgrade" == "yes" || "$isNewInstall" == "yes" ]]; then

# proxychains
if [[ -x "$(command -v proxychains4)" ]]; then
    if [[ -d "$HOME/proxychains-ng" ]]; then
        colorEcho ${BLUE} "Updating proxychains-ng..."
        cd $HOME/proxychains-ng && git pull
        # only recompile if update
        # git_latest_update=$(git log -1 --format="%at" | xargs -I{} date -d @{} +'%Y-%m-%d %H:%M:%S')
        git_latest_update=$(git log -1 --format="%at" | xargs -I{} date -d @{})
        proxychains4_date=$(date -d "$(stat --printf='%y\n' $(which proxychains4))")
        # if [[ $(date -d "$git_latest_update") > $(date --date='7 day ago') ]]; then
        if [[ $(date -d "$git_latest_update") > $(date -d "$proxychains4_date") ]]; then
            sudo ./configure --prefix=/usr --sysconfdir=/etc/proxychains && \
                sudo make && sudo make install
        fi
        cd $HOME
    fi
else
    colorEcho ${BLUE} "Installing proxychains-ng..."
    if [[ -x "$(command -v pacman)" ]]; then
        if pacman -Si proxychains-ng  >/dev/null 2>&1; then
            sudo pacman --noconfirm -S proxychains-ng 
        fi
    fi

    if [[ $UID -eq 0 && ! -x "$(command -v proxychains4)" ]]; then
        cd $HOME && \
            git clone https://github.com/rofl0r/proxychains-ng && \
            cd proxychains-ng && \
            sudo ./configure --prefix=/usr --sysconfdir=/etc/proxychains && \
            sudo make && sudo make install && sudo make install-config
    fi

    if [[ -s "/etc/proxychains/proxychains.conf" ]]; then
        sudo cp /etc/proxychains/proxychains.conf /etc/proxychains/proxychains.conf.bak && \
            sudo sed -i 's/socks4/# socks4/g' /etc/proxychains/proxychains.conf && \
            echo 'socks5 127.0.0.1 55880' | sudo tee -a /etc/proxychains/proxychains.conf >/dev/null
    fi
    cd $HOME
fi
