#!/usr/bin/env bash

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


## https://stackoverflow.com/questions/61002681/connecting-to-wsl2-server-via-local-network


## https://github.com/shayne/go-wsl2-host


## https://superuser.com/questions/1594420/cant-access-127-0-0-180-outside-of-wsl2-ubuntu-20-04
## https://docs.microsoft.com/en-us/windows/wsl/wsl-config
# @'
# [wsl2]
# localhostForwarding=true
# '@ | Tee-Object "$HOME\.wslconfig" -Append | Out-Null


## Enabling WSL2 Support in Firewall Settings
## https://docs.microsoft.com/en-us/powershell/module/netsecurity/new-netfirewallrule
## In the Administrative PowerShell Prompt run the following command:
# New-NetFirewallRule -DisplayName "WSL" -Direction Inbound -InterfaceAlias "vEthernet (WSL)"  -Action Allow
# Get-NetFirewallRule -Direction Inbound | Where-Object { $_.DisplayName -eq "WSL" }
# Remove-NetFireWallRule -DisplayName "WSL"


## tunnel your port towards your IP address:
## https://github.com/microsoft/WSL/issues/5131
## In the Administrative PowerShell Prompt run the following command:
# # $env:MainIP=(Test-Connection -IPv4 -ComputerName $env:COMPUTERNAME -Count 1).Address.toString()
# # netsh interface portproxy show all
# # netsh interface portproxy reset all
# $env:MainIP=Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -match 'wsl' } | Select-Object -ExpandProperty IPv4Address
# # netsh interface portproxy delete v4tov4 listenaddress=$env:MainIP listenport=7890
# netsh interface portproxy add v4tov4 listenaddress=$env:MainIP listenport=7890 connectaddress=localhost connectport=7890


## https://gist.github.com/toryano0820/6ee3bff2474cdf13e70d972da710996a
if [[ -n "${GLOBAL_WSL2_HOST_IP}" ]]; then
    WSL_HOST_IP="${GLOBAL_WSL2_HOST_IP}"
else
    WSL_HOST_IP=$(grep -m1 nameserver /etc/resolv.conf | awk '{print $2}')
fi

if [[ -n "${WSL_HOST_IP}" ]]; then
    if ! grep -q "${WSL_HOST_IP} localhost" /etc/hosts; then
        colorEcho "${GREEN}  :: Mapping ${FUCHSIA}${WSL_HOST_IP}${GREEN} to ${YELLOW}localhost${GREEN}..."
        LOCALHOST_ENTRY=$(grep -v "127.0.0.1" /etc/hosts | grep "\slocalhost$")
        if [[ -n "${LOCALHOST_ENTRY}" ]]; then
            sudo sed -i "s/${LOCALHOST_ENTRY}/${WSL_HOST_IP} localhost/g" /etc/hosts
        else
            echo "${WSL_HOST_IP} localhost" | sudo tee -a /etc/hosts >/dev/null
        fi
    fi
fi

unset WSL_HOST_IP

# cat /etc/hosts
