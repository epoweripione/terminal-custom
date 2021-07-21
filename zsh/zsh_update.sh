#!/usr/bin/env zsh

trap 'rm -rf "$WORKDIR"' EXIT

[[ -z "$WORKDIR" ]] && WORKDIR="$(mktemp -d)"
[[ -z "$CURRENT_DIR" ]] && CURRENT_DIR=$(pwd)

if [[ -z "$ZSH" ]]; then
    colorEcho "${RED}Please install ${FUCHSIA}ZSH & Oh-my-zsh${RED} first!"
    exit 0
else
    [[ -z "$ZSH_CUSTOM" ]] && ZSH_CUSTOM="$ZSH/custom"
fi

[[ -z "$MY_SHELL_SCRIPTS" ]] && MY_SHELL_SCRIPTS="$HOME/terminal-custom"

# Load custom functions
if type 'colorEcho' 2>/dev/null | grep -q 'function'; then
    :
else
    if [[ -s "${MY_SHELL_SCRIPTS}/custom_functions.sh" ]]; then
        source "${MY_SHELL_SCRIPTS}/custom_functions.sh"
    else
        echo "${MY_SHELL_SCRIPTS}/custom_functions.sh not exist!"
        exit 0
    fi
fi

[[ -z "${OS_INFO_TYPE}" ]] && get_os_type


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
        read -t 10 OHMYZSH_CUSTOM_URL
        echo
    fi

    if [[ -n "$OHMYZSH_CUSTOM_URL" ]]; then
        wget -c -O "${WORKDIR}/oh-my-zsh-custom.zip" "${OHMYZSH_CUSTOM_URL}" && \
            find "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}" -mindepth 2 -maxdepth 2 \
                ! -name "example*" -exec /bin/rm -rf {} \; && \
            unzip -qo "${WORKDIR}/oh-my-zsh-custom.zip" -d "$ZSH"
        # wget -c -O "${WORKDIR}/oh-my-zsh-custom.zip" "${OHMYZSH_CUSTOM_URL}" && \
        #     cd "$ZSH_CUSTOM" && \
        #     find "$ZSH_CUSTOM" -maxdepth 2 -regextype posix-extended \
        #         ! \( -path "." \
        #             -or -path "./plugins" \
        #             -or -path "./themes" \
        #             -or -path "./plugins/example" \
        #             -or -name "example.*" \
        #         \) -exec rm -rf {} \; && \
        #     unzip -qo "${WORKDIR}/oh-my-zsh-custom.zip" -d "$ZSH"
    fi
fi


# ZSH
# upgrade_oh_my_zsh
[[ -n "$ZSH" ]] && Git_Clone_Update "ohmyzsh/ohmyzsh" "$ZSH"


# tmux
if [[ ! -x "$(command -v tmux)" ]] && [[ -x "$(command -v pacman)" ]]; then
    if pacman -Si tmux >/dev/null 2>&1; then
        colorEcho "${BLUE}Installing ${FUCHSIA}tmux${BLUE}..."
        sudo pacman --noconfirm -S tmux
    fi
fi

