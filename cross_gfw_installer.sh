#!/bin/bash

# Load custom functions
if type 'colorEcho' 2>/dev/null | grep -q 'function'; then
    :
else
    if [[ -s "$HOME/custom_functions.sh" ]]; then
        source "$HOME/custom_functions.sh"
    else
        echo "$HOME/custom_functions.sh not exist!"
        exit 0
    fi
fi


# Shadowsocks
# Shadowsocks-Python：/etc/shadowsocks-python/config.json
# ShadowsocksR: /etc/shadowsocks-r/config.json
# Shadowsocks-Go：/etc/shadowsocks-go/config.json
# Shadowsocks-libev：/etc/shadowsocks-libev/config.json

# ./shadowsocks_exec.sh start | stop | restart | status
if [[ ! -e "$HOME/shadowsocks_exec.sh" ]]; then
    cat > shadowsocks_exec.sh <<EOF
#!/bin/bash

[ -e /etc/init.d/shadowsocks-r ] && /etc/init.d/shadowsocks-r \$1
[ -e /etc/init.d/shadowsocks-libev ] && /etc/init.d/shadowsocks-libev \$1
[ -e /etc/init.d/shadowsocks-python ] && /etc/init.d/shadowsocks-r \$1
[ -e /etc/init.d/shadowsocks-go ] && /etc/init.d/shadowsocks-libev \$1

if [ -x "\$(command -v supervisorctl)" ]; then
    supervisorctl \$1 kcptun
fi
EOF

    chmod +x shadowsocks_exec.sh
fi


if [[ -s "$HOME/shadowsocks-all.sh" ]]; then
    source "$HOME/shadowsocks_exec.sh stop"
    source "$HOME/shadowsocks-all.sh uninstall"
    rm -fr shadowsocks-all* && rm -fr mbedtls-* libsodium-*
fi

wget --no-check-certificate https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks-all.sh && \
    chmod +x shadowsocks-all.sh && \
    ./shadowsocks-all.sh 2>&1 | tee shadowsocks-all.log


# Multi-V2Ray
# https://github.com/Jrohy/multi-v2ray
# /etc/v2ray/config.json
rm -rf /etc/localtime && \
    TZ="Asia/Shanghai" && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

if [[ -x "$(command -v v2ray)" ]]; then
    if v2ray -v 2>&1 | grep -q 'multi-v2ray'; then
        source <(curl -sL https://git.io/fNgqx) -k
    fi
else
    source <(curl -sL https://git.io/fNgqx)
fi


# V2Ray Client
# https://www.v2ray.com/chapter_00/install.html
bash <(curl -L -s https://install.direct/go.sh) && \
    systemctl enable v2ray && \
    systemctl start v2ray && \
    sudo ln -sv /usr/bin/v2ray/v2ray /usr/local/bin/v2ray || true

service v2ray start|stop|status|reload|restart|force-reload
