#!/usr/bin/env bash

# Usage:
# ${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/cross/clash_client_providers.sh /srv/web/www/public
# (crontab -l 2>/dev/null || true; echo "0 8,12,15,20 * * * /root/terminal-custom/cross/clash_client_providers.sh /srv/web/www/public >/dev/null") | crontab -

trap 'rm -rf "$WORKDIR"' EXIT

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


COPY_TO_DIR=${1:-""}
TARGET_CONFIG_FILE=${2:-"/etc/clash/clash_provider.yml"}

SUB_URL_LIST=${3:-"/etc/clash/My_Clash_Sub_Providers.txt"}
if [[ ! -s "${SUB_URL_LIST}" ]]; then
    colorEcho "${FUCHSIA}    ${SUB_URL_LIST}${RED} not exist!"
    exit 1
fi

CLASH_CONFIG=${4:-"/etc/clash/clash_client_providers.yml"}
if [[ ! -s "${CLASH_CONFIG}" ]]; then
    colorEcho "${FUCHSIA}    ${CLASH_CONFIG}${RED} not exist!"
    exit 1
fi


if ! pgrep -f "subconverter" >/dev/null 2>&1; then
    # if [[ -s "/srv/subconverter/subconverter" ]]; then
    #     nohup /srv/subconverter/subconverter >/dev/null 2>&1 & disown
    # fi
    [[ $(systemctl is-enabled subconverter 2>/dev/null) ]] && sudo systemctl restart subconverter
fi

if ! pgrep -f "subconverter" >/dev/null 2>&1; then
    colorEcho "${RED}Please install and run ${FUCHSIA}subconverter${RED} first!"
    exit 1
fi


colorEcho "${BLUE}Getting ${FUCHSIA}clash rules${BLUE}..."

