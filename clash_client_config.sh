#!/bin/bash

# Usage:
# ./clash_client_config.sh /srv/clash/config.yaml /srv/web/www/default/clash_config.yml
# (crontab -l 2>/dev/null || true; echo "0 8,12,15,20 * * * /root/clash_client_config.sh /srv/clash/config.yaml /srv/web/www/default/clash_config.yml >/dev/null") | crontab -

trap 'rm -r "$WORKDIR"' EXIT

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


[[ $# > 0 ]] && TARGET_CONFIG_FILE=$1
if [[ -z "$TARGET_CONFIG_FILE" ]]; then
    mkdir -p "/srv/clash"
    TARGET_CONFIG_FILE="/srv/clash/config.yaml"
fi
TARGET_WITH_CUSTOM_PROXY=$(echo "$TARGET_CONFIG_FILE" | sed 's/\./_custom\./')

[[ $# > 1 ]] && COPY_TO_FILE=$2


if ! pgrep -f "subconverter" >/dev/null 2>&1; then
    # if [[ -s "/srv/subconverter/subconverter" ]]; then
    #     nohup /srv/subconverter/subconverter >/dev/null 2>&1 & disown
    # fi
    [[ $(systemctl is-enabled subconverter 2>/dev/null) ]] && sudo systemctl restart subconverter
fi

if ! pgrep -f "subconverter" >/dev/null 2>&1; then
    colorEcho ${RED} "Please install and run subconverter first!"
    exit 1
fi

# Update ACL4SSR
# https://github.com/ACL4SSR/ACL4SSR
if [[ -s "/srv/subconverter/subconverter" ]]; then
    Git_Clone_Update "ACL4SSR/ACL4SSR" "/srv/subconverter/ACL4SSR"
fi


WORKDIR="$(mktemp -d)"


# Get v2ray config from subscriptions
function get_v2ray_config_from_subscription() {
    local SUBSCRIBE_URL="https://jiang.netlify.com/"
    local VMESS_FILENAME="${WORKDIR}/v2ray.vmess"
    local DECODE_FILENAME="${WORKDIR}/v2ray_decode.vmess"

    colorEcho ${BLUE} "Getting v2ray subscriptions..."
    curl -sSf --connect-timeout 10 --max-time 30 "${SUBSCRIBE_URL}" -o "${VMESS_FILENAME}"
    if [[ $? != 0  ]]; then
        colorEcho ${RED} "Can't get the subscriptions from ${SUBSCRIBE_URL}!"
        return 1
    fi

    if [[ -s "${VMESS_FILENAME}" ]]; then
        base64 -d "${VMESS_FILENAME}" > "${DECODE_FILENAME}"
        sed -i '/^vmess:\/\//!d' "${DECODE_FILENAME}"
        sed -i 's|^vmess://||g' "${DECODE_FILENAME}"
    fi

    if [[ ! -s "${DECODE_FILENAME}" ]]; then
        colorEcho ${RED} "Can't get the subscriptions from ${SUBSCRIBE_URL}!"
        return 1
    fi

    colorEcho ${BLUE} "Getting v2ray config from subscriptions..."
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
    done < "${DECODE_FILENAME}"
}


CLASH_CONFIG="./clash_client_config.yml"

CFW_BYPASS_LINE=$(grep -E -n "^# \[CFW_BYPASS\]" "$CLASH_CONFIG" | cut -d: -f1)
PROXY_CUSTOM_LINE=$(grep -E -n "^# \[PROXY_CUSTOM\]" "$CLASH_CONFIG" | cut -d: -f1)
PROXY_LINE=$(grep -E -n "^# \[PROXY\]" "$CLASH_CONFIG" | cut -d: -f1)
PROXY_GROUP_LINE=$(grep -E -n "^# \[PROXY_GROUP\]" "$CLASH_CONFIG" | cut -d: -f1)
RULES_LINE=$(grep -E -n "^# \[RULES\]" "$CLASH_CONFIG" | cut -d: -f1)

# [RULES]
colorEcho ${BLUE} "Setting rules..."
RULES=""
# if (grep -E -q "^# \[RULES\]" "$CLASH_CONFIG"); then
if [[ ${RULES_LINE} -gt 0 ]]; then
    RULES_URL=$(sed -n "${RULES_LINE}p" "$CLASH_CONFIG" | cut -d"]" -f2-)
    if [[ -n "$RULES_URL" ]]; then
        colorEcho ${BLUE} "  Getting subscription rules..."
        curl -sL --connect-timeout 5 --max-time 15 \
            -o "${WORKDIR}/rules.yml" "${RULES_URL}"
    fi

    if [[ -s "${WORKDIR}/rules.yml" ]]; then
        RULES_START_LINE=$(grep -E -n "^Rule:" "${WORKDIR}/rules.yml" | cut -d: -f1)
        if [[ ${RULES_START_LINE} -gt 0 ]]; then
            RULES_START_LINE=$((${RULES_START_LINE} + 1))
            RULES=$(sed -n "${RULES_START_LINE},$ p" "${WORKDIR}/rules.yml")
        fi
    fi
fi

# [PROXY_GROUP]
colorEcho ${BLUE} "Setting proxy group..."
PROXY_GROUP=""
if [[ ${RULES_START_LINE} -gt 0 ]]; then
    if [[ -s "${WORKDIR}/rules.yml" ]]; then
        GROUP_START_LINE=$(grep -E -n "^Proxy Group:" "${WORKDIR}/rules.yml" | cut -d: -f1)
        if [[ ${GROUP_START_LINE} -gt 0 ]]; then
            GROUP_START_LINE=$((${GROUP_START_LINE} + 1))
            GROUP_END_LINE=$((${RULES_START_LINE} - 2))
            PROXY_GROUP=$(sed -n "${GROUP_START_LINE},${GROUP_END_LINE} p" "${WORKDIR}/rules.yml")
        fi
    fi
fi

# [PROXY]
colorEcho ${BLUE} "Setting proxy..."
PROXY=""
if [[ ${GROUP_START_LINE} -gt 0 ]]; then
    if [[ -s "${WORKDIR}/rules.yml" ]]; then
        PROXY_START_LINE=$(grep -E -n "^Proxy:" "${WORKDIR}/rules.yml" | cut -d: -f1)
        if [[ ${GROUP_START_LINE} -gt 0 ]]; then
            PROXY_START_LINE=$((${PROXY_START_LINE} + 1))
            PROXY_END_LINE=$((${GROUP_START_LINE} - 2))
            PROXY=$(sed -n "${PROXY_START_LINE},${PROXY_END_LINE} p" "${WORKDIR}/rules.yml")
        fi
    fi
fi

# [PROXY_CUSTOM]
PROXY_CUSTOM_FILE="/srv/clash/clash_proxy_custom.yml"
if [[ -s "$PROXY_CUSTOM_FILE" ]]; then
    colorEcho ${BLUE} "Setting custom proxy..."
    PROXY_CUSTOM=$(cat "$PROXY_CUSTOM_FILE")
fi

# [CFW_BYPASS]
colorEcho ${BLUE} "Setting cfw bypass..."
CFW_BYPASS=""
if [[ ${CFW_BYPASS_LINE} -gt 0 ]]; then
    CFW_BYPASS_URL=$(sed -n "${CFW_BYPASS_LINE}p" "$CLASH_CONFIG" | cut -d"]" -f2-)
    colorEcho ${BLUE} "  Getting cfw bypass rules..."
    curl -sL --connect-timeout 5 --max-time 15 \
        -o "${WORKDIR}/cfw_bypass.yml" "${CFW_BYPASS_URL}"
    if [[ -s "${WORKDIR}/cfw_bypass.yml" ]]; then
        BYPASS_START_LINE=$(grep -E -n "^cfw\-bypass:" "${WORKDIR}/cfw_bypass.yml" | cut -d: -f1)
        if [[ ${BYPASS_START_LINE} -gt 0 ]]; then
            BYPASS_START_LINE=$((${BYPASS_START_LINE} + 1))
            CFW_BYPASS=$(sed -n "${BYPASS_START_LINE},$ p" "${WORKDIR}/cfw_bypass.yml")
        fi
    fi
fi

# custom rules
RULE_CUSTOM_FILE="/srv/clash/clash_rule_custom.yml"
if [[ -s "$RULE_CUSTOM_FILE" ]]; then
    colorEcho ${BLUE} "Setting custom RULE..."
    RULE_CUSTOM=$(cat "$RULE_CUSTOM_FILE")
fi

# Delete all proxy name from proxy group
colorEcho ${BLUE} "Optimizing rules..."
if [[ -n "$PROXY" && -n "$PROXY_GROUP" ]]; then
    # proxy list
    PROXY_LIST=$(echo "$PROXY" | grep -E "\-\s{name:.*.," | cut -d, -f1 | cut -d: -f2-)
    PROXY_NAME=()
    while read -r line; do PROXY_NAME+=("$line"); done <<<"$PROXY_LIST"

    # GROUP_CNT=$(echo "$PROXY_GROUP" | grep -E "\-\sname:" | wc -l)
    PROXY_GROUP_MAIN=$(echo "$PROXY_GROUP" | awk "/- name:/{i++}i<=2")
    PROXY_GROUP_REST=$(echo "$PROXY_GROUP" | awk "/- name:/{i++}i>2")

    # add custom proxy to 1st,2nd group,before 1st proxy list
    if [[ -n "$PROXY_CUSTOM" ]]; then
        CUSTOM_LIST=$(echo "$PROXY_CUSTOM" | grep -E "\-\s{name:.*.," | cut -d, -f1 | cut -d: -f2-)
        CUSTOM_NAME=()
        while read -r line; do CUSTOM_NAME+=("$line"); done <<<"$CUSTOM_LIST"

        # FIRST_PROXY_NAME=$(echo "${PROXY_NAME[0]}" | sed 's/[^a-zA-Z 0-9]/\\&/g')
        FIRST_PROXY_NAME=$(echo "${PROXY_NAME[0]}" \
            | sed -e 's/^"//' -e 's/"$//' \
            | sed 's/[\\/:\*\?<>\|\$\(\)\[\^\{\}\+\.\=\!]/\\&/g' \
            | sed 's/]/\\&/g')
        for TargetName in "${CUSTOM_NAME[@]}"; do
            PROXY_GROUP_MAIN=$(echo "$PROXY_GROUP_MAIN" | sed "/- ${FIRST_PROXY_NAME}$/i\      - ${TargetName}")
        done
    fi

    # delete proxy list after 3th group
    for TargetName in "${PROXY_NAME[@]}"; do
        TargetName=$(echo "${TargetName}" \
            | sed -e 's/^"//' -e 's/"$//' \
            | sed 's/[\\/:\*\?<>\|\$\(\)\[\^\{\}\+\.\=\!]/\\&/g' \
            | sed 's/]/\\&/g')
        PROXY_GROUP_REST=$(echo "$PROXY_GROUP_REST" | sed "/- ${TargetName}$/d")
    done

    PROXY_GROUP=$(echo -e "${PROXY_GROUP_MAIN}\n${PROXY_GROUP_REST}")

    # add blank line before each group
    PROXY_GROUP=$(echo "$PROXY_GROUP" | sed "s/  - name:/\n&/" | sed '1d')
fi


# Add contents to target config file
colorEcho ${BLUE} "Output all config to ${TARGET_CONFIG_FILE}..."
[[ -f "$TARGET_CONFIG_FILE" ]] && rm -f "$TARGET_CONFIG_FILE"

START_LINE=1
ADD_CONTENT=$(sed -n "${START_LINE},${CFW_BYPASS_LINE} p" "$CLASH_CONFIG")
# while read -r line; do printf "%s\n" "${line}" >> "$TARGET_CONFIG_FILE"; done <<<"$ADD_CONTENT"
echo "$ADD_CONTENT" >> "$TARGET_CONFIG_FILE"

if [[ -n "$CFW_BYPASS" ]]; then
    colorEcho ${BLUE} "  Output cfw bypass..."
    echo "${CFW_BYPASS}" | tee -a "$TARGET_CONFIG_FILE" >/dev/null
fi

START_LINE=$((${CFW_BYPASS_LINE} + 1))
ADD_CONTENT=$(sed -n "${START_LINE},${PROXY_CUSTOM_LINE} p" "$CLASH_CONFIG")
echo "$ADD_CONTENT" >> "$TARGET_CONFIG_FILE"

if [[ -n "$PROXY_CUSTOM" ]]; then
    colorEcho ${BLUE} "  Output custom proxies..."
    echo "${PROXY_CUSTOM}" | tee -a "$TARGET_CONFIG_FILE" >/dev/null
fi

START_LINE=$((${PROXY_CUSTOM_LINE} + 1))
ADD_CONTENT=$(sed -n "${START_LINE},${PROXY_LINE} p" "$CLASH_CONFIG")
echo "$ADD_CONTENT" >> "$TARGET_CONFIG_FILE"

if [[ -n "$PROXY" ]]; then
    colorEcho ${BLUE} "  Output proxies..."
    echo "${PROXY}" | tee -a "$TARGET_CONFIG_FILE" >/dev/null
fi

START_LINE=$((${PROXY_LINE} + 1))
ADD_CONTENT=$(sed -n "${START_LINE},${PROXY_GROUP_LINE} p" "$CLASH_CONFIG")
echo "$ADD_CONTENT" >> "$TARGET_CONFIG_FILE"

if [[ -n "$PROXY_GROUP" ]]; then
    colorEcho ${BLUE} "  Output proxy group..."
    echo "${PROXY_GROUP}" | tee -a "$TARGET_CONFIG_FILE" >/dev/null
fi

START_LINE=$((${PROXY_GROUP_LINE} + 1))
ADD_CONTENT=$(sed -n "${START_LINE},${RULES_LINE} p" "$CLASH_CONFIG")
echo "$ADD_CONTENT" >> "$TARGET_CONFIG_FILE"

if [[ -n "$RULE_CUSTOM" ]]; then
    colorEcho ${BLUE} "  Output custom rules..."
    echo "${RULE_CUSTOM}" | tee -a "$TARGET_CONFIG_FILE" >/dev/null
fi

if [[ -n "$RULES" ]]; then
    colorEcho ${BLUE} "  Output rules..."
    echo "${RULES}" | tee -a "$TARGET_CONFIG_FILE" >/dev/null
fi

sed -i "/^# \[.*/d" "$TARGET_CONFIG_FILE"

# Config file with custom proxy
if [[ -n "$TARGET_WITH_CUSTOM_PROXY" ]]; then
    cp -f "$TARGET_CONFIG_FILE" "$TARGET_WITH_CUSTOM_PROXY"
fi

# Remove custom proxy from $TARGET_CONFIG_FILE
if [[ -n "$PROXY_CUSTOM" ]]; then
    CUSTOM_START_LINE=$(grep -E -n "^Proxy:" "${TARGET_CONFIG_FILE}" | cut -d: -f1)
    CUSTOM_START_LINE=$((${CUSTOM_START_LINE} + 1))
    PROXY_CUSTOM_COUNT=$(echo "$PROXY_CUSTOM" | wc -l)
    CUSTOM_END_LINE=$((${CUSTOM_START_LINE} + ${PROXY_CUSTOM_COUNT}))
    sed -i "${CUSTOM_START_LINE},${CUSTOM_END_LINE} d" "$TARGET_CONFIG_FILE" 
fi

# Copy to file
if [[ -n "$COPY_TO_FILE" ]]; then
    colorEcho ${BLUE} "Copy config to ${COPY_TO_FILE}..."
    cp -f "$TARGET_CONFIG_FILE" "$COPY_TO_FILE"

    if [[ ! -s "${COPY_TO_FILE}.md5" ]]; then
        colorEcho ${BLUE} "Gen md5 for ${COPY_TO_FILE}..."
        (openssl md5 -hex "${COPY_TO_FILE}" | cut -d" " -f2) > "${COPY_TO_FILE}.md5"
    fi

    COPY_TO_CUSTOM=$(echo "$COPY_TO_FILE" | sed 's/\./_custom\./')
    colorEcho ${BLUE} "Copy config with custom proxy to ${COPY_TO_CUSTOM}..."
    cp -f "$TARGET_WITH_CUSTOM_PROXY" "$COPY_TO_CUSTOM"

    if [[ ! -s "${COPY_TO_CUSTOM}.md5" ]]; then
        colorEcho ${BLUE} "Gen md5 for ${COPY_TO_CUSTOM}..."
        (openssl md5 -hex "${COPY_TO_CUSTOM}" | cut -d" " -f2) > "${COPY_TO_CUSTOM}.md5"
    fi
fi


colorEcho ${BLUE} "Done!"
