#!/bin/zsh

if [[ -z "$ZSH" ]]; then
    colorEcho ${RED} "Please install ZSH & Oh-my-zsh first!"
    exit 0
else
    [[ -z "$ZSH_CUSTOM" ]] && ZSH_CUSTOM=$ZSH/custom
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

if [[ -z "$ostype" ]]; then
    get_os_type
fi


# # pacapt - An Arch's pacman-like package manager for some Unices
# # https://github.com/icy/pacapt
# if [[ ! -x "$(command -v pacapt)" ]]; then
#     colorEcho ${BLUE} "Installing pacapt - An Arch's pacman-like package manager for some Unices..."
#     sudo curl -SL https://github.com/icy/pacapt/raw/ng/pacapt -o /usr/bin/pacapt && \
#         sudo chmod 755 /usr/bin/pacapt && \
#         sudo ln -sv /usr/bin/pacapt /usr/bin/pacman || true
# fi

# # install pre-request packages
# if [[ -x "$(command -v pacapt)" || -x "$(command -v pacman)" ]]; then
#     pacman -S curl wget g++ gcc make git zip unzip
# fi


# oh-my-zsh custom plugins & themes
if [[ ! -s "$ZSH_CUSTOM/themes/agnosterzak-my.zsh-theme" ]]; then
    if check_webservice_up www.google.com; then
        :
    else
        echo "Download URL for oh-my-zsh custom plugins & themes?"
        read -p "[Use github by default] " OHMYZSH_CUSTOM_URL
    fi

    if [[ -n "$OHMYZSH_CUSTOM_URL" ]]; then
        curl -SL -o "/tmp/oh-my-zsh-custom.zip" "${OHMYZSH_CUSTOM_URL}" && \
            rm -rf "$ZSH_CUSTOM" && \
            unzip -qo "/tmp/oh-my-zsh-custom.zip" -d "$ZSH" && \
            rm -f "/tmp/oh-my-zsh-custom.zip"
    fi
fi


# ZSH
colorEcho ${BLUE} "Updating Oh-my-zsh..."
# upgrade_oh_my_zsh
cd $ZSH && git pull


# neofetch
colorEcho ${BLUE} "Updating neofetch..."
if [[ -d $HOME/neofetch ]]; then
    cd $HOME/neofetch && git pull
else
    git clone https://github.com/dylanaraps/neofetch $HOME/neofetch
fi

if [[ $ostype == "darwin" ]]; then
    cd $HOME/neofetch && make PREFIX=/usr/local install
elif [[ $ostype =~ "windows" ]]; then
    cd $HOME/neofetch && make -i install
else
    if [[ $UID -eq 0 ]]; then
        cd $HOME/neofetch && make install
    fi
fi

if [[ -x "$(command -v neofetch)" ]]; then
    mkdir -p ~/.config/neofetch/ && \
        cp ~/terminal-custom/zsh/neofetch_config.conf ~/.config/neofetch/config.conf
fi


# fzf
if [[ $UID -eq 0 ]]; then
    colorEcho ${BLUE} "Updating fzf..."
    if [[ ! -x "$(command -v fzf)" ]]; then
        git clone --depth 1 https://github.com/junegunn/fzf ~/.fzf
        ~/.fzf/install
    else
        cd ~/.fzf && git pull && ./install --bin
    fi
fi


# navi
# if [[ $UID -eq 0 ]]; then
#     colorEcho ${BLUE} "Updating navi..."
#     if [[ ! -x "$(command -v navi)" ]]; then
#         git clone --depth 1 http://github.com/denisidoro/navi /opt/navi
#         cd /opt/navi && make install
#     else
#         cd /opt/navi && git pull && make update
#     fi
# fi


# Custom plugins
colorEcho ${BLUE} "Updating custom plugins..."

# zsh-navigation-tools
# echo "Updating zsh-navigation-tools..."
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/psprint/zsh-navigation-tools/master/doc/install.sh)"

# fast-syntax-highlighting
colorEcho ${BLUE} "Updating fast-syntax-highlighting..."
if [[ -d $ZSH_CUSTOM/plugins/fast-syntax-highlighting ]]; then
    cd $ZSH_CUSTOM/plugins/fast-syntax-highlighting && git pull
else
    git clone https://github.com/zdharma/fast-syntax-highlighting $ZSH_CUSTOM/plugins/fast-syntax-highlighting
fi

# zsh-syntax-highlighting
colorEcho ${BLUE} "Updating zsh-syntax-highlighting..."
if [[ -d $ZSH_CUSTOM/plugins/zsh-syntax-highlighting ]]; then
    cd $ZSH_CUSTOM/plugins/zsh-syntax-highlighting && git pull
else
    git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
fi

# zsh-autosuggestions
colorEcho ${BLUE} "Updating zsh-autosuggestions..."
if [[ -d $ZSH_CUSTOM/plugins/zsh-autosuggestions ]]; then
    cd $ZSH_CUSTOM/plugins/zsh-autosuggestions && git pull