# Update ACL4SSR
# https://github.com/ACL4SSR/ACL4SSR
if [[ -s "/srv/subconverter/subconverter" ]]; then
    if [[ -d "/etc/clash" ]]; then
        find "/etc/clash" -type f -name "*_Profile*" -print0 | xargs -0 -I{} cp -f {} "/srv/subconverter/profiles"
        find "/srv/subconverter/config" -type l -name "*_Rules*" -print0 | xargs -0 -I{} rm -f {}
        find "/etc/clash" -type f -name "*_Rules*" -print0 | xargs -0 -I{} cp -f {} "/srv/subconverter/config"
    fi

    if Git_Clone_Update "ACL4SSR/ACL4SSR" "/srv/subconverter/ACL4SSR" "github.com" "master"; then
        cp -f /srv/subconverter/ACL4SSR/Clash/*.list /srv/subconverter/rules/ACL4SSR/Clash
        cp -f /srv/subconverter/ACL4SSR/Clash/Ruleset/*.list /srv/subconverter/rules/ACL4SSR/Clash/Ruleset
        cp -f /srv/subconverter/ACL4SSR/Clash/*.yml /srv/subconverter/config
        cp -f /srv/subconverter/ACL4SSR/Clash/config/*.ini /srv/subconverter/config
    fi
fi


TARGET_CONFIG_DIR=$(dirname "${TARGET_CONFIG_FILE}")
TARGET_CONFIG_NAME=$(basename "${TARGET_CONFIG_FILE}")

PROXIES_PRIVATE=""
PROXIES_PUBLIC=""

PROXY_LIST_ALL=()
PROXY_SERVER_ALL=()

FILELIST=()
FILEOPTION=()
while read -r READLINE || [[ "${READLINE}" ]]; do
    [[ -z "${READLINE}" ]] && continue

    TARGET_FILE=$(echo ${READLINE} | cut -d' ' -f1)
    [[ "${TARGET_FILE}" == "#" ]] && continue

    TARGET_URL=$(echo ${READLINE} | cut -d' ' -f2)
    TARGET_OPTION=$(echo ${READLINE} | cut -d' ' -f3)
    TARGET_FILTER=$(echo ${READLINE} | cut -d' ' -f4)
    TARGET_TYPE_FILTER=$(echo ${READLINE} | cut -d' ' -f5)

    colorEcho "${BLUE}  Getting ${FUCHSIA}${TARGET_FILE}${BLUE}..."
    DOWNLOAD_FILE="${WORKDIR}/${TARGET_FILE}.yml"

    curl -fsL --connect-timeout 10 --max-time 30 -o "${DOWNLOAD_FILE}" "${TARGET_URL}"
    if [[ $? != 0 ]]; then
        colorEcho "${RED}    Error when downloading from ${FUCHSIA}${TARGET_URL}${RED}!"
        [[ "${TARGET_OPTION}" == "rules" ]] && exit 1 || continue
    fi

    if [[ "${TARGET_OPTION}" =~ "scrap" ]]; then
        SCRAP_PATTERN=()
        SCRAP_SUCCESS="no"
        SCRAP_INDEX=0

        SCRAP_PATTERN=(`echo "${TARGET_OPTION}" | sed 's/→/\n/g'`)
        for TargetPattern in "${SCRAP_PATTERN[@]}"; do
            SCRAP_INDEX=$((${SCRAP_INDEX} + 1))
            [[ ${SCRAP_INDEX} -eq 1 ]] && continue

            sed -i -e 's/\&amp;/\&/g' -e 's/\&\&/\&/g' "${DOWNLOAD_FILE}"

            MATCH_URL=$(cat "${DOWNLOAD_FILE}" | grep -o -P "${TargetPattern}" | uniq)
            while read -r TARGET_URL; do
                [[ -z "${TARGET_URL}" ]] && continue

                TARGET_URL=$(echo "${TARGET_URL}" | grep -o -P "(((ht|f)tps?):\/\/)?[\w-]+(\.[\w-]+)+([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?")
                [[ -z "${TARGET_URL}" ]] && continue

                colorEcho "${BLUE}    Scraping from ${FUCHSIA}${TARGET_URL}${BLUE}..."
                curl -fsL --connect-timeout 10 --max-time 30 -o "${DOWNLOAD_FILE}" "${TARGET_URL}"
                [[ $? != 0 ]] && continue

                if [[ ${SCRAP_INDEX} -eq ${#SCRAP_PATTERN[@]} ]]; then
                    SCRAP_SUCCESS="yes"
                else
                    MATCH_NEXT=$(cat "${DOWNLOAD_FILE}" | grep -o -P "${SCRAP_PATTERN[$SCRAP_INDEX]}")
                    [[ -n "${MATCH_NEXT}" ]] && break
                fi
            done <<<"${MATCH_URL}"
        done

        [[ "${SCRAP_SUCCESS}" == "no" ]] && continue
    fi

    [[ ! -s "${DOWNLOAD_FILE}" ]] && continue

    if [[ "${TARGET_OPTION}" == "rules" ]]; then
        # Get rules
        RULES_START_LINE=$(grep -E -n "^rules:" "${DOWNLOAD_FILE}" | cut -d: -f1)
        if [[ ${RULES_START_LINE} -gt 0 ]]; then
            RULES_START_LINE=$((${RULES_START_LINE} + 1))
            RULES=$(sed -n "${RULES_START_LINE},$ p" "${DOWNLOAD_FILE}")
        fi
    else
        FILELIST+=("${TARGET_FILE}")
        FILEOPTION+=("${TARGET_OPTION}")

        TARGET_LIST_FILE="${WORKDIR}/${TARGET_FILE}.list"

        # Compact proxies
        sed -i 's/^\s*-/-/g' "${DOWNLOAD_FILE}"
        sed -i -e 's/":/: /g' -e 's/:"/: /g' -e 's/",/, /g' -e 's/,"/, /g' -e 's/"//g' "${DOWNLOAD_FILE}"
        sed -i -e 's/\[/【/g' -e 's/\]/】/g' -e 's/|/｜/g' -e 's/\?/？/g' -e 's/\&/δ/g' "${DOWNLOAD_FILE}"
        sed -i -e 's/ @/ /g' -e "s/name:\s*\-\s*/name: /g" "${DOWNLOAD_FILE}"

        # Merge proxies
        TARGET_PROXIES=""
        if [[ "${TARGET_OPTION}" == *"full"* ]]; then
            PROXY_START_LINE=$(grep -E -n "^proxies:" "${DOWNLOAD_FILE}" | cut -d: -f1)
            GROUP_START_LINE=$(grep -E -n "^proxy-groups:" "${DOWNLOAD_FILE}" | cut -d: -f1)
            if [[ ${PROXY_START_LINE} -gt 0 && ${GROUP_START_LINE} -gt 0 && ${GROUP_START_LINE} -gt ${PROXY_START_LINE} ]]; then
                PROXY_START_LINE=$((${PROXY_START_LINE} + 1))
                PROXY_END_LINE=$((${GROUP_START_LINE} - 1))
                TARGET_PROXIES=$(sed -n "${PROXY_START_LINE},${PROXY_END_LINE} p" "${DOWNLOAD_FILE}")
            fi
        elif [[ "${TARGET_OPTION}" == *"proxypool"* ]]; then
            TARGET_PROXIES=$(cat "${DOWNLOAD_FILE}" | sed -e '1d' -e '$d')
        else
            TARGET_PROXIES=$(cat "${DOWNLOAD_FILE}" | sed '1d')
        fi

        if [[ -n "${TARGET_TYPE_FILTER}" ]]; then
            TARGET_PROXIES=$(echo "${TARGET_PROXIES}" | grep -E "type:\s*(${TARGET_TYPE_FILTER}),")
        fi

        PROXY_NAME=()
        PROXY_NEW_NAME=()
        PROXY_DELETE=()
        while read -r line; do
            [[ -z "${line}" ]] && continue

            TargetName=$(echo "${line}" \
                | sed -rn "s/.*[\s\{\,]+name:([^,{}]+).*/\1/ip" \
                | sed -e "s/^\s//" -e "s/\s$//" \
                | sed -e "s/^\"//" -e "s/\"$//")

            TargetServer=$(echo "${line}" \
                | sed -rn "s/.*server:([^,{}]+).*/\1/ip" \
                | sed -e "s/^\s//" -e "s/\s$//" \
                | sed -e "s/^\"//" -e "s/\"$//")

            [[ -z "${TargetName}" || -z "${TargetServer}" ]] && continue

            TargetUUID=$(echo "${line}" \
                | sed -rn "s/.*uuid:([^,{}]+).*/\1/ip" \
                | sed -e "s/^\s//" -e "s/\s$//" \
                | sed -e "s/^\"//" -e "s/\"$//")

            # Rename node name contains only numbers & spaces & special characters
            if echo "${TargetName}" | grep -Eq "^[[:digit:][:space:][:punct:]]+$"; then
                TargetNewName="ZZ💤${TargetName}"
            else
                TargetNewName="${TargetName}"
            fi

            PROXY_IS_DELETE="N"
            if [[ " ${PROXY_LIST_ALL[@]} " =~ " ${TargetNewName} " ]]; then
                PROXY_IS_DELETE="Y"
            else
                if [[ "${TARGET_OPTION}" == *"proxypool"* && " ${PROXY_SERVER_ALL[@]} " =~ " ${TargetServer} " ]]; then
                    PROXY_IS_DELETE="Y"
                elif [[ -n "${TARGET_FILTER}" ]]; then
                    if echo "${TargetName}" | grep -Eq "${TARGET_FILTER}"; then
                        PROXY_IS_DELETE="Y"
                    fi
                fi

                if [[ -n "${TargetUUID}" ]]; then
                    [[ ${TargetUUID//-/} =~ ^[[:xdigit:]]{32}$ ]] || PROXY_IS_DELETE="Y"
                fi
            fi

            if [[ "${PROXY_IS_DELETE}" == "Y" ]]; then
                PROXY_DELETE+=("${TargetName}")
            else
                PROXY_NAME+=("${TargetName}")
                PROXY_NEW_NAME+=("${TargetNewName}")
                PROXY_LIST_ALL+=("${TargetNewName}")
                PROXY_SERVER_ALL+=("${TargetServer}")
            fi
        done <<<"${TARGET_PROXIES}"

        for TargetName in "${PROXY_DELETE[@]}"; do
            TargetName=$(echo "${TargetName}" \
                | sed 's/[\\\/\:\*\?\|\$\&\#\[\^\+\.\=\!\"]/\\&/g' \
                | sed 's/]/\\&/g')
            TARGET_PROXIES=$(echo "${TARGET_PROXIES}" | sed "/name:\s*${TargetName},/d")
        done

        # Rename node name contains only numbers & spaces & special characters
        PROXY_INDEX=-1
        for TargetName in "${PROXY_NAME[@]}"; do
            PROXY_INDEX=$((${PROXY_INDEX} + 1))

            TargetNewName="${PROXY_NEW_NAME[$PROXY_INDEX]}"

            echo "      - ${TargetNewName}" >> "${TARGET_LIST_FILE}"

            if [[ "${TargetName}" != "${TargetNewName}" ]]; then
                TargetName=$(echo "${TargetName}" \
                    | sed 's/[\\\/\:\*\?\|\$\&\#\[\^\+\.\=\!\"]/\\&/g' \
                    | sed 's/]/\\&/g')
                TargetNewName=$(echo "${TargetNewName}" \
                    | sed 's/[\\\/\:\*\?\|\$\&\#\[\^\+\.\=\!\"]/\\&/g' \
                    | sed 's/]/\\&/g')
                TARGET_PROXIES=$(echo "${TARGET_PROXIES}" | sed "s/name:\s*${TargetName},/name: ${TargetNewName},/")
            fi
        done

        case "${TARGET_OPTION}" in
            "private")
                [[ -n "${PROXIES_PRIVATE}" ]] && \
                    PROXIES_PRIVATE=$(echo -e "${PROXIES_PRIVATE}\n${TARGET_PROXIES}") || \
                    PROXIES_PRIVATE="${TARGET_PROXIES}"
                ;;
            *)
                [[ -n "${PROXIES_PUBLIC}" ]] && \
                    PROXIES_PUBLIC=$(echo -e "${PROXIES_PUBLIC}\n${TARGET_PROXIES}") || \
                    PROXIES_PUBLIC="${TARGET_PROXIES}"
                ;;
        esac
    fi
done < "${SUB_URL_LIST}"


colorEcho "${BLUE}  Processing ${FUCHSIA}proxies${BLUE}..."
# Sort public proxies
PROXIES_PUBLIC=$(echo "${PROXIES_PUBLIC}" | sort | uniq)

# Proxies
if [[ -n "${PROXIES_PRIVATE}" ]]; then
    PROXIES_ALL=$(echo -e "${PROXIES_PRIVATE}\n${PROXIES_PUBLIC}" | sed 's/^-/  -/g')
else
    PROXIES_ALL=$(echo -e "${PROXIES_PUBLIC}" | sed 's/^-/  -/g')
fi

# Delete lines with empty name
PROXIES_ALL=$(echo -e "${PROXIES_ALL}" | sed '/name:\s*,/d')
PROXIES_ALL=$(echo -e "${PROXIES_ALL}" | sed 's/,,/,/g')

## Add placeholder for proxy-groups
# PROXIES_ALL=$(echo -e "${PROXIES_ALL}\n  - {name: FORBIDDEN-PLACEHOLDER, server: forbidden-placeholder.com, port: 0000, type: trojan, password: Trojan}")

# sort proxy list
sort_array PROXY_LIST_ALL

PROXY_USE_ALL=""
PROXY_TYPE_ALL=()
for TargetName in "${PROXY_LIST_ALL[@]}"; do
    [[ -n "${PROXY_USE_ALL}" ]] && \
        PROXY_USE_ALL=$(echo -e "${PROXY_USE_ALL}\n      - ${TargetName}") || \
        PROXY_USE_ALL="      - ${TargetName}"

    TargetName=$(echo "${TargetName}" \
        | sed 's/[\\\/\:\*\?\|\$\&\#\[\^\+\.\=\!\"]/\\&/g' \
        | sed 's/]/\\&/g')

    TargetLine=$(echo "${PROXIES_ALL}" | grep -E "name: ${TargetName},")

    TargetType=$(echo "${TargetLine}" \
        | sed -rn "s/.*type:([^,{}]+).*/\1/ip" \
        | sed -e "s/^\s//" -e "s/\s$//" \
        | sed -e "s/^\"//" -e "s/\"$//")

    [[ "${TargetType}" == "ss" || "${TargetType}" == "ssr" ]] && TargetType="shadowsocks"
    PROXY_TYPE_ALL+=("${TargetType}")
done

## Add proxies to all
# FILE_INDEX=-1
# for TargetFile in "${FILELIST[@]}"; do
#     FILE_INDEX=$((${FILE_INDEX} + 1))
#     if [[ "${FILEOPTION[$FILE_INDEX]}" == *"all"* ]]; then
#         echo -e "proxies:\n${PROXIES_ALL}" | tee "${WORKDIR}/${TargetFile}" >/dev/null
#     fi
# done

# custom rules
RULE_CUSTOM_FILE="/etc/clash/clash_rule_custom.yml"
if [[ -s "${RULE_CUSTOM_FILE}" ]]; then
    colorEcho "${BLUE}  Getting ${FUCHSIA}custom rules${BLUE}..."
    RULE_CUSTOM=$(cat "${RULE_CUSTOM_FILE}")
fi

# all rules
[[ -n "${RULE_CUSTOM}" ]] && RULES=$(echo -e "${RULE_CUSTOM}\n${RULES}")

# remove 2nd+ occurernce rules
colorEcho "${BLUE}  Processing ${FUCHSIA}duplicate rules${BLUE}..."
DUPLICATE_RULES=$(echo "${RULES}" | grep -Eo ",[a-zA-Z0-9./?=_%:-]*," \
                    | sort -n | uniq -c | awk '{if($1>1) print $2}' | sort -rn)
while read -r line; do
    [[ -z "${line}" ]] && continue
    DUPLICATE_ENTRY=$(echo "${line}" \
        | sed 's/[\\\/\:\*\?\|\$\&\#\[\^\+\.\=\!\"]/\\&/g' \
        | sed 's/]/\\&/g')

    # https://stackoverflow.com/questions/30688682/how-to-remove-from-second-occurrence-until-the-end-of-the-file
    RULES=$(echo "${RULES}" | sed "0,/${DUPLICATE_ENTRY}/b; /${DUPLICATE_ENTRY}/d")

    ## https://stackoverflow.com/questions/16202900/using-sed-between-specific-lines-only
    # ENTRY_FIRST_LINE=$(echo "${RULES}" | grep -En "${DUPLICATE_ENTRY}" | cut -d: -f1 | head -n1)
    # [[ -z "${ENTRY_FIRST_LINE}" ]] && continue
    # ENTRY_START_LINE=$((${ENTRY_FIRST_LINE} + 1))
    # RULES=$(echo "${RULES}" | sed "${ENTRY_START_LINE},$ {/${DUPLICATE_ENTRY}/d;}")
done <<<"${DUPLICATE_RULES}"


# Add contents to target config file
colorEcho "${BLUE}  Setting all config to ${FUCHSIA}${TARGET_CONFIG_FILE}${BLUE}..."
[[ -f "${TARGET_CONFIG_FILE}" ]] && rm -f "${TARGET_CONFIG_FILE}"

FILL_LINES=$(grep -E -n "^#-" "${CLASH_CONFIG}")
LINE_START=1
PROXY_LIST_FILTERED=()
while read -r READLINE || [[ "${READLINE}" ]]; do
    TARGET_LINE=$(echo ${READLINE} | cut -d':' -f1)
    TARGET_TAG=$(echo ${READLINE} | cut -d'-' -f2)
    TARGET_GROUP=$(echo ${READLINE} | cut -d'-' -f3)
    TARGET_FILTER=$(echo ${READLINE} | cut -d'-' -f4)

    LINE_END=$((${TARGET_LINE} - 1))

    [[ -n "${TARGET_FILTER}" ]] && MSG_INFO="${TARGET_FILTER}" || MSG_INFO="${TARGET_TAG}"
    colorEcho "${BLUE}    Generating ${FUCHSIA}${MSG_INFO}${BLUE}..."

    CONTENT_PREFIX=$(sed -n "${LINE_START},${LINE_END} p" "${CLASH_CONFIG}")
    CONTENT_TAG=""
    [[ -n "${TARGET_GROUP}" ]] && CONTENT_IS_GROUP="yes" || CONTENT_IS_GROUP="no"
    case "${TARGET_TAG}" in
        "proxies")
            CONTENT_TAG="${PROXIES_ALL}"
            ;;
        "all")
            CONTENT_TAG="${PROXY_USE_ALL}"
            ;;
        "rules")
            CONTENT_TAG="${RULES}"
            ;;
        "type")
            # filter by protocol type
            PROXY_INDEX=-1
            for TargetName in "${PROXY_LIST_ALL[@]}"; do
                PROXY_INDEX=$((${PROXY_INDEX} + 1))

                if echo "${PROXY_TYPE_ALL[$PROXY_INDEX]}" | grep -Eq "${TARGET_FILTER}"; then
                    [[ -n "${CONTENT_TAG}" ]] && \
                        CONTENT_TAG=$(echo -e "${CONTENT_TAG}\n      - ${TargetName}") || \
                        CONTENT_TAG="      - ${TargetName}"
                fi
            done
            ;;
        "OTHERS")
            for TargetName in "${PROXY_LIST_ALL[@]}"; do
                if [[ " ${PROXY_LIST_FILTERED[@]} " =~ " ${TargetName} " ]]; then
                    :
                else
                    [[ -n "${CONTENT_TAG}" ]] && \
                        CONTENT_TAG=$(echo -e "${CONTENT_TAG}\n      - ${TargetName}") || \
                        CONTENT_TAG="      - ${TargetName}"
                fi
            done
            ;;
        *)
            MATCH_TAG="no"
            for TargetFile in "${FILELIST[@]}"; do
                if [[ "${TargetFile}" == "${TARGET_TAG}" && -s "${WORKDIR}/${TargetFile}.list" ]]; then
                    MATCH_TAG="yes"
                    CONTENT_TAG=$(cat "${WORKDIR}/${TargetFile}.list")
                fi
            done

            # Filter by country
            if [[ "${MATCH_TAG}" == "no" ]]; then
                for TargetName in "${PROXY_LIST_ALL[@]}"; do
                    if echo "${TargetName}" | grep -Eq "${TARGET_TAG}"; then
                        [[ -n "${CONTENT_TAG}" ]] && \
                            CONTENT_TAG=$(echo -e "${CONTENT_TAG}\n      - ${TargetName}") || \
                            CONTENT_TAG="      - ${TargetName}"
                        PROXY_LIST_FILTERED+=("${TargetName}")
                    fi
                done
            fi
            ;;
    esac

    # delete empty group
    if [[ -z "${CONTENT_TAG}" && "${CONTENT_IS_GROUP}" == "yes" ]]; then
        CONTENT_PREFIX=$(echo "${CONTENT_PREFIX}" | sed "/name:\s*${TARGET_GROUP}$/,$ d")
        CONTENT_PREFIX=$(echo "${CONTENT_PREFIX}" | sed "/^\s*\-\s*${TARGET_GROUP}$/d")
        sed -i "/^\s*\-\s*${TARGET_GROUP}$/d" "${TARGET_CONFIG_FILE}"
    fi

    [[ -n "${CONTENT_PREFIX}" ]] && echo "${CONTENT_PREFIX}" | tee -a "${TARGET_CONFIG_FILE}" >/dev/null
    [[ -n "${CONTENT_TAG}" ]] && echo "${CONTENT_TAG}" | tee -a "${TARGET_CONFIG_FILE}" >/dev/null

    LINE_START=$((${TARGET_LINE} + 1))
