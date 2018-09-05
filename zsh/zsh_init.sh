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


# custom theme
colorEcho ${BLUE} "custom theme..."
cp ~/zsh_custom_env.sh ~/.zshenv

theme="agnosterzak-my"
custom_theme="zsh_custom_theme_${theme}"

sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"${theme}\"/" ~/.zshrc

sed -i "/^source ~\/zsh_custom_theme_.*/d" ~/.zshrc
if [[ -e ~/${custom_theme}.sh ]]; then
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


# enable plugins
colorEcho ${BLUE} "enable plugins..."
# if [[ ! $(grep "  command-time" ~/.zshrc) ]]; then
#   sed -i '/^  git/a\  command-time' ~/.zshrc
# fi

if [[ ! $(grep "  colored-man-pages" ~/.zshrc) ]]; then
  sed -i '/^  git/a\  colored-man-pages' ~/.zshrc
fi

if [[ ! $(grep "  zsh-autosuggestions" ~/.zshrc) ]]; then
  sed -i '/^  git/a\  zsh-autosuggestions' ~/.zshrc
fi

if [[ ! $(grep "  fast-syntax-highlighting" ~/.zshrc) ]]; then
  sed -i '/^  git/a\  fast-syntax-highlighting' ~/.zshrc
fi


# nano color settings
tee ~/.nanorc <<-'EOF'

set titlecolor brightwhite,red
set statuscolor brightwhite,red
# set selectedcolor brightwhite,cyan
set numbercolor magenta
set keycolor brightmagenta
set functioncolor magenta

include "/usr/share/nano/*.nanorc"
EOF

colorEcho ${GREEN} "ZSH init done, please restart ZSH!"
