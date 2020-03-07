#!/bin/bash

CURRENT_DIR=$(pwd)

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

# https://termux.com/
if [[ -z "$PREFIX" ]]; then
    colorEcho ${RED} "This script only for Termux!"
    exit 0
fi

# extra keys rows
mkdir -p "$HOME/.termux"
tee "$HOME/.termux/termux.properties" >/dev/null <<-'EOF'
extra-keys = [ \
        ['ESC','/','BACKSLASH','_','|','HOME','UP','END','PGUP','DEL'], \
        ['CTRL','ALT','TAB','-','ENTER','LEFT','DOWN','RIGHT','PGDN','BKSP'] \
    ]
EOF

# reload termux settings
# termux-reload-settings

# apt mirror
sed -i 's/^deb /# deb /g' "$PREFIX/etc/apt/sources.list"
echo "deb https://mirrors.tuna.tsinghua.edu.cn/termux stable main" >> "$PREFIX/etc/apt/sources.list"

# install packages
pkg up -y
pkg i -y nano curl wget git unzip unrar htop nmap

# https://wiki.termux.com/wiki/Termux:API
pkg i -y termux-api

# nanorc
git clone --depth=1 "https://github.com/scopatz/nanorc" "$HOME/.local/share/nano"
tee "$HOME/.nanorc" >/dev/null <<-'EOF'
set titlecolor brightwhite,red
set statuscolor brightwhite,red
set selectedcolor brightwhite,cyan
set numbercolor magenta
set keycolor brightmagenta
set functioncolor magenta

include "$HOME/.local/share/nano/*.nanorc"
EOF

# frp
CHECK_URL="https://api.github.com/repos/fatedier/frp/releases/latest"
REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
DOWNLOAD_URL=https://github.com/fatedier/frp/releases/download/v${REMOTE_VERSION}/frp_${REMOTE_VERSION}_linux_arm64.tar.gz
curl -SL -o frp.tar.gz -C- $DOWNLOAD_URL && \
    tar -zxPf frp.tar.gz -C "$HOME" && \
    rm frp.tar.gz && \
    mkdir -p "$HOME/frp" && \
    cp -rf "$HOME/frp_*/*" "$HOME/frp" && \
    rm -rf "$HOME/frp_*/"
# cd $HOME/frp/ && nohup ./frpc -c ./frpc.ini  >/dev/null 2>&1 & disown

# zsh
sh -c "$(curl -fsSL https://github.com/Cabbagec/termux-ohmyzsh/raw/master/install.sh)"

# zsh custom
sed -i 's/[#]*[ ]*HIST_STAMPS.*/HIST_STAMPS="yyyy-mm-dd"/' "$HOME/.zshrc"

# zsh plugins
sed -i '/zsh-syntax-highlighting.zsh/d' "$HOME/.zshrc"

git clone --depth=1 "https://github.com/zsh-users/zsh-history-substring-search" \
    "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
git clone --depth=1 "https://github.com/zsh-users/zsh-autosuggestions" \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

Plugins="zsh-autosuggestions zsh-syntax-highlighting history-substring-search"

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

# webui-aria2
# git clone https://github.com/ziahamza/webui-aria2 "$HOME/webui-aria2" && \
#     cd "$HOME/webui-aria2" && node node-server.js

# sshd auto start
echo "sshd" >> "$HOME/.zshrc"

cd "${CURRENT_DIR}"