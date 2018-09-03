#######color code########
RED="31m"      # Error message
GREEN="32m"    # Success message
YELLOW="33m"   # Warning message
BLUE="36m"     # Info message

function colorEcho() {
    COLOR=$1
    echo -e "\033[${COLOR}${@:2}\033[0m"
}

function get_os_type() {
    os=$(uname)
    os_wsl=$(uname -r)
    if [[ $os == "Darwin" ]]; then
        ostype="darwin"
    elif [[ $os_wsl =~ "Microsoft" || $os =~ "MSYS_NT" || $os =~ "MINGW" || $os =~ "CYGWIN_NT" ]]; then
        ostype="windows"
    else
        ostype=$(echo "$os" | sed 's/.*/\L&/')
    fi
}

function check_release_package_manager() {
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
    elif [[ $os =~ "MSYS_NT" || $os =~ "MINGW" ]]; then
        release="MSYS"
        systemPackage="pacman"
    elif [[ $os =~ "CYGWIN_NT" ]]; then
        release="CYGWIN"
        systemPackage="apt-cyg"
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

function get_arch() {
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

function get_os_icon() {
    case $(uname) in
        Darwin)
        OS='OSX'
        OS_ICON=$'\uF179'
        ;;
        MSYS_NT-* | MINGW* | CYGWIN_NT-*)
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
