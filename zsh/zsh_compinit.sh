#!/bin/zsh

if [[ "$ZSH_VERSION" ]]; then
  rm -f ~/.zcompdump*
  autoload -U compinit && compinit
  if [[ -e ~/.zcompdump ]]; then
    [[ -n "$HOST" ]] && cp ~/.zcompdump ~/.zcompdump-$HOST-$ZSH_VERSION
    [[ -n "$HOSTNAME" ]] && cp ~/.zcompdump ~/.zcompdump-$HOSTNAME-$ZSH_VERSION
  fi
fi

# recreate soft link
[[ -L $ZSH/custom/themes/agnosterzak.zsh-theme ]] && rm -f $ZSH/custom/themes/agnosterzak.zsh-theme
ln -s $ZSH/custom/themes/agnosterzak/agnosterzak.zsh-theme $ZSH/custom/themes/agnosterzak.zsh-theme

[[ -L $ZSH/custom/themes/spaceship.zsh-theme ]] && rm -f $ZSH/custom/themes/spaceship.zsh-theme
ln -s $ZSH/custom/themes/spaceship-prompt/spaceship.zsh-theme $ZSH/custom/themes/spaceship.zsh-theme

[[ -L $ZSH/custom/themes/powerlevel9k.zsh-theme ]] && rm -f $ZSH/custom/themes/powerlevel9k.zsh-theme
ln -s $ZSH/custom/themes/powerlevel9k/powerlevel9k.zsh-theme $ZSH/custom/themes/powerlevel9k.zsh-theme

[[ -L $ZSH/custom/themes/agkozak.zsh-theme ]] && rm -f $ZSH/custom/themes/agkozak.zsh-theme
ln -s $ZSH/custom/themes/agkozak/agkozak-zsh-prompt.plugin.zsh $ZSH/custom/themes/agkozak.zsh-theme

[[ -L $ZSH/custom/themes/alien.zsh-theme ]] && rm -f $ZSH/custom/themes/alien.zsh-theme
ln -s $ZSH/custom/themes/alien/alien.plugin.zsh $ZSH/custom/themes/alien.zsh-theme
