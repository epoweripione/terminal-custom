#!/bin/bash

#######color code########
# https://misc.flogisoft.com/bash/tip_colors_and_formatting
RED="31m"      # Error message
GREEN="32m"    # Success message
YELLOW="33m"   # Warning message
BLUE="36m"     # Info message

colorEcho() {
    COLOR=$1
    echo -e "\033[${COLOR}${@:2}\033[0m"
}

changeTheme() {
    theme="$1"
    custom_theme="zsh_custom_theme_${theme}"

    # custom theme
    sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"${theme}\"/" ~/.zshrc

    # custom theme configuration
    sed -i "/^source ~\/zsh_custom_theme_.*/d" ~/.zshrc
    if [[ -e ~/${custom_theme}.sh ]]; then
        sed -i "/^ZSH_THEME=.*/a\source ~/${custom_theme}.sh" ~/.zshrc
    fi

    # .zshenv
    [[ -e ~/.zshenv ]] && rm -f ~/.zshenv

    if [[ "$theme" == "powerlevel9k" && $(tput colors) -ne 256 ]]; then
        cp ~/zsh_custom_env_xterm.sh ~/.zshenv
        # sed -i '/^  command-time.*/d' ~/.zshrc
    else
        cp ~/zsh_custom_env.sh ~/.zshenv
        # # if grep -q "command-time" ~/.zshrc; then
        # if [[ $(grep "command-time" ~/.zshrc) ]]; then
        #     :
        # else
        #     sed -i '/^  git/a\  command-time' ~/.zshrc
        # fi
    fi

    colorEcho ${GREEN} "ZSH theme has change to ${theme}，please exit and restart ZSH Shell!"
}


PARAMS_NUM=$#

# get params
while [[ $# > 0 ]]; do
    theme="$1"
    sed -i "s/[#]*[ ]*ZSH_THEME=.*/ZSH_THEME=\"${theme}\"/" ~/.zshrc
    shift # past argument or value
done

# if pass a valid param then exit
[[ $PARAMS_NUM > 0 ]] && exit

echo -e ""
echo -e "1.agkozak"
echo -e "2.agnosterzak"
echo -e "3.agnosterzak-my"
echo -e "4.alien"
echo -e "5.powerlevel9k"
echo -e "6.spaceship"
echo -e "7.ys-my"

while :; do echo
	read -n1 -p "Please choose theme(enter to exit):" CHOICE
	if [[ ! $CHOICE =~ ^[1-7]$ ]]; then
        if [[ -z ${CHOICE} ]]; then
            exit 0
        fi
		colorEcho ${RED} "Input error, please choose theme from above!"
	else
        echo -e "\n"
		break
	fi
done

case "$CHOICE" in
    1)
        changeTheme "agkozak"
        ;;
    2)
        changeTheme "agnosterzak"
        ;;
    3)
        changeTheme "agnosterzak-my"
        ;;
    4)
        changeTheme "alien"
        ;;
    5)
        changeTheme "powerlevel9k"
        ;;
    6)
        changeTheme "spaceship"
        ;;
    7)
        changeTheme "ys-my"
        ;;
    *)
        colorEcho ${YELLOW} "Wrong choice!"  # unknown option
        ;;
esac