if [[ -x "$(command -v tmux)" ]]; then
    # Oh My Tmux: https://github.com/gpakosz/.tmux
    Git_Clone_Update "gpakosz/.tmux" "$HOME/.tmux"

    [[ -d "$HOME/.tmux" ]] && \
        cd $HOME && ln -s -f .tmux/.tmux.conf && cp -f .tmux/.tmux.conf.local .

    # custom settings for tmux
    if [[ -s "$HOME/.tmux.conf.local" ]]; then
        # tmux config ref
        # https://github.com/kaushalmodi/dotfiles/blob/master/tmux/dot-tmux.conf
        #    
        sed -i "s/^tmux_conf_theme_left_separator_main=.*/tmux_conf_theme_left_separator_main='\\\uE0B4'/" $HOME/.tmux.conf.local
        sed -i "s/^tmux_conf_theme_left_separator_sub=.*/tmux_conf_theme_left_separator_sub='\\\uE0B5'/" $HOME/.tmux.conf.local
        sed -i "s/^tmux_conf_theme_right_separator_main=.*/tmux_conf_theme_right_separator_main='\\\uE0B6'/" $HOME/.tmux.conf.local
        sed -i "s/^tmux_conf_theme_right_separator_sub=.*/tmux_conf_theme_right_separator_sub='\\\uE0B7'/" $HOME/.tmux.conf.local

        # disable update tpm and all plugins on launch or reload
        sed -i "s/^tmux_conf_update_plugins_on_launch=.*/tmux_conf_update_plugins_on_launch=false/" $HOME/.tmux.conf.local
        sed -i "s/^tmux_conf_update_plugins_on_reload=.*/tmux_conf_update_plugins_on_reload=false/" $HOME/.tmux.conf.local

        ## mouse on
        # sed -i "s/^#set -g mouse on/set -g mouse on/" $HOME/.tmux.conf.local

        # disable secondary prefix Ctrl-a
        sed -i "s/^# set -gu prefix2/set -gu prefix2/" $HOME/.tmux.conf.local
        sed -i "s/^# unbind C-a/unbind C-a/" $HOME/.tmux.conf.local

        # increase history size
        sed -i "s/^#set -g history-limit 10000/set -g history-limit 10000/" $HOME/.tmux.conf.local

        # move status line to top
        sed -i "s/^#set -g status-position top/set -g status-position top/" $HOME/.tmux.conf.local

        # Date Time format
        sed -i "s/, %R , %d %b |/, %H:%M , %Y-%m-%d %a |/" $HOME/.tmux.conf.local

        # bind key | for split current window vertically
        echo -e "unbind _\nbind | split-window -h" >> $HOME/.tmux.conf.local

        # Add true color support
        # echo "" >> $HOME/.tmux.conf.local
        # echo '# if-shell "infocmp xterm-256color" "set-option -g default-terminal xterm-256color"' >> $HOME/.tmux.conf.local
        # echo '# if-shell "infocmp screen-256color" "set-option -g default-terminal screen-256color"' >> $HOME/.tmux.conf.local
        # echo '# if-shell "infocmp tmux-256color" "set-option -g default-terminal tmux-256color"' >> $HOME/.tmux.conf.local
        # echo 'set -g default-terminal "screen-256color"' >> $HOME/.tmux.conf.local
        # echo 'set -ga terminal-overrides ",*256col*:Tc"' >> $HOME/.tmux.conf.local

        # https://github.com/tmux-plugins/tmux-sidebar
        # echo "" >> $HOME/.tmux.conf.local
        # echo "set -g @plugin 'tmux-plugins/tmux-sidebar'" >> $HOME/.tmux.conf.local

#         # add blank line on top of tmux statusbar (tmux 2.9+)
#         TMUX_VERSION=$(tmux -V | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
#         if version_ge $TMUX_VERSION "2.9"; then
#             tee -a "$HOME/.tmux.conf.local" >/dev/null <<-EOF
# set -gF 'status-format[1]' '#{status-format[0]}'
# set -g 'status-format[0]' ''
# set -g status 2
# EOF
#         fi
#         unset TMUX_VERSION
    fi
fi


# neofetch
if [[ ! -x "$(command -v neofetch)" ]] && [[ -x "$(command -v pacman)" ]]; then
    if pacman -Si neofetch >/dev/null 2>&1; then
        colorEcho "${BLUE}Installing ${FUCHSIA}neofetch${BLUE}..."
        sudo pacman --noconfirm -S neofetch
    fi
fi

if [[ ! -x "$(command -v neofetch)" ]]; then
    Git_Clone_Update "dylanaraps/neofetch" "$HOME/neofetch"

    if [[ "${OS_INFO_TYPE}" == "darwin" ]]; then
        cd $HOME/neofetch && sudo make PREFIX=/usr/local install
    elif [[ "${OS_INFO_TYPE}" == "windows" ]]; then
        cd $HOME/neofetch && sudo make -i install
    else
        cd $HOME/neofetch && sudo make install
    fi
fi

if [[ -x "$(command -v neofetch)" ]]; then
    mkdir -p $HOME/.config/neofetch/ && \
        cp $HOME/terminal-custom/zsh/neofetch_config.conf \
            $HOME/.config/neofetch/config.conf
fi


# fzf
# if [[ ! -x "$(command -v fzf)" ]] && [[ -x "$(command -v pacman)" ]]; then
#     if checkPackageNeedInstall "fzf"; then
#         colorEcho "${BLUE}Installing ${FUCHSIA}fzf${BLUE}..."
#         sudo pacman --noconfirm -S fzf
#     fi
# fi

if [[ ! -x "$(command -v fzf)" ]]; then
    Git_Clone_Update "junegunn/fzf" "$HOME/.fzf"
    [[ -s "$HOME/.fzf/install" ]] && $HOME/.fzf/install