else
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
fi

# zsh-command-time
colorEcho ${BLUE} "Updating zsh-command-time..."
if [[ -d $ZSH_CUSTOM/plugins/command-time ]]; then
    cd $ZSH_CUSTOM/plugins/command-time && git pull
else
    git clone https://github.com/popstas/zsh-command-time $ZSH_CUSTOM/plugins/command-time
fi

# git-flow-completion
colorEcho ${BLUE} "Updating git-flow-completion..."
if [[ -d $ZSH_CUSTOM/plugins/git-flow-completion ]]; then
    cd $ZSH_CUSTOM/plugins/git-flow-completion && git pull
else
    git clone https://github.com/petervanderdoes/git-flow-completion $ZSH_CUSTOM/plugins/git-flow-completion
fi

# zsh-interactive-cd
colorEcho ${BLUE} "Updating zsh-interactive-cd..."
if [[ -d $ZSH_CUSTOM/plugins/zsh-interactive-cd ]]; then
    cd $ZSH_CUSTOM/plugins/zsh-interactive-cd && git pull
else
    git clone https://github.com/changyuheng/zsh-interactive-cd $ZSH_CUSTOM/plugins/zsh-interactive-cd
fi


# Custom themes
colorEcho ${BLUE} "Updating custom themes..."

# agnosterzak
colorEcho ${BLUE} "Updating agnosterzak..."
if [[ -d $ZSH_CUSTOM/themes/agnosterzak ]]; then
    cd $ZSH_CUSTOM/themes/agnosterzak && git pull
else
    git clone https://github.com/zakaziko99/agnosterzak-ohmyzsh-theme $ZSH_CUSTOM/themes/agnosterzak
fi

[[ -L $ZSH_CUSTOM/themes/agnosterzak.zsh-theme ]] && rm -f $ZSH_CUSTOM/themes/agnosterzak.zsh-theme
ln -s $ZSH_CUSTOM/themes/agnosterzak/agnosterzak.zsh-theme $ZSH_CUSTOM/themes/agnosterzak.zsh-theme

# spaceship-prompt
colorEcho ${BLUE} "Updating spaceship-prompt..."
if [[ -d $ZSH_CUSTOM/themes/spaceship-prompt ]]; then
    cd $ZSH_CUSTOM/themes/spaceship-prompt && git pull
else
    git clone https://github.com/denysdovhan/spaceship-prompt $ZSH_CUSTOM/themes/spaceship-prompt
fi

[[ -L $ZSH_CUSTOM/themes/spaceship.zsh-theme ]] && rm -f $ZSH_CUSTOM/themes/spaceship.zsh-theme
ln -s $ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme $ZSH_CUSTOM/themes/spaceship.zsh-theme

# powerlevel9k
colorEcho ${BLUE} "Updating powerlevel9k..."
if [[ -d $ZSH_CUSTOM/themes/powerlevel9k ]]; then
    cd $ZSH_CUSTOM/themes/powerlevel9k && git pull
else
    git clone https://github.com/bhilburn/powerlevel9k $ZSH_CUSTOM/themes/powerlevel9k
fi

[[ -L $ZSH_CUSTOM/themes/powerlevel9k.zsh-theme ]] && rm -f $ZSH_CUSTOM/themes/powerlevel9k.zsh-theme
ln -s $ZSH_CUSTOM/themes/powerlevel9k/powerlevel9k.zsh-theme $ZSH_CUSTOM/themes/powerlevel9k.zsh-theme

# Powerlevel10k
colorEcho ${BLUE} "Updating powerlevel10k..."
if [[ -d $ZSH_CUSTOM/themes/powerlevel10k ]]; then
    cd $ZSH_CUSTOM/themes/powerlevel10k && git pull
else
    git clone https://github.com/romkatv/powerlevel10k $ZSH_CUSTOM/themes/powerlevel10k
fi

[[ -L $ZSH_CUSTOM/themes/powerlevel10k.zsh-theme ]] && rm -f $ZSH_CUSTOM/themes/powerlevel10k.zsh-theme
ln -s $ZSH_CUSTOM/themes/powerlevel10k/powerlevel10k.zsh-theme $ZSH_CUSTOM/themes/powerlevel10k.zsh-theme

# agkozak
colorEcho ${BLUE} "Updating agkozak..."
if [[ -d $ZSH_CUSTOM/themes/agkozak ]]; then
    cd $ZSH_CUSTOM/themes/agkozak && git pull
else
    git clone https://github.com/agkozak/agkozak-zsh-prompt $ZSH_CUSTOM/themes/agkozak
fi

