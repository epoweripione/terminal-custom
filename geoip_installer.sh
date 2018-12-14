#!/bin/bash

if [[ $UID -ne 0 ]]; then
    echo "Please run this script as root user!"
    exit 0
fi

# Load custom functions
if type 'colorEcho' 2>/dev/null | grep -q 'function'; then
    :
else
    if [[ -e "$HOME/custom_functions.sh" ]]; then
        source "$HOME/custom_functions.sh"
    else
        echo "$HOME/custom_functions.sh not exist!"
        exit 0
    fi
fi


# if check_release_package_manager packageManager yum; then
#     yum update -y && yum -y -q install geoip geoip-data
# elif check_release_package_manager packageManager apt; then
#     apt update && apt -y install geoip-bin geoip-database
# elif check_release_package_manager packageManager pacman; then
#     pacman -Sy && pacman -S geoip geoip-data
# fi


# pacapt - An Arch's pacman-like package manager for some Unices
# https://github.com/icy/pacapt
if [[ ! -x "$(command -v pacapt)" ]]; then
    colorEcho ${BLUE} "Installing pacapt - An Arch's pacman-like package manager for some Unices..."
    sudo curl -SL https://github.com/icy/pacapt/raw/ng/pacapt -o /usr/bin/pacapt && \
        sudo chmod 755 /usr/bin/pacapt && \
        sudo ln -sv /usr/bin/pacapt /usr/bin/pacman || true
fi

# GeoIP binary and database
# http://kbeezie.com/geoiplookup-command-line/
if pacman -Si geoip-bin >/dev/null 2>&1; then
    pacman -S geoip-bin geoip-database
else
    pacman -S geoip geoip-data
fi

## How to use
# geoiplookup 8.8.8.8