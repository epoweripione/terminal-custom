
#!/bin/bash

# Load custom functions
if [[ -e "$HOME/custom_functions.sh" ]]; then
    source "$HOME/custom_functions.sh"
else
    echo "$HOME/custom_functions.sh not exist!"
    exit 0
fi

if [[ -z "$spruce_type" ]]; then
    get_os_type
    get_arch
fi


if [[ ! "$(command -v curl)" ]]; then
    if check_release_package_manager packageManager yum; then
        yum update -y && yum -y -q install curl
    elif check_release_package_manager packageManager apt; then
        apt update && apt -y install curl
    elif check_release_package_manager packageManager pacman; then
        pacman -Sy && pacman -S curl
    fi
fi

if [[ ! "$(command -v curl)" ]]; then
    colorEcho ${RED} "curl is not installed! Please install curl first!"
    exit
fi


if [[ $ostype == "windows" ]]; then
    if [[ $spruce_type == "amd64" ]]; then
        ver="win64"
        url1="https://storage.googleapis.com/chromium-browser-snapshots/Win_x64"
        url2="https://storage.googleapis.com/chromium-browser-snapshots/win_rel"
    else
        ver="win32"
        url1="https://storage.googleapis.com/chromium-browser-snapshots/Win"
        url2="https://storage.googleapis.com/chromium-browser-snapshots/win32_rel"
    fi

    chromium_ver1=$(curl --socks5-hostname 127.0.0.1:55880 -fsSL ${url1}/LAST_CHANGE)
    chromium_ver2=$(curl --socks5-hostname 127.0.0.1:55880 -fsSL ${url2}/LAST_CHANGE)
    if [[ $chromium_ver1 -gt $chromium_ver2 ]]; then
        url=$url1
        chromium_ver=$chromium_ver1
    else
        url=$url2
        chromium_ver=$chromium_ver2
    fi

    if [[ -d /d/Downloads ]]; then
        echo "Downloading Chromium Dev $ostype-$spruce_type-r$chromium_ver"
        curl --socks5-hostname 127.0.0.1:55880 -fSL ${url}/${chromium_ver}/chrome-win32.zip -o /d/Downloads/chrome-$ver-$chromium_ver.zip
    fi
fi
