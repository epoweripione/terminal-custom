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

# PageSpeed Insights
# https://developers.google.com/speed/pagespeed/insights/

# http://ping.chinaz.com/
# http://www.ipip.net/ping.php
# https://www.17ce.com/
# http://www.webkaka.com/
# http://ce.cloud.360.cn/
# 这几个在线测速工具各有各的优缺点，
# 推荐使用 ipip.net 测试服务器 IP 和路由追踪，
# 用 17ce.com 测试网页加载速度，
# 用 ping.chinaz.com 用国内不同地方的 Ping 值。

# bench.sh
# https://teddysun.com/444.html
function bench() {
    curl -fsSL -o- bench.sh | bash
}

# Superbench.sh & SuperSpeed.sh
# https://www.oldking.net/305.html
function SuperBench() {
    curl -fsSL -o- https://raw.githubusercontent.com/oooldking/script/master/superbench.sh | bash
}

function SuperSpeed() {
    wget https://raw.githubusercontent.com/oooldking/script/master/superspeed.sh && \
        chmod +x superspeed.sh && \
        ./superspeed.sh
}

function Besttrack() {
    wget -qO- git.io/besttrace | bash
}

function ZBench() {
    wget -qO- https://raw.githubusercontent.com/FunctionClub/ZBench/master/ZBench-CN.sh | bash
}

function LemonBenchFast() {
    curl -fsSL https://ilemonrain.com/download/shell/LemonBench.sh | bash -s fast
}

function LemonBenchFull() {
    curl -fsSL https://ilemonrain.com/download/shell/LemonBench.sh | bash -s full
}

function UnixBench() {
    wget --no-check-certificate https://github.com/teddysun/across/raw/master/unixbench.sh && \
        chmod +x unixbench.sh && \
        ./unixbench.sh
}

echo -e ""
echo -e "1.bench.sh(teddysun)"
echo -e "2.SuperBench.sh(oldking)"
echo -e "3.SuperSpeed.sh(oldking)"
echo -e "4.Besttrack"
echo -e "5.ZBench-CN.sh"
echo -e "6.LemonBench.sh(Fast)"
echo -e "7.LemonBench.sh(Full)"
echo -e "8.UnixBench.sh"

while :; do echo
	read -n1 -p "Please choose test(enter to exit):" CHOICE
	if [[ ! $CHOICE =~ ^[1-3]$ ]]; then
        if [[ -z ${CHOICE} ]]; then
            exit 0
        fi
		colorEcho "${RED}Input error, please choose test from above!"
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
    4)
        Besttrack
        ;;
    5)
        ZBench
        ;;
    6)
        LemonBenchFast
        ;;
    7)
        LemonBenchFull
        ;;
    8)
        UnixBench
        ;;
    *)
        colorEcho "${YELLOW}Wrong choice!"  # unknown option
        ;;
esac
