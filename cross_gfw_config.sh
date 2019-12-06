#!/bin/bash

# if [[ $UID -ne 0 ]]; then
#     echo "Please run this script as root user!"
#     exit 0
# fi

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

if [[ -z "$ostype" ]]; then
    get_os_type
    get_arch
    get_sysArch
fi

if check_webservice_up www.google.com; then
    colorEcho ${BLUE} "You are not blocked by the firewall! Congratulations!"
    exit 0
fi


if [[ $# > 0 ]]; then
    PROXY_PORT=$1
else
    PROXY_PORT="55880"
fi
PROXY_URL="127.0.0.1:${PROXY_PORT}"

[[ $# > 1 ]] && SUBSCRIBE_URL=$1
[[ -z "$SUBSCRIBE_URL" ]] && SUBSCRIBE_URL="https://jiang.netlify.com/"


# V2Ray Client
# https://www.v2ray.com/chapter_00/install.html
# service v2ray start|stop|status|reload|restart|force-reload
function install_v2ray_client() {
    local CURRENT_VERSION
    local DOWNLOAD_URL
    local CHECK_URL="https://api.github.com/repos/v2ray/v2ray-core/releases/latest"
    local REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

    CURRENT_VERSION=0.0.0
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
    local exitStatus=1

    # local SUBSCRIBE_URL="https://jiang.netlify.com/"
    local VMESS_FILENAME="/tmp/v2ray.vmess"
    local DECODE_FILENAME="/tmp/v2ray_decode.vmess"

    colorEcho ${BLUE} "Geting v2ray subscriptions..."
    curl -sSf --connect-timeout 10 --max-time 30 "${SUBSCRIBE_URL}" -o "${VMESS_FILENAME}"
    if [[ $? != 0  ]]; then
        colorEcho ${RED} "Can't get the subscriptions from ${SUBSCRIBE_URL}!"
        return 1
    fi

    if [[ -s "${VMESS_FILENAME}" ]]; then
        base64 -d "${VMESS_FILENAME}" > "${DECODE_FILENAME}"
        sed -i -e 's|^vmess://||g' -e '/^ss:\/\//d' "${DECODE_FILENAME}"
    fi

    if [[ ! -s "${DECODE_FILENAME}" ]]; then
        colorEcho ${RED} "Can't get the subscriptions from ${SUBSCRIBE_URL}!"
        return 1
    fi

    colorEcho ${BLUE} "Testing v2ray config from subscriptions..."
    # Decode subscriptions line by line
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

    while read -r READLINE; do
        [[ -z "${READLINE}" ]] && continue

        VMESS_CONFIG=$(echo "${READLINE}" | base64 -di | sed -e 's/[{}", ]//g' -e 's/\r//g')
        [[ -z "${VMESS_CONFIG}" ]] && continue

        VMESS_PS=$(echo "${VMESS_CONFIG}" | grep '^ps:' | cut -d':' -f2-)
        VMESS_ADDR=$(echo "${VMESS_CONFIG}" | grep '^add:' | cut -d':' -f2)
        VMESS_PORT=$(echo "${VMESS_CONFIG}" | grep '^port:' | cut -d':' -f2)
        [[ -z "${VMESS_ADDR}" || -z "${VMESS_PORT}" ]] && continue

        VMESS_USER_ID=$(echo "${VMESS_CONFIG}" | grep '^id:' | cut -d':' -f2)
        VMESS_USER_ALTERID=$(echo "${VMESS_CONFIG}" | grep '^aid:' | cut -d':' -f2)
        VMESS_NETWORK=$(echo "${VMESS_CONFIG}" | grep '^net:' | cut -d':' -f2)
        VMESS_TYPE=$(echo "${VMESS_CONFIG}" | grep '^type:' | cut -d':' -f2)
        VMESS_SECURITY=$(echo "${VMESS_CONFIG}" | grep '^tls:' | cut -d':' -f2)
        VMESS_WS_HOST=$(echo "${VMESS_CONFIG}" | grep '^host:' | cut -d':' -f2)
        VMESS_WS_PATH=$(echo "${VMESS_CONFIG}" | grep '^path:' | cut -d':' -f2)

        colorEcho ${BLUE} "Testing ${VMESS_PS} ${VMESS_ADDR}:${VMESS_PORT}..."
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
            "port": ${PROXY_PORT},
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
            if check_socks5_proxy_up ${PROXY_URL}; then
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


## main
colorEcho ${BLUE} "Checking & loading socks proxy..."
if check_socks5_proxy_up ${PROXY_URL}; then
    colorEcho ${BLUE} "Socks proxy address: ${PROXY_URL}"
else
    if [[ ! -x "$(command -v v2ray)" ]]; then
        install_v2ray_client
    fi

    if [[ -x "$(command -v v2ray)" ]]; then
        if get_v2ray_config_from_subscription; then
            colorEcho ${BLUE} "Socks proxy address: ${PROXY_URL}"
        else
            colorEcho ${RED} "Something wrong when setup proxy ${PROXY_URL}!"
        fi
    fi
fi