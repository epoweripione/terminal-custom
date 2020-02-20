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

# ostype: darwin, windows, linux, bsd, solaris
# spruce_type: amd64, 386
# VDIS: 64, 32, arm, arm64, mips64le, mips64, mipsle, mips, s390x, ppc64le, ppc64
if [[ -z "$spruce_type" ]]; then
    get_os_type
    get_arch
    get_sysArch
fi


# # Shadowsocks
# # Shadowsocks-Python：/etc/shadowsocks-python/config.json
# # ShadowsocksR: /etc/shadowsocks-r/config.json
# # Shadowsocks-Go：/etc/shadowsocks-go/config.json
# # Shadowsocks-libev：/etc/shadowsocks-libev/config.json

# # ./shadowsocks_exec.sh start | stop | restart | status
# if [[ ! -e "$HOME/shadowsocks_exec.sh" ]]; then
#     cat > shadowsocks_exec.sh <<EOF
# #!/bin/bash

# [ -e /etc/init.d/shadowsocks-r ] && /etc/init.d/shadowsocks-r \$1
# [ -e /etc/init.d/shadowsocks-libev ] && /etc/init.d/shadowsocks-libev \$1
# [ -e /etc/init.d/shadowsocks-python ] && /etc/init.d/shadowsocks-r \$1
# [ -e /etc/init.d/shadowsocks-go ] && /etc/init.d/shadowsocks-libev \$1

# if [ -x "\$(command -v supervisorctl)" ]; then
#     supervisorctl \$1 kcptun
# fi
# EOF

#     chmod +x shadowsocks_exec.sh
# fi


# if [[ -s "$HOME/shadowsocks-all.sh" ]]; then
#     source "$HOME/shadowsocks_exec.sh stop"
#     source "$HOME/shadowsocks-all.sh uninstall"
#     rm -fr shadowsocks-all* && rm -fr mbedtls-* libsodium-*
# fi

# # https://github.com/teddysun/shadowsocks_install/tree/master
# wget --no-check-certificate https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks-all.sh && \
#     chmod +x shadowsocks-all.sh && \
#     ./shadowsocks-all.sh 2>&1 | tee shadowsocks-all.log


# # Kcptun
# # https://github.com/kuoruan/shell-scripts/
# wget --no-check-certificate -O kcptun.sh https://github.com/kuoruan/shell-scripts/raw/master/kcptun/kcptun.sh && \
#     sh kcptun.sh


# Multi-V2Ray
# https://github.com/Jrohy/multi-v2ray
# /etc/v2ray_util/util.cfg
# /etc/v2ray/config.json
sudo rm -rf /etc/localtime && \
    TZ="Asia/Shanghai" && \
    sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ | sudo tee /etc/timezone >/dev/null

if [[ ! -x "$(command -v v2ray-util)" ]]; then
    colorEcho ${BLUE} "Installing v2ray-util..."

    source <(curl -sL https://multi.netlify.com/v2ray.sh) --zh
    # source <(curl -sL https://git.io/fNgqx) --zh
fi

# # V2Ray Client
# # https://www.v2ray.com/chapter_00/install.html
# bash <(curl -L -s https://install.direct/go.sh) && \
#     sudo systemctl enable v2ray && \
#     sudo systemctl start v2ray && \
#     sudo ln -sv /usr/bin/v2ray/v2ray /usr/local/bin/v2ray || true

# service v2ray start|stop|status|reload|restart|force-reload


# trojan
# https://github.com/trojan-gfw/trojan
if [[ ! -s "/srv/trojan/trojan" ]]; then
    colorEcho ${BLUE} "Installing trojan..."

    CHECK_URL="https://api.github.com/repos/trojan-gfw/trojan/releases/latest"

    CURRENT_VERSION="0.0.0"
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        DOWNLOAD_URL=https://github.com/trojan-gfw/trojan/releases/download/v${REMOTE_VERSION}/trojan-${REMOTE_VERSION}-${ostype}-${spruce_type}.tar.xz
        curl -SL -o trojan.tar.xz -C- $DOWNLOAD_URL && \
            tar -JxPf trojan.tar.xz -C /srv/ && \
            rm trojan.tar.xz

        if [[ ! -s "/etc/systemd/system/trojan.service" ]]; then
            sudo cp -f /srv/trojan/examples/trojan.service-example /etc/systemd/system/trojan.service
            sudo sed -i "s|ExecStart=.*|ExecStart=/srv/trojan/trojan -c /etc/trojan/trojan.json|" /etc/systemd/system/trojan.service
        fi

        if [[ -s "/etc/trojan/trojan.json" ]]; then
            # sudo systemctl enable trojan && sudo systemctl start trojan
            [[ $(systemctl is-enabled trojan 2>/dev/null) ]] || sudo systemctl enable trojan
            sudo systemctl restart trojan
        else
            sudo mkdir -p /etc/trojan && \
                sudo cp -f /srv/trojan/examples/server.json-example /etc/trojan/trojan.json
        fi
    fi
fi

# clash
# https://github.com/Dreamacro/clash
if [[ ! -s "/srv/clash/clash" ]]; then
    colorEcho ${BLUE} "Installing clash..."

    CHECK_URL="https://api.github.com/repos/Dreamacro/clash/releases/latest"

    CURRENT_VERSION="0.0.0"
    # REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    REMOTE_VERSION="0.17.1"
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        DOWNLOAD_URL=https://github.com/Dreamacro/clash/releases/download/v${REMOTE_VERSION}/clash-${ostype}-${spruce_type}-v${REMOTE_VERSION}.gz
        curl -SL -o clash-${ostype}-${spruce_type}.gz -C- $DOWNLOAD_URL && \
            mkdir -p /srv/clash && \
            mv clash-${ostype}-${spruce_type}.gz /srv/clash && \
            cd /srv/clash && \
            gzip -d clash-${ostype}-${spruce_type}.gz && \
            rm clash-${ostype}-${spruce_type}.gz && \
            chmod +x clash-linux-amd64 && \
            sudo ln -sv /srv/clash/clash-${ostype}-${spruce_type} /srv/clash/clash || true && \
            cd - >/dev/null 2>&1
    fi
    # nohup /srv/clash/clash -d /srv/clash >/dev/null 2>&1 & disown
fi

# subconverter
# https://github.com/tindy2013/subconverter
if [[ ! -s "/srv/subconverter/subconverter" ]]; then
    colorEcho ${BLUE} "Installing subconverter..."

    CHECK_URL="https://api.github.com/repos/tindy2013/subconverter/releases/latest"

    CURRENT_VERSION="0.0.0"
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        DOWNLOAD_URL=https://github.com/tindy2013/subconverter/releases/download/v${REMOTE_VERSION}/subconverter_${ostype}${VDIS}.tar.gz
        curl -SL -o subconverter.tar.gz -C- $DOWNLOAD_URL && \
            mkdir -p /srv/subconverter && \
            tar -zxPf subconverter.tar.gz -C /srv/subconverter && \
            rm subconverter.tar.gz && \
            echo ${REMOTE_VERSION} > /srv/subconverter/.version
    fi

    if [[ -s "/srv/subconverter/subconverter" ]]; then
        Install_systemd_Service "subconverter" "/srv/subconverter/subconverter"
    fi
    # nohup /srv/subconverter/subconverter >/dev/null 2>&1 & disown
    # http://127.0.0.1:25500/sub?target=clash&url=https%3A%2F%2Fjiang.netlify.com%2F&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fpref.ini
fi