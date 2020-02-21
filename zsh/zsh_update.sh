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

[[ -z "$ostype" ]] && get_os_type
[[ -z "$CURRENT_DIR" ]] && CURRENT_DIR=$(pwd)

# # pacapt - An Arch's pacman-like package manager for some Unices
# # https://github.com/icy/pacapt
# if [[ ! -x "$(command -v pacapt)" ]]; then
#     colorEcho ${BLUE} "Installing pacapt - An Arch's pacman-like package manager for some Unices..."
#     sudo curl -SL https://github.com/icy/pacapt/raw/ng/pacapt -o /usr/bin/pacapt && \
#         sudo chmod 755 /usr/bin/pacapt && \
#         sudo ln -sv /usr/bin/pacapt /usr/bin/pacman || true
# fi

# # install pre-requisite packages
# if [[ -x "$(command -v pacapt)" || -x "$(command -v pacman)" ]]; then
#     pacman -S curl wget g++ gcc make git zip unzip
# fi


## oh-my-zsh custom plugins & themes
# cd $ZSH && \
#     zip -qyr "$HOME/oh-my-zsh-custom.zip" "./custom" \
#         -x  "custom/example.zsh" \
#             "custom/plugins/example*" \
#             "custom/themes/example.zsh-theme" && \
#     mv "$HOME/oh-my-zsh-custom.zip" "/srv/web/www/default"
if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
    if check_webservice_up www.google.com; then
        :
    else
        echo "Download URL for oh-my-zsh custom plugins & themes?"
        echo -n "[Use github by default] "
        read OHMYZSH_CUSTOM_URL
    fi

    if [[ -n "$OHMYZSH_CUSTOM_URL" ]]; then
        # curl -SL -o "/tmp/oh-my-zsh-custom.zip" "${OHMYZSH_CUSTOM_URL}" && \
        wget -c -O "/tmp/oh-my-zsh-custom.zip" "${OHMYZSH_CUSTOM_URL}" && \
            cd "$ZSH_CUSTOM" && \
            find . -maxdepth 2 -regextype posix-extended \
                ! \( -path "." \
                    -or -path "./plugins" \
                    -or -path "./themes" \
                    -or -path "./plugins/example" \
                    -or -name "example.*" \
                \) -exec rm -rf {} \; && \
            unzip -qo "/tmp/oh-my-zsh-custom.zip" -d "$ZSH" && \
            rm -f "/tmp/oh-my-zsh-custom.zip" && \
            cd - >/dev/null 2>&1
    fi
fi


# ZSH
# upgrade_oh_my_zsh
[[ -n "$ZSH" ]] && Git_Clone_Update "ohmyzsh/ohmyzsh" "$ZSH"


# tmux
if [[ ! -x "$(command -v tmux)" ]]; then
    if [[ -x "$(command -v pacapt)" || -x "$(command -v pacman)" ]]; then
        if pacman -Si tmux >/dev/null 2>&1; then
            colorEcho ${BLUE} "Installing tmux..."
            sudo pacman --noconfirm -S tmux
        fi
    fi
fi

if [[ -x "$(command -v tmux)" ]]; then
    # Oh My Tmux: https://github.com/gpakosz/.tmux
    Git_Clone_Update "gpakosz/.tmux" "$HOME/.tmux"

    if [[ ! -s "$HOME/.tmux.conf.local" ]]; then
        cd $HOME && \
            ln -s -f .tmux/.tmux.conf && \
            cp .tmux/.tmux.conf.local . && \
            cd - >/dev/null
    fi
    # custom settings for tmux
    if [[ -s "$HOME/.tmux.conf.local" ]]; then
        #    
        sed -i "s/^tmux_conf_theme_left_separator_main=.*/tmux_conf_theme_left_separator_main='\\\uE0B4'/" $HOME/.tmux.conf.local
        sed -i "s/^tmux_conf_theme_left_separator_sub=.*/tmux_conf_theme_left_separator_sub='\\\uE0B5'/" $HOME/.tmux.conf.local
        sed -i "s/^tmux_conf_theme_right_separator_main=.*/tmux_conf_theme_right_separator_main='\\\uE0B6'/" $HOME/.tmux.conf.local
        sed -i "s/^tmux_conf_theme_right_separator_sub=.*/tmux_conf_theme_right_separator_sub='\\\uE0B7'/" $HOME/.tmux.conf.local
    fi
