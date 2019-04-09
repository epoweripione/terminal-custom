#!/bin/bash

if [[ $UID -ne 0 ]]; then
    echo "Please run this script as root user!"
    exit 0
fi

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


# Cockpit
# https://cockpit-project.org/
# https://github.com/cockpit-project/cockpit
# GETTING STARTED WITH COCKPIT
# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/getting_started_with_cockpit/index

# Setting up the primary Cockpit server
colorEcho ${BLUE} "Installing Cockpit..."
if check_release_package_manager release centos; then
    yum install -y -q cockpit cockpit-docker
    # yum install -y -q cockpit-doc cockpit-machines
    
    systemctl enable --now cockpit.socket

    firewall-cmd --permanent --zone=public --add-service=cockpit
    firewall-cmd --reload
elif check_release_package_manager release debian; then
    # echo 'deb http://deb.debian.org/debian stretch-backports main' > \
    #     /etc/apt/sources.list.d/stretch-backports.list
    apt update && apt -y install cockpit cockpit-docker
    # apt -y install cockpit-doc cockpit-machines
elif check_release_package_manager packageManager pacman; then
    pacman -Sy && pacman -S cockpit cockpit-docker
    # pacman -S cockpit-doc cockpit-machines
fi

# If you already have Cockpit on your server, 
# point your web browser to: https://ip-address-of-machine:9090

# /etc/cockpit/cockpit.conf

# Proxying Cockpit over NGINX
# https://github.com/cockpit-project/cockpit/wiki/Proxying-Cockpit-over-NGINX


# Adding secondary systems
# Once you log in to the primary server,
# you will be able to connect to secondary servers.
# These secondary systems need to have:
# The cockpit packages installed.
# An SSH server running and available on port 22 that supports password or key-based authentication.

# https://github.com/cockpit-project/cockpit/issues/8110
# secondary needs cockpit-system.
# The only package that it doesn't need is cockpit-ws.
# systemctl disable cockpit.socket
# systemctl disable cockpit