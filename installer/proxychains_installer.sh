#!/usr/bin/env bash

trap 'rm -r "$WORKDIR"' EXIT

[[ -z "$WORKDIR" ]] && WORKDIR="$(mktemp -d)"
[[ -z "$CURRENT_DIR" ]] && CURRENT_DIR=$(pwd)

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

        Git_Clone_Update "rofl0r/proxychains-ng" "$HOME/proxychains-ng"

        # only recompile if update
        # git_latest_update=$(git log -1 --format="%at" | xargs -I{} date -d @{} +'%Y-%m-%d %H:%M:%S')
        git_latest_update=$(git log -1 --format="%at" | xargs -I{} date -d @{})
        proxychains4_date=$(date -d "$(stat --printf='%y\n' $(which proxychains4))")
        # if [[ $(date -d "$git_latest_update") > $(date --date='7 day ago') ]]; then
        if [[ $(date -d "$git_latest_update") > $(date -d "$proxychains4_date") ]]; then
            cd "$HOME/proxychains-ng" && \
                sudo ./configure --prefix=/usr --sysconfdir=/etc/proxychains >/dev/null && \
                sudo make >/dev/null && sudo make install >/dev/null
        fi
    fi
else
    colorEcho ${BLUE} "Installing proxychains-ng..."
    if [[ -x "$(command -v pacman)" ]]; then
        if pacman -Si proxychains4 >/dev/null 2>&1; then
            sudo pacman --noconfirm -S proxychains4
        fi
    fi

    if [[ ! -x "$(command -v proxychains4)" ]]; then
        Git_Clone_Update "rofl0r/proxychains-ng" "$HOME/proxychains-ng"

        if [[ -d "$HOME/proxychains-ng" ]]; then
            cd "$HOME/proxychains-ng" && \
                sudo ./configure --prefix=/usr --sysconfdir=/etc/proxychains >/dev/null && \
                sudo make >/dev/null && sudo make install >/dev/null && sudo make install-config >/dev/null
        fi
    fi

    if [[ -s "/etc/proxychains/proxychains.conf" ]]; then
        sudo cp /etc/proxychains/proxychains.conf /etc/proxychains/proxychains.conf.bak && \
            sudo sed -i 's/socks4/# socks4/g' /etc/proxychains/proxychains.conf

        if check_socks5_proxy_up "127.0.0.1:7890"; then
            echo 'socks5 127.0.0.1 7890' | sudo tee -a /etc/proxychains/proxychains.conf >/dev/null
        elif check_socks5_proxy_up "127.0.0.1:7891"; then
            echo 'socks5 127.0.0.1 7891' | sudo tee -a /etc/proxychains/proxychains.conf >/dev/null
        fi
    fi
fi

cd "${CURRENT_DIR}"