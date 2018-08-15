#!/bin/bash

## How to use
## cd ~ && curl -fSL https://github.com/epoweripione/terminal-custom/raw/master/zsh/zsh_download_custom_script.sh -o ~/zsh_download_custom_script.sh && chmod +x ~/zsh_download_custom_script.sh && ./zsh_download_custom_script.sh && ./zsh_update.sh

ostype=$(uname)

git clone https://github.com/epoweripione/terminal-custom.git ~/terminal-custom

# copy *.sh to HOME
cp -f ~/terminal-custom/*.sh ~
chmod +x ~/hosts_update.sh
chmod +x ~/install_fonts.sh
chmod +x ~/terminal_colors.sh
chmod +x ~/terminal_fillrow.sh

cp -f ~/terminal-custom/zsh/*.sh ~
chmod +x ~/zsh_change_theme.sh
chmod +x ~/zsh_clean_history.sh
chmod +x ~/zsh_compinit.sh
chmod +x ~/zsh_download_custom_script.sh
chmod +x ~/zsh_init.sh
chmod +x ~/zsh_update.sh

if [[ $ostype =~ "MSYS_NT" || $ostype =~ "CYGWIN_NT" ]]; then
    cp -f ~/terminal-custom/zsh/*.sh ~
    chmod +x ~/chromium_download.sh
    chmod +x ~/msys2_clean_cache.sh
    chmod +x ~/msys2_pacman_mirrors.sh
fi

# zsh custom plugins
cp -f ~/terminal-custom/zsh/plugins/*.zsh-theme $ZSH/custom/plugins


# zsh custom themes
cp -f ~/terminal-custom/zsh/themes/*.zsh-theme $ZSH/custom/themes
