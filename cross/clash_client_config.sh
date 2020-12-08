#!/usr/bin/env bash

# Usage:
# ${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/cross/clash_client_config.sh /etc/clash/config.yaml /srv/web/www/default/clash_config.yml
# (crontab -l 2>/dev/null || true; echo "0 8,12,15,20 * * * /root/terminal-custom/cross/clash_client_config.sh /etc/clash/config.yaml /srv/web/www/default/clash_config.yml >/dev/null") | crontab -

# while getopts ":t:c:i:u:o:g:l" OPTNAME; do
#     case $OPTNAME in
#         t) TARGET_CONFIG_FILE="$OPTARG";;
#         c) COPY_TO_FILE="$OPTARG";;
#         i) RULES_INI="$OPTARG";;
#         u) SUB_URL_TXT="$OPTARG";;
#         o) OPTIMIZE_OPTION="$OPTARG";;
#         g) CLASH_CONFIG="$OPTARG";;
#         l) SUB_LIST_FILE="$OPTARG";;
#         :)
#         echo "No argument value for option $OPTARG!"
#         exit 1
#         ;;
#         ?)
#         echo "Unknown option $OPTARG!"
#         exit 1
#         ;;
#         *)
#         echo "Unknown error while processing options!"
#         exit 1
#         ;;
#     esac
#     # echo "-$OPTNAME=$OPTARG index=$OPTIND"
# done

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

# jq
if [[ ! -x "$(command -v jq)" ]]; then
    if [[ -x "$(command -v pacman)" ]]; then
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


TARGET_CONFIG_FILE=${1:-""}
if [[ -z "$TARGET_CONFIG_FILE" ]]; then
    mkdir -p "/srv/clash"
    TARGET_CONFIG_FILE="/srv/clash/config.yaml"
fi
TARGET_WITH_CUSTOM_PROXY=$(echo "$TARGET_CONFIG_FILE" | sed 's/\./_custom\./')

COPY_TO_FILE=${2:-""}

RULES_INI=${3:-"My_Clash_Rules.ini"}

SUB_URL_TXT=${4:-"My_Clash_Sub_URL.txt"}

OPTIMIZE_OPTION=${5:-"no"}

CLASH_CONFIG=${6:-"${CURRENT_DIR}/clash_client_config.yml"}
[[ ! -s "$CLASH_CONFIG" ]] && CLASH_CONFIG="${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/cross/clash_client_config.yml"
if [[ ! -s "$CLASH_CONFIG" ]]; then
    colorEcho ${BLUE} "    ${CLASH_CONFIG} not exist!"
    exit 1
fi

SUB_LIST_FILE=${7:-"${CURRENT_DIR}/clash_client_subscription.list"}
[[ ! -s "$SUB_LIST_FILE" ]] && SUB_LIST_FILE=${7:-"${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/cross/clash_client_subscription.list"}
if [[ -s "$SUB_LIST_FILE" ]]; then
    SUB_LIST=()
    # || In case the file has an incomplete (missing newline) last line
    while read -r READLINE || [[ "$READLINE" ]]; do
        SUB_LIST+=("$READLINE")
    done < "${SUB_LIST_FILE}"

    SUB_DOWNLOAD_FILE="${WORKDIR}/clash_sub.yaml"
    for TargetURL in "${SUB_LIST[@]}"; do
        [[ -z "$TargetURL" ]] && continue
        colorEcho ${BLUE} "Downloading clash client connfig from ${TargetURL}..."
        curl -SL --connect-timeout 10 --max-time 60 \
            -o "$SUB_DOWNLOAD_FILE" "$TargetURL"
        if [[ $? -eq 0 ]]; then
            sed -i "s/^allow-lan:.*/allow-lan: false/" "$SUB_DOWNLOAD_FILE"
            sed -i "s/^external-controller:.*/# &/" "$SUB_DOWNLOAD_FILE"
            cp -f "$SUB_DOWNLOAD_FILE" "$TARGET_CONFIG_FILE"
            exit 0
        fi
    done
fi


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


