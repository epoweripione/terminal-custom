#!/bin/zsh

if [[ -z "$ZSH" ]]; then
    colorEcho ${RED} "Please install ZSH & Oh-my-zsh first!"
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
colorEcho ${BLUE} "Updating fzf..."
if [[ ! -x "$(command -v fzf)" ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
else
    cd ~/.fzf && git pull && ./install --bin
fi


# zsh-interactive-cd
if [[ -x "$(command -v fzf)" ]]; then
    colorEcho ${BLUE} "Updating zsh-interactive-cd..."
    if [[ -d $ZSH/custom/plugins/zsh-interactive-cd ]]; then
        cd $ZSH/custom/plugins/zsh-interactive-cd && git pull
    else
        git clone https://github.com/changyuheng/zsh-interactive-cd.git $ZSH/custom/plugins/zsh-interactive-cd
    fi
fi


# custom plugins
colorEcho ${BLUE} "Updating custom plugins..."

# zsh-navigation-tools
# echo "Updating zsh-navigation-tools..."
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/psprint/zsh-navigation-tools/master/doc/install.sh)"

# fast-syntax-highlighting
colorEcho ${BLUE} "Updating fast-syntax-highlighting..."
if [[ -d $ZSH/custom/plugins/fast-syntax-highlighting ]]; then
    cd $ZSH/custom/plugins/fast-syntax-highlighting && git pull
else
    git clone https://github.com/zdharma/fast-syntax-highlighting.git $ZSH/custom/plugins/fast-syntax-highlighting
fi

# zsh-syntax-highlighting
colorEcho ${BLUE} "Updating zsh-syntax-highlighting..."
if [[ -d $ZSH/custom/plugins/zsh-syntax-highlighting ]]; then
    cd $ZSH/custom/plugins/zsh-syntax-highlighting && git pull
else
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH/custom/plugins/zsh-syntax-highlighting
fi

# zsh-autosuggestions
colorEcho ${BLUE} "Updating zsh-autosuggestions..."
if [[ -d $ZSH/custom/plugins/zsh-autosuggestions ]]; then
    cd $ZSH/custom/plugins/zsh-autosuggestions && git pull
else
    git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH/custom/plugins/zsh-autosuggestions
fi

# zsh-command-time
colorEcho ${BLUE} "Updating zsh-command-time..."
if [[ -d $ZSH/custom/plugins/command-time ]]; then
    cd $ZSH/custom/plugins/command-time && git pull
else
    git clone https://github.com/popstas/zsh-command-time.git $ZSH/custom/plugins/command-time
fi

# zsh-command-time
colorEcho ${BLUE} "Updating git-flow-completion..."
if [[ -d $ZSH/custom/plugins/git-flow-completion ]]; then
    cd $ZSH/custom/plugins/git-flow-completion && git pull
else
    git clone https://github.com/petervanderdoes/git-flow-completion.git $ZSH/custom/plugins/git-flow-completion
fi


# custom themes
colorEcho ${BLUE} "Updating custom themes..."

# agnosterzak
colorEcho ${BLUE} "Updating agnosterzak..."
if [[ -d $ZSH/custom/themes/agnosterzak ]]; then
    cd $ZSH/custom/themes/agnosterzak && git pull
else
    git clone https://github.com/zakaziko99/agnosterzak-ohmyzsh-theme.git $ZSH/custom/themes/agnosterzak
fi

[[ -L $ZSH/custom/themes/agnosterzak.zsh-theme ]] && rm -f $ZSH/custom/themes/agnosterzak.zsh-theme
ln -s $ZSH/custom/themes/agnosterzak/agnosterzak.zsh-theme $ZSH/custom/themes/agnosterzak.zsh-theme

# spaceship-prompt
colorEcho ${BLUE} "Updating spaceship-prompt..."
if [[ -d $ZSH/custom/themes/spaceship-prompt ]]; then
    cd $ZSH/custom/themes/spaceship-prompt && git pull
else
    git clone https://github.com/denysdovhan/spaceship-prompt.git $ZSH/custom/themes/spaceship-prompt
fi

[[ -L $ZSH/custom/themes/spaceship.zsh-theme ]] && rm -f $ZSH/custom/themes/spaceship.zsh-theme
ln -s $ZSH/custom/themes/spaceship-prompt/spaceship.zsh-theme $ZSH/custom/themes/spaceship.zsh-theme

# powerlevel9k
colorEcho ${BLUE} "Updating powerlevel9k..."
if [[ -d $ZSH/custom/themes/powerlevel9k ]]; then
    cd $ZSH/custom/themes/powerlevel9k && git pull
else
    git clone https://github.com/bhilburn/powerlevel9k.git $ZSH/custom/themes/powerlevel9k
fi

[[ -L $ZSH/custom/themes/powerlevel9k.zsh-theme ]] && rm -f $ZSH/custom/themes/powerlevel9k.zsh-theme
ln -s $ZSH/custom/themes/powerlevel9k/powerlevel9k.zsh-theme $ZSH/custom/themes/powerlevel9k.zsh-theme

# agkozak
colorEcho ${BLUE} "Updating agkozak..."
if [[ -d $ZSH/custom/themes/agkozak ]]; then
    cd $ZSH/custom/themes/agkozak && git pull
else
    git clone https://github.com/agkozak/agkozak-zsh-prompt.git $ZSH/custom/themes/agkozak
fi

[[ -L $ZSH/custom/themes/agkozak.zsh-theme ]] && rm -f $ZSH/custom/themes/agkozak.zsh-theme
ln -s $ZSH/custom/themes/agkozak/agkozak-zsh-prompt.plugin.zsh $ZSH/custom/themes/agkozak.zsh-theme

# alien
colorEcho ${BLUE} "Updating alien..."
if [[ -d $ZSH/custom/themes/alien ]]; then
    cd $ZSH/custom/themes/alien && git pull
else
    git clone https://github.com/eendroroy/alien.git $ZSH/custom/themes/alien
fi

[[ -L $ZSH/custom/themes/alien.zsh-theme ]] && rm -f $ZSH/custom/themes/alien.zsh-theme && \
ln -s $ZSH/custom/themes/alien/alien.plugin.zsh $ZSH/custom/themes/alien.zsh-theme


# enable plugins
colorEcho ${BLUE} "enable plugins..."
sed -i "s/^plugins=(git)/plugins=(\n  git\n)/" ~/.zshrc

## zsh-syntax-highlighting must be the last plugin sourced
# if [[ ! $(grep "  zsh-syntax-highlighting" ~/.zshrc) ]]; then
#     sed -i '/^  git$/a\  zsh-syntax-highlighting' ~/.zshrc
# fi

if [[ ! $(grep "  history-substring-search" ~/.zshrc) ]]; then
    sed -i '/^  git$/a\  history-substring-search' ~/.zshrc
fi

if [[ ! $(grep "  fast-syntax-highlighting" ~/.zshrc) ]]; then
    sed -i '/^  git$/a\  fast-syntax-highlighting' ~/.zshrc
fi

if [[ ! $(grep "  zsh-autosuggestions" ~/.zshrc) ]]; then
    sed -i '/^  git$/a\  zsh-autosuggestions' ~/.zshrc
fi

if [[ ! $(grep "  zsh-interactive-cd" ~/.zshrc) ]]; then
    sed -i '/^  git$/a\  zsh-interactive-cd' ~/.zshrc
fi

if [[ ! $(grep "  git-flow-completion" ~/.zshrc) ]]; then
    sed -i '/^  git$/a\  git-flow-completion' ~/.zshrc
fi

if [[ "$(command -v fuck)" ]]; then
    if [[ ! $(grep "  thefuck" ~/.zshrc) ]]; then
        sed -i '/^  git$/a\  thefuck' ~/.zshrc
    fi
fi

if [[ -x "$(command -v redis-cli)" ]]; then
    if [[ ! $(grep "  redis-cli" ~/.zshrc) ]]; then
        sed -i '/^  git$/a\  redis-cli' ~/.zshrc
    fi
fi

if [[ -x "$(command -v fab)" ]]; then
    if [[ ! $(grep "  fabric" ~/.zshrc) ]]; then
        sed -i '/^  git$/a\  fabric' ~/.zshrc
    fi
fi

if [[ -x "$(command -v docker-machine)" ]]; then
    if [[ ! $(grep "  docker-machine" ~/.zshrc) ]]; then
        sed -i '/^  git$/a\  docker-machine' ~/.zshrc
    fi
fi

if [[ -x "$(command -v docker)" ]]; then
    if [[ ! $(grep "  docker docker-compose" ~/.zshrc) ]]; then
        sed -i '/^  git$/a\  docker docker-compose' ~/.zshrc
    fi
fi

if [[ -x "$(command -v composer)" ]]; then
    if [[ ! $(grep "  composer" ~/.zshrc) ]]; then
        sed -i '/^  git$/a\  composer' ~/.zshrc
    fi
fi

# if [[ ! $(grep "  command-time" ~/.zshrc) ]]; then
#   sed -i '/^  git$/a\  command-time' ~/.zshrc
# fi

if [[ ! $(grep "  colored-man-pages" ~/.zshrc) ]]; then
    sed -i '/^  git$/a\  colored-man-pages' ~/.zshrc
fi

if [[ -x "$(command -v autojump)" ]]; then
    if [[ ! $(grep "  autojump" ~/.zshrc) ]]; then
        sed -i '/^  git$/a\  autojump' ~/.zshrc
        # sed -i '0,/^  git$/s//  git\n  autojump/' ~/.zshrc
    fi
fi

if [[ -x "$(command -v fzf)" ]]; then
    if [[ ! $(grep "  fzf" ~/.zshrc) ]]; then
        sed -i '/^  git$/a\  fzf' ~/.zshrc
    fi
fi

if [[ ! $(grep "  cp rsync sudo supervisor" ~/.zshrc) ]]; then
    sed -i '/^  git$/a\  cp rsync sudo supervisor' ~/.zshrc
fi

if [[ $ostype == "darwin" ]]; then
    if [[ ! $(grep "  osx" ~/.zshrc) ]]; then
        sed -i '/^  git$/a\  osx' ~/.zshrc
    fi
fi


# nano
colorEcho ${BLUE} "Updating nano-syntax-highlighting..."
if [[ -d ~/.local/share/nano ]]; then
    cd ~/.local/share/nano && git pull
else
    git clone https://github.com/scopatz/nanorc.git ~/.local/share/nano
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
