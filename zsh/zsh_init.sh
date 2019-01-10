#!/bin/bash

#######color code########
RED="31m"      # Error message
GREEN="32m"    # Success message
YELLOW="33m"   # Warning message
BLUE="36m"     # Info message

colorEcho() {
    COLOR=$1
    echo -e "\033[${COLOR}${@:2}\033[0m"
}

# Determine which desktop environment is installed from the shell
# desktop=$(ps -e | grep -E -i "gnome|kde|mate|cinnamon|lxde|xfce|jwm")
if [[ -n "$XDG_CURRENT_DESKTOP" ]]; then
    desktop=$(echo "$XDG_DATA_DIRS" | sed 's/.*\(gnome\|kde\|mate\|cinnamon\|lxde\|xfce\|jwm\).*/\1/')
else
    desktop=$XDG_CURRENT_DESKTOP
fi


# custom configuration
colorEcho ${BLUE} "custom configuration..."
if [[ ! $(grep "zsh_custom_conf.sh" ~/.zshrc) ]]; then
    echo -e "\n# Custom configuration\nsource ~/zsh_custom_conf.sh" >> ~/.zshrc
fi
# tee -a ~/.zshrc <<-'EOF'

# # Custom configuration
# source ~/zsh_custom_conf.sh

# EOF


# change the command execution time stamp shown in the history command output
sed -i 's/[#]*[ ]*HIST_STAMPS.*/HIST_STAMPS="yyyy-mm-dd"/' ~/.zshrc

# disable auto update
sed -i "s/[#]*[ ]*DISABLE_AUTO_UPDATE.*/DISABLE_AUTO_UPDATE=\"true\"/" ~/.zshrc


# custom theme
colorEcho ${BLUE} "custom theme..."
cp ~/zsh_custom_env.sh ~/.zshenv

theme="agnosterzak-my"
custom_theme="zsh_custom_theme_${theme}"

sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"${theme}\"/" ~/.zshrc

sed -i "/^source ~\/zsh_custom_theme_.*/d" ~/.zshrc
if [[ -s ~/${custom_theme}.sh ]]; then
    sed -i "/^ZSH_THEME=.*/a\source ~/${custom_theme}.sh" ~/.zshrc
fi

# if [[ -n "$desktop" ]]; then
#   cp ~/zsh_custom_env_xterm.sh ~/.zshenv
#   sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"powerlevel9k\"/" ~/.zshrc
#   sed -i "/^source ~\/zsh_custom_theme_.*/d" ~/.zshrc
#   sed -i "/^ZSH_THEME=.*/a\source ~/zsh_custom_theme_powerlevel9k.sh" ~/.zshrc
#   # echo -e "\nsource ~/zsh_custom_theme_powerlevel9k.sh" >> ~/.zshrc
# else
#   cp ~/zsh_custom_env.sh ~/.zshenv
#   sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"agnosterzak-my\"/" ~/.zshrc
#   sed -i "/^source ~\/zsh_custom_theme_.*/d" ~/.zshrc
#   sed -i "/^ZSH_THEME=.*/a\source ~/zsh_custom_theme_agnosterzak-my.sh" ~/.zshrc
#   #echo -e "\nsource ~/zsh_custom_theme_agnosterzak-my.sh" >> ~/.zshrc
# fi


colorEcho ${GREEN} "ZSH init done, please restart ZSH!"
