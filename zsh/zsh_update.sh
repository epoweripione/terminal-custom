#!/bin/zsh

ostype=$(uname)

# ZSH
echo "Updating Oh-my-zsh..."
# upgrade_oh_my_zsh
cd $ZSH && git pull


# neofetch
echo "Updating neofetch..."
if [[ -d $HOME/neofetch ]]; then
  cd $HOME/neofetch && git pull
# else
  # git clone https://github.com/dylanaraps/neofetch $HOME/neofetch
  # cd $HOME/neofetch
  # if [[ $ostype == "Darwin" ]]; then
  #   make PREFIX=/usr/local install
  # elif [[ $ostype =~ "MSYS_NT" ]] || [[ $ostype =~ "CYGWIN_NT" ]]; then
  #   make -i install
  # else
  #   make install
  #  fi
fi


# custom plugins
echo "Updating custom plugins..."

# zsh-navigation-tools
# echo "Updating zsh-navigation-tools..."
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/psprint/zsh-navigation-tools/master/doc/install.sh)"

# fast-syntax-highlighting
echo "Updating fast-syntax-highlighting..."
if [[ -d $ZSH/custom/plugins/fast-syntax-highlighting ]]; then
  cd $ZSH/custom/plugins/fast-syntax-highlighting && git pull
else
  git clone https://github.com/zdharma/fast-syntax-highlighting.git $ZSH/custom/plugins/fast-syntax-highlighting
fi

# zsh-syntax-highlighting
echo "Updating zsh-syntax-highlighting..."
if [[ -d $ZSH/custom/plugins/zsh-syntax-highlighting ]]; then
  cd $ZSH/custom/plugins/zsh-syntax-highlighting && git pull
else
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH/custom/plugins/zsh-syntax-highlighting
fi

# zsh-autosuggestions
echo "Updating zsh-autosuggestions..."
if [[ -d $ZSH/custom/plugins/zsh-autosuggestions ]]; then
  cd $ZSH/custom/plugins/zsh-autosuggestions && git pull
else
  git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH/custom/plugins/zsh-autosuggestions
fi

# zsh-command-time
echo "Updating zsh-command-time..."
if [[ -d $ZSH/custom/plugins/command-time ]]; then
  cd $ZSH/custom/plugins/command-time && git pull
else
  git clone https://github.com/popstas/zsh-command-time.git $ZSH/custom/plugins/command-time
fi


# custom themes
echo "Updating custom themes..."

# agnosterzak
echo "Updating agnosterzak..."
if [[ -d $ZSH/custom/themes/agnosterzak ]]; then
  cd $ZSH/custom/themes/agnosterzak && git pull
else
  git clone https://github.com/zakaziko99/agnosterzak-ohmyzsh-theme.git $ZSH/custom/themes/agnosterzak
fi

[[ -L $ZSH/custom/themes/agnosterzak.zsh-theme ]] && rm -f $ZSH/custom/themes/agnosterzak.zsh-theme
ln -s $ZSH/custom/themes/agnosterzak/agnosterzak.zsh-theme $ZSH/custom/themes/agnosterzak.zsh-theme

# spaceship-prompt
echo "Updating spaceship-prompt..."
if [[ -d $ZSH/custom/themes/spaceship-prompt ]]; then
  cd $ZSH/custom/themes/spaceship-prompt && git pull
else
  git clone https://github.com/denysdovhan/spaceship-prompt.git $ZSH/custom/themes/spaceship-prompt
fi

[[ -L $ZSH/custom/themes/spaceship.zsh-theme ]] && rm -f $ZSH/custom/themes/spaceship.zsh-theme
ln -s $ZSH/custom/themes/spaceship-prompt/spaceship.zsh-theme $ZSH/custom/themes/spaceship.zsh-theme

# powerlevel9k
echo "Updating powerlevel9k..."
if [[ -d $ZSH/custom/themes/powerlevel9k ]]; then
  cd $ZSH/custom/themes/powerlevel9k && git pull
else
  git clone https://github.com/bhilburn/powerlevel9k.git $ZSH/custom/themes/powerlevel9k
fi

[[ -L $ZSH/custom/themes/powerlevel9k.zsh-theme ]] && rm -f $ZSH/custom/themes/powerlevel9k.zsh-theme
ln -s $ZSH/custom/themes/powerlevel9k/powerlevel9k.zsh-theme $ZSH/custom/themes/powerlevel9k.zsh-theme

# agkozak
echo "Updating agkozak..."
if [[ -d $ZSH/custom/themes/agkozak ]]; then
  cd $ZSH/custom/themes/agkozak && git pull
else
  git clone https://github.com/agkozak/agkozak-zsh-prompt.git $ZSH/custom/themes/agkozak
fi

[[ -L $ZSH/custom/themes/agkozak.zsh-theme ]] && rm -f $ZSH/custom/themes/agkozak.zsh-theme
ln -s $ZSH/custom/themes/agkozak/agkozak-zsh-prompt.plugin.zsh $ZSH/custom/themes/agkozak.zsh-theme

# alien
echo "Updating alien..."
if [[ -d $ZSH/custom/themes/alien ]]; then
  cd $ZSH/custom/themes/alien && git pull
else
  git clone https://github.com/eendroroy/alien.git $ZSH/custom/themes/alien
fi

[[ -L $ZSH/custom/themes/alien.zsh-theme ]] && rm -f $ZSH/custom/themes/alien.zsh-theme && \
ln -s $ZSH/custom/themes/alien/alien.plugin.zsh $ZSH/custom/themes/alien.zsh-theme


echo "Update finished!"
cd $HOME
