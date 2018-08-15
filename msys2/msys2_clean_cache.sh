#!/bin/bash

pacman -Scc

[ -d ~/.cache ] && rm -r ~/.cache
[ -e ~/.wget-hsts ] && rm -f ~/.wget-hsts
[ -e ~/.ssh/known_hosts ] && rm -f ~/.ssh/known_hosts
[ -e ~/.local/share/lftp/rl_history ] && rm -f ~/.local/share/lftp/rl_history

cat /dev/null > ~/.zsh_history
exec $SHELL -l

echo "Done"
