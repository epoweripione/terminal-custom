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

[[ -z "$OS_INFO_TYPE" ]] && get_os_type
[[ -z "$OS_INFO_ARCH" ]] && get_arch
[[ -z "$OS_INFO_VDIS" ]] && get_sysArch


# # Shadowsocks
# # Shadowsocks-Python：/etc/shadowsocks-python/config.json
# # ShadowsocksR: /etc/shadowsocks-r/config.json
# # Shadowsocks-Go：/etc/shadowsocks-go/config.json
# # Shadowsocks-libev：/etc/shadowsocks-libev/config.json

# # ./shadowsocks_exec.sh start | stop | restart | status
# if [[ ! -e "$HOME/shadowsocks_exec.sh" ]]; then
#     cat > shadowsocks_exec.sh <<EOF
# #!/usr/bin/env bash

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


## Multi-V2Ray
## https://github.com/Jrohy/multi-v2ray
## /etc/v2ray_util/util.cfg
## /etc/v2ray/config.json
# sudo rm -rf /etc/localtime && \
#     TZ="Asia/Shanghai" && \
#     sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
#     echo $TZ | sudo tee /etc/timezone >/dev/null

# if [[ ! -x "$(command -v v2ray-util)" ]]; then
#     colorEcho ${BLUE} "Installing v2ray-util..."

#     source <(curl -sL https://multi.netlify.com/v2ray.sh) --zh
#     # source <(curl -sL https://git.io/fNgqx) --zh
# fi


## https://github.com/v2fly/v2ray-core
## https://github.com/v2fly/fhs-install-v2ray
## /usr/local/etc/v2ray/config.json
## /var/log/v2ray/
## UUID: v2ctl uuid
if [[ ! -s "/usr/local/bin/v2ray" ]]; then
    colorEcho ${BLUE} "Installing v2ray-core..."

    CHECK_URL="https://api.github.com/repos/v2fly/v2ray-core/releases/latest"

    CURRENT_VERSION="0.0.0"
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        # https://github.com/v2fly/fhs-install-v2ray/wiki/Migrate-from-the-old-script-to-this
        if [[ -d "/usr/bin/v2ray/" ]]; then
            sudo systemctl disable v2ray.service --now
            sudo rm -rf /usr/bin/v2ray/ /etc/v2ray/
            sudo rm -f /etc/systemd/system/v2ray.service
            sudo rm -f /lib/systemd/system/v2ray.service
            sudo rm -f /etc/init.d/v2ray
        fi

        bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
        # bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-dat-release.sh)
    fi
fi


# trojan
# https://github.com/trojan-gfw/trojan
if [[ ! -s "/srv/trojan/trojan" ]]; then
    colorEcho ${BLUE} "Installing trojan..."

    CHECK_URL="https://api.github.com/repos/trojan-gfw/trojan/releases/latest"

    CURRENT_VERSION="0.0.0"
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        DOWNLOAD_URL="https://github.com/trojan-gfw/trojan/releases/download/v${REMOTE_VERSION}/trojan-${REMOTE_VERSION}-${OS_INFO_TYPE}-${OS_INFO_ARCH}.tar.xz"
        curl -SL -o "${WORKDIR}/trojan.tar.xz" -C- $DOWNLOAD_URL && \
            tar -JxPf "${WORKDIR}/trojan.tar.xz" -C "/srv/"

        if [[ ! -s "/etc/systemd/system/trojan.service" ]]; then
            sudo cp -f "/srv/trojan/examples/trojan.service-example" "/etc/systemd/system/trojan.service"
            sudo sed -i "s|ExecStart=.*|ExecStart=/srv/trojan/trojan -c /etc/trojan/trojan.json|" "/etc/systemd/system/trojan.service"
        fi

        if [[ -s "/etc/trojan/trojan.json" ]]; then
            # sudo systemctl enable trojan && sudo systemctl start trojan
            [[ $(systemctl is-enabled trojan 2>/dev/null) ]] || sudo systemctl enable trojan
            sudo systemctl restart trojan
        else
            sudo mkdir -p "/etc/trojan" && \
                sudo cp -f "/srv/trojan/examples/server.json-example" "/etc/trojan/trojan.json"
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
    # Pre-release
    REMOTE_VERSION=$(curl -s -N https://github.com/Dreamacro/clash/releases \
        | grep -Eo -m1 '\/releases\/tag\/v([0-9]{1,}\.)+[0-9]{1,}' \
        | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        DOWNLOAD_URL="https://github.com/Dreamacro/clash/releases/download/v${REMOTE_VERSION}/clash-${OS_INFO_TYPE}-${OS_INFO_ARCH}-v${REMOTE_VERSION}.gz"
        curl -SL -o "${WORKDIR}/clash-${OS_INFO_TYPE}-${OS_INFO_ARCH}.gz" -C- $DOWNLOAD_URL && \
            mkdir -p "/srv/clash" && \
            mv "${WORKDIR}/clash-${OS_INFO_TYPE}-${OS_INFO_ARCH}.gz" "/srv/clash" && \
            cd "/srv/clash" && \
            gzip -d "clash-${OS_INFO_TYPE}-${OS_INFO_ARCH}.gz" && \
            chmod +x "clash-${OS_INFO_TYPE}-${OS_INFO_ARCH}" && \
            sudo ln -sv "/srv/clash/clash-${OS_INFO_TYPE}-${OS_INFO_ARCH}" "/srv/clash/clash" || true
    fi

    # MMDB_URL="https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb"
    MMDB_URL="https://geolite.clash.dev/Country.mmdb"
    CHECK_URL="https://geolite.clash.dev/version"

    if [[ -s "/srv/clash/mmdb.ver" ]]; then
        CURRENT_VERSION=$(head -n1 /srv/clash/mmdb.ver)
    else
        CURRENT_VERSION="20000101"
    fi

    REMOTE_VERSION=$(wget -qO- $CHECK_URL)
    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        curl -SL -o "${WORKDIR}/Country.mmdb" "$MMDB_URL" && \
            mv -f "${WORKDIR}/Country.mmdb" "/srv/clash/Country.mmdb" && \
            echo ${REMOTE_VERSION} > "/srv/clash/mmdb.ver"
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
        DOWNLOAD_URL="https://github.com/tindy2013/subconverter/releases/download/v${REMOTE_VERSION}/subconverter_${OS_INFO_TYPE}${OS_INFO_VDIS}.tar.gz"
        curl -SL -o "${WORKDIR}/subconverter.tar.gz" -C- $DOWNLOAD_URL && \
            tar -zxPf "${WORKDIR}/subconverter.tar.gz" -C "/srv" && \
            echo ${REMOTE_VERSION} > "/srv/subconverter/.version"
    fi

    if [[ -s "/srv/subconverter/subconverter" ]]; then
        Install_systemd_Service "subconverter" "/srv/subconverter/subconverter"
    fi
    # nohup /srv/subconverter/subconverter >/dev/null 2>&1 & disown
    # http://127.0.0.1:25500/sub?target=clash&url=https%3A%2F%2Fjiang.netlify.com%2F&config=https%3A%2F%2Fraw.githubusercontent.com%2FACL4SSR%2FACL4SSR%2Fmaster%2FClash%2Fpref.ini
fi

cd "${CURRENT_DIR}"