elif [[ -d "$HOME/.fzf" ]]; then
    Git_Clone_Update "junegunn/fzf" "$HOME/.fzf"
    [[ -s "$HOME/.fzf/install" ]] && $HOME/.fzf/install --bin
fi


## PathPicker
## https://github.com/facebook/pathpicker/
# Git_Clone_Update "facebook/pathpicker" "$HOME/.pathpicker"
# if [[ ! -x "$(command -v fpp)" ]] ; then
#     [[ -s "$HOME/.pathpicker/fpp" ]] && sudo ln -s "$HOME/.pathpicker/fpp" "/usr/local/bin/fpp"
# fi


# Custom plugins
colorEcho "${BLUE}Oh-my-zsh custom plugins..."

PluginList=(
    "zsh-users/zsh-syntax-highlighting"
    # "zsh-users/zsh-history-substring-search"
    "zsh-users/zsh-autosuggestions"
    "zdharma/fast-syntax-highlighting"
    # "zdharma/history-search-multi-word"
    # "popstas/zsh-command-time"
    # "petervanderdoes/git-flow-completion"
    # "changyuheng/zsh-interactive-cd"
    "Aloxaf/fzf-tab"
    "lincheney/fzf-tab-completion"
    "wfxr/forgit"
    "NullSense/fuzzy-sys"
    # "bigH/auto-sized-fzf"
    # "kevinhwang91/fzf-tmux-script"
)

for Target in "${PluginList[@]}"; do
    TargetName=$(echo ${Target} | awk -F"/" '{print $NF}')
    Git_Clone_Update "${Target}" "${ZSH_CUSTOM}/plugins/${TargetName}"
done

# fzf-tab: speed up parse and apply filename colorizing
if [[ ! -s "${ZSH_CUSTOM}/plugins/fzf-tab/modules/Src/aloxaf/fzftab.so" ]]; then
    if [[ "$(command -v build-fzf-tab-module)" ]]; then
        colorEcho "${BLUE}Building fzf-tab modules..."
        build-fzf-tab-module >/dev/null
    fi
fi

# Custom themes
colorEcho "${BLUE}Oh-my-zsh custom themes..."
ThemeList=(
    # "zakaziko99/agnosterzak-ohmyzsh-theme"
    # "denysdovhan/spaceship-prompt"
    "romkatv/powerlevel10k"
    # "agkozak/agkozak-zsh-prompt"
    # "eendroroy/alien"
    # "sindresorhus/pure"
)

for Target in "${ThemeList[@]}"; do
    TargetName=$(echo ${Target} | awk -F"/" '{print $NF}')
    Git_Clone_Update "${Target}" "${ZSH_CUSTOM}/themes/${TargetName}"
done

# agnosterzak
[[ -L "$ZSH_CUSTOM/themes/agnosterzak.zsh-theme" ]] && \
    rm -f "$ZSH_CUSTOM/themes/agnosterzak.zsh-theme"
[[ -s "$ZSH_CUSTOM/themes/agnosterzak-ohmyzsh-theme/agnosterzak.zsh-theme" ]] && \
    ln -s "$ZSH_CUSTOM/themes/agnosterzak-ohmyzsh-theme/agnosterzak.zsh-theme" \
        "$ZSH_CUSTOM/themes/agnosterzak.zsh-theme"

# spaceship-prompt
[[ -L "$ZSH_CUSTOM/themes/spaceship.zsh-theme" ]] && \
    rm -f "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
