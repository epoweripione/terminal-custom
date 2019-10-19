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
    local theme="$1"
    local theme_name="$1"
    local custom_theme="zsh_custom_theme_${theme}"

    if [[ ! -s "$ZSH/themes/${theme}.zsh-theme" && ! -s "$ZSH_CUSTOM/themes/${theme}.zsh-theme" ]]; then
        colorEcho ${RED} "Theme ${theme} not exist!"
        exit
    fi

    # custom theme
    [[ "$theme" == "powerlevel9k" ]] && theme_name="powerlevel9k/powerlevel9k"

    # https://github.com/romkatv/powerlevel10k
    [[ "$theme" == "powerlevel10k" ]] && theme_name="powerlevel10k/powerlevel10k"
    [[ "$theme" != "powerlevel10k" ]] && sed -i "/\.p10k\.zsh/d" ~/.zshrc

    # https://github.com/sindresorhus/pure
    if [[ "$theme" == "pure" ]]; then
        theme_name=""
        sed $'$a \\\n' ~/.zshrc
        sed -i '$a source ~/zsh_custom_pure_prompt.sh' ~/.zshrc
    else
        sed -i "/^source ~\/zsh_custom_pure_prompt\.sh/d" ~/.zshrc
    fi

    # change theme
    sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"${theme_name}\"/" ~/.zshrc

    # custom theme configuration
    sed -i "/^source ~\/zsh_custom_theme_.*/d" ~/.zshrc
    if [[ -s ~/${custom_theme}.sh ]]; then
        sed -i "/^ZSH_THEME=.*/a\source ~/${custom_theme}.sh" ~/.zshrc
    fi

    # .zshenv
    [[ -s ~/.zshenv ]] && rm -f ~/.zshenv

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

    if [[ "$theme" == "powerlevel10k" && $(tput colors) -ne 256 ]]; then
        cp ~/zsh_custom_env_xterm.sh ~/.zshenv
    else
        cp ~/zsh_custom_env.sh ~/.zshenv
    fi

    colorEcho ${GREEN} "ZSH theme has change to ${theme}，please exit and restart ZSH Shell!"
}


if [[ -z "$ZSH" ]]; then
    colorEcho ${RED} "Please install ZSH & Oh-my-zsh first!"
    exit 0
else
    [[ -z "$ZSH_CUSTOM" ]] && ZSH_CUSTOM=$ZSH/custom
fi


PARAMS_NUM=$#

# get params
while [[ $# > 0 ]]; do
    theme="$1"
    changeTheme ${theme}
    # sed -i "s/[#]*[ ]*ZSH_THEME=.*/ZSH_THEME=\"${theme}\"/" ~/.zshrc
    shift # past argument or value
done

# if pass a valid param then exit
[[ $PARAMS_NUM > 0 ]] && exit

echo -e ""
echo -e "1.ys"
echo -e "2.ys-my"
echo -e "3.agnosterzak"
echo -e "4.agnosterzak-my"
echo -e "5.agkozak"
echo -e "6.alien"
echo -e "7.powerlevel9k"
echo -e "8.powerlevel10k"
echo -e "9.spaceship"
echo -e "A.pure"

while :; do echo
	read -p "Please choose theme(enter to exit):" CHOICE
    [[ -z ${CHOICE} ]] && exit 0
	if [[ ! $CHOICE =~ ^[0-9a-zA-Z]$ ]]; then
		colorEcho ${RED} "Input error, please choose theme from above!"
	else
		break
	fi
done

case "$CHOICE" in
    1)
        changeTheme "ys"
        ;;
    2)
        changeTheme "ys-my"
        ;;
    3)
        changeTheme "agnosterzak"
        ;;
    4)
        changeTheme "agnosterzak-my"
        ;;
    5)
        changeTheme "agkozak"
        ;;
    6)
        changeTheme "alien"
        ;;
    7)
        changeTheme "powerlevel9k"
        ;;
    8)
        changeTheme "powerlevel10k"
        ;;
    9)
        changeTheme "spaceship"
        ;;
    a | A)
        changeTheme "pure"
        ;;
    *)
        colorEcho ${YELLOW} "Wrong choice!"  # unknown option
        ;;
esac
