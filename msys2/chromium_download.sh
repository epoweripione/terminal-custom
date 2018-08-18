
#!/bin/bash

get_os_type() {
    os=$(uname)
    if [[ $os == "Darwin" ]]; then
        ostype="darwin"
    elif [[ $os =~ "MSYS_NT" || $os =~ "MINGW" || $os =~ "CYGWIN_NT" ]]; then
        ostype="windows"
    else
        ostype=$(echo "$os" | sed 's/.*/\L&/')
    fi
}

check_sys() {
    local checkType=$1
    local value=$2

    local release=''
    local systemPackage=''

    os=$(uname)
    if [[ -f /etc/redhat-release ]]; then
        release="centos"
        systemPackage="yum"
    elif [[ -f /etc/alpine-release ]]; then
        release="alpine"
        systemPackage="apk"
    elif [[ -f /etc/arch-release ]]; then
        release="arch"
        systemPackage="pacman"
    elif [[ $os =~ "MSYS_NT" || $os =~ "MINGW" || $os =~ "CYGWIN_NT" ]]; then
        release="MSYS"
        systemPackage="pacman"
    elif cat /etc/issue | grep -Eqi "debian"; then
        release="debian"
        systemPackage="apt"
    elif cat /etc/issue | grep -Eqi "ubuntu"; then
        release="ubuntu"
        systemPackage="apt"
    elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
        release="centos"
        systemPackage="yum"
    elif cat /proc/version | grep -Eqi "debian"; then
        release="debian"
        systemPackage="apt"
    elif cat /proc/version | grep -Eqi "ubuntu"; then
        release="ubuntu"
        systemPackage="apt"
    elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
        release="centos"
        systemPackage="yum"
    fi

    if [[ ${checkType} == "sysRelease" ]]; then
        if [[ "$value" == "$release" ]]; then
            return 0
        else
            return 1
        fi
    elif [[ ${checkType} == "packageManager" ]]; then
        if [[ "$value" == "$systemPackage" ]]; then
            return 0
        else
            return 1
        fi
    fi
}

get_arch() {
	architecture=$(uname -m)
	case "$architecture" in
		amd64|x86_64)
			spruce_type='amd64'
			;;
		i386|i486|i586|i686|x86)
			spruce_type='386'
			;;
		*)
			cat 1>&2 <<-EOF
			This script only support 32bit and 64bit architecture!
			Your OS is: $architecture.
			EOF
			exit 1
			;;
	esac
}

get_os_icon() {
    case $(uname) in
        Darwin)
        OS='OSX'
        OS_ICON=$'\uF179'
        ;;
        CYGWIN_NT-* | MSYS_NT-*)
        OS='Windows'
        OS_ICON=$'\uF17A'
        ;;
        FreeBSD)
        OS='BSD'
        OS_ICON=$'\uF30C'
        ;;
        OpenBSD)
        OS='BSD'
        OS_ICON=$'\uF30C'
        ;;
        DragonFly)
        OS='BSD'
        OS_ICON=$'\uF30C'
        ;;
        Linux)
        OS='Linux'
        os_release_id="$(grep -E '^ID=([a-zA-Z]*)' /etc/os-release | cut -d '=' -f 2)"
        case "$os_release_id" in
            *arch*)
            OS_ICON=$'\uF303'
            ;;
            *debian*)
            OS_ICON=$'\uF306'
            ;;
        *ubuntu*)
            OS_ICON=$'\uF31B'
            ;;
        *elementary*)
            OS_ICON=$'\uF309'
            ;;
        *fedora*)
            OS_ICON=$'\uF30A'
            ;;
        *coreos*)
            OS_ICON=$'\uF305'
            ;;
        *gentoo*)
            OS_ICON=$'\uF30D'
            ;;
        *mageia*)
            OS_ICON=$'\uF310'
            ;;
        *centos*)
            OS_ICON=$'\uF304'
            ;;
        *opensuse*|*tumbleweed*)
            OS_ICON=$'\uF314'
            ;;
        *sabayon*)
            OS_ICON=$'\uF317'
            ;;
        *slackware*)
            OS_ICON=$'\uF319'
            ;;
        *linuxmint*)
            OS_ICON=$'\uF30E'
            ;;
        *alpine*)
            OS_ICON=$'\uF300'
            ;;
        *aosc*)
            OS_ICON=$'\uF301'
            ;;
        *nixos*)
            OS_ICON=$'\uF313'
            ;;
        *devuan*)
            OS_ICON=$'\uF307'
            ;;
        *manjaro*)
            OS_ICON=$'\uF312'
            ;;
            *)
            OS='Linux'
            OS_ICON=$'\uF17C'
            ;;
        esac

        # Check if we're running on Android
        case $(uname -o 2>/dev/null) in
            Android)
            OS='Android'
            OS_ICON=$'\uF17B'
            ;;
        esac
        ;;
        SunOS)
        OS='Solaris'
        OS_ICON=$'\uF185'
        ;;
        *)
        OS=''
        OS_ICON=''
        ;;
    esac
}


if [ -z "$spruce_type" ]; then
    get_os_type
    get_arch
fi

# if check_sys packageManager yum; then
#     yum update -y && yum  -y -q install curl
# elif check_sys packageManager apt; then
#     apt update && apt -y install curl
# elif check_sys packageManager pacman; then
#     pacman -Sy && pacman -S curl
# fi

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

    echo "Downloading Chromium Dev $ostype-$spruce_type-r$chromium_ver"
    curl --socks5-hostname 127.0.0.1:55880 -fSL ${url}/${chromium_ver}/chrome-win32.zip -o /d/Downloads/chrome-$ver-$chromium_ver.zip
fi
