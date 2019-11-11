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
fi


# Local WAN IP
if [[ -z "$WAN_NET_IP" ]]; then
    get_network_wan_ipv4
    get_network_wan_geo
fi

if [[ "${WAN_NET_IP_GEO}" =~ 'China' || "${WAN_NET_IP_GEO}" =~ 'CN' ]]; then
    :
else
    colorEcho ${BLUE} "You are not in china! Congratulations!"
    exit 0
fi

if [[ -z "$WAN_NET_IP" ]]; then
    colorEcho ${RED} "Can't get local WAN IP address!"
    exit 1
fi


PARAMS_NUM=$#

# hosts file
if [[ $PARAMS_NUM > 0 ]]; then
    HostsFile="$1"
else
    if [[ "$ostype" == "windows" ]]; then
        HostsFile=/c/Windows/System32/drivers/etc/hosts
    else
        HostsFile=/etc/hosts
    fi
fi

if [[ ! -s "$HostsFile" ]]; then
    colorEcho ${RED} "${HostsFile} not exist!"
    exit 1
fi

# use dig or curl
[[ $PARAMS_NUM > 1 ]] && CHECK_METHOD="$2"
[[ -z "$CHECK_METHOD" ]] && CHECK_METHOD="curl"

# don't modify hosts file
[[ $PARAMS_NUM > 2 ]] && TEST_ONLY="$3"


# dig
if [[ "$CHECK_METHOD" == "dig" && ! -x "$(command -v dig)" ]]; then
    if [[ -x "$(command -v pacapt)" || -x "$(command -v pacman)" ]]; then
        if pacman -Si bind-tools >/dev/null 2>&1; then
            colorEcho ${BLUE} "Installing bind-tools..."
            sudo pacman --noconfirm -S bind-tools
        elif pacman -Si bind-utils >/dev/null 2>&1; then
            colorEcho ${BLUE} "Installing bind-utils..."
            sudo pacman --noconfirm -S bind-utils
        elif pacman -Si dnsutils >/dev/null 2>&1; then
            colorEcho ${BLUE} "Installing dnsutils..."
            sudo pacman --noconfirm -S dnsutils
        fi
    fi
fi


colorEcho ${BLUE} "Setting hosts for github..."
# first char with `-`: Same IP as prior host
HostsList=(
    github.com
    www.github.com
    api.github.com
    gist.github.com
    codeload.github.com
    assets-cdn.github.com
    github.global.ssl.fastly.net
    github-cloud.s3.amazonaws.com
    github-production-release-asset-2e65be.s3.amazonaws.com
    github.githubassets.com
    raw.githubusercontent.com
    -gist.githubusercontent.com
    -cloud.githubusercontent.com
    -camo.githubusercontent.com
    -avatars0.githubusercontent.com
    -avatars1.githubusercontent.com
    -avatars2.githubusercontent.com
    -avatars3.githubusercontent.com
    -avatars4.githubusercontent.com
    -avatars5.githubusercontent.com
    -avatars6.githubusercontent.com
    -avatars7.githubusercontent.com
    -avatars8.githubusercontent.com
)

IP_HOSTS=""

# begin line
if [[ $(grep "^# Github Start" ${HostsFile}) ]]; then
    LineBegin=$(cat -n ${HostsFile} | grep '# Github Start' | awk '{print $1}')
    LineEnd=$(cat -n ${HostsFile} | grep '# Github End' | awk '{print $1}')
    if [[ -n "$LineBegin" && -n "$LineEnd" && -z "$TEST_ONLY" ]]; then
        DeleteBegin=$((${LineBegin}+1))
        DeleteEnd=$((${LineEnd}-1))
        sudo sed -i "${DeleteBegin},${DeleteEnd}d" ${HostsFile}

        LineEnd=$(cat -n ${HostsFile} | grep '# Github End' | awk '{print $1}')
    fi