fi


# neofetch
if [[ ! -x "$(command -v neofetch)" ]]; then
    if [[ -x "$(command -v pacapt)" || -x "$(command -v pacman)" ]]; then
        if pacman -Si neofetch >/dev/null 2>&1; then
            colorEcho ${BLUE} "Installing neofetch..."
            sudo pacman --noconfirm -S neofetch
        fi
    fi
fi

if [[ ! -x "$(command -v neofetch)" ]]; then
    Git_Clone_Update "dylanaraps/neofetch" "$HOME/neofetch"

    if [[ $ostype == "darwin" ]]; then
        cd $HOME/neofetch && sudo make PREFIX=/usr/local install
    elif [[ $ostype =~ "windows" ]]; then
        cd $HOME/neofetch && sudo make -i install
    else
        cd $HOME/neofetch && sudo make install
    fi
fi

if [[ -x "$(command -v neofetch)" ]]; then
    mkdir -p ~/.config/neofetch/ && \
        cp ~/terminal-custom/zsh/neofetch_config.conf ~/.config/neofetch/config.conf
fi


# fzf
if [[ ! -x "$(command -v fzf)" ]]; then
    if [[ -x "$(command -v pacapt)" || -x "$(command -v pacman)" ]]; then
        if pacman -Si fzf >/dev/null 2>&1; then
            colorEcho ${BLUE} "Installing fzf..."
            sudo pacman --noconfirm -S fzf
        fi
    fi
fi

if [[ $UID -eq 0 ]]; then
    Git_Clone_Update "junegunn/fzf" "$HOME/.fzf"

    if [[ ! -x "$(command -v fzf)" ]]; then
        colorEcho ${BLUE} "Installing fzf..."
        $HOME/.fzf/install
    elif [[ -d "$HOME/.fzf" ]]; then
        cd "$HOME/.fzf" && ./install --bin && cd - >/dev/null
    fi
fi


# navi
# Git_Clone_Update "denisidoro/navi" "/opt/navi"
# if [[ ! -x "$(command -v navi)" ]]; then
#     colorEcho ${BLUE} "Installing navi..."
#     cd /opt/navi && sudo make install
# elif [[ -d "/opt/navi" ]]; then
#     cd /opt/navi && sudo make update && cd - /dev/null
# fi


# Custom plugins
colorEcho ${BLUE} "Oh-my-zsh custom plugins..."

# zsh-navigation-tools
# echo "Updating zsh-navigation-tools..."
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/psprint/zsh-navigation-tools/master/doc/install.sh)"

# fast-syntax-highlighting
if [[ $ostype != "windows" ]]; then
    Git_Clone_Update "zdharma/fast-syntax-highlighting" \
        "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting"
fi

PluginList=(
    "zsh-users/zsh-syntax-highlighting"
    "zsh-users/zsh-history-substring-search"
    "zsh-users/zsh-autosuggestions"
    "popstas/zsh-command-time"
    "petervanderdoes/git-flow-completion"
    "changyuheng/zsh-interactive-cd"
)

for Target in "${PluginList[@]}"; do
    TargetName=$(echo ${Target} | awk -F"/" '{print $NF}')
    Git_Clone_Update "$Target" "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/${TargetName}"
done


# Custom themes
colorEcho ${BLUE} "Oh-my-zsh custom themes..."
ThemeList=(
    "zakaziko99/agnosterzak-ohmyzsh-theme"
    "denysdovhan/spaceship-prompt"
    "romkatv/powerlevel10k"
    "agkozak/agkozak-zsh-prompt"
    "eendroroy/alien"
    "sindresorhus/pure"
)

