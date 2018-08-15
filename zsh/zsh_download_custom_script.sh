#!/bin/bash

## How to use
## cd ~ && curl -fSL https://github.com/epoweripione/terminal-custom/raw/master/zsh/zsh_download_custom_script.sh -o ~/zsh_download_custom_script.sh && chmod +x ~/zsh_download_custom_script.sh && ./zsh_download_custom_script.sh && ./zsh_update.sh

git clone https://github.com/epoweripione/terminal-custom.git ~/terminal-custom

# copy *.sh to HOME
cp -f ~/terminal-custom/zsh/*.sh ~

chmod +x ~/clean_zsh_history.sh
chmod +x ~/hosts_update.sh
chmod +x ~/install_fonts.sh
chmod +x ~/zsh_change_theme.sh
chmod +x ~/zsh_compinit.sh
chmod +x ~/zsh_init.sh
chmod +x ~/zsh_update.sh
chmod +x ~/terminal_colors.sh


# zsh custom plugins
cp -f ~/terminal-custom/zsh/plugins/*.zsh-theme $ZSH/custom/plugins


# zsh custom themes
cp -f ~/terminal-custom/zsh/themes/*.zsh-theme $ZSH/custom/themes