colorEcho ${BLUE} "Getting clash rules..."

# Update ACL4SSR
# https://github.com/ACL4SSR/ACL4SSR
if [[ -s "/srv/subconverter/subconverter" ]]; then
    if Git_Clone_Update "ACL4SSR/ACL4SSR" "/srv/subconverter/ACL4SSR"; then
        cp -f /srv/subconverter/ACL4SSR/Clash/*.list \
            /srv/subconverter/rules/ACL4SSR/Clash && \
        cp -f /srv/subconverter/ACL4SSR/Clash/Ruleset/*.list \
            /srv/subconverter/rules/ACL4SSR/Clash/Ruleset && \
        cp -f /srv/subconverter/ACL4SSR/Clash/*.yml \
            /srv/subconverter/config && \
        cp -f /srv/subconverter/ACL4SSR/Clash/config/*.ini \
            /srv/subconverter/config

        if [[ ! -L "/srv/subconverter/config/${RULES_INI}" ]]; then
            CLASH_RULES="/etc/clash/${RULES_INI}"
            [[ ! -s "$CLASH_RULES" ]] && CLASH_RULES="${CURRENT_DIR}/${RULES_INI}"
            if [[ -s "$CLASH_RULES" ]]; then
                ln -s "$CLASH_RULES" "/srv/subconverter/config/${RULES_INI}"
            fi
        fi
    fi
fi

CFW_BYPASS_LINE=$(grep -E -n "^# \[CFW_BYPASS\]" "$CLASH_CONFIG" | cut -d: -f1)
PROXY_CUSTOM_LINE=0
# PROXY_CUSTOM_LINE=$(grep -E -n "^# \[PROXY_CUSTOM\]" "$CLASH_CONFIG" | cut -d: -f1)
PROXY_LINE=$(grep -E -n "^# \[PROXY\]" "$CLASH_CONFIG" | cut -d: -f1)
PROXY_MERGE_LINE=0
# PROXY_MERGE_LINE=$(grep -E -n "^# \[PROXY_MERGE\]" "$CLASH_CONFIG" | cut -d: -f1)
PROXY_GROUP_LINE=$(grep -E -n "^# \[PROXY_GROUP\]" "$CLASH_CONFIG" | cut -d: -f1)
RULES_LINE=$(grep -E -n "^# \[RULES\]" "$CLASH_CONFIG" | cut -d: -f1)

# [RULES]
colorEcho ${BLUE} "  Getting subscription rules..."
RULES=""

if [[ -s "/etc/clash/${SUB_URL_TXT}" ]]; then
    RULES_URL=$(head -n1 "/etc/clash/${SUB_URL_TXT}")
else
    if [[ ${RULES_LINE} -gt 0 ]]; then
        RULES_URL=$(sed -n "${RULES_LINE}p" "$CLASH_CONFIG" | cut -d"]" -f2-)
    fi
fi

if [[ -n "$RULES_URL" ]]; then
    curl -sL --connect-timeout 10 --max-time 30 \
        -o "${WORKDIR}/rules.yml" "${RULES_URL}"
    if [[ $? != 0 ]]; then
        colorEcho ${RED} "    Can't get rules from ${RULES_URL}!"
        exit 1
    fi
fi

if [[ -s "${WORKDIR}/rules.yml" ]]; then
    RULES_START_LINE=$(grep -E -n "^rules:" "${WORKDIR}/rules.yml" | cut -d: -f1)
    if [[ ${RULES_START_LINE} -gt 0 ]]; then
        RULES_START_LINE=$((${RULES_START_LINE} + 1))
        RULES=$(sed -n "${RULES_START_LINE},$ p" "${WORKDIR}/rules.yml")
    fi
fi

# [PROXY_GROUP]
colorEcho ${BLUE} "  Getting proxy-groups..."
PROXY_GROUP=""
if [[ ${RULES_START_LINE} -gt 0 ]]; then
    if [[ -s "${WORKDIR}/rules.yml" ]]; then
        GROUP_START_LINE=$(grep -E -n "^proxy-groups:" "${WORKDIR}/rules.yml" | cut -d: -f1)
        if [[ ${GROUP_START_LINE} -gt 0 ]]; then
            GROUP_START_LINE=$((${GROUP_START_LINE} + 1))
            GROUP_END_LINE=$((${RULES_START_LINE} - 2))
            PROXY_GROUP=$(sed -n "${GROUP_START_LINE},${GROUP_END_LINE} p" "${WORKDIR}/rules.yml")
        fi
    fi
fi

# [PROXY]
colorEcho ${BLUE} "  Getting proxies..."
PROXY=""
if [[ ${GROUP_START_LINE} -gt 0 ]]; then
    if [[ -s "${WORKDIR}/rules.yml" ]]; then
        PROXY_START_LINE=$(grep -E -n "^proxies:" "${WORKDIR}/rules.yml" | cut -d: -f1)
        if [[ ${GROUP_START_LINE} -gt 0 ]]; then
            PROXY_START_LINE=$((${PROXY_START_LINE} + 1))
            PROXY_END_LINE=$((${GROUP_START_LINE} - 2))
            PROXY=$(sed -n "${PROXY_START_LINE},${PROXY_END_LINE} p" "${WORKDIR}/rules.yml")
        fi
    fi
fi

# [PROXY_CUSTOM]
PROXY_CUSTOM=""
PROXY_CUSTOM_FILE="/etc/clash/clash_proxy_custom.yml"
if [[ -s "$PROXY_CUSTOM_FILE" ]]; then
    colorEcho ${BLUE} "  Getting custom proxies..."
    PROXY_CUSTOM=$(cat "$PROXY_CUSTOM_FILE")
fi

# [PROXY_MERGE]
PROXY_MERGE=""
if [[ ${PROXY_MERGE_LINE} -gt 0 ]]; then
    MERGE_URL=$(sed -n "${PROXY_MERGE_LINE}p" "$CLASH_CONFIG" | cut -d"]" -f2-)
    if [[ -n "$MERGE_URL" ]]; then
        colorEcho ${BLUE} "  Getting merge proxies..."
        curl -sL --connect-timeout 10 --max-time 30 \
            -o "${WORKDIR}/merge.yml" "${MERGE_URL}"
        if [[ $? != 0 ]]; then
            colorEcho ${RED} "    Can't get merge proxies from ${MERGE_URL}!"
            exit 1
        fi
    fi

    if [[ -s "${WORKDIR}/merge.yml" ]]; then
        PROXY_MERGE=$(grep "{name:" "${WORKDIR}/merge.yml")
    fi
fi

# [CFW_BYPASS]
colorEcho ${BLUE} "  Getting cfw bypass rules..."
CFW_BYPASS=""
if [[ ${CFW_BYPASS_LINE} -gt 0 ]]; then
    CFW_BYPASS_FILE="/srv/subconverter/config/GeneralClashConfig.yml"
    if [[ ! -s "${CFW_BYPASS_FILE}" ]]; then
        CFW_BYPASS_FILE=""
        CFW_BYPASS_URL=$(sed -n "${CFW_BYPASS_LINE}p" "$CLASH_CONFIG" | cut -d"]" -f2-)
        if [[ -n "$CFW_BYPASS_URL" ]]; then
            curl -sL --connect-timeout 10 --max-time 30 \
                -o "${CFW_BYPASS_FILE}" "${CFW_BYPASS_URL}"
            if [[ $? != 0  ]]; then
                colorEcho ${RED} "    Can't get cfw bypass rules from ${CFW_BYPASS_URL}!"
                exit 1
            fi
        fi
    fi

    if [[ -s "${CFW_BYPASS_FILE}" ]]; then
        BYPASS_START_LINE=$(grep -E -n "^cfw\-bypass:" "${CFW_BYPASS_FILE}" | cut -d: -f1)
        if [[ ${BYPASS_START_LINE} -gt 0 ]]; then
            BYPASS_START_LINE=$((${BYPASS_START_LINE} + 1))
            CFW_BYPASS=$(sed -n "${BYPASS_START_LINE},$ p" "${CFW_BYPASS_FILE}")
        fi
    fi
fi

# custom rules
RULE_CUSTOM_FILE="/etc/clash/clash_rule_custom.yml"
if [[ -s "$RULE_CUSTOM_FILE" ]]; then
    colorEcho ${BLUE} "  Getting custom rules..."
    RULE_CUSTOM=$(cat "$RULE_CUSTOM_FILE")
fi

# proxy list
# Extract word from string using grep/sed/awk
# https://askubuntu.com/questions/697120/extract-word-from-string-using-grep-sed-awk
PROXY_NAME=()
PROXY_TYPE=()
while read -r line; do
    [[ -z "${line}" ]] && continue
    line_name=$(echo "$line" \
        | sed -rn "s/.*name:([^,{}]+).*/\1/ip" \
        | sed -e "s/^\s//" -e "s/\s$//" \
        | sed -e "s/^\"//" -e "s/\"$//")
    PROXY_NAME+=("$line_name")

    line_type=$(echo "$line" \
        | sed -rn "s/.*type:([^,{}]+).*/\1/ip" \
        | sed -e "s/^\s//" -e "s/\s$//" \
        | sed -e "s/^\"//" -e "s/\"$//")
    PROXY_TYPE+=("$line_type")
