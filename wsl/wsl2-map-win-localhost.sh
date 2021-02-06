#!/usr/bin/env bash

## https://superuser.com/questions/1594420/cant-access-127-0-0-180-outside-of-wsl2-ubuntu-20-04
## https://docs.microsoft.com/en-us/windows/wsl/wsl-config
# @'
# [wsl2]
# localhostForwarding=true
# '@ | Tee-Object "$HOME\.wslconfig" -Append | Out-Null


## Enabling WSL2 Support in Firewall Settings
## In the Administrative PowerShell Prompt run the following command:
# New-NetFirewallRule -DisplayName "WSL" -Direction Inbound  -InterfaceAlias "vEthernet (WSL)"  -Action Allow


## tunnel your port towards your IP address:
## https://github.com/microsoft/WSL/issues/5131
## In the Administrative PowerShell Prompt run the following command:
# $env:MainIP=(Test-Connection -IPv4 -ComputerName $env:COMPUTERNAME -Count 1).Address.toString()
# # netsh interface portproxy show all
# # netsh interface portproxy reset all
# netsh interface portproxy add v4tov4 listenaddress=$env:MainIP listenport=7890 connectaddress=localhost connectport=7890


## https://gist.github.com/toryano0820/6ee3bff2474cdf13e70d972da710996a
nameserver=$(grep -m 1 nameserver /etc/resolv.conf | awk '{print $2}')
if [[ -n "$nameserver" ]]; then
    localhost_entry=$(grep -v "127.0.0.1" /etc/hosts | grep "\slocalhost$")
    if [[ -n "$localhost_entry" ]]; then
        sudo sed -i "s/$localhost_entry/$nameserver localhost/g" /etc/hosts
    else
        echo "$nameserver localhost" | sudo tee -a /etc/hosts >/dev/null
    fi
fi

# cat /etc/hosts