else
    # echo -e "\n# Github Start" | sudo tee -a ${HostsFile}
    IP_HOSTS="\n# Github Start"
    sudo sed -i "/github/d" ${HostsFile}
fi

# https://amazonaws.com.ipaddress.com/github-cloud.s3.amazonaws.com
# https://github.com.ipaddress.com/
# https://github.com.ipaddress.com/assets-cdn.github.com
# https://fastly.net.ipaddress.com/github.global.ssl.fastly.net
for TargetHost in ${HostsList[@]}; do
    # echo ${TargetHost}

    SameIPPrior=""
    # first char with `-`: Same IP as prior host
    if [[ $(echo ${TargetHost} | grep "^-") ]]; then
        SameIPPrior="yes"
        TargetHost=$(echo ${TargetHost##-}) # remove -
    fi

    colorEcho ${BLUE} "Checking ${TargetHost}..."
    TargetDomain=$(echo ${TargetHost} | awk -F. '{print $(NF-1),$NF}' OFS=".")
    if [[ "$TargetDomain" == "$TargetHost" ]]; then
        TargetURL=https://${TargetDomain}.ipaddress.com/
    else
        TargetURL=https://${TargetDomain}.ipaddress.com/${TargetHost}
    fi

    if [[ -z "$SameIPPrior" ]]; then
        if [[ "$CHECK_METHOD" == "dig" ]]; then
            TargetIP=$(dig +short ${TargetHost} @8.8.8.8 \
                        | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' \
                        | grep -v ${WAN_NET_IP} | head -n1)
        else
            TargetIP=$(curl -sL --connect-timeout 5 --max-time 15 ${TargetURL} \
                        | grep -Eo '<main>.*</main>' \
                        | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' \
                        | grep -v ${WAN_NET_IP} | head -n1)
        fi
    fi

    if [[ -n "$TargetIP" ]]; then
        if [[ -z "$IP_HOSTS" ]]; then
            IP_HOSTS="${TargetIP} ${TargetHost}"
        else
            IP_HOSTS="${IP_HOSTS}\n${TargetIP} ${TargetHost}"
        fi
    fi
done

[[ -n "$IP_HOSTS" ]] && echo -e "${IP_HOSTS}"

if [[ -n "$IP_HOSTS" && -z "$TEST_ONLY" ]]; then
    if [[ ! $(grep "^# Github End" ${HostsFile}) ]]; then
        IP_HOSTS="${IP_HOSTS}\n# Github End"
    fi

    if [[ -n "$LineBegin" ]]; then
        sudo sed -i "${LineBegin}a ${IP_HOSTS}" ${HostsFile}
    elif [[ -n "$LineEnd" ]]; then
        sudo sed -i "${LineEnd}i ${IP_HOSTS}" ${HostsFile}
    else
        # echo -e "${IP_HOSTS}" | sudo tee -a ${HostsFile}
        echo -e "${IP_HOSTS}" | sudo tee -a ${HostsFile} >/dev/null
    fi
fi


# Flush DNS cache
if [[ "$ostype" == "windows" ]]; then
    ipconfig -flushdns || true
else
    [[ -s "/lib/systemd/system/systemd-resolved.service" ]] && \
        sudo ln -sf /lib/systemd/system/systemd-resolved.service \
            /etc/systemd/system/dbus-org.freedesktop.resolve1.service || true

    [[ -x "$(command -v systemd-resolve)" ]] && sudo systemd-resolve --flush-caches

    [[ -s "/etc/init.d/dns-clean" ]] && /etc/init.d/dns-clean start

    if [[ $(systemctl is-enabled systemd-resolved 2>/dev/null) ]]; then
        sudo systemctl restart systemd-resolved.service
    fi

    if [[ $(systemctl is-enabled dnsmasq 2>/dev/null) ]]; then
        sudo systemctl restart dnsmasq.service
    fi
fi


colorEcho ${BLUE} "Done."