done <<<"$PROXY"

# Optimize rules
if [[ "$OPTIMIZE_OPTION" == "yes" && -n "$PROXY" && -n "$PROXY_GROUP" ]]; then
    colorEcho ${BLUE} "  Optimizing rules..."

    # GROUP_CNT=$(echo "$PROXY_GROUP" | grep -E "^[ ]*\-\sname:" | wc -l)
    PROXY_GROUP_MAIN=$(echo "$PROXY_GROUP" | awk "/^[ ]*-[ ]*name:/{i++}i<=2")
    PROXY_GROUP_REMAIN=$(echo "$PROXY_GROUP" | awk "/^[ ]*-[ ]*name:/{i++}i>2")

    # add custom proxies to 1st,2nd group,before 1st proxy list
    if [[ -n "$PROXY_CUSTOM" ]]; then
        CUSTOM_NAME=()
        while read -r line; do
            [[ -z "${line}" ]] && continue
            line_name=$(echo "$line" \
                | sed -rn "s/.*name:([^,{}]+).*/\1/ip" \
                | sed -e "s/^\s//" -e "s/\s$//" \
                | sed -e "s/^\"//" -e "s/\"$//")
            CUSTOM_NAME+=("$line_name")
        done <<<"$PROXY_CUSTOM"

        FIRST_PROXY_NAME=$(echo "${PROXY_NAME[0]}" \
            | sed 's/[\\\/\:\*\?\|\$\&\#\[\^\+\.\=\!\"]/\\&/g' \
            | sed 's/]/\\&/g')
        for TargetName in "${CUSTOM_NAME[@]}"; do
            [[ -z "$TargetName" ]] && continue
            PROXY_GROUP_MAIN=$(echo "$PROXY_GROUP_MAIN" \
                | sed "/^\s*\-\s*${FIRST_PROXY_NAME}$/i\      - ${TargetName}" \
                | sed "/^\s*\-\s*\"${FIRST_PROXY_NAME}\"$/i\      - ${TargetName}")
        done
    fi

    # add merge proxies to 1st,2nd group,after last proxy list
    if [[ -n "$PROXY_MERGE" ]]; then
        MERGE_NAME=()
        while read -r line; do
            [[ -z "${line}" ]] && continue
            line_name=$(echo "$line" \
                | sed -rn "s/.*name:([^,{}]+).*/\1/ip" \
                | sed -e "s/^\s//" -e "s/\s$//" \
                | sed -e "s/^\"//" -e "s/\"$//")
            MERGE_NAME+=("$line_name")
        done <<<"$PROXY_MERGE"

        LAST_PROXY_NAME=$(echo "${PROXY_NAME[-1]}" \
            | sed 's/[\\\/\:\*\?\|\$\&\#\[\^\+\.\=\!\"]/\\&/g' \
            | sed 's/]/\\&/g')
        for TargetName in "${MERGE_NAME[@]}"; do
            [[ -z "$TargetName" ]] && continue
            PROXY_GROUP_MAIN=$(echo "$PROXY_GROUP_MAIN" \
                | sed "/^\s*\-\s*${LAST_PROXY_NAME}$/a\      - ${TargetName}" \
                | sed "/^\s*\-\s*\"${LAST_PROXY_NAME}\"$/a\      - ${TargetName}")
        done
    fi

    PROXY_INDEX=-1
    for TargetName in "${PROXY_NAME[@]}"; do
        PROXY_INDEX=$((${PROXY_INDEX} + 1))

        [[ -z "$TargetName" ]] && continue

        TargetName=$(echo "${TargetName}" \
            | sed 's/[\\\/\:\*\?\|\$\&\#\[\^\+\.\=\!\"]/\\&/g' \
            | sed 's/]/\\&/g')

        # delete proxy list after 3th group
        PROXY_GROUP_REMAIN=$(echo "$PROXY_GROUP_REMAIN" \
            | sed -e "/^\s*\-\s*${TargetName}$/d" -e "/^\s*\-\s*\"${TargetName}\"$/d")
    done

    PROXY_GROUP_REMAIN=$(echo "$PROXY_GROUP_REMAIN" | sed "/^\s*\-\s*\"\"$/d")
    PROXY_GROUP=$(echo -e "${PROXY_GROUP_MAIN}\n${PROXY_GROUP_REMAIN}")
    # add blank line before each group
    PROXY_GROUP=$(echo "$PROXY_GROUP" | sed 's/^\s*\-\s*name:/\n&/' | sed '1d')