done <<<"${FILL_LINES}"


# Copy to dir
if [[ -n "${COPY_TO_DIR}" ]]; then
    COPY_TO_FILE="${COPY_TO_DIR}/${TARGET_CONFIG_NAME}"
    cp -f "${TARGET_CONFIG_FILE}" "${COPY_TO_FILE}"

    if [[ -n "${PROXIES_PRIVATE}" ]]; then
        if [[ ! -s "${COPY_TO_FILE}.md5" ]]; then
            colorEcho "${BLUE}  Generating md5 for ${FUCHSIA}${COPY_TO_FILE}${BLUE}..."
            (openssl md5 -hex "${COPY_TO_FILE}" | cut -d" " -f2) > "${COPY_TO_FILE}.md5"
        fi
    fi

    # FILE_INDEX=-1
    # for TargetFile in "${FILELIST[@]}"; do
    #     FILE_INDEX=$((${FILE_INDEX} + 1))

    #     COPY_TO_FILE="${COPY_TO_DIR}/${TargetFile}.yml"
    #     cp -f "${WORKDIR}/${TargetFile}.yml" "${COPY_TO_FILE}"

    #     if [[ "${FILEOPTION[$FILE_INDEX]}" == *"private"* ]]; then
    #         if [[ ! -s "${COPY_TO_FILE}.md5" ]]; then
    #             colorEcho "${BLUE}  Gen md5 for ${FUCHSIA}${COPY_TO_FILE}${BLUE}..."
    #             (openssl md5 -hex "${COPY_TO_FILE}" | cut -d" " -f2) > "${COPY_TO_FILE}.md5"
    #         fi
    #     fi
    # done
fi


colorEcho "${BLUE}  Done!"
