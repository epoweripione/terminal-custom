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

[[ -z "$ostype" ]] && get_os_type && get_arch && get_sysArch

# jq
if [[ ! -x "$(command -v jq)" ]]; then
    if [[ -x "$(command -v pacapt)" || -x "$(command -v pacman)" ]]; then
        if pacman -Si jq >/dev/null 2>&1; then
            colorEcho ${BLUE} "Installing jq..."
            sudo pacman --noconfirm -S jq
        fi
    fi
fi

if [[ ! -x "$(command -v jq)" ]]; then
    colorEcho ${RED} "jq is not installed!"
    exit 1
fi


# V2Ray Client
# https://www.v2ray.com/chapter_00/install.html
# service v2ray start|stop|status|reload|restart|force-reload
function install_v2ray_client() {
    local CURRENT_VERSION
    local DOWNLOAD_URL
    local CHECK_URL="https://api.github.com/repos/v2ray/v2ray-core/releases/latest"
    local REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

    CURRENT_VERSION="0.0.0"
    if [[ $(systemctl is-enabled v2ray 2>/dev/null) ]]; then
        CURRENT_VERSION=$(v2ray --version | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
    fi

    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        if [[ "$CURRENT_VERSION" == "0.0.0" ]]; then
            colorEcho ${BLUE} "Installing v2ray-core..."
        else
            colorEcho ${BLUE} "Updating v2ray-core..."
        fi

        # bash <(curl -L -s https://install.direct/go.sh)

        echo "Download URL for v2ray-core?"
        read -p "[Use github by default] " DOWNLOAD_URL
        [[ -z "$DOWNLOAD_URL" ]] && \
            DOWNLOAD_URL=https://github.com/v2ray/v2ray-core/releases/download/v${REMOTE_VERSION}/v2ray-${ostype}-${VDIS}.zip

        # curl -SL -o v2ray-core.zip $DOWNLOAD_URL && \
        wget -c -O v2ray-core.zip $DOWNLOAD_URL && \
            curl -sL https://install.direct/go.sh | sudo bash -s -- --local ./v2ray-core.zip && \
            rm -f ./v2ray-core.zip && \
            sudo ln -sv /usr/bin/v2ray/v2ray /usr/local/bin/v2ray || true
    fi
}

# Get v2ray config from subscriptions
function get_v2ray_config_from_subscription() {
    local SUBSCRIBE_URL=${1:-"https://jiang.netlify.com/"}
    local V2RAY_ADDRESS=${2:-"127.0.0.1:55880"}

    local VMESS_FILENAME="/tmp/v2ray.vmess"
    local DECODE_FILENAME="/tmp/v2ray_decode.vmess"
    local exitStatus=1

    colorEcho ${BLUE} "  Getting v2ray subscriptions..."
    curl -sSf -4 --connect-timeout 10 --max-time 30 \
        -o "${VMESS_FILENAME}" "${SUBSCRIBE_URL}"
    if [[ $? != 0 ]]; then
        colorEcho ${RED} "  Can't get the subscriptions from ${SUBSCRIBE_URL}!"
        return 1
    fi

    if [[ -s "${VMESS_FILENAME}" ]]; then
        base64 -d "${VMESS_FILENAME}" > "${DECODE_FILENAME}"
        # sed -i -e '/^ss:\/\//d' -e '/^ssr:\/\//d' "${DECODE_FILENAME}"
        sed -i '/^vmess:\/\//!d' "${DECODE_FILENAME}"
        sed -i 's|^vmess://||g' "${DECODE_FILENAME}"
    fi

    if [[ ! -s "${DECODE_FILENAME}" ]]; then
        colorEcho ${RED} "  Can't get the subscriptions from ${SUBSCRIBE_URL}!"
        return 1
    fi

    colorEcho ${BLUE} "  Testing v2ray config from subscriptions..."
    # Decode subscriptions line by line
    local V2RAY_PORT
    local READLINE
    local VMESS_CONFIG
    local VMESS_PS
    local VMESS_ADDR
    local VMESS_PORT
    local VMESS_USER_ID
    local VMESS_USER_ALTERID
    local VMESS_NETWORK
    local VMESS_TYPE
    local VMESS_SECURITY
    local VMESS_TLS_SETTINGS
    local VMESS_WS_HOST
    local VMESS_WS_PATH
    local VMESS_WS_SETTINGS
    local VMESS_KCP_SETTINGS

    V2RAY_PORT=$(echo "$V2RAY_ADDRESS" | cut -d":" -f2)

    while read -r READLINE; do
        [[ -z "${READLINE}" ]] && continue

        VMESS_CONFIG=$(echo "${READLINE}" | base64 -di)
        [[ -z "${VMESS_CONFIG}" ]] && continue

        VMESS_PS=$(echo "${VMESS_CONFIG}" | jq -r '.ps//empty')
        VMESS_ADDR=$(echo "${VMESS_CONFIG}" | jq -r '.add//empty')
        VMESS_PORT=$(echo "${VMESS_CONFIG}" | jq -r '.port//empty')
        [[ -z "${VMESS_ADDR}" || -z "${VMESS_PORT}" ]] && continue

        VMESS_USER_ID=$(echo "${VMESS_CONFIG}" | jq -r '.id//empty')
        VMESS_USER_ALTERID=$(echo "${VMESS_CONFIG}" | jq -r '.aid//empty')
        VMESS_NETWORK=$(echo "${VMESS_CONFIG}" | jq -r '.net//empty')
        VMESS_TYPE=$(echo "${VMESS_CONFIG}" | jq -r '.type//empty')
        VMESS_SECURITY=$(echo "${VMESS_CONFIG}" | jq -r '.tls//empty')
        VMESS_WS_HOST=$(echo "${VMESS_CONFIG}" | jq -r '.host//empty')
        VMESS_WS_PATH=$(echo "${VMESS_CONFIG}" | jq -r '.path//empty')

        colorEcho ${BLUE} "  Testing ${VMESS_PS} ${VMESS_ADDR}:${VMESS_PORT}..."
        if [[ -z "${VMESS_SECURITY}" ]]; then
            VMESS_SECURITY=$(echo "null")
        else
            VMESS_SECURITY=$(echo "\"${VMESS_SECURITY}\"")
        fi

        VMESS_TLS_SETTINGS=$(echo "null")
        VMESS_WS_SETTINGS=$(echo "null")
        VMESS_KCP_SETTINGS=$(echo "null")

        if [[ "${VMESS_NETWORK}" == "ws" ]]; then
            if [[ -z "${VMESS_WS_PATH}" ]]; then
                VMESS_WS_PATH=$(echo "null")
            else
                VMESS_WS_PATH=$(echo "\"${VMESS_WS_PATH}\"")
            fi

            if [[ -z "${VMESS_WS_HOST}" ]]; then
                VMESS_WS_HOST=$(echo "null")
            else
                VMESS_WS_HOST=$(echo "\"${VMESS_WS_HOST}\"")
            fi

            VMESS_TLS_SETTINGS=$({ \
                    echo "{"; \
                    echo "                    \"allowInsecure\": false,"; \
                    echo "                    \"serverName\": ${VMESS_WS_HOST}"; \
                    echo "                }"; \
                })

            if [[ "${VMESS_WS_HOST}" == "null" ]]; then
                VMESS_WS_SETTINGS=$({ \
                        echo "{"; \
                        echo "                    \"connectionReuse\": true,"; \
                        echo "                    \"path\": ${VMESS_WS_PATH},"; \
                        echo "                    \"headers\": null"; \
                        echo "                }"; \
                    })
            else
                VMESS_WS_SETTINGS=$({ \
                        echo "{"; \
                        echo "                    \"connectionReuse\": true,"; \
                        echo "                    \"path\": ${VMESS_WS_PATH},"; \
                        echo "                    \"headers\": {"; \
                        echo "                        \"Host\": ${VMESS_WS_HOST}"; \
                        echo "                    }"; \
                        echo "                }"; \
                    })
            fi
        elif [[ "${VMESS_NETWORK}" == "kcp" ]]; then
            VMESS_KCP_SETTINGS=$({ \
                    echo "{"; \
                    echo "                    \"mtu\": 1350,"; \
                    echo "                    \"tti\": 50,"; \
                    echo "                    \"uplinkCapacity\": 12,"; \
                    echo "                    \"downlinkCapacity\": 100,"; \
                    echo "                    \"congestion\": false,"; \
                    echo "                    \"readBufferSize\": 2,"; \
                    echo "                    \"writeBufferSize\": 2,"; \
                    echo "                    \"headers\": {"; \
                    echo "                        \"type\": \"${VMESS_TYPE}\","; \
                    echo "                        \"request\": null,"; \
                    echo "                        \"response\": null"; \
                    echo "                    }"; \
                    echo "                }"; \
                })
        else
            continue
        fi

        # Gen config file
        # cat >/etc/v2ray/config.json <<-EOF
        sudo tee /etc/v2ray/config.json >/dev/null <<-EOF
{
    "inbounds": [{
            "tag": "proxy",
            "port": ${V2RAY_PORT},
            "listen": "0.0.0.0",
            "protocol": "socks",
            "sniffing": {
                "enabled": true,
                "destOverride": ["http", "tls"]
            },
            "settings": {
                "auth": "noauth",
                "udp": true,
                "ip": null,
                "address": null,
                "clients": null
            }
        }
    ],
    "outbounds": [{
            "tag": "proxy",
            "protocol": "vmess",
            "settings": {
                "vnext": [{
                    "address": "${VMESS_ADDR}",
                    "port": ${VMESS_PORT},
                    "users": [{
                        "id": "${VMESS_USER_ID}",
                        "alterId": ${VMESS_USER_ALTERID},
                        "email": "t@t.tt",
                        "security": "auto"
                    }]
                }]
            },
            "streamSettings": {
                "network": "${VMESS_NETWORK}",
                "security": ${VMESS_SECURITY},
                "tlsSettings": ${VMESS_TLS_SETTINGS},
                "tcpSettings": null,
                "kcpSettings": ${VMESS_KCP_SETTINGS},
                "wsSettings": ${VMESS_WS_SETTINGS},
                "httpSettings": null,
                "quicSettings": null
            },
            "mux": {
                "enabled": true
            }
        }
    ]
}
EOF

        # removed ^M
        sudo sed -i -e 's/'$(echo "\013")'//g' -e 's/\r//g' /etc/v2ray/config.json

        # check the config file
        if v2ray -test -config /etc/v2ray/config.json; then
            # restart v2ray client
            # service v2ray restart && sleep 1
            sudo systemctl restart v2ray && sleep 1

            # check the proxy work or not
            if check_socks5_proxy_up ${V2RAY_ADDRESS}; then
                exitStatus=0
                break
            fi
        else
            break
        fi
    done < "${DECODE_FILENAME}"

    # rm -f ${VMESS_FILENAME} ${DECODE_FILENAME}

    if [ "$exitStatus" -eq "0" ]; then
        return 0
    else
        return 1
    fi
}

# subconverter
# https://github.com/tindy2013/subconverter
function install_update_subconverter() {
    local CURRENT_VERSION
    local DOWNLOAD_URL
    local CHECK_URL
    local REMOTE_VERSION
    local IS_UPDATE="no"

    [[ -z "$ostype" ]] && get_os_type && get_arch && get_sysArch

    if [[ -s "/srv/subconverter/subconverter" ]]; then
        colorEcho ${BLUE} "  Updating subconverter..."
        CURRENT_VERSION=$(head -n1 /srv/subconverter/.version)
    else
        colorEcho ${BLUE} "  Installing subconverter..."
        CURRENT_VERSION="0.0.0"
    fi

    CHECK_URL="https://api.github.com/repos/tindy2013/subconverter/releases/latest"
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        IS_UPDATE="yes"
        DOWNLOAD_URL="https://github.com/tindy2013/subconverter/releases/download/v${REMOTE_VERSION}/subconverter_${ostype}${VDIS}.tar.gz"
        curl -SL -o subconverter.tar.gz -C- $DOWNLOAD_URL && \
            mkdir -p /srv/subconverter && \
            tar -zxPf subconverter.tar.gz -C /srv && \
            rm subconverter.tar.gz && \
            echo ${REMOTE_VERSION} > /srv/subconverter/.version
    fi

    if [[ "$IS_UPDATE" == "yes" ]]; then
        [[ $(systemctl is-enabled subconverter 2>/dev/null) ]] && \
            sudo systemctl restart subconverter
    fi
}

# clash
# https://github.com/Dreamacro/clash
function install_update_clash() {
    local CURRENT_VERSION
    local DOWNLOAD_URL
    local CHECK_URL
    local REMOTE_VERSION
    local IS_UPDATE="no"

    [[ -z "$ostype" ]] && get_os_type && get_arch && get_sysArch

    if ! pgrep -f "subconverter" >/dev/null 2>&1; then
        [[ $(systemctl is-enabled subconverter 2>/dev/null) ]] && sudo systemctl restart subconverter
    fi

    if ! pgrep -f "subconverter" >/dev/null 2>&1; then
        colorEcho ${RED} "  Please install and run subconverter first!"
        return 1
    fi

    if [[ -s "/srv/clash/clash" ]]; then
        colorEcho ${BLUE} "  Updating clash..."
        CURRENT_VERSION=$(/srv/clash/clash -v 2>&1 | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
    else
        colorEcho ${BLUE} "  Installing clash..."
        CURRENT_VERSION="0.0.0"
    fi

    # CHECK_URL="https://api.github.com/repos/Dreamacro/clash/releases/latest"
    # REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    # Pre-release
    REMOTE_VERSION=$(curl -s -N https://github.com/Dreamacro/clash/releases \
        | grep -Eo -m1 '\/releases\/tag\/v([0-9]{1,}\.)+[0-9]{1,}' \
        | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)

    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        IS_UPDATE="yes"
        DOWNLOAD_URL="https://github.com/Dreamacro/clash/releases/download/v${REMOTE_VERSION}/clash-${ostype}-${spruce_type}-v${REMOTE_VERSION}.gz"
        curl -SL -o clash-${ostype}-${spruce_type}.gz -C- $DOWNLOAD_URL && \
            mkdir -p /srv/clash && \
            mv clash-${ostype}-${spruce_type}.gz /srv/clash && \
            cd /srv/clash && \
            gzip -df clash-${ostype}-${spruce_type}.gz && \
            chmod +x clash-${ostype}-${spruce_type} && \
            sudo ln -sv /srv/clash/clash-${ostype}-${spruce_type} /srv/clash/clash || true
    fi

    # geo database
    colorEcho ${BLUE} "  Updating clash geo database..."
    if [[ -s "/srv/clash/mmdb.ver" ]]; then
        CURRENT_VERSION=$(head -n1 /srv/clash/mmdb.ver)
    else
        CURRENT_VERSION="20000101"
    fi

    CHECK_URL="https://geolite.clash.dev/version"
    REMOTE_VERSION=$(wget -qO- $CHECK_URL)

    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        IS_UPDATE="yes"
        # MMDB_URL="https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb"
        MMDB_URL="https://geolite.clash.dev/Country.mmdb"
        curl -SL -o "/tmp/Country.mmdb" "$MMDB_URL" && \
            mv -f "/tmp/Country.mmdb" "/srv/clash/Country.mmdb" && \
            echo ${REMOTE_VERSION} > "/srv/clash/mmdb.ver"
    fi

    if [[ "$IS_UPDATE" == "yes" ]]; then
        [[ $(systemctl is-enabled clash 2>/dev/null) ]] && \
            sudo systemctl restart clash && sleep 3
    fi
}

function use_clash() {
    local ostype_wsl=$(uname -r)
    local last_update="/srv/clash/.last_update"
    local PROXY_URL=${1:-"127.0.0.1:7891"}
    local SUB_CLASH_URL

    if [[ "$ostype_wsl" =~ "Microsoft" || "$ostype_wsl" =~ "microsoft" ]]; then
        :
    else
        colorEcho ${BLUE} "  Checking & loading clash proxy..."

        if [[ ! -s "/srv/subconverter/subconverter" && ! -s "/srv/clash/clash" ]]; then
            echo "Download URL for subconverter & clash?"
            echo -n "[Use github by default] "
            read SUB_CLASH_URL
            if [[ -n "$SUB_CLASH_URL" ]]; then
                wget -c -O "/tmp/subconverter_clash.zip" "${SUB_CLASH_URL}" && \
                    unzip -qo "/tmp/subconverter_clash.zip" -d "/srv" && \
                    rm -f "/tmp/subconverter_clash.zip"
            fi
        fi

        install_update_subconverter
        [[ -s "/srv/subconverter/subconverter" ]] || {
                colorEcho ${RED} "  Please install and run subconverter first!"
                return 1
            }

        [[ $(systemctl is-enabled subconverter 2>/dev/null) ]] || {
                Install_systemd_Service "subconverter" "/srv/subconverter/subconverter"
            }

        install_update_clash
        [[ -s "/srv/clash/clash" ]] || {
                colorEcho ${RED} "  Please install and run clash first!"
                return 1
            }

        [[ $(systemctl is-enabled clash 2>/dev/null) ]] || {
                Install_systemd_Service "clash" "/srv/clash/clash -d /srv/clash"
            }

        if [[ $(systemctl is-enabled clash 2>/dev/null) ]]; then
            # get clash config
            [[ ! -s "$last_update" ]] && \
                date -d "1 day ago" +"%F" > "$last_update"

            # only update config first time in one day
            if [[ $(date -d $(date +"%F") +"%s") -gt $(date -d $(head -n1 "$last_update") +"%s") ]]; then
                [[ -s "$HOME/clash_client_config.sh" ]] && \
                    bash "$HOME/clash_client_config.sh"
                # restart clash and sleep 3s wait for clash ready
                sudo systemctl restart clash && sleep 3

                date +"%F" > "$last_update"
            fi

            if check_socks5_proxy_up ${PROXY_URL}; then
                return 0
            else
                [[ -s "$HOME/clash_client_config.sh" ]] && \
                    bash "$HOME/clash_client_config.sh"
                sudo systemctl restart clash && sleep 3
            fi
        fi
    fi
}

function use_v2ray() {
    local ostype_wsl=$(uname -r)
    local SubList
    local SubListFile
    local SubError
    local PROXY_URL=${1:-"127.0.0.1:55880"}

    if [[ "$ostype_wsl" =~ "Microsoft" || "$ostype_wsl" =~ "microsoft" ]]; then
        :
    else
        colorEcho ${BLUE} "  Checking & loading v2ray proxy..."

        [[ ! -x "$(command -v v2ray)" ]] && install_v2ray_client

        SubListFile="./cross_gfw_subscription.list"
        if [[ -s "$SubListFile" ]]; then
            SubList=()
            while read -r READLINE || [[ "$READLINE" ]]; do
                SubList+=("$READLINE")
            done < "${SubListFile}"
        else
            SubList=(
                "https://jiang.netlify.com/"
            )
        fi

        if check_socks5_proxy_up ${PROXY_URL}; then
            return 0
        else
            if [[ -x "$(command -v v2ray)" ]]; then
                SubError="yes"
                for TargetSub in "${SubList[@]}"; do
                    if get_v2ray_config_from_subscription "$TargetSub" "$PROXY_URL"; then
                        SubError="no"
                        break
                    fi
                done

                if [[ "$SubError" == "yes" ]]; then
                    colorEcho ${RED} "  Something wrong when setup proxy ${PROXY_URL}!"
                    return 1
                else
                    return 0
                fi
            fi
        fi
    fi

    return 1
}


## main
function main() {
    local SOCKS_ADDRESS

    # Set proxy or mirrors env in china
    set_proxy_mirrors_env

    # set global clash socks5 proxy or v2ray socks5 proxy
    if [[ -z "$GITHUB_NOT_USE_PROXY" ]]; then
        colorEcho ${BLUE} "Checking & loading socks proxy..."
        use_clash
        if ! check_set_global_proxy 7891 7890; then
            SOCKS_ADDRESS="127.0.0.1:55880"
            if use_v2ray "${SOCKS_ADDRESS}"; then
                set_special_socks5_proxy "${SOCKS_ADDRESS}"
                set_git_special_proxy "github.com,gitlab.com" "${SOCKS_ADDRESS}"
                colorEcho ${GREEN} "  Socks5 proxy address: ${SOCKS_ADDRESS}"
            else
                set_special_socks5_proxy
                set_git_special_proxy "github.com,gitlab.com"
            fi
        fi
    fi
}


CURL_SPECIAL_CONFIG=${CURL_SPECIAL_CONFIG:-"$HOME/.curl_socks5"}
main