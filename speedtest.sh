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

# bench.sh
# https://teddysun.com/444.html
function bench() {
    curl -Lso- bench.sh | bash
}

# Superbench.sh & SuperSpeed.sh
# https://www.oldking.net/305.html
function SuperBench() {
    curl -Lso- https://raw.githubusercontent.com/oooldking/script/master/superbench.sh | bash
}

function SuperSpeed() {
    wget https://raw.githubusercontent.com/oooldking/script/master/superspeed.sh && \
        chmod +x superspeed.sh && \
        ./superspeed.sh
}

echo -e ""
echo -e "1.bench.sh(teddysun)"
echo -e "2.SuperBench.sh(oldking)"
echo -e "3.SuperSpeed.sh(oldking)"

while :; do echo
	read -n1 -p "Please choose test(enter to exit):" CHOICE
	if [[ ! $CHOICE =~ ^[1-3]$ ]]; then
        if [[ -z ${CHOICE} ]]; then
            exit 0
        fi
		colorEcho ${RED} "Input error, please choose test from above!"
	else
        echo -e "\n"
		break
	fi
done

case "$CHOICE" in
    1)
        bench
        ;;
    2)
        SuperBench
        ;;
    3)
        SuperSpeed
        ;;
    *)
        colorEcho ${YELLOW} "Wrong choice!"  # unknown option
        ;;
esac