fi

# Delete Shadowsocks proxies
colorEcho ${BLUE} "  Deleting Shadowsocks proxies..."
PROXY_INDEX=-1
for TargetName in "${PROXY_NAME[@]}"; do
    PROXY_INDEX=$((${PROXY_INDEX} + 1))

    [[ -z "$TargetName" ]] && continue

    TargetName=$(echo "${TargetName}" \
        | sed 's/[\\\/\:\*\?\|\$\&\#\[\^\+\.\=\!\"]/\\&/g' \
        | sed 's/]/\\&/g')

    if [[ "${PROXY_TYPE[$PROXY_INDEX]}" == "ss" || "${PROXY_TYPE[$PROXY_INDEX]}" == "ssr" ]]; then
        PROXY=$(echo "$PROXY" | sed "/name:\s*${TargetName},/d")
        PROXY_GROUP=$(echo "$PROXY_GROUP" | sed "/^\s*\-\s*${TargetName}$/d")
    fi
done

# Delete empty group
colorEcho ${BLUE} "  Deleting empty group..."
if [[ -n "$PROXY_GROUP" ]]; then
    GROUP_LIST=$(echo "$PROXY_GROUP" | grep -E "^[ ]*\-\sname:" | sed "s/^[ ]*\-\sname:\s//g")
    GROUP_NAME=()
    while read -r line; do
        GROUP_NAME+=("$line")
    done <<<"$GROUP_LIST"

    # GROUP_CNT=$(echo "$PROXY_GROUP" | grep -E "^[ ]*\-\sname:" | wc -l)
    PROXY_GROUP_REMAIN=""
    GROUP_DELETE=()
    for ((g=0; g < ${#GROUP_NAME[@]}; g++)); do
        awk_cnt=$((${g} + 1))
        GROUP_CHECK=$(echo "$PROXY_GROUP" | awk "/^[ ]*-[ ]*name:/{i++}i==${awk_cnt}")

        if [[ "$(echo ${GROUP_NAME[$g]} | grep '直连')" ]]; then
            PROXIES_CNT=3
        else
            PROXIES_CNT=$(echo "$GROUP_CHECK" | grep -E "^[ ]*\-" | grep -v 'DIRECT' | wc -l)
        fi

        if [[ ${PROXIES_CNT} -gt 1 ]]; then
            if [[ -n "${PROXY_GROUP_REMAIN}" ]]; then
                PROXY_GROUP_REMAIN=$(echo -e "${PROXY_GROUP_REMAIN}\n${GROUP_CHECK}")
            else
                PROXY_GROUP_REMAIN=$(echo "${GROUP_CHECK}")
            fi
        else
            GROUP_DELETE+=("${GROUP_NAME[$g]}")
        fi
    done

    for TargetName in "${GROUP_DELETE[@]}"; do
        TargetName=$(echo "${TargetName}" \
            | sed 's/[\\\/\:\*\?\|\$\&\#\[\^\+\.\=\!\"]/\\&/g' \
            | sed 's/]/\\&/g')
        PROXY_GROUP_REMAIN=$(echo "$PROXY_GROUP_REMAIN" | sed "/^\s*\-\s*${TargetName}$/d")
    done

    PROXY_GROUP=$(echo "${PROXY_GROUP_REMAIN}")
fi

# Add contents to target config file
colorEcho ${BLUE} "  Setting all config to ${TARGET_CONFIG_FILE}..."
[[ -f "$TARGET_CONFIG_FILE" ]] && rm -f "$TARGET_CONFIG_FILE"

START_LINE=1
ADD_CONTENT=$(sed -n "${START_LINE},${CFW_BYPASS_LINE} p" "$CLASH_CONFIG")
# while read -r line; do printf "%s\n" "${line}" >> "$TARGET_CONFIG_FILE"; done <<<"$ADD_CONTENT"
echo "$ADD_CONTENT" >> "$TARGET_CONFIG_FILE"

if [[ -n "$CFW_BYPASS" ]]; then
    colorEcho ${BLUE} "    Setting cfw bypass..."
    echo "${CFW_BYPASS}" | tee -a "$TARGET_CONFIG_FILE" >/dev/null
fi

START_LINE=$((${CFW_BYPASS_LINE} + 1))
if [[ ${PROXY_CUSTOM_LINE} -gt 0 ]]; then
    ADD_CONTENT=$(sed -n "${START_LINE},${PROXY_CUSTOM_LINE} p" "$CLASH_CONFIG")
    echo "$ADD_CONTENT" >> "$TARGET_CONFIG_FILE"
fi

if [[ -n "$PROXY_CUSTOM" ]]; then
    colorEcho ${BLUE} "    Setting custom proxies..."
    echo "${PROXY_CUSTOM}" | tee -a "$TARGET_CONFIG_FILE" >/dev/null
fi

if [[ ${PROXY_CUSTOM_LINE} -gt 0 ]]; then
    START_LINE=$((${PROXY_CUSTOM_LINE} + 1))
else
    START_LINE=$((${CFW_BYPASS_LINE} + 1))
fi
ADD_CONTENT=$(sed -n "${START_LINE},${PROXY_LINE} p" "$CLASH_CONFIG")
echo "$ADD_CONTENT" >> "$TARGET_CONFIG_FILE"

if [[ -n "$PROXY" ]]; then
    colorEcho ${BLUE} "    Setting proxies..."
    echo "${PROXY}" | tee -a "$TARGET_CONFIG_FILE" >/dev/null
fi

START_LINE=$((${PROXY_LINE} + 1))
if [[ ${PROXY_MERGE_LINE} -gt 0 ]]; then
    ADD_CONTENT=$(sed -n "${START_LINE},${PROXY_MERGE_LINE} p" "$CLASH_CONFIG")
    echo "$ADD_CONTENT" >> "$TARGET_CONFIG_FILE"
fi

if [[ -n "$PROXY_MERGE" ]]; then
    colorEcho ${BLUE} "    Setting merge proxies..."
    echo "${PROXY_MERGE}" | tee -a "$TARGET_CONFIG_FILE" >/dev/null
fi

if [[ ${PROXY_MERGE_LINE} -gt 0 ]]; then
    START_LINE=$((${PROXY_MERGE_LINE} + 1))
else
    START_LINE=$((${PROXY_LINE} + 1))
fi
ADD_CONTENT=$(sed -n "${START_LINE},${PROXY_GROUP_LINE} p" "$CLASH_CONFIG")
echo "$ADD_CONTENT" >> "$TARGET_CONFIG_FILE"

if [[ -n "$PROXY_GROUP" ]]; then
    colorEcho ${BLUE} "    Setting proxy groups..."
    echo "${PROXY_GROUP}" | tee -a "$TARGET_CONFIG_FILE" >/dev/null
fi

START_LINE=$((${PROXY_GROUP_LINE} + 1))
ADD_CONTENT=$(sed -n "${START_LINE},${RULES_LINE} p" "$CLASH_CONFIG")
echo "$ADD_CONTENT" >> "$TARGET_CONFIG_FILE"

if [[ -n "$RULE_CUSTOM" ]]; then
    colorEcho ${BLUE} "    Setting custom rules..."
    echo "${RULE_CUSTOM}" | tee -a "$TARGET_CONFIG_FILE" >/dev/null
fi

if [[ -n "$RULES" ]]; then
    colorEcho ${BLUE} "    Setting rules..."
    echo "${RULES}" | tee -a "$TARGET_CONFIG_FILE" >/dev/null
fi

sed -i "/^# \[.*/d" "$TARGET_CONFIG_FILE"

# Config file with custom proxy
if [[ -n "$TARGET_WITH_CUSTOM_PROXY" ]]; then
    cp -f "$TARGET_CONFIG_FILE" "$TARGET_WITH_CUSTOM_PROXY"
fi

# Remove custom proxy from $TARGET_CONFIG_FILE
if [[ -n "$PROXY_CUSTOM" ]]; then
    CUSTOM_START_LINE=$(grep -E -n "^proxies:" "${TARGET_CONFIG_FILE}" | cut -d: -f1)
    CUSTOM_START_LINE=$((${CUSTOM_START_LINE} + 1))
    PROXY_CUSTOM_COUNT=$(echo "$PROXY_CUSTOM" | wc -l)
    CUSTOM_END_LINE=$((${CUSTOM_START_LINE} + ${PROXY_CUSTOM_COUNT}))
    sed -i "${CUSTOM_START_LINE},${CUSTOM_END_LINE} d" "$TARGET_CONFIG_FILE"

    for TargetName in "${CUSTOM_NAME[@]}"; do
        sed -i "/      - ${TargetName}/d" "$TARGET_CONFIG_FILE"
    done
fi

# Copy to file
if [[ -n "$COPY_TO_FILE" ]]; then
    colorEcho ${BLUE} "  Copy config to ${COPY_TO_FILE}..."
    if [[ -d "/srv/clash" && "$TARGET_CONFIG_FILE" != "/srv/clash/config.yaml" ]]; then
        cp -f "$TARGET_CONFIG_FILE" "/srv/clash/config.yaml"
    fi

    cp -f "$TARGET_CONFIG_FILE" "$COPY_TO_FILE"

    if [[ ! -s "${COPY_TO_FILE}.md5" ]]; then
        colorEcho ${BLUE} "  Gen md5 for ${COPY_TO_FILE}..."
        (openssl md5 -hex "${COPY_TO_FILE}" | cut -d" " -f2) > "${COPY_TO_FILE}.md5"
    fi

    COPY_TO_CUSTOM=$(echo "$COPY_TO_FILE" | sed 's/\./_custom\./')
    colorEcho ${BLUE} "  Copy config with custom proxy to ${COPY_TO_CUSTOM}..."
    cp -f "$TARGET_WITH_CUSTOM_PROXY" "$COPY_TO_CUSTOM"

    if [[ ! -s "${COPY_TO_CUSTOM}.md5" ]]; then
        colorEcho ${BLUE} "  Gen md5 for ${COPY_TO_CUSTOM}..."
        (openssl md5 -hex "${COPY_TO_CUSTOM}" | cut -d" " -f2) > "${COPY_TO_CUSTOM}.md5"
    fi
fi


colorEcho ${BLUE} "  Done!"
