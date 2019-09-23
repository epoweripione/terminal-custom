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

if [[ -z "$ostype" ]]; then
    get_os_type
fi


# Local WAN IP
if [[ -z "$WAN_NET_IP" ]]; then
    get_network_wan_ipv4
fi

if [[ -z "$WAN_NET_IP" ]]; then
    colorEcho ${RED} "Can't get local WAN IP address!"
    exit 1
fi


if [[ $ostype == "windows" ]]; then
    HostsFile=/c/Windows/System32/drivers/etc/hosts
else
    HostsFile=/etc/hosts
fi


colorEcho ${BLUE} "Setting hosts for github..."
HostsList=(
github.com
www.github.com
api.github.com
gist.github.com
assets-cdn.github.com
github.global.ssl.fastly.net
github-cloud.s3.amazonaws.com
)
# raw.githubusercontent.com
# gist.githubusercontent.com
# cloud.githubusercontent.com
# camo.githubusercontent.com
# avatars0.githubusercontent.com
# avatars1.githubusercontent.com
# avatars2.githubusercontent.com
# avatars3.githubusercontent.com
# avatars4.githubusercontent.com
# avatars5.githubusercontent.com
# avatars6.githubusercontent.com
# avatars7.githubusercontent.com
# avatars8.githubusercontent.com
# github.githubassets.com

# begin line
if [[ $(grep "^# Github Start" ${HostsFile}) ]]; then
    LineBegin=$(cat -n ${HostsFile} | grep '# Github Start' | awk '{print $1}')
    LineEnd=$(cat -n ${HostsFile} | grep '# Github End' | awk '{print $1}')
    if [[ -n "$LineBegin" && -n "$LineEnd" ]]; then
        DeleteBegin=$((${LineBegin}+1))
        DeleteEnd=$((${LineEnd}-1))
        sed -i "${DeleteBegin},${DeleteEnd}d" ${HostsFile}
    fi
else
    echo -e "\n# Github Start" | tee -a ${HostsFile}
    sed -i "/github/d" ${HostsFile}
fi

# https://amazonaws.com.ipaddress.com/github-cloud.s3.amazonaws.com
# https://github.com.ipaddress.com/
# https://github.com.ipaddress.com/assets-cdn.github.com
# https://fastly.net.ipaddress.com/github.global.ssl.fastly.net
for TargetHost in ${HostsList[@]}; do
    # echo ${TargetHost}
    TargetDomain=$(echo ${TargetHost} | awk -F. '{print $(NF-1),$NF}' OFS=".")
    if [[ "$TargetDomain" == "$TargetHost" ]]; then
        TargetURL=https://${TargetDomain}.ipaddress.com/
    else
        TargetURL=https://${TargetDomain}.ipaddress.com/${TargetHost}
    fi

    TargetIP=$(curl -sL --connect-timeout 5 --max-time 10 ${TargetURL} | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' | grep -v ${WAN_NET_IP} | head -n1)
    if [[ -n "$TargetIP" ]]; then
        if [[ -n "$LineEnd" ]]; then
            echo "${TargetIP} ${TargetHost}"
            sed -i "${LineEnd}i ${TargetIP} ${TargetHost}" ${HostsFile}
        elif [[ -n "$LineBegin" ]]; then
            echo "${TargetIP} ${TargetHost}"
            sed -i "${LineBegin}a ${TargetIP} ${TargetHost}" ${HostsFile}
        else
            echo "${TargetIP} ${TargetHost}" | tee -a ${HostsFile}
        fi
    fi
done

# end line
if [[ ! $(grep "^# Github End" ${HostsFile}) ]]; then
    echo "# Github End" | tee -a ${HostsFile}
fi


# Flush DNS cache
if [[ $ostype == "windows" ]]; then
    ipconfig -flushdns || true
else
    systemd-resolve --flush-caches || true
    /etc/init.d/dns-clean start || true
    systemctl restart dnsmasq.service || true
fi


colorEcho ${BLUE} "Done."