#!/bin/zsh

GREEN="32m"

cat /dev/null > ~/.zsh_history

# exec $SHELL -l

echo "\033[${GREEN}Done, please restart ZSH!\033[0m"
