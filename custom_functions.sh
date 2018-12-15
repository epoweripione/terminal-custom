#######color code########
RED="31m"      # Error message
GREEN="32m"    # Success message
YELLOW="33m"   # Warning message
BLUE="36m"     # Info message

function colorEcho() {
    COLOR=$1
    echo -e "\033[${COLOR}${@:2}\033[0m"
}

## get os type & release info
function get_os_type() {
    local os=$(uname)
    local os_wsl=$(uname -r)
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
	local architecture=$(uname -m)
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

function get_sysArch(){
    ARCH=$(uname -m)
    if [[ "$ARCH" == "amd64" ]] || [[ "$ARCH" == "x86_64" ]]; then
        VDIS="64"
    elif [[ "$ARCH" == "i686" ]] || [[ "$ARCH" == "i386" ]]; then
        VDIS="32"
    elif [[ "$ARCH" == *"armv7"* ]] || [[ "$ARCH" == "armv6l" ]]; then
        VDIS="arm"
    elif [[ "$ARCH" == *"armv8"* ]] || [[ "$ARCH" == "aarch64" ]]; then
        VDIS="arm64"
    elif [[ "$ARCH" == *"mips64le"* ]]; then
        VDIS="mips64le"
    elif [[ "$ARCH" == *"mips64"* ]]; then
        VDIS="mips64"
    elif [[ "$ARCH" == *"mipsle"* ]]; then
        VDIS="mipsle"
    elif [[ "$ARCH" == *"mips"* ]]; then
        VDIS="mips"
    elif [[ "$ARCH" == *"s390x"* ]]; then
        VDIS="s390x"
    elif [[ "$ARCH" == "ppc64le" ]]; then
        VDIS="ppc64le"
    elif [[ "$ARCH" == "ppc64" ]]; then
        VDIS="ppc64"
    fi
    return 0
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

# version compare functions
function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; } # >
function version_ge() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"; } # >=
function version_lt() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" != "$1"; } # <
function version_le() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" == "$1"; } # <=

function version_compare() {
    VERSION1=$1
    VERSION2=$2
    if version_gt $VERSION1 $VERSION2; then
        echo "$VERSION1 is greater than $VERSION2"
    fi

    if version_le $VERSION1 $VERSION2; then
        echo "$VERSION1 is less than or equal to $VERSION2"
    fi

    if version_lt $VERSION1 $VERSION2; then
        echo "$VERSION1 is less than $VERSION2"
    fi

    if version_ge $VERSION1 $VERSION2; then
        echo "$VERSION1 is greater than or equal to $VERSION2"
    fi
}


## Proxy functions
function set_proxy() {
    local proxy_url=$1
    local proxy_port=$2

    [[ -z "$proxy_url" ]] && proxy_url="127.0.0.1"
    [[ -z "$proxy_port" ]] && proxy_url="8080"

    export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"

    export http_proxy=http://${proxy_url}:${proxy_port}
    export https_proxy=http://${proxy_url}:${proxy_port}
}

function clear_proxy() {
    export http_proxy=
    export https_proxy=
}

function proxy_cmd() {
    if [[ -n $* ]]; then
        local COLOR='\033[0;35m'
        local NOCOLOR='\033[0m'
        set_proxy && echo -e "${COLOR}[proxy] set${NOCOLOR}"
        $*
        clear_proxy && echo -e "${COLOR}[proxy] clear${NOCOLOR}"
    else
        echo "Set proxy for specific command."
    fi
}

# SET_PROXY_FOR=('brew' 'git' 'apm')
# for cmd in $SET_PROXY_FOR; do
#     hash ${cmd} > /dev/null 2>&1 && alias ${cmd}="proxy ${cmd}"
# done

## Query IP address
function myip() {
    # https://stackoverflow.com/questions/13322485/how-to-get-the-primary-ip-address-of-the-local-machine-on-linux-and-os-x
    # LOCAL_NET_IP=$(hostname -I | cut -d' ' -f1)
    LOCAL_NET_IF=`netstat -rn | awk '/^0.0.0.0/ {thif=substr($0,74,10); print thif;} /^default.*UG/ {thif=substr($0,65,10); print thif;}'`
    LOCAL_NET_IP=`ifconfig ${LOCAL_NET_IF} | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`

    WAN_NET_IP=`dig +short myip.opendns.com @resolver1.opendns.com`

    echo -e "Local IP: ${LOCAL_NET_IP}\nPublic IP: ${WAN_NET_IP}"
}

function myip_local() {
    LOCAL_NET_IF=`netstat -rn | awk '/^0.0.0.0/ {thif=substr($0,74,10); print thif;} /^default.*UG/ {thif=substr($0,65,10); print thif;}'`
    LOCAL_NET_IP=`ifconfig ${LOCAL_NET_IF} | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`

    echo -e "Local IP: ${LOCAL_NET_IP}"
}

function myip_wan() {
    WAN_NET_IP=`dig +short myip.opendns.com @resolver1.opendns.com`

    echo -e "Public IP: ${WAN_NET_IP}"
}

function myip_wan_geo() {
    if [[ -x "$(command -v geoiplookup)" ]]; then
        WAN_NET_IP=`dig +short myip.opendns.com @resolver1.opendns.com`
        WAN_NET_IP_GEO=`geoiplookup ${WAN_NET_IP}`
        echo -e "Public IP: ${WAN_NET_IP}\n${WAN_NET_IP_GEO}"
    else
        echo "Can't get GEO by WAN IP!"
    fi
}


## Set proxy or mirrors env in china
function set_proxy_mirrors_env() {
    if [[ -z "$WAN_NET_IP_GEO" ]]; then
        myip_wan_geo >/dev/null 2>&1
    fi

    if [[ ${WAN_NET_IP_GEO:-null} =~ 'CN, China' ]]; then
        unset APT_NOT_USE_MIRRORS
        unset DOCKER_INSTALLER_NOT_USE_MIRROR
        unset GVM_INSTALLER_NOT_USE_PROXY
        unset NVM_INSTALLER_NOT_USE_MIRROR
        unset NPM_INSTALLER_NOT_USE_MIRROR
    else
        APT_NOT_USE_MIRRORS=true
        DOCKER_INSTALLER_NOT_USE_MIRROR=true
        GVM_INSTALLER_NOT_USE_PROXY=true
        NVM_INSTALLER_NOT_USE_MIRROR=true
        NPM_INSTALLER_NOT_USE_MIRROR=true
    fi
}


## Dateutils
# http://www.fresse.org/dateutils/
# apt install -y dateutils
# dateutils.dadd 2018-05-22 +120d
function date_diff() {
    # date_diff 20180522 20180918
    if [[ $# -eq 2 ]]; then
        echo $(( ($(date -d "$1" +%s) - $(date -d "$2" +%s) )/(60*60*24) ))
    fi
}