[[ -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" ]] && \
    ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" \
        "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

# Powerlevel10k
[[ -L "$ZSH_CUSTOM/themes/powerlevel10k.zsh-theme" ]] && \
    rm -f "$ZSH_CUSTOM/themes/powerlevel10k.zsh-theme"
[[ -s "$ZSH_CUSTOM/themes/powerlevel10k/powerlevel10k.zsh-theme" ]] && \
    ln -s "$ZSH_CUSTOM/themes/powerlevel10k/powerlevel10k.zsh-theme" \
        "$ZSH_CUSTOM/themes/powerlevel10k.zsh-theme"

# agkozak
[[ -L "$ZSH_CUSTOM/themes/agkozak.zsh-theme" ]] && \
    rm -f "$ZSH_CUSTOM/themes/agkozak.zsh-theme"
[[ -s "$ZSH_CUSTOM/themes/agkozak-zsh-prompt/agkozak-zsh-prompt.plugin.zsh" ]] && \
    ln -s "$ZSH_CUSTOM/themes/agkozak-zsh-prompt/agkozak-zsh-prompt.plugin.zsh" \
        "$ZSH_CUSTOM/themes/agkozak.zsh-theme"

# alien
[[ -L "$ZSH_CUSTOM/themes/alien.zsh-theme" ]] && \
    rm -f "$ZSH_CUSTOM/themes/alien.zsh-theme"
[[ -s "$ZSH_CUSTOM/themes/alien/alien.plugin.zsh" ]] && \
    ln -s "$ZSH_CUSTOM/themes/alien/alien.plugin.zsh" \
        "$ZSH_CUSTOM/themes/alien.zsh-theme"


# Enable plugins
colorEcho "${BLUE}enable plugins..."

# plugin list
Plugins="git"

[[ "$(command -v git-flow)" ]] && Plugins="${Plugins} git-flow-avh"

[[ "${OS_INFO_TYPE}" == "darwin" ]] && Plugins="${Plugins} osx"

Plugins="${Plugins} cp z rsync sudo supervisor colored-man-pages"
# Plugins="${Plugins} command-time"

[[ -d "$HOME/.asdf" ]] && Plugins="${Plugins} asdf"

[[ -x "$(command -v tmux)" ]] && Plugins="${Plugins} tmux"
[[ -x "$(command -v autojump)" ]] && Plugins="${Plugins} autojump"
[[ -x "$(command -v composer)" ]] && Plugins="${Plugins} composer"
[[ -x "$(command -v docker)" ]] && Plugins="${Plugins} docker"
[[ -x "$(command -v docker-compose)" ]] && Plugins="${Plugins} docker-compose"
[[ -x "$(command -v docker-machine)" ]] && Plugins="${Plugins} docker-machine"
[[ -x "$(command -v kubectl)" ]] && Plugins="${Plugins} kubectl"
[[ -x "$(command -v fab)" ]] && Plugins="${Plugins} fabric"
[[ -x "$(command -v redis-cli)" ]] && Plugins="${Plugins} redis-cli"

[[ "$(command -v fuck)" ]] && Plugins="${Plugins} thefuck"

if [[ -x "$(command -v fzf)" || -d "$HOME/.fzf" ]]; then
    Plugins="${Plugins} fzf"
    [[ -d "${ZSH_CUSTOM}/plugins/fzf-tab" ]] && Plugins="${Plugins} fzf-tab"
else
    Plugins="${Plugins} zsh-interactive-cd"
fi

Plugins="${Plugins} zsh-autosuggestions fast-syntax-highlighting history-substring-search"

# Plugins="${Plugins} zsh-navigation-tools history-search-multi-word"


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


# nano
Git_Clone_Update "scopatz/nanorc" "$HOME/.local/share/nano"

colorEcho "${BLUE}nano settings..."
if [[ ! $(grep "set titlecolor" "$HOME/.nanorc") ]]; then
    echo "set titlecolor brightwhite,red" >> "$HOME/.nanorc"
fi

if [[ ! $(grep "set statuscolor" "$HOME/.nanorc") ]]; then
    echo "set statuscolor brightwhite,red" >> "$HOME/.nanorc"
fi

if [[ ! $(grep "set selectedcolor" "$HOME/.nanorc") ]]; then
    echo "set selectedcolor brightwhite,cyan" >> "$HOME/.nanorc"
fi

if [[ ! $(grep "set numbercolor" "$HOME/.nanorc") ]]; then
    echo "set numbercolor magenta" >> "$HOME/.nanorc"
fi

if [[ ! $(grep "set keycolor" "$HOME/.nanorc") ]]; then
    echo "set keycolor brightmagenta" >> "$HOME/.nanorc"
fi

if [[ ! $(grep "set functioncolor" "$HOME/.nanorc") ]]; then
    echo "set functioncolor magenta" >> "$HOME/.nanorc"
fi

# if [[ ! $(grep "set linenumbers" "$HOME/.nanorc") ]]; then
#     echo "set linenumbers" >> "$HOME/.nanorc"
# fi

if [[ -d "$HOME/.local/share/nano" ]]; then
    if [[ ! $(grep "\$HOME/.local/share/nano/\*\.nanorc" "$HOME/.nanorc") ]]; then
        echo "include \"$HOME/.local/share/nano/*.nanorc\"" >> "$HOME/.nanorc"
    fi
fi


cd "${CURRENT_DIR}"
# colorEcho "${GREEN}Update finished!"
