#!/usr/bin/env bash

# Colors
NOCOLOR='\033[0m'
RED='\033[0;31m'        # Error message
LIGHTRED='\033[1;31m'
GREEN='\033[0;32m'      # Success message
LIGHTGREEN='\033[1;32m'
ORANGE='\033[0;33m'
YELLOW='\033[1;33m'     # Warning message
BLUE='\033[0;34m'       # Info message
LIGHTBLUE='\033[1;34m'
PURPLE='\033[0;35m'
FUCHSIA='\033[0;35m'
LIGHTPURPLE='\033[1;35m'
CYAN='\033[0;36m'
LIGHTCYAN='\033[1;36m'
DARKGRAY='\033[1;30m'
LIGHTGRAY='\033[0;37m'
WHITE='\033[1;37m'

function colorEcho() {
    if [[ $# > 1 ]]; then
        local COLOR=$1
        echo -e "${COLOR}${@:2}${NOCOLOR}"
    else
        echo -e "${@:1}${NOCOLOR}"
    fi
}

# Determine which desktop environment is installed from the shell
# desktop=$(ps -e | grep -E -i "gnome|kde|mate|cinnamon|lxde|xfce|jwm")
if [[ -n "$XDG_CURRENT_DESKTOP" ]]; then
    desktop=$(echo "$XDG_DATA_DIRS" | sed 's/.*\(gnome\|kde\|mate\|cinnamon\|lxde\|xfce\|jwm\).*/\1/')
else
    desktop=$XDG_CURRENT_DESKTOP
fi


# custom configuration
colorEcho "${BLUE}custom configuration..."
if [[ ! $(grep "zsh_custom_conf.sh" $HOME/.zshrc) ]]; then
    echo -e "\n# Custom configuration\nsource ~/terminal-custom/zsh/zsh_custom_conf.sh" >> $HOME/.zshrc
fi
# tee -a $HOME/.zshrc >/dev/null <<-'EOF'

# # Custom configuration
# source ~/terminal-custom/zsh/zsh_custom_conf.sh

# EOF


# change the command execution time stamp shown in the history command output
sed -i 's/[#]*[ ]*HIST_STAMPS.*/HIST_STAMPS="yyyy-mm-dd"/' $HOME/.zshrc

# disable auto update
sed -i "s/[#]*[ ]*DISABLE_AUTO_UPDATE.*/DISABLE_AUTO_UPDATE=\"true\"/" $HOME/.zshrc


# custom theme
colorEcho "${BLUE}custom theme..."
cp "~/terminal-custom/zsh/zsh_custom_env.sh" $HOME/.zshenv

theme="ys"
custom_theme="zsh_custom_theme_${theme}"

sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"${theme}\"/" $HOME/.zshrc

sed -i "/zsh_custom_theme_.*/d" $HOME/.zshrc
if [[ -s "~/terminal-custom/zsh/${custom_theme}.sh" ]]; then
    sed -i "/^ZSH_THEME=.*/a\source ~/terminal-custom/zsh/${custom_theme}.sh" $HOME/.zshrc
fi

# if [[ -n "$desktop" ]]; then
#   cp ~/terminal-custom/zsh/zsh_custom_env_xterm.sh $HOME/.zshenv
#   sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"powerlevel9k\"/" $HOME/.zshrc
#   sed -i "/zsh_custom_theme_.*/d" $HOME/.zshrc
#   sed -i "/^ZSH_THEME=.*/a\source ~/terminal-custom/zsh/zsh_custom_theme_powerlevel9k.sh" $HOME/.zshrc
#   # echo -e "\nsource ~/terminal-custom/zsh/zsh_custom_theme_powerlevel9k.sh" >> $HOME/.zshrc
# else
#   cp ~/terminal-custom/zsh/zsh_custom_env.sh $HOME/.zshenv
#   sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"agnosterzak-my\"/" $HOME/.zshrc
#   sed -i "/zsh_custom_theme_.*/d" $HOME/.zshrc
#   sed -i "/^ZSH_THEME=.*/a\source ~/terminal-custom/zsh/zsh_custom_theme_agnosterzak-my.sh" $HOME/.zshrc
# fi


colorEcho "${GREEN}ZSH init done, please restart ZSH!"
