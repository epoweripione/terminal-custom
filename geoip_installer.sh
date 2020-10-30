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


# if check_release_package_manager packageManager yum; then
#     yum update -y && yum -y -q install geoip geoip-data
# elif check_release_package_manager packageManager apt; then
#     apt update && apt -y install geoip-bin geoip-database
# elif check_release_package_manager packageManager pacman; then
#     pacman -Sy && pacman -S geoip geoip-data
# fi


if [[ ! -x "$(command -v pacaptr)" ]]; then
    [[ -s "$HOME/pacaptr_installer.sh" ]] && source "$HOME/pacaptr_installer.sh"
fi

# GeoIP binary and database
# http://kbeezie.com/geoiplookup-command-line/
if pacman -Si geoip-bin >/dev/null 2>&1; then
    sudo pacman -S --noconfirm geoip-bin geoip-database
else
    if pacman -Si GeoIP >/dev/null 2>&1; then
        sudo pacman -S --noconfirm GeoIP GeoIP-data
    else
        sudo pacman -S --noconfirm geoip geoip-data
    fi
fi

## How to use
# geoiplookup 8.8.8.8
