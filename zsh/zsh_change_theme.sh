#!/usr/bin/env bash

# Colors
NOCOLOR='\033[0m'
RED='\033[0;31m'        # Error message
LIGHTRED='\033[1;31m'
GREEN='\033[0;32m'      # Success message
LIGHTGREEN='\033[1;32m'
ORANGE='\033[0;33m'
YELLOW='\033[1;33m'     # Warning message
BLUE='\033[0;34m'       # Info message
LIGHTBLUE='\033[1;34m'
PURPLE='\033[0;35m'
FUCHSIA='\033[0;35m'
LIGHTPURPLE='\033[1;35m'
CYAN='\033[0;36m'
LIGHTCYAN='\033[1;36m'
DARKGRAY='\033[1;30m'
LIGHTGRAY='\033[0;37m'
WHITE='\033[1;37m'

function colorEcho() {
    if [[ $# > 1 ]]; then
        local COLOR=$1
        echo -e "${COLOR}${@:2}${NOCOLOR}"
    else
        echo -e "${@:1}${NOCOLOR}"
    fi
}

changeTheme() {
    local theme="$1"
    local theme_name="$1"
    local custom_theme="zsh_custom_theme_${theme}"

    if [[ ! -s "$ZSH/themes/${theme}.zsh-theme" && ! -s "$ZSH_CUSTOM/themes/${theme}.zsh-theme" ]]; then
        colorEcho "${RED}Theme ${FUCHSIA}${theme}${RED} not exist!"
        exit
    fi

    # custom theme
    [[ "$theme" == "powerlevel9k" ]] && theme_name="powerlevel9k/powerlevel9k"

    # https://github.com/romkatv/powerlevel10k
    [[ "$theme" == "powerlevel10k" ]] && theme_name="powerlevel10k/powerlevel10k"
    [[ "$theme" != "powerlevel10k" ]] && sed -i "/\.p10k\.zsh/d" $HOME/.zshrc

    # https://github.com/sindresorhus/pure
    if [[ "$theme" == "pure" ]]; then
        theme_name=""
        sed $'$a \\\n' $HOME/.zshrc
        sed -i '$a source ${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/zsh/zsh_custom_pure_prompt.sh' $HOME/.zshrc
    else
        sed -i "/zsh_custom_pure_prompt\.sh/d" $HOME/.zshrc
    fi

    # change theme
    sed -i "s|^ZSH_THEME=.*|ZSH_THEME=\"${theme_name}\"|" $HOME/.zshrc

    # custom theme configuration
    sed -i "/zsh_custom_theme_.*/d" $HOME/.zshrc
    if [[ -s "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/zsh/${custom_theme}.sh" ]]; then
        sed -i "/^ZSH_THEME=.*/a\source ${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/zsh/${custom_theme}.sh" $HOME/.zshrc
    fi

    # .zshenv
    [[ -s $HOME/.zshenv ]] && rm -f $HOME/.zshenv

    if [[ "$theme" == "powerlevel9k" && $(tput colors) -ne 256 ]]; then
        cp ${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/zsh/zsh_custom_env_xterm.sh $HOME/.zshenv
        # sed -i '/^  command-time.*/d' $HOME/.zshrc
    else
        cp ${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/zsh/zsh_custom_env.sh $HOME/.zshenv
        # # if grep -q "command-time" $HOME/.zshrc; then
        # if [[ $(grep "command-time" $HOME/.zshrc) ]]; then
        #     :
        # else
        #     sed -i '/^  git/a\  command-time' $HOME/.zshrc
        # fi
    fi

    if [[ "$theme" == "powerlevel10k" && $(tput colors) -ne 256 ]]; then
        cp ${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/zsh/zsh_custom_env_xterm.sh $HOME/.zshenv
    else
        cp ${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/zsh/zsh_custom_env.sh $HOME/.zshenv
    fi

    colorEcho "${GREEN}ZSH theme has change to ${theme}，please exit and restart ZSH Shell!"
}


if [[ -z "$ZSH" ]]; then
    colorEcho "${RED}Please install ${FUCHSIA}ZSH & Oh-my-zsh${RED} first!"
    exit 0
else
    [[ -z "$ZSH_CUSTOM" ]] && ZSH_CUSTOM=$ZSH/custom
fi


PARAMS_NUM=$#

# get params
while [[ $# > 0 ]]; do
    theme="$1"
    changeTheme ${theme}
    # sed -i "s/[#]*[ ]*ZSH_THEME=.*/ZSH_THEME=\"${theme}\"/" $HOME/.zshrc
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
echo -e "7.powerlevel10k"
echo -e "8.spaceship"
echo -e "9.pure"

while :; do
    echo
	read -p "Please choose theme(enter to exit):" CHOICE
    [[ -z "$CHOICE" ]] && exit 0
	# if [[ ! $CHOICE =~ ^[0-9a-zA-Z]$ ]]; then
	if [[ ! $CHOICE =~ ^[0-9]$ ]]; then
		colorEcho "${RED}Input error, please choose theme from above!"
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
        changeTheme "powerlevel10k"
        ;;
    8)
        changeTheme "spaceship"
        ;;
    9)
        changeTheme "pure"
        ;;
    *)
        colorEcho "${YELLOW}Wrong choice!"  # unknown option
        ;;
esac
