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

    sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"${theme}\"/" ~/.zshrc

    # custom theme configuration 
    sed -i "/^source ~\/zsh_custom_theme_.*/d" ~/.zshrc

    custom_theme="zsh_custom_theme_${theme}"
    if [[ -e ~/${custom_theme}.sh ]]; then
        sed -i "/^ZSH_THEME=.*/a\source ~/${custom_theme}.sh" ~/.zshrc
    fi

    # .zshenv
    [[ -e ~/.zshenv ]] && rm -f ~/.zshenv

    if [[ "$theme" == "powerlevel9k" ]]; then
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

    colorEcho ${GREEN} "ZSH 主题已更换为 ${theme}，重启 zsh 后生效！"
}


PARAMS_NUM=$#

#######get params#########
while [[ $# > 0 ]]; do
    theme="$1"
    sed -i "s/[#]*[ ]*ZSH_THEME=.*/ZSH_THEME=\"${theme}\"/" ~/.zshrc
    shift # past argument or value
done
#############################

##有参数输入操作一波后就结束
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
	read -n1 -p "请输入数字选择自定义主题(按回车键退出)：" CHOICE
	if [[ ! $CHOICE =~ ^[1-7]$ ]]; then
        if [[ -z ${CHOICE} ]]; then
            exit 0
        fi
		colorEcho ${RED} "输入错误，请输入正确的数字！"
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
        colorEcho ${YELLOW} "传参有误！"  # unknown option
        ;;
esac