for Target in "${ThemeList[@]}"; do
    TargetName=$(echo ${Target} | awk -F"/" '{print $NF}')
    Git_Clone_Update "$Target" "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/${TargetName}"
done

# agnosterzak
[[ -L $ZSH_CUSTOM/themes/agnosterzak.zsh-theme ]] && rm -f $ZSH_CUSTOM/themes/agnosterzak.zsh-theme
ln -s $ZSH_CUSTOM/themes/agnosterzak-ohmyzsh-theme/agnosterzak.zsh-theme $ZSH_CUSTOM/themes/agnosterzak.zsh-theme

# spaceship-prompt
[[ -L $ZSH_CUSTOM/themes/spaceship.zsh-theme ]] && rm -f $ZSH_CUSTOM/themes/spaceship.zsh-theme
ln -s $ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme $ZSH_CUSTOM/themes/spaceship.zsh-theme

# Powerlevel10k
[[ -L $ZSH_CUSTOM/themes/powerlevel10k.zsh-theme ]] && rm -f $ZSH_CUSTOM/themes/powerlevel10k.zsh-theme
ln -s $ZSH_CUSTOM/themes/powerlevel10k/powerlevel10k.zsh-theme $ZSH_CUSTOM/themes/powerlevel10k.zsh-theme

# agkozak
[[ -L $ZSH_CUSTOM/themes/agkozak.zsh-theme ]] && rm -f $ZSH_CUSTOM/themes/agkozak.zsh-theme
ln -s $ZSH_CUSTOM/themes/agkozak-zsh-prompt/agkozak-zsh-prompt.plugin.zsh $ZSH_CUSTOM/themes/agkozak.zsh-theme

# alien
[[ -L $ZSH_CUSTOM/themes/alien.zsh-theme ]] && rm -f $ZSH_CUSTOM/themes/alien.zsh-theme
ln -s $ZSH_CUSTOM/themes/alien/alien.plugin.zsh $ZSH_CUSTOM/themes/alien.zsh-theme


# Enable plugins
colorEcho ${BLUE} "enable plugins..."

# plugin list
Plugins="git"

[[ "$(command -v git-flow)" ]] && Plugins="${Plugins} git-flow-completion"

[[ $ostype == "darwin" ]] && Plugins="${Plugins} osx"

Plugins="${Plugins} cp rsync sudo supervisor colored-man-pages"
# Plugins="${Plugins} command-time"

[[ -x "$(command -v tmux)" ]] && Plugins="${Plugins} tmux"
[[ -x "$(command -v fzf)" || -d ~/.fzf ]] && Plugins="${Plugins} fzf"
[[ -x "$(command -v autojump)" ]] && Plugins="${Plugins} autojump"
[[ -x "$(command -v composer)" ]] && Plugins="${Plugins} composer"
[[ -x "$(command -v docker)" ]] && Plugins="${Plugins} docker"
[[ -x "$(command -v docker-compose)" ]] && Plugins="${Plugins} docker-compose"
[[ -x "$(command -v docker-machine)" ]] && Plugins="${Plugins} docker-machine"
[[ -x "$(command -v fab)" ]] && Plugins="${Plugins} fabric"
[[ -x "$(command -v redis-cli)" ]] && Plugins="${Plugins} redis-cli"

[[ "$(command -v fuck)" ]] && Plugins="${Plugins} thefuck"

Plugins="${Plugins} zsh-interactive-cd zsh-autosuggestions"

if [[ $ostype == "windows" ]]; then
    Plugins="${Plugins} zsh-syntax-highlighting"
else
    Plugins="${Plugins} fast-syntax-highlighting"
fi

Plugins="${Plugins} history-substring-search"


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
Git_Clone_Update "scopatz/nanorc" "$HOME/.local/share/nano"

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


cd "${CURRENT_DIR}"
# colorEcho ${GREEN} "Update finished!"
