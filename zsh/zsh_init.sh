#!/bin/bash

ostype=$(uname)

# Determine which desktop environment is installed from the shell
# desktop=$(ps -e | grep -E -i "gnome|kde|mate|cinnamon|lxde|xfce|jwm")
if [[ -n "$XDG_CURRENT_DESKTOP" ]]; then
  desktop=$(echo "$XDG_DATA_DIRS" | sed 's/.*\(gnome\|kde\|mate\|cinnamon\|lxde\|xfce\|jwm\).*/\1/')
else
  desktop=$XDG_CURRENT_DESKTOP
fi


# custom configuration
tee -a ~/.zshrc <<-'EOF'

# Custom configuration
source ~/zsh_custom_conf.sh

EOF


# change the command execution time stamp shown in the history command output
sed -i 's/[#]*[ ]*HIST_STAMPS.*/HIST_STAMPS="yyyy-mm-dd"/' ~/.zshrc


# custom theme
if [[ -n "$desktop" ]]; then
  cp ~/zsh_custom_env_xterm.sh ~/.zshenv
  sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"powerlevel9k\"/" ~/.zshrc
  sed -i "/^source ~\/zsh_custom_theme_.*/d" ~/.zshrc
  sed -i "/^ZSH_THEME=.*/a\source ~/zsh_custom_theme_powerlevel9k.sh" ~/.zshrc
  # echo -e "\nsource ~/zsh_custom_theme_powerlevel9k.sh" >> ~/.zshrc
else
  cp ~/zsh_custom_env.sh ~/.zshenv
  sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"agnosterzak-my\"/" ~/.zshrc
  sed -i "/^source ~\/zsh_custom_theme_.*/d" ~/.zshrc
  sed -i "/^ZSH_THEME=.*/a\source ~/zsh_custom_theme_agnosterzak-my.sh" ~/.zshrc
  #echo -e "\nsource ~/zsh_custom_theme_agnosterzak-my.sh" >> ~/.zshrc
fi


# enable plugins
echo "enable plugins..."
sed -i '/^  git/a\  command-time' ~/.zshrc
sed -i '/^  git/a\  colored-man-pages' ~/.zshrc
sed -i '/^  git/a\  zsh-autosuggestions' ~/.zshrc
sed -i '/^  git/a\  fast-syntax-highlighting' ~/.zshrc


# nano color settings
tee -a ~/.nanorc <<-'EOF'

set titlecolor brightwhite,red
set statuscolor brightwhite,red
# set selectedcolor brightwhite,cyan
set numbercolor magenta
set keycolor brightmagenta
set functioncolor magenta

include "/usr/share/nano/*.nanorc"
EOF
