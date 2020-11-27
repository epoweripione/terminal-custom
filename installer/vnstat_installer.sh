#!/usr/bin/env bash

trap 'rm -r "$WORKDIR"' EXIT

[[ -z "$WORKDIR" ]] && WORKDIR="$(mktemp -d)"
[[ -z "$CURRENT_DIR" ]] && CURRENT_DIR=$(pwd)

# Load custom functions
if type 'colorEcho' 2>/dev/null | grep -q 'function'; then
    :
else
    if [[ -s "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/custom_functions.sh" ]]; then
        source "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/custom_functions.sh"
    else
        echo "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/custom_functions.sh not exist!"
        exit 0
    fi
fi


if [[ ! -x "$(command -v pacaptr)" ]]; then
    [[ -s "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/installer/pacaptr_installer.sh" ]] && \
        source "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/installer/pacaptr_installer.sh"
fi


colorEcho ${BLUE} "Installing vnstat..."
if pacman -Si sqlite-devel >/dev/null 2>&1; then
    pacman --noconfirm -S sqlite sqlite-devel
else
    pacman --noconfirm -S libsqlite3-dev
fi


cd "${WORKDIR}" && \
    curl -SL -o vnstat.tar.gz https://humdi.net/vnstat/vnstat-latest.tar.gz && \
    sudo tar xvzf vnstat.tar.gz && \
    sudo mv vnstat-* vnstat && cd vnstat/ && \
    sudo ./configure --prefix=/usr --sysconfdir=/etc && \
    sudo make && \
    sudo make install && \
    : && \
    sudo cp -v examples/systemd/vnstat.service /etc/systemd/system/ && \
    sudo sed -i -e '/^ProtectSystem=/d' /etc/systemd/system/vnstat.service && \
    sudo systemctl enable vnstat && \
    sudo systemctl start vnstat

cd "${CURRENT_DIR}"

# 如遇到 Failed to restart vnstat.service: Unit vnstat.service is masked.
# 请删除 /etc/systemd/system/ 下的 vnstat.service 文件

# Error: Unable to open database "/var/lib/vnstat/vnstat.db": No such file or directory
# update-rc.d vnstat defaults && service vnstat start
# [ -d /var/lib/vnstat ] && rm -r /var/lib/vnstat
# mkdir -p /var/lib/vnstat && chown -R vnstat:vnstat /var/lib/vnstat

# 定时生成数据库
# vnstat -u -i eth0

# nano /etc/cron.d/vnstat
# # 写入如下内容
# 0-55/5 *        * * *   root   vnstat -u -i eth0
# 0-55/5 *        * * *   root   vnstat --dumpdb -i eth0 >/var/lib/vnstat/vnstat_dump_eth0

# service vnstat restart
