#!/usr/bin/env bash

## termux: required storage access permission 

## install openssh
# pkg up -y && pkg i -y openssh
## start openssh service
# sshd
## ssh port: 8022
# netstat -an | grep 8022

## local computer:
## gen ssh key
# ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_ed25519 -C "username@mail.com"
## run a simple http server using python3
# cd ~./ssh; python -m http.server 8080

## termux:
# curl -fsSL -o ~/.ssh/id_ed25519.pub "http://<local computer ip>:8080/id_ed25519.pub"
# cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys

## local computer:
# cat >> ~/.ssh/config <<-EOF
# Host <phone>
#   Hostname <phone ip>
#   Port 8022
#   IdentityFile ~/.ssh/id_ed25519
#   User root
# EOF
# scp -Cp .ssh/* <phone>:~/.ssh/

## connect to phone using ssh:
# ssh <phone>
# rm -f .ssh/known_hosts && chmod 600 ~/.ssh/*

## set apt mirror
# sed -i 's/^deb /# deb /g' "$PREFIX/etc/apt/sources.list"
# echo "deb https://mirrors.tuna.tsinghua.edu.cn/termux stable main" >> "$PREFIX/etc/apt/sources.list"

## install packages
# pkg up -y && pkg i -y nano curl wget git unzip unrar htop nmap screenfetch starship

## init termux
# source <(curl -fsSL https://git.io/fNpeJ) && ./termux_init.sh

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

# https://termux.com/
if [[ -z "$PREFIX" ]]; then
    colorEcho "${RED}This script only for Termux!"
    exit 0
fi

# extra keys rows
colorEcho "${BLUE}Setting termux.properties..."
mkdir -p "$HOME/.termux"
tee "$HOME/.termux/termux.properties" >/dev/null <<-'EOF'
extra-keys = [ \
        ['ESC','/','BACKSLASH',|','HOME','UP','END','PGUP','DEL'], \
        ['CTRL','ALT','TAB',ENTER','LEFT','DOWN','RIGHT','PGDN','BKSP'] \
    ]
EOF

## reload termux settings
# termux-reload-settings

# https://wiki.termux.com/wiki/Termux:API
colorEcho "${BLUE}Installing ${FUCHSIA}termux-api${BLUE}..."
pkg i -y termux-api

# nanorc
colorEcho "${BLUE}Setting nanorc..."
git clone --depth=1 "https://github.com/scopatz/nanorc" "$HOME/.local/share/nano"
tee "$HOME/.nanorc" >/dev/null <<-EOF
set titlecolor brightwhite,red
set statuscolor brightwhite,red
set selectedcolor brightwhite,cyan
set numbercolor magenta
set keycolor brightmagenta
set functioncolor magenta

include "$HOME/.local/share/nano/*.nanorc"
EOF

# frp
if [[ ! -d "$HOME/frp" ]]; then
    colorEcho "${BLUE}Installing ${FUCHSIA}frp${BLUE}..."
    CHECK_URL="https://api.github.com/repos/fatedier/frp/releases/latest"
    REMOTE_VERSION=$(curl -fsL $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

    if [[ -n "$REMOTE_VERSION" ]]; then
        DOWNLOAD_URL="https://github.com/fatedier/frp/releases/download/v${REMOTE_VERSION}/frp_${REMOTE_VERSION}_linux_arm64.tar.gz"
        curl -fSL -o frp.tar.gz -C- "$DOWNLOAD_URL" && \
            tar -xzf frp.tar.gz -C "$HOME" && \
            rm frp.tar.gz && \
            mkdir -p "$HOME/frp" && \
            cp -rf $HOME/frp_*/* "$HOME/frp" && \
            rm -rf $HOME/frp_*/
    fi
fi
# cd $HOME/frp/ && nohup ./frpc -c ./frpc.ini >/dev/null 2>&1 & disown

# zsh
if [[ -x "$(command -v zsh)" ]]; then
    colorEcho "${BLUE}Installing ${FUCHSIA}zsh & oh-my-zsh${BLUE}..."
    sh -c "$(curl -fsSL https://github.com/Cabbagec/termux-ohmyzsh/raw/master/install.sh)"
fi

if [[ -s "$HOME/.zshrc" ]]; then
    colorEcho "${BLUE}Setting zsh..."
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # ys theme
    sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"ys\"/" "$HOME/.zshrc"

    # change the command execution time stamp shown in the history command output
    sed -i 's/[#]*[ ]*HIST_STAMPS.*/HIST_STAMPS="yyyy-mm-dd"/' "$HOME/.zshrc"

    # disable auto update
    sed -i "s/[#]*[ ]*DISABLE_AUTO_UPDATE.*/DISABLE_AUTO_UPDATE=\"true\"/" "$HOME/.zshrc"

    # zsh plugins
    sed -i '/zsh-syntax-highlighting.zsh/d' "$HOME/.zshrc"

    git clone --depth=1 "https://github.com/zdharma/fast-syntax-highlighting" \
        "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"

    git clone --depth=1 "https://github.com/zsh-users/zsh-history-substring-search" \
        "$ZSH_CUSTOM/plugins/zsh-history-substring-search"

    git clone --depth=1 "https://github.com/zsh-users/zsh-autosuggestions" \
        "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

    Plugins="zsh-autosuggestions fast-syntax-highlighting history-substring-search"

    PluginList=($(echo ${Plugins}))

    Plugins=""
    for TargetPlugin in "${PluginList[@]}"; do
        if [[ -n "$TargetPlugin" ]]; then
            if [[ -z "$Plugins" ]]; then
                Plugins="  ${TargetPlugin}"
            else
                Plugins="${Plugins}\n  ${TargetPlugin}"
            fi
        fi
    done

    # replace plugins in .zshrc
    sed -i "s/^plugins=(git)/plugins=(\n  git\n)/" "$HOME/.zshrc"

    LineBegin=$(cat -n "$HOME/.zshrc" | grep 'plugins=(' | awk '{print $1}' | tail -n1)
    LineShift=$(tail -n +${LineBegin} "$HOME/.zshrc" | cat -n | grep ')' | awk '{print $1}' | head -n1)
    LineEnd=$((${LineBegin}+${LineShift}-1))

    if [[ -n "$LineBegin" && -n "$LineEnd" ]]; then
        DeleteBegin=$((${LineBegin}+1))
        DeleteEnd=$((${LineEnd}-1))
        sed -i "${DeleteBegin},${DeleteEnd}d" "$HOME/.zshrc"
    fi

    sed -i "${LineBegin}a\\${Plugins}" "$HOME/.zshrc"
fi

## webui-aria2
# colorEcho "${BLUE}Installing ${FUCHSIA}webui-aria2${BLUE}..."
# git clone https://github.com/ziahamza/webui-aria2 "$HOME/webui-aria2" && \
#     cd "$HOME/webui-aria2" && node node-server.js

# sshd auto start
colorEcho "${BLUE}Setting sshd start with zsh..."
echo "sshd" >> "$HOME/.zshrc"

cd "${CURRENT_DIR}"