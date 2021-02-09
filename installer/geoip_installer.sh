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


# if check_release_package_manager packageManager yum; then
#     yum update -y && yum -y -q install geoip geoip-data
# elif check_release_package_manager packageManager apt; then
#     apt update && apt -y install geoip-bin geoip-database
# elif check_release_package_manager packageManager pacman; then
#     pacman -Sy && pacman -S geoip geoip-data
# fi


if [[ ! -x "$(command -v pacaptr)" ]]; then
    [[ -s "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/installer/pacaptr_installer.sh" ]] && \
        source "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/installer/pacaptr_installer.sh"
fi

# GeoIP binary and database
# http://kbeezie.com/geoiplookup-command-line/
PackagesList=(
    geoip-bin
    geoip-database
    GeoIP
    GeoIP-data
    geoip
    geoip-data
)
for TargetPackage in "${PackagesList[@]}"; do
    if checkPackageNeedInstall "${TargetPackage}"; then
        colorEcho "${BLUE}  Installing ${TargetPackage}..."
        sudo pacman --noconfirm -S "${TargetPackage}"
    fi
done

## How to use
# geoiplookup 8.8.8.8