[[ -L $ZSH_CUSTOM/themes/agkozak.zsh-theme ]] && rm -f $ZSH_CUSTOM/themes/agkozak.zsh-theme
ln -s $ZSH_CUSTOM/themes/agkozak/agkozak-zsh-prompt.plugin.zsh $ZSH_CUSTOM/themes/agkozak.zsh-theme

# alien
colorEcho ${BLUE} "Updating alien..."
if [[ -d $ZSH_CUSTOM/themes/alien ]]; then
    cd $ZSH_CUSTOM/themes/alien && git pull
else
    git clone https://github.com/eendroroy/alien $ZSH_CUSTOM/themes/alien
fi

[[ -L $ZSH_CUSTOM/themes/alien.zsh-theme ]] && rm -f $ZSH_CUSTOM/themes/alien.zsh-theme
ln -s $ZSH_CUSTOM/themes/alien/alien.plugin.zsh $ZSH_CUSTOM/themes/alien.zsh-theme

# Pure
colorEcho ${BLUE} "Updating pure..."
if [[ -d $ZSH_CUSTOM/themes/pure ]]; then
    cd $ZSH_CUSTOM/themes/pure && git pull
else
    git clone https://github.com/sindresorhus/pure $ZSH_CUSTOM/themes/pure
fi


# Enable plugins
colorEcho ${BLUE} "enable plugins..."

# plugin list
Plugins="git"

[[ "$(command -v git-flow)" ]] && Plugins="${Plugins} git-flow-completion"

[[ $ostype == "darwin" ]] && Plugins="${Plugins} osx"

Plugins="${Plugins} cp rsync sudo supervisor colored-man-pages"
# Plugins="${Plugins} command-time"

[[ -x "$(command -v fzf)" || -d ~/.fzf ]] && Plugins="${Plugins} fzf"
[[ -x "$(command -v autojump)" ]] && Plugins="${Plugins} autojump"
[[ -x "$(command -v composer)" ]] && Plugins="${Plugins} composer"
[[ -x "$(command -v docker)" ]] && Plugins="${Plugins} docker"
[[ -x "$(command -v docker-compose)" ]] && Plugins="${Plugins} docker-compose"
[[ -x "$(command -v docker-machine)" ]] && Plugins="${Plugins} docker-machine"
[[ -x "$(command -v fab)" ]] && Plugins="${Plugins} fabric"
[[ -x "$(command -v redis-cli)" ]] && Plugins="${Plugins} redis-cli"

[[ "$(command -v fuck)" ]] && Plugins="${Plugins} thefuck"

Plugins="${Plugins} zsh-interactive-cd history-substring-search fast-syntax-highlighting zsh-autosuggestions"

## zsh-syntax-highlighting must be the last plugin sourced
# if [[ ! $(grep "  zsh-syntax-highlighting" ~/.zshrc) ]]; then
#     sed -i '/^  git$/a\  zsh-syntax-highlighting' ~/.zshrc
# fi
# Plugins="${Plugins} zsh-syntax-highlighting"


PluginList=($(echo ${Plugins}))

Plugins=""
for TargetPlugin in ${PluginList[@]}; do
    if [[ -n "$TargetPlugin" ]]; then
        if [[ -z "$Plugins" ]]; then
            Plugins="  ${TargetPlugin}"
        else
            Plugins="${Plugins}\n  ${TargetPlugin}"
        fi
    fi
done

# replace plugins in .zshrc
sed -i "s/^plugins=(git)/plugins=(\n  git\n)/" ~/.zshrc

LineBegin=$(cat -n ~/.zshrc | grep 'plugins=(' | awk '{print $1}' | tail -n1)
LineShift=$(tail -n +${LineBegin} ~/.zshrc | cat -n | grep ')' | awk '{print $1}' | head -n1)
LineEnd=$((${LineBegin}+${LineShift}-1))

if [[ -n "$LineBegin" && -n "$LineEnd" ]]; then
    DeleteBegin=$((${LineBegin}+1))
    DeleteEnd=$((${LineEnd}-1))
    sed -i "${DeleteBegin},${DeleteEnd}d" ~/.zshrc
fi

sed -i "${LineBegin}a\\${Plugins}" ~/.zshrc


# nano
colorEcho ${BLUE} "Updating nano-syntax-highlighting..."
if [[ -d ~/.local/share/nano ]]; then
    cd ~/.local/share/nano && git pull
else
    git clone https://github.com/scopatz/nanorc ~/.local/share/nano
fi

colorEcho ${BLUE} "nano settings..."
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

# if [[ ! $(grep "set linenumbers" ~/.nanorc) ]]; then
#     echo "set linenumbers" >> ~/.nanorc
# fi

if [[ -d ~/.local/share/nano ]]; then
    if [[ ! $(grep "\~/.local/share/nano/\*\.nanorc" ~/.nanorc) ]]; then
        echo "include \"~/.local/share/nano/*.nanorc\"" >> ~/.nanorc
    fi
fi


cd $HOME
# colorEcho ${GREEN} "Update finished!"
