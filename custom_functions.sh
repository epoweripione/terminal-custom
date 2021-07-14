# Colors
NOCOLOR='\033[0m'
RED='\033[0;31m'        # Error message
LIGHTRED='\033[1;31m'
GREEN='\033[0;32m'      # Success message
LIGHTGREEN='\033[1;32m'
ORANGE='\033[0;33m'
YELLOW='\033[1;33m'     # Warning message
BLUE='\033[0;34m'       # Info message
LIGHTBLUE='\033[1;34m'
PURPLE='\033[0;35m'
FUCHSIA='\033[0;35m'
LIGHTPURPLE='\033[1;35m'
CYAN='\033[0;36m'
LIGHTCYAN='\033[1;36m'
DARKGRAY='\033[1;30m'
LIGHTGRAY='\033[0;37m'
WHITE='\033[1;37m'

function colorEcho() {
    if [[ $# > 1 ]]; then
        local COLOR=$1
        echo -e "${COLOR}${@:2}${NOCOLOR}"
    else
        echo -e "${@:1}${NOCOLOR}"
    fi
}

function colorEchoN() {
    if [[ $# > 1 ]]; then
        local COLOR=$1
        echo -e -n "${COLOR}${@:2}${NOCOLOR}"
    else
        echo -e -n "${@:1}${NOCOLOR}"
    fi
}

function colorEchoAllColor() {
    colorEchoN "${RED}red ${GREEN}green ${YELLOW}yellow ${BLUE}blue ${ORANGE}orange ${PURPLE}purple ${FUCHSIA}fuchsia ${CYAN}cyan "
    colorEchoN "${LIGHTRED}lightred ${LIGHTGREEN}lightgreen ${LIGHTBLUE}lightblue ${LIGHTPURPLE}lightpurple ${LIGHTCYAN}lightcyan "
    colorEcho "${LIGHTGRAY}lightgray ${DARKGRAY}darkgray ${WHITE}white"
}

# no proxy lists
NO_PROXY_LISTS="localhost,127.0.0.1,.local"
NO_PROXY_LISTS="${NO_PROXY_LISTS},fastgit.org,gitclone.com,cnpmjs.org"
NO_PROXY_LISTS="${NO_PROXY_LISTS},ip.sb,ip-api.com,ident.me,ifconfig.co,icanhazip.com,ipinfo.io"


## Get OS type, architecture etc.
# get os type: darwin, windows, linux, bsd, solaris
function get_os_type() {
    local osname=$(uname)
    local ostype

    case "$osname" in
        Darwin)
            ostype="darwin"
            ;;
        MSYS_NT-* | MINGW* | CYGWIN_NT-*)
            ostype="windows"
            ;;
        FreeBSD | OpenBSD | DragonFly)
            ostype="bsd"
            ;;
        SunOS)
            ostype='solaris'
            ;;
        *)
            ostype=$(echo "$osname" | sed 's/.*/\L&/')
            ;;
    esac

    OS_INFO_TYPE=$ostype
}

# Determine which desktop environment is installed from the shell
# OSDesktopENV=$(ps -e | grep -E -i "gnome|kde|mate|cinnamon|lxde|xfce|jwm")
function get_os_desktop() {
    local osdesktop

    if [[ -n "$XDG_CURRENT_DESKTOP" ]]; then
        osdesktop=$(echo "$XDG_DATA_DIRS" | sed 's/.*\(gnome\|kde\|mate\|cinnamon\|lxde\|xfce\|jwm\).*/\1/')
    else
        osdesktop=$XDG_CURRENT_DESKTOP
    fi

    OS_INFO_DESKTOP=$osdesktop
}

function get_arch() {
	local architecture=$(uname -m)
    local spruce_type

	case "$architecture" in
		amd64 | x86_64)
			spruce_type='amd64'
			;;
		i686 | i586 | i486 | i386 | x86)
			spruce_type='386'
			;;
		*armv7* | armv6l)
            spruce_type="arm"
            ;;
		*armv8* | aarch64)
            spruce_type="arm64"
            ;;
		*mips64le*)
            spruce_type="mips64le"
            ;;
		*mips64*)
            spruce_type="mips64"
            ;;
		*mipsle*)
            spruce_type="mipsle"
            ;;
		*mips*)
            spruce_type="mips"
            ;;
		*s390x*)
            spruce_type="s390x"
            ;;
		*ppc64le*)
            spruce_type="ppc64le"
            ;;
		*ppc64*)
            spruce_type="ppc64"
            ;;
        riscv64)
            spruce_type="riscv64"
            ;;
		*)
            spruce_type=""
			# cat 1>&2 <<-EOF
			# This script only support 32bit and 64bit architecture!
			# Your OS is: $architecture.
			# EOF
			# exit 1
            ;;
	esac

    OS_INFO_ARCH=$spruce_type
}

function get_sysArch() {
	local architecture=$(uname -m)
    local VDIS

    case "$architecture" in
        amd64 | x86_64)
            VDIS="64"
            ;;
		i686 | i586 | i486 | i386 | x86)
            VDIS="32"
            ;;
		*armv7* | armv6l)
            VDIS="arm"
            ;;
		*armv8* | aarch64)
            VDIS="arm64"
            ;;
		*mips64le*)
            VDIS="mips64le"
            ;;
		*mips64*)
            VDIS="mips64"
            ;;
		*mipsle*)
            VDIS="mipsle"
            ;;
		*mips*)
            VDIS="mips"
            ;;
		*s390x*)
            VDIS="s390x"
            ;;
		*ppc64le*)
            VDIS="ppc64le"
            ;;
		*ppc64*)
            VDIS="ppc64"
            ;;
        riscv64)
            VDIS="riscv64"
            ;;
		*)
            VDIS=""
            ;;
    esac

    OS_INFO_VDIS=$VDIS
}

function get_os() {
    local OS

    case $(uname) in
        Darwin)
            OS='macOS'
            ;;
        MSYS_NT-* | MINGW* | CYGWIN_NT-*)
            OS='Windows'
            ;;
        FreeBSD | OpenBSD | DragonFly)
            OS='BSD'
            ;;
        Linux)
            OS='Linux'
            # Check if we're running on Android
            case $(uname -o 2>/dev/null) in
                Android)
                    OS='Android'
                    ;;
            esac
            ;;
        SunOS)
            OS='Solaris'
            ;;
        *)
            OS=''
            ;;
    esac

    local os_wsl=$(uname -r)
    if [[ "$os_wsl" =~ "Microsoft" ]]; then
        OS='Windows'
    fi

    OS_INFO_RELEASE_TYPE=$OS
}

function get_arch_float() {
    # https://raspberrypi.stackexchange.com/questions/4677/how-can-i-tell-if-i-am-using-the-hard-float-or-the-soft-float-version-of-debian
    [[ -z "$OS_INFO_ARCH" ]] && get_arch

    unset OS_INFO_FLOAT
    case "$OS_INFO_ARCH" in
        mips | mipsle)
            if [[ -x "$(command -v dpkg)" ]]; then
                local dpkg_arch=$(dpkg --print-architecture 2>/dev/null)
                [[ "${dpkg_arch}" == "armhf" ]] && OS_INFO_FLOAT="hardfloat" || OS_INFO_FLOAT="softfloat"
            else
                [[ -d "/lib/arm-linux-gnueabihf" ]] && OS_INFO_FLOAT="hardfloat" || OS_INFO_FLOAT="softfloat"
            fi
            ;;
    esac
}

function get_os_release() {
    local OS_RELEASE

    case $(uname) in
        Darwin)
            OS_RELEASE='macos'
            ;;
        MSYS_NT-* | MINGW* | CYGWIN_NT-*)
            OS_RELEASE='windows'
            ;;
        FreeBSD)
            OS_RELEASE='freebsd'
            ;;
        OpenBSD)
            OS_RELEASE='openbsd'
            ;;
        DragonFly)
            OS_RELEASE='dragonfly'
            ;;
        Linux)
            if [[ -r "/etc/os-release" ]]; then
                OS_RELEASE="$(. /etc/os-release && echo "$ID")"
                [[ -z "$OS_RELEASE" ]] && \
                    OS_RELEASE="$(grep -E '^ID=([a-zA-Z]*)' /etc/os-release \
                                | cut -d'=' -f2 | sed 's/\"//g')"
            fi

            # Check if we're running on Android
            case $(uname -o 2>/dev/null) in
                Android)
                    OS_RELEASE='android'
                    ;;
            esac
            ;;
        SunOS)
            OS_RELEASE='solaris'
            ;;
        *)
            OS_RELEASE=''
            ;;
    esac

    local os_wsl=$(uname -r)
    if [[ "$os_wsl" =~ "Microsoft" ]]; then
        OS_RELEASE='windows'
    fi

    OS_INFO_RELEASE=$OS_RELEASE
}

function get_os_icon() {
    local OS_ICON

    case $(uname) in
        Darwin)
            OS_ICON=$'\uF179'
            ;;
        MSYS_NT-* | MINGW* | CYGWIN_NT-*)
            OS_ICON=$'\uF17A'
            ;;
        FreeBSD | OpenBSD | DragonFly)
            OS_ICON=$'\uF30C'
            ;;
        Linux)
            local os_release_id="$(grep -E '^ID=([a-zA-Z]*)' /etc/os-release 2>/dev/null | cut -d '=' -f2)"
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
                *opensuse* | *tumbleweed*)
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
                    OS_ICON=$'\uF17C'
                    ;;
            esac

            # Check if we're running on Android
            case $(uname -o 2>/dev/null) in
                Android)
                    OS_ICON=$'\uF17B'
                    ;;
            esac
            ;;
        SunOS)
            OS_ICON=$'\uF185'
            ;;
        *)
            OS_ICON=''
            ;;
    esac

    local os_wsl=$(uname -r)
    if [[ "$os_wsl" =~ "Microsoft" ]]; then
        OS_ICON=$'\uF17A'
    fi

    OS_INFO_ICON=$OS_ICON
}


## Get OS package manager
function check_os_package_manager() {
    # ref to: https://github.com/icy/pacapt/blob/ng/pacapt
    local _pacman

    _pacman="$1"; shift

    [[ "$(uname)" == "SunOS" ]] && OS_PACKAGE_MANAGER="$_pacman" && return
    grep -qis "$@" /etc/issue && OS_PACKAGE_MANAGER="$_pacman" && return
    grep -qis "$@" /etc/os-release && OS_PACKAGE_MANAGER="$_pacman" && return
}

function get_os_package_manager() {
    unset OS_PACKAGE_MANAGER

    # ref to: https://github.com/icy/pacapt/blob/ng/pacapt
    check_os_package_manager sun_tools "SunOS" && return
    check_os_package_manager pacman "Arch Linux" && return
    check_os_package_manager dpkg "Debian GNU/Linux" && return
    check_os_package_manager dpkg "Ubuntu" && return
    check_os_package_manager cave "Exherbo Linux" && return
    # check_os_package_manager dnf "CentOS Linux 8" && return
    # check_os_package_manager dnf "CentOS-8" && return
    # check_os_package_manager yum "CentOS" && return
    # check_os_package_manager yum "Red Hat" && return
    check_os_package_manager zypper "SUSE" && return
    check_os_package_manager pkg_tools "OpenBSD" && return
    check_os_package_manager pkg_tools "Bitrig" && return
    check_os_package_manager apk "Alpine Linux" && return
    check_os_package_manager opkg "OpenWrt" && return

    [[ -z "$OS_PACKAGE_MANAGER" ]] || return

    # Prevent a loop when this script is installed on non-standard system
    if [[ -x "/usr/bin/pacman" ]]; then
        grep -q "pacapt" '/usr/bin/pacman' >/dev/null 2>&1
        [[ $? -ge 1 ]] && OS_PACKAGE_MANAGER="pacman" && return
    fi

    [[ -x "/usr/bin/apt-get" ]] && OS_PACKAGE_MANAGER="dpkg" && return
    [[ -x "/data/data/com.termux/files/usr/bin/apt-get" ]] && OS_PACKAGE_MANAGER="dpkg" && return
    [[ -x "/usr/bin/cave" ]] && OS_PACKAGE_MANAGER="cave" && return
    [[ -x "/usr/bin/dnf" ]] && OS_PACKAGE_MANAGER="dnf" && return
    [[ -x "/usr/bin/yum" ]] && OS_PACKAGE_MANAGER="yum" && return
    [[ -x "/opt/local/bin/port" ]] && OS_PACKAGE_MANAGER="macports" && return
    [[ -x "/usr/bin/emerge" ]] && OS_PACKAGE_MANAGER="portage" && return
    [[ -x "/usr/bin/zypper" ]] && OS_PACKAGE_MANAGER="zypper" && return
    [[ -x "/usr/sbin/pkg" ]] && OS_PACKAGE_MANAGER="pkgng" && return
    # make sure pkg_add is after pkgng, FreeBSD base comes with it until converted
    [[ -x "/usr/sbin/pkg_add" ]] && OS_PACKAGE_MANAGER="pkg_tools" && return
    [[ -x "/usr/sbin/pkgadd" ]] && OS_PACKAGE_MANAGER="sun_tools" && return
    [[ -x "/sbin/apk" ]] && OS_PACKAGE_MANAGER="apk" && return
    [[ -x "/bin/opkg" ]] && OS_PACKAGE_MANAGER="opkg" && return
    [[ -x "/usr/bin/tazpkg" ]] && OS_PACKAGE_MANAGER="tazpkg" && return
    [[ -x "/usr/bin/swupd" ]] && OS_PACKAGE_MANAGER="swupd" && return

    command -v brew >/dev/null && OS_PACKAGE_MANAGER="homebrew" && return

    return 1
}

function check_release_package_manager() {
    local checkType=$1
    local value=$2

    local release=''
    local systemPackage=''

    local osname=$(uname)
    if [[ -f /etc/redhat-release ]]; then
        if [[ $(cat /etc/redhat-release | grep Fedora) ]]; then
            release="fedora"
            systemPackage="dnf"
        # elif [[ $(cat /etc/redhat-release |grep "CentOS Linux release 8") ]]; then
        #     release="centos8"
        #     systemPackage="dnf"
        else
            release="centos"
            systemPackage="yum"
        fi
    elif [[ -f /etc/alpine-release ]]; then
        release="alpine"
        systemPackage="apk"
    elif [[ -f /etc/arch-release ]]; then
        release="arch"
        systemPackage="pacman"
    elif [[ $osname =~ "MSYS_NT" || $osname =~ "MINGW" ]]; then
        release="MSYS"
        systemPackage="pacman"
    elif [[ $osname =~ "CYGWIN_NT" ]]; then
        release="CYGWIN"
        systemPackage="apt-cyg"
    elif cat /etc/issue | grep -Eqi "debian"; then
        release="debian"
        systemPackage="apt"
    elif cat /etc/issue | grep -Eqi "ubuntu"; then
        release="ubuntu"
        systemPackage="apt"
    elif cat /etc/issue | grep -Eqi "raspbian"; then
        release="raspbian"
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


## version compare functions
function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; } # >
function version_ge() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" = "$1"; } # >=
function version_lt() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" != "$1"; } # <
function version_le() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" = "$1"; } # <=

function version_compare() {
    local VERSION1=$1
    local VERSION2=$2
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

# https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash/49351294#49351294
function ver_compare() {
    # Compare two version strings [$1: version string 1 (v1), $2: version string 2 (v2), $3: version regular expressions (regex)]
    # Return values:
    #   0: v1 == v2
    #   1: v1 > v2
    #   2: v1 < v2
    # Based on: https://stackoverflow.com/a/4025065 by Dennis Williamson

    # Trivial v1 == v2 test based on string comparison
    [[ "$1" == "$2" ]] && return 0

    # Local variables
    local regex=${3:-"^(.*)-r([0-9]*)$"} va1=() vr1=0 va2=() vr2=0 len i IFS="."

    # Split version strings into arrays, extract trailing revisions
    if [[ "$1" =~ ${regex} ]]; then
        va1=(${BASH_REMATCH[1]})
        [[ -n "${BASH_REMATCH[2]}" ]] && vr1=${BASH_REMATCH[2]}
    else
        va1=($1)
    fi

    if [[ "$2" =~ ${regex} ]]; then
        va2=(${BASH_REMATCH[1]})
        [[ -n "${BASH_REMATCH[2]}" ]] && vr2=${BASH_REMATCH[2]}
    else
        va2=($2)
    fi

    # Bring va1 and va2 to same length by filling empty fields with zeros
    (( ${#va1[@]} > ${#va2[@]} )) && len=${#va1[@]} || len=${#va2[@]}
    for ((i=0; i < len; ++i)); do
        [[ -z "${va1[i]}" ]] && va1[i]="0"
        [[ -z "${va2[i]}" ]] && va2[i]="0"
    done

    # Append revisions, increment length
    va1+=($vr1)
    va2+=($vr2)
    len=$((len+1))

    # *** DEBUG ***
    #echo "TEST: '${va1[@]} (?) ${va2[@]}'"

    # Compare version elements, check if v1 > v2 or v1 < v2
    for ((i=0; i < len; ++i)); do
        if (( 10#${va1[i]} > 10#${va2[i]} )); then
            return 1
        elif (( 10#${va1[i]} < 10#${va2[i]} )); then
            return 2
        fi
    done

    # All elements are equal, thus v1 == v2
    return 0
}

function ver_compare_eq() {
    ver_compare $@
    [[ $? -eq 0 ]] && return 0 || return 1
}

function ver_compare_gt() {
    ver_compare $@
    [[ $? -eq 1 ]] && return 0 || return 1
}

function ver_compare_ge() {
    ver_compare $@
    [[ $? -eq 0 || $? -eq 1 ]] && return 0 || return 1
}

function ver_compare_lt() {
    ver_compare $@
    [[ $? -eq 2 ]] && return 0 || return 1
}

function ver_compare_le() {
    ver_compare $@
    [[ $? -eq 0 || $? -eq 2 ]] && return 0 || return 1
}


## Get network interface, ipv4/ipv6 address
# Get local machine network interfaces
function get_network_interface_list() {
    unset NETWORK_INTERFACE_LIST
    if [[ -x "$(command -v ip)" ]]; then
        NETWORK_INTERFACE_LIST=$(ip link | awk -F: '$0 !~ "lo|vir|^[^0-9]" {print $2;getline}')
        # Without wireless
        # NETWORK_INTERFACE_LIST=$(ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]" {print $2;getline}')
    else
        NETWORK_INTERFACE_LIST=$(ls /sys/class/net | tr "\t" "\n" | grep -Ev "lo|vir|^[0-9]")
    fi
}

function get_network_interface_default() {
    unset NETWORK_INTERFACE_DEFAULT
    if [[ -x "$(command -v ip)" ]]; then
        NETWORK_INTERFACE_DEFAULT=$(ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//" -e "s/[ \t]//g" | head -n1)
        if [[ -z "${NETWORK_INTERFACE_DEFAULT}" ]]; then
            NETWORK_INTERFACE_DEFAULT=$(ip route | grep -Ev "^0\.|^127\.|^172\." | sed -e "s/^.*dev.//" -e "s/.proto.*//" -e "s/[ \t]//g" | head -n1)
        fi
    elif [[ -x "$(command -v netstat)" ]]; then
        NETWORK_INTERFACE_DEFAULT=$(netstat -rn | awk '/^0.0.0.0/ {thif=substr($0,74,10); print thif;} /^default.*UG/ {thif=substr($0,65,10); print thif;}')
    fi
}

# get local machine ip list
function get_network_local_ip_list() {
    unset NETWORK_LOCAL_IP_LIST

    get_network_interface_list
    [[ -z "$NETWORK_INTERFACE_LIST" ]] && return 0

    local net_interface_list
    local net_interface
    local net_ip

    net_interface_list=(`echo $NETWORK_INTERFACE_LIST | tr '\n' ' '`)
    for net_interface in ${net_interface_list[@]}; do
        if [[ -z "$NETWORK_LOCAL_IP_LIST" ]]; then
            NETWORK_LOCAL_IP_LIST="${net_interface}:"
        else
            NETWORK_LOCAL_IP_LIST="${NETWORK_LOCAL_IP_LIST}\n\n${net_interface}:"
        fi

        if [[ -x "$(command -v ip)" ]]; then
            net_ip=$(ip addr show ${net_interface} | grep "inet\|inet6" | awk '{print $2}' | cut -d'/' -f1)
        elif [[ -x "$(command -v ifconfig)" ]]; then
            net_ip=$(ifconfig ${net_interface} | grep "inet\|inet6" |awk -F' ' '{print $2}' | awk '{print $1}')
        fi

        net_ip=$(echo ${net_ip} | grep -v "127.0.0.1" | grep -v "^::1" | grep -v "^fe80")

        NETWORK_LOCAL_IP_LIST="${NETWORK_LOCAL_IP_LIST}\n${net_ip}"
    done
}

function get_network_local_ipv4_list() {
    unset NETWORK_LOCAL_IPV4_LIST

    get_network_local_ip_list
    [[ -z "$NETWORK_LOCAL_IP_LIST" ]] && return 0

    NETWORK_LOCAL_IPV4_LIST=$(echo $NETWORK_LOCAL_IP_LIST | grep -B1 "\.")

    NETWORK_LOCAL_IPV4_LIST=${NETWORK_LOCAL_IPV4_LIST//-/}
}

function get_network_local_ipv6_list() {
    unset NETWORK_LOCAL_IPV6_LIST

    get_network_local_ip_list
    [[ -z "$NETWORK_LOCAL_IP_LIST" ]] && return 0

    NETWORK_LOCAL_IPV6_LIST=$(echo $NETWORK_LOCAL_IP_LIST | grep -v "\.")
}


# get local machine default interface ip
function get_network_local_ip_default() {
    unset NETWORK_LOCAL_IP_DEFAULT

    get_network_interface_default
    [[ -z "$NETWORK_INTERFACE_DEFAULT" ]] && return 0

    local net_ip

    if [[ -x "$(command -v ip)" ]]; then
        net_ip=$(ip addr show ${NETWORK_INTERFACE_DEFAULT} | grep "inet\|inet6" | awk '{print $2}' | cut -d'/' -f1)
    elif [[ -x "$(command -v ifconfig)" ]]; then
        net_ip=$(ifconfig ${NETWORK_INTERFACE_DEFAULT} | grep "inet\|inet6" |awk -F' ' '{print $2}' | awk '{print $1}')
    fi

    NETWORK_LOCAL_IP_DEFAULT="${NETWORK_INTERFACE_DEFAULT}:\n${net_ip}"
}

function get_network_local_ipv4_default() {
    # https://stackoverflow.com/questions/13322485/how-to-get-the-primary-ip-address-of-the-local-machine-on-linux-and-os-x
    # LOCAL_NET_IF=`netstat -rn | awk '/^0.0.0.0/ {thif=substr($0,74,10); print thif;} /^default.*UG/ {thif=substr($0,65,10); print thif;}'`
    # LOCAL_NET_IP=`ifconfig ${LOCAL_NET_IF} | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`

    unset NETWORK_LOCAL_IPV4_DEFAULT

    get_network_local_ip_default
    [[ -z "$NETWORK_LOCAL_IP_DEFAULT" ]] && return 0

    NETWORK_LOCAL_IPV4_DEFAULT=$(echo $NETWORK_LOCAL_IP_DEFAULT | grep "\." | head -n1)
}

function get_network_local_ipv6_default() {
    unset NETWORK_LOCAL_IPV6_DEFAULT

    get_network_local_ip_default
    [[ -z "$NETWORK_LOCAL_IP_DEFAULT" ]] && return 0

    NETWORK_LOCAL_IPV6_DEFAULT=$(echo $NETWORK_LOCAL_IP_DEFAULT | grep ":" | sed '1d' | head -n1)
}

# get wan ip
function get_network_wan_ipv4() {
    # https://guoyu841020.oschina.io/2017/02/23/linux%E8%8E%B7%E5%8F%96%E5%85%AC%E7%BD%91IP%E7%9A%84%E6%96%B9%E6%B3%95/
    # nginx:
    # https://www.jianshu.com/p/14320f300223
    # location /ip {
    #         default_type text/plain;
    #         return 200 "$remote_addr";
    # }

    # location /ipinfo {
    #         default_type application/json;
    #         return 200  '{"IP":"$remote_addr","PORT":"$remote_port","X-Forwarded-For":"$proxy_add_x_forwarded_for"}';
    # }
    # php:
    # <?php echo $_SERVER["REMOTE_ADDR"]; ?>
    # pacman -S --noconfirm html2text
    # curl -fsSL http://yourdomainname/getip.php | html2text
    # nodejs:
    # https://github.com/alsotang/externalip
    # https://github.com/sindresorhus/public-ip
    unset NETWORK_WAN_NET_IP

    local remote_host_list
    local target_host

    remote_host_list=(
        "https://api-ipv4.ip.sb/ip"
        "http://ip-api.com/line/?fields=query"
        "https://v4.ident.me/"
        "http://icanhazip.com/"
        "http://ipinfo.io/ip"
        "https://ifconfig.co/"
    )

    for target_host in ${remote_host_list[@]}; do
        NETWORK_WAN_NET_IP=$(curl -fsL -4 --connect-timeout 5 --max-time 10 "${target_host}" \
                        | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' \
                        | head -n1)
        [[ -n "$NETWORK_WAN_NET_IP" ]] && break
    done
    # NETWORK_WAN_NET_IP=`dig +short myip.opendns.com @resolver1.opendns.com`
}

function get_network_wan_ipv6() {
    unset NETWORK_WAN_NET_IPV6

    local remote_host_list
    local target_host

    remote_host_list=(
        "https://api-ipv6.ip.sb/ip"
        "https://v6.ident.me/"
        "http://icanhazip.com/"
        "https://ifconfig.co/"
    )

    for target_host in ${remote_host_list[@]}; do
        NETWORK_WAN_NET_IPV6=$(curl -fsL -6 --connect-timeout 5 --max-time 10 "${target_host}" \
                        | grep -Eo '^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$' \
                        | head -n1)
        [[ -n "$NETWORK_WAN_NET_IPV6" ]] && break
    done
}

function get_network_wan_geo() {
    unset NETWORK_WAN_NET_IP_GEO

    if [[ -x "$(command -v geoiplookup)" ]]; then
        get_network_wan_ipv4
        if [[ -n "$NETWORK_WAN_NET_IP" ]]; then
            NETWORK_WAN_NET_IP_GEO=`geoiplookup ${NETWORK_WAN_NET_IP} | head -n1 | cut -d':' -f2-`
        fi
    fi

    if [[ -z "$NETWORK_WAN_NET_IP_GEO" ]]; then
        NETWORK_WAN_NET_IP_GEO=`curl -fsL -4 --connect-timeout 5 --max-time 10 \
            "https://api.ip.sb/geoip" | jq -r '.country//empty'`
    fi

    if [[ -z "$NETWORK_WAN_NET_IP_GEO" ]]; then
        # Country lookup: China
        NETWORK_WAN_NET_IP_GEO=`curl -fsL -4 --connect-timeout 5 --max-time 10 \
            "http://ip-api.com/line/?fields=country"`
        if [[ -z "$NETWORK_WAN_NET_IP_GEO" ]]; then
            # Country lookup: CN
            NETWORK_WAN_NET_IP_GEO=`curl -fsL -4 --connect-timeout 5 --max-time 10 \
                "http://ip-api.com/line/?fields=countryCode"`
        fi
    fi
}

# display local machine ip info
function myip_lan_wan() {
    get_network_local_ipv4_default
    get_network_local_ipv6_default
    get_network_wan_ipv4
    get_network_wan_ipv6

    [[ -n "$NETWORK_LOCAL_IPV4_DEFAULT" ]] && echo -e "Local IP: ${NETWORK_LOCAL_IPV4_DEFAULT}"
    [[ -n "$NETWORK_LOCAL_IPV6_DEFAULT" ]] && echo -e "Local IPV6: ${NETWORK_LOCAL_IPV6_DEFAULT}"
    [[ -n "$NETWORK_WAN_NET_IP" ]] && echo -e "Public IP: ${NETWORK_WAN_NET_IP}"
    [[ -n "$NETWORK_WAN_NET_IPV6" ]] && echo -e "Public IPV6: ${NETWORK_WAN_NET_IPV6}"
}

function myip_lan() {
    get_network_local_ipv4_default
    get_network_local_ipv6_default

    [[ -n "$NETWORK_LOCAL_IPV4_DEFAULT" ]] && echo -e "Local IP: ${NETWORK_LOCAL_IPV4_DEFAULT}"
    [[ -n "$NETWORK_LOCAL_IPV6_DEFAULT" ]] && echo -e "Local IPV6: ${NETWORK_LOCAL_IPV6_DEFAULT}"
}

function myip_wan() {
    get_network_wan_ipv4
    get_network_wan_ipv6

    [[ -n "$NETWORK_WAN_NET_IP" ]] && echo -e "Public IP: ${NETWORK_WAN_NET_IP}"
    [[ -n "$NETWORK_WAN_NET_IPV6" ]] && echo -e "Public IPV6: ${NETWORK_WAN_NET_IPV6}"
}

function myip_wan_geo() {
    get_network_wan_ipv4
    get_network_wan_geo

    if [[ -n "$NETWORK_WAN_NET_IP_GEO" ]]; then
        echo -e "Public IP: ${NETWORK_WAN_NET_IP}\n${NETWORK_WAN_NET_IP_GEO}"
    else
        echo "Can't get GEO by WAN IP!"
    fi
}

# Get Opened Port on Android Device(No Root)
# https://null-byte.wonderhowto.com/forum/see-your-opened-port-your-android-device-no-root-0200475/
function nmap_scan_opened_port() {
    local ip_address=${1:-""}

    [[ -z "${ip_address}" ]] && get_network_local_ipv4_default && ip_address=${NETWORK_LOCAL_IPV4_DEFAULT}
    [[ -n "${ip_address}" ]] && nmap -Pn ${ip_address}
}


## Proxy functions
function set_proxy() {
    # PROTOCOL://USERNAME:PASSWORD@HOST:PORT
    # http://127.0.0.1:8080
    # socks5h://127.0.0.1:8080
    # PASSWORD has special characters:
    # [@ %40] [: %3A] [! %21] [# %23] [$ %24]
    # F@o:o!B#ar$ -> F%40o%3Ao%21B%23ar%24
    local PROXY_ADDRESS=${1:-""}

    if [[ -z "${PROXY_ADDRESS}" && -n "${GLOBAL_PROXY_IP}" ]]; then
        if [[ -n "${GLOBAL_PROXY_SOCKS_PORT}" ]]; then
            PROXY_ADDRESS="${GLOBAL_PROXY_SOCKS_PROTOCOL}://${GLOBAL_PROXY_IP}:${GLOBAL_PROXY_SOCKS_PORT}"
        elif [[ -n "${GLOBAL_PROXY_HTTP_PORT}" ]]; then
            PROXY_ADDRESS="http://${GLOBAL_PROXY_IP}:${GLOBAL_PROXY_HTTP_PORT}"
        fi
    fi

    [[ -z "${PROXY_ADDRESS}" ]] && PROXY_ADDRESS="http://127.0.0.1:8080"

    export {http,https,ftp,all}_proxy=${PROXY_ADDRESS}
    export no_proxy="${NO_PROXY_LISTS}"
    # export no_proxy="localhost,127.0.0.0/8,*.local"

    # for curl
    export {HTTP,HTTPS,FTP,ALL}_PROXY=${PROXY_ADDRESS}
    export NO_PROXY="${NO_PROXY_LISTS}"
}

function get_proxy() {
    local proxy_output1 proxy_output2

    [[ -n "${http_proxy}" ]] && colorEcho "${BLUE}http_proxy=${FUCHSIA}${http_proxy}"
    [[ -n "${https_proxy}" ]] && colorEcho "${BLUE}https_proxy=${FUCHSIA}${https_proxy}"
    [[ -n "${ftp_proxy}" ]] && colorEcho "${BLUE}ftp_proxy=${FUCHSIA}${ftp_proxy}"
    [[ -n "${all_proxy}" ]] && colorEcho "${BLUE}all_proxy=${FUCHSIA}${all_proxy}"
    [[ -n "${no_proxy}" ]] && colorEcho "${BLUE}no_proxy=${FUCHSIA}${no_proxy}"

    [[ -n "${HTTP_PROXY}" ]] && colorEcho "${BLUE}HTTP_PROXY=${FUCHSIA}${HTTP_PROXY}"
    [[ -n "${HTTPS_PROXY}" ]] && colorEcho "${BLUE}HTTPS_PROXY=${FUCHSIA}${HTTPS_PROXY}"
    [[ -n "${FTP_PROXY}" ]] && colorEcho "${BLUE}FTP_PROXY=${FUCHSIA}${FTP_PROXY}"
    [[ -n "${ALL_PROXY}" ]] && colorEcho "${BLUE}ALL_PROXY=${FUCHSIA}${ALL_PROXY}"
    [[ -n "${NO_PROXY}" ]] && colorEcho "${BLUE}NO_PROXY=${FUCHSIA}${NO_PROXY}"

    if [[ -x "$(command -v git)" ]]; then
        proxy_output1=$(git config --global --list 2>/dev/null | grep -E "http\.|https\.")
        [[ -n "${proxy_output1}" ]] && colorEcho "\n${BLUE}git proxies:\n${FUCHSIA}${proxy_output1}"
    fi

    if [[ -x "$(command -v node)" && -x "$(command -v npm)" ]]; then
        proxy_output1=$(npm config get proxy | grep -v "null")
        proxy_output2=$(npm config get https-proxy | grep -v "null")
        [[ -n "${proxy_output1}" ]] && colorEcho "\n${BLUE}npm proxies:\n${FUCHSIA}${proxy_output1}"
        [[ -n "${proxy_output2}" ]] && colorEcho "${FUCHSIA}${proxy_output2}"
    fi

    if [[ -x "$(command -v yarn)" ]]; then
        proxy_output1=$(yarn config get proxy | grep -v "null")
        proxy_output2=$(yarn config get https-proxy | grep -v "null")
        [[ -n "${proxy_output1}" ]] && colorEcho "\n${BLUE}yarn proxies:\n${FUCHSIA}${proxy_output1}"
        [[ -n "${proxy_output2}" ]] && colorEcho "${FUCHSIA}${proxy_output2}"
    fi

    if [[ -s "/etc/apt/apt.conf.d/80proxy" ]]; then
        proxy_output1=$(cat "/etc/apt/apt.conf.d/80proxy")
        [[ -n "${proxy_output1}" ]] && colorEcho "\n${BLUE}apt proxies:\n${FUCHSIA}${proxy_output1}"
    fi

    if [[ -s "/etc/yum.conf" ]]; then
        proxy_output1=$(grep "proxy=" "/etc/yum.conf")
        [[ -n "${proxy_output1}" ]] && colorEcho "\n${BLUE}yum proxies:\n${FUCHSIA}${proxy_output1}"
    fi

    if [[ -s "$HOME/.wgetrc" ]]; then
        proxy_output1=$(cat "$HOME/.wgetrc")
        [[ -n "${proxy_output1}" ]] && colorEcho "\n${BLUE}wget proxies:\n${FUCHSIA}${proxy_output1}"
    fi

    if [[ -s "$HOME/.curlrc" ]]; then
        proxy_output1=$(cat "$HOME/.curlrc")
        [[ -n "${proxy_output1}" ]] && colorEcho "\n${BLUE}curl proxies(.curlrc):\n${FUCHSIA}${proxy_output1}"
    fi

    if [[ -s "$HOME/.curl_socks5" ]]; then
        proxy_output1=$(cat "$HOME/.curl_socks5")
        [[ -n "${proxy_output1}" ]] && colorEcho "\n${BLUE}curl proxies(.curl_socks5):\n${FUCHSIA}${proxy_output1}"
    fi

    if [[ -s "$HOME/.gradle/gradle.properties" ]]; then
        proxy_output1=$(grep "systemProp.http" "$HOME/.gradle/gradle.properties")
        [[ -n "${proxy_output1}" ]] && colorEcho "\n${BLUE}gradle proxies:\n${FUCHSIA}${proxy_output1}"
    fi

    if [[ -s "$HOME/.gemrc" ]]; then
        proxy_output1=$(grep "http_proxy: " "$HOME/.gemrc")
        [[ -n "${proxy_output1}" ]] && colorEcho "\n${BLUE}gem proxies:\n${FUCHSIA}${proxy_output1}"
    fi
}

function clear_proxy() {
    unset {http,https,ftp,all}_proxy
    unset {HTTP,HTTPS,FTP,ALL}_PROXY
}

function clear_all_proxy() {
    clear_proxy
    set_git_proxy
    set_curl_proxy
    # [[ -s "$HOME/.curl_socks5" ]] && set_curl_proxy "" "$HOME/.curl_socks5"
    set_special_socks5_proxy
    set_wget_proxy
}

function proxy_cmd() {
    [[ -z $* ]] && colorEcho "${GREEN}Set proxy for specific command." && return 0

    if [[ -n "${all_proxy}" ]]; then
        colorEcho "${GREEN}Using proxy: ${FUCHSIA}${all_proxy}"
        $*
    else
        if [[ -n "${GLOBAL_PROXY_IP}" ]]; then
            if [[ -n "${GLOBAL_PROXY_SOCKS_PORT}" ]]; then
                set_proxy "socks5h://${GLOBAL_PROXY_IP}:${GLOBAL_PROXY_SOCKS_PORT}"
            elif [[ -n "${GLOBAL_PROXY_HTTP_PORT}" ]]; then
                set_proxy "http://${GLOBAL_PROXY_IP}:${GLOBAL_PROXY_HTTP_PORT}"
            fi
        fi

        [[ -n "${all_proxy}" ]] && colorEcho "${GREEN}Using proxy: ${FUCHSIA}${all_proxy}"
        $*
        [[ -n "${all_proxy}" ]] && clear_proxy && colorEcho "${GREEN}Proxy clear."
    fi
}

function noproxy_cmd() {
    [[ -z $* ]] && colorEcho "${GREEN}No proxy for specific command." && return 0

    if [[ -n "${all_proxy}" ]]; then
        http_proxy="" https_proxy="" ftp_proxy="" all_proxy="" \
            HTTP_PROXY="" HTTPS_PROXY="" FTP_PROXY="" ALL_PROXY="" \
            $*
    else
        $*
    fi
}

function proxy_socks5h_to_socks5() {
    # fix: golang - proxyconnect tcp: dial tcp: lookup socks5h: no such host
    # https://github.com/golang/go/issues/13454
    # https://github.com/golang/go/issues/24135
    [[ -z $* ]] && colorEcho "${GREEN}Use ${FUCHSIA}socks5${GREEN} proxy instead of ${BLUE}socks5h${GREEN} for specific command." && return 0

    if echo "${all_proxy}" | grep -q 'socks5h'; then
        colorEcho "${GREEN}Using proxy: ${FUCHSIA}${all_proxy/socks5h/socks5}"
        http_proxy=${http_proxy/socks5h/socks5} \
            https_proxy=${https_proxy/socks5h/socks5} \
            ftp_proxy=${ftp_proxy/socks5h/socks5} \
            all_proxy=${all_proxy/socks5h/socks5} \
            HTTP_PROXY=${HTTP_PROXY/socks5h/socks5} \
            HTTPS_PROXY=${HTTPS_PROXY/socks5h/socks5} \
            FTP_PROXY=${FTP_PROXY/socks5h/socks5} \
            ALL_PROXY=${ALL_PROXY/socks5h/socks5} \
            $*
    else
        [[ -n "${all_proxy}" ]] && colorEcho "${GREEN}Using proxy: ${FUCHSIA}${all_proxy}"
        $*
    fi
}

# SET_PROXY_FOR=('brew' 'git' 'apm')
# for cmd in $SET_PROXY_FOR; do
#     hash ${cmd} > /dev/null 2>&1 && alias ${cmd}="proxy_cmd ${cmd}"
# done

# Use proxy or mirror when some sites were blocked or low speed
function set_proxy_mirrors_env() {
    if check_webservice_up www.google.com; then
        APT_NOT_USE_MIRRORS=true
        CONDA_NOT_USE_MIRROR=true
        PIP_NOT_USE_MIRROR=true
        DOCKER_INSTALLER_NOT_USE_MIRROR=true
        GO_INSTALLER_NOT_USE_PROXY=true
        NVM_INSTALLER_NOT_USE_MIRROR=true
        NVS_INSTALLER_NOT_USE_MIRROR=true
        NPM_INSTALLER_NOT_USE_MIRROR=true
        GITHUB_NOT_USE_PROXY=true
        SDKMAN_NOT_USE_PROXY=true
        BREW_NOT_USE_PROXY=true
        RUST_NOT_USE_PROXY=true
    else
        unset APT_NOT_USE_MIRRORS
        unset CONDA_NOT_USE_MIRROR
        unset PIP_NOT_USE_MIRROR
        unset DOCKER_INSTALLER_NOT_USE_MIRROR
        unset GO_INSTALLER_NOT_USE_PROXY
        unset NVM_INSTALLER_NOT_USE_MIRROR
        unset NVS_INSTALLER_NOT_USE_MIRROR
        unset NPM_INSTALLER_NOT_USE_MIRROR
        unset GITHUB_NOT_USE_PROXY
        unset SDKMAN_NOT_USE_PROXY
        unset BREW_NOT_USE_PROXY
        unset RUST_NOT_USE_PROXY
    fi
}

## curl to check webservice is up
# https://stackoverflow.com/questions/12747929/linux-script-with-curl-to-check-webservice-is-up
function check_webservice_up() {
    # How to use:
    # if check_webservice_up www.google.com; then echo "ok"; else echo "something wrong"; fi
    local webservice_url=${1:-"www.google.com"}

    local http=`curl -fsL --noproxy "*" --connect-timeout 3 --max-time 5 \
                -w "%{http_code}\\n" "${webservice_url}" -o /dev/null`
    local exitStatus=0

    case "$http" in
        [2]*)
            ;;
        [3]*)
            # echo "$webservice_url is REDIRECT with ${http}"
            ;;
        [4]*)
            exitStatus=4
            # echo "$webservice_url is DENIED with ${http}"
            ;;
        [5]*)
            exitStatus=5
            # echo "$webservice_url is ERROR with ${http}"
            ;;
        *)
            exitStatus=6
            # echo "$webservice_url is NO RESPONSE with ${http}"
            ;;
    esac

    if [[ "$exitStatus" -eq "0" ]]; then
        # echo "$webservice_url is UP with ${http}"
        return 0
    else
        return 1
    fi

    # return $http
    # exit $exitStatus
}

## curl to check webservice timeout
# https://stackoverflow.com/questions/18215389/how-do-i-measure-request-and-response-times-at-once-using-curl
#     time_namelookup:  %{time_namelookup}\n
#        time_connect:  %{time_connect}\n
#     time_appconnect:  %{time_appconnect}\n
#    time_pretransfer:  %{time_pretransfer}\n
#       time_redirect:  %{time_redirect}\n
#  time_starttransfer:  %{time_starttransfer}\n
#                     ----------\n
#          time_total:  %{time_total}\n
function check_webservice_timeout() {
    local webservice_url=${1:-"www.google.com"}

    local http_timeout=`curl -fsL --connect-timeout 5 --max-time 20 \
                -w "%{time_connect} + %{time_starttransfer} = %{time_total}\\n" \
                "${webservice_url}" -o /dev/null`
    echo "time_connect + time_starttransfer: $http_timeout"
}

# test the availability of a socks5 proxy
function check_socks5_proxy_up() {
    # How to use:
    # if check_socks5_proxy_up 127.0.0.1:1080 www.google.com; then echo "ok"; else echo "something wrong"; fi
    local PROXY_ADDRESS=${1:-""}
    local webservice_url=${2:-"www.google.com"}
    local exitStatus=0

    if [[ -z "${PROXY_ADDRESS}" && -n "${GLOBAL_PROXY_IP}" && -n "${GLOBAL_PROXY_SOCKS_PORT}" ]]; then
        PROXY_ADDRESS="${GLOBAL_PROXY_IP}:${GLOBAL_PROXY_SOCKS_PORT}"
    fi

    [[ -z "${PROXY_ADDRESS}" ]] && PROXY_ADDRESS="127.0.0.1:1080"

    curl -fsL -I --connect-timeout 3 --max-time 5 \
        --socks5-hostname "${PROXY_ADDRESS}" \
        "${webservice_url}" >/dev/null 2>&1 || exitStatus=$?

    if [[ "$exitStatus" -eq "0" ]]; then
        return 0
    else
        return 1
    fi
}

# test the availability of a http proxy
function check_http_proxy_up() {
    # How to use:
    # if check_http_proxy_up 127.0.0.1:8080 www.google.com; then echo "ok"; else echo "something wrong"; fi
    local PROXY_ADDRESS=${1:-""}
    local webservice_url=${2:-"www.google.com"}
    local exitStatus=0

    if [[ -z "${PROXY_ADDRESS}" && -n "${GLOBAL_PROXY_IP}" && -n "${GLOBAL_PROXY_HTTP_PORT}" ]]; then
        PROXY_ADDRESS="${GLOBAL_PROXY_IP}:${GLOBAL_PROXY_HTTP_PORT}"
    fi

    [[ -z "${PROXY_ADDRESS}" ]] && PROXY_ADDRESS="127.0.0.1:8080"

    curl -fsL -I --connect-timeout 3 --max-time 5 \
        --proxy "${PROXY_ADDRESS}" \
        "${webservice_url}" >/dev/null 2>&1 || exitStatus=$?

    if [[ "$exitStatus" -eq "0" ]]; then
        return 0
    else
        return 1
    fi
}

# Set global git proxy
function set_git_proxy() {
    local PROXY_ADDRESS=$1

    if [[ -z "$PROXY_ADDRESS" ]]; then
        git config --global --unset http.proxy
        git config --global --unset https.proxy
    else
        git config --global http.proxy "${PROXY_ADDRESS}"
        git config --global https.proxy "${PROXY_ADDRESS}"
    fi
}

# Set socks5 proxy for certain git repos
function set_git_special_proxy() {
    # Usage: set_git_special_proxy github.com,gitlab.com 127.0.0.1:55880
    local GIT_REPO_LIST=$1
    local PROXY_ADDRESS=${2:-""}
    local Url_List
    local TargetUrl

    Url_List=($(echo ${GIT_REPO_LIST} | sed 's/,/ /g'))

    for TargetUrl in ${Url_List[@]}; do
        [[ -z "$TargetUrl" ]] && continue

        if [[ -z "$PROXY_ADDRESS" ]]; then
            git config --global --unset http.https://${TargetUrl}.proxy
            git config --global --unset https.https://${TargetUrl}.proxy
        else
            git config --global http.https://${TargetUrl}.proxy "${PROXY_ADDRESS}"
            git config --global https.https://${TargetUrl}.proxy "${PROXY_ADDRESS}"
        fi
    done
}

# Set apt proxy
function set_apt_proxy() {
    local PROXY_ADDRESS=$1
    local APT_PROXY_CONFIG=${2:-"/etc/apt/apt.conf.d/80proxy"}

    [[ ! -x "$(command -v apt)" ]] && return 0

    if [[ -n "$PROXY_ADDRESS" ]]; then
        echo -e "Acquire::http::proxy \"http://${PROXY_ADDRESS}/\";" \
            | sudo tee -a "$APT_PROXY_CONFIG" >/dev/null
        echo -e "Acquire::https::proxy \"http://${PROXY_ADDRESS}/\";" \
            | sudo tee -a "$APT_PROXY_CONFIG" >/dev/null
        echo -e "Acquire::ftp::proxy \"http://${PROXY_ADDRESS}/\";" \
            | sudo tee -a "$APT_PROXY_CONFIG" >/dev/null
    else
        [[ -s "$APT_PROXY_CONFIG" ]] && \
            sudo rm -f "$APT_PROXY_CONFIG"
    fi
}

# Set yum proxy
function set_yum_proxy() {
    local PROXY_ADDRESS=${1:-"_none_"}
    local YUM_PROXY_CONFIG=${2:-"/etc/yum.conf"}

    [[ ! -x "$(command -v yum)" ]] && return 0

    # sudo sed -i "s/[#]*[ ]*proxy.*/proxy=_none_/" "$YUM_PROXY_CONFIG"
    sudo sed -i "/[#]*[ ]*proxy.*/d" "$YUM_PROXY_CONFIG"
    echo "proxy=socks5://${PROXY_ADDRESS}" | sudo tee -a "$YUM_PROXY_CONFIG" >/dev/null
}

# Set wget proxy
function set_wget_proxy() {
    local PROXY_ADDRESS=$1
    local WGET_CONFIG=${2:-"$HOME/.wgetrc"}

    [[ ! -x "$(command -v wget)" ]] && return 0

    if [[ -s "$WGET_CONFIG" ]]; then
        sed -i "/^use_proxy.*/d" "$WGET_CONFIG"
        sed -i "/^http_proxy.*/d" "$WGET_CONFIG"
        sed -i "/^https_proxy.*/d" "$WGET_CONFIG"
        sed -i "/^ftp_proxy.*/d" "$WGET_CONFIG"
        sed -i "/^no_proxy.*/d" "$WGET_CONFIG"
    fi

    if [[ -n "$PROXY_ADDRESS" ]]; then
        echo "use_proxy=on" >> "$WGET_CONFIG"
        echo "http_proxy=http://${PROXY_ADDRESS}/" >> "$WGET_CONFIG"
        echo "https_proxy=http://${PROXY_ADDRESS}/" >> "$WGET_CONFIG"
        echo "ftp_proxy=http://${PROXY_ADDRESS}/" >> "$WGET_CONFIG"
        echo "no_proxy=${NO_PROXY_LISTS}" >> "$WGET_CONFIG"
    fi
}

# Set curl proxy
function set_curl_proxy() {
    local PROXY_ADDRESS=$1
    local CURL_CONFIG=${2:-"$HOME/.curlrc"}

    [[ ! -x "$(command -v curl)" ]] && return 0

    if [[ -s "$CURL_CONFIG" ]]; then
        sed -i "/^socks5-hostname.*/d" "${CURL_CONFIG}"
        sed -i "/^noproxy.*/d" "${CURL_CONFIG}"
    fi

    if [[ -n "$PROXY_ADDRESS" ]]; then
        echo "socks5-hostname=${PROXY_ADDRESS}" >> "${CURL_CONFIG}"
        echo "noproxy=${NO_PROXY_LISTS}" >> "${CURL_CONFIG}"
    fi
}

# Set npm http proxy
function set_npm_proxy() {
    local PROXY_ADDRESS=$1

    [[ ! -x "$(command -v npm)" ]] && return 0

    if [[ -n "$PROXY_ADDRESS" ]]; then
        npm config set proxy "http://${PROXY_ADDRESS}"
        npm config set https-proxy "http://${PROXY_ADDRESS}"
    else
        npm config delete proxy
        npm config delete https-proxy
    fi
}

# Set yarn http proxy
function set_yarn_proxy() {
    local PROXY_ADDRESS=$1

    [[ ! -x "$(command -v yarn)" ]] && return 0

    if [[ -n "$PROXY_ADDRESS" ]]; then
        yarn config set proxy "http://${PROXY_ADDRESS}"
        yarn config set https-proxy "http://${PROXY_ADDRESS}"
    else
        yarn config delete proxy
        yarn config delete https-proxy
    fi
}

# Set gradle http proxy
function set_gradle_proxy() {
    local PROXY_HOST=$1
    local PROXY_PORT=$2
    local GRADLE_CONFIG=${3:-"$HOME/.gradle/gradle.properties"}

    [[ ! -x "$(command -v gradle)" ]] && return 0

    if [[ -s "$GRADLE_CONFIG" ]]; then
        sed -i "/^systemProp.http.proxyHost.*/d" "${GRADLE_CONFIG}"
        sed -i "/^systemProp.http.proxyPort.*/d" "${GRADLE_CONFIG}"
        sed -i "/^systemProp.https.proxyHost.*/d" "${GRADLE_CONFIG}"
        sed -i "/^systemProp.https.proxyPort.*/d" "${GRADLE_CONFIG}"
    fi

    if [[ -n "$PROXY_HOST" && -n "$PROXY_PORT" ]]; then
        echo "systemProp.http.proxyHost=${PROXY_HOST}" >> "${GRADLE_CONFIG}"
        echo "systemProp.http.proxyPort=${PROXY_PORT}" >> "${GRADLE_CONFIG}"
        echo "systemProp.https.proxyHost=${PROXY_HOST}" >> "${GRADLE_CONFIG}"
        echo "systemProp.https.proxyPort=${PROXY_PORT}" >> "${GRADLE_CONFIG}"
    fi
}

# Set ruby gem proxy
function set_gem_proxy() {
    local PROXY_ADDRESS=$1
    local GEM_CONFIG=${2:-"$HOME/.gemrc"}

    [[ ! -x "$(command -v gem)" ]] && return 0

    if [[ -s "$GEM_CONFIG" ]]; then
        sed -i "/^http_proxy.*/d" "$GEM_CONFIG"
    fi

    if [[ -n "$PROXY_ADDRESS" ]]; then
        echo "http_proxy: http://${PROXY_ADDRESS}" >> "$GEM_CONFIG"
    fi
}

# Set global proxy
function set_global_proxy() {
    local SOCKS_ADDRESS=${1:-""}
    local HTTP_ADDRESS=${2:-""}
    local SOCKS_PROTOCOL=${3:-"socks5h"}

    # clear git special proxy
    set_git_special_proxy "github.com,gitlab.com"

    # clear special socks5 proxy(curl...)
    set_special_socks5_proxy

    if [[ -n "$SOCKS_ADDRESS" ]]; then
        set_proxy "${SOCKS_PROTOCOL}://${SOCKS_ADDRESS}"

        # set_curl_proxy "${SOCKS_ADDRESS}"

        ## set git global proxy
        # set_git_proxy "${SOCKS_PROTOCOL}://${SOCKS_ADDRESS}"

        ## set special socks5 proxy(curl...)
        # set_special_socks5_proxy "${SOCKS_ADDRESS}"

        colorEcho "${GREEN}  :: Now using ${FUCHSIA}${SOCKS_PROTOCOL}://${SOCKS_ADDRESS} ${GREEN}for global socks5 proxy!"

        # wget must use http proxy
        if [[ -n "$HTTP_ADDRESS" ]]; then
            set_wget_proxy "${HTTP_ADDRESS}"
            colorEcho "${GREEN}  :: Now using ${FUCHSIA}${HTTP_ADDRESS} ${GREEN}for http proxy(wget etc.)!"
        else
            set_wget_proxy
        fi

        return 0
    else
        clear_all_proxy

        return 1
    fi
}

# Check & set global proxy
function check_set_global_proxy() {
    local SOCKS_PORT=${1:-"1080"}
    local MIXED_PORT=${2:-"8080"}
    local PROXY_IP
    local PROXY_SOCKS=""
    local PROXY_HTTP=""
    local IP_LIST="127.0.0.1"
    local IP_WSL
    local PROXY_UP="NO"

    if [[ "$(uname -r)" =~ "microsoft" ]]; then
        # wsl2
        IP_LIST=$(ipconfig.exe | grep "IPv4" \
                    | grep -Eo '([0-9]{1,3}[\.]){3}[0-9]{1,3}' \
                    | grep -Ev "^0\.|^127\.|^172\.")
        IP_WSL=$(grep -m1 nameserver /etc/resolv.conf | awk '{print $2}')
        IP_LIST=$(echo -e "${IP_LIST}\n${IP_WSL}" | uniq)
        # IP_LIST=$(echo -e "${IP_WSL}\n${IP_LIST}" | uniq)
    fi

    unset GLOBAL_PROXY_IP
    unset GLOBAL_PROXY_SOCKS_PROTOCOL
    unset GLOBAL_PROXY_SOCKS_PORT
    unset GLOBAL_PROXY_HTTP_PORT

    # Set global proxy
    while read -r PROXY_IP; do
        if check_socks5_proxy_up "${PROXY_IP}:${MIXED_PORT}"; then
            SOCKS_PORT=${MIXED_PORT}
            PROXY_UP="YES"
        else
            if check_socks5_proxy_up "${PROXY_IP}:${SOCKS_PORT}"; then
                if ! check_http_proxy_up "${PROXY_IP}:${MIXED_PORT}"; then
                    MIXED_PORT=""
                fi
                PROXY_UP="YES"
            fi
        fi

        [[ "$PROXY_UP" == "YES" ]] && break
    done <<<"${IP_LIST}"

    if [[ "$PROXY_UP" == "YES" ]]; then
        [[ -n "${SOCKS_PORT}" ]] && PROXY_SOCKS="${PROXY_IP}:${SOCKS_PORT}"
        [[ -n "${MIXED_PORT}" ]] && PROXY_HTTP="${PROXY_IP}:${MIXED_PORT}"

        if set_global_proxy "${PROXY_SOCKS}" "${PROXY_HTTP}" "socks5h"; then
            export GLOBAL_PROXY_IP=${PROXY_IP}
            export GLOBAL_PROXY_SOCKS_PROTOCOL="socks5h"
            export GLOBAL_PROXY_SOCKS_PORT=${SOCKS_PORT}
            export GLOBAL_PROXY_HTTP_PORT=${MIXED_PORT}

            [[ "$(uname -r)" =~ "microsoft" ]] && export GLOBAL_WSL2_HOST_IP=${PROXY_IP}

            return 0
        fi
    else
        set_global_proxy # clear global proxy

        return 1
    fi
}

# Set special app socks5 proxy (curl...)
function set_special_socks5_proxy() {
    local SOCKS5_PROXY=${1:-""}

    CURL_SPECIAL_CONFIG=${CURL_SPECIAL_CONFIG:-"$HOME/.curl_socks5"}

    if [[ -n "$SOCKS5_PROXY" ]]; then
        set_curl_proxy "${SOCKS5_PROXY}" "${CURL_SPECIAL_CONFIG}"
    else
        cat /dev/null > "${CURL_SPECIAL_CONFIG}"
    fi
}


## Flush dns cache
function flush_dns_cache() {
    [[ -s "/lib/systemd/system/systemd-resolved.service" ]] && \
        sudo ln -sf /lib/systemd/system/systemd-resolved.service \
            /etc/systemd/system/dbus-org.freedesktop.resolve1.service || true

    [[ -x "$(command -v systemd-resolve)" ]] && \
        sudo systemd-resolve --flush-caches >/dev/null 2>&1

    [[ -s "/etc/init.d/dns-clean" ]] && /etc/init.d/dns-clean start

    [[ $(systemctl is-enabled systemd-resolved 2>/dev/null) ]] && \
        sudo systemctl restart systemd-resolved.service >/dev/null 2>&1

    [[ $(systemctl is-enabled dnsmasq 2>/dev/null) ]] && \
        sudo systemctl restart dnsmasq.service >/dev/null 2>&1
}


## Download hosts from url
function download_hosts() {
    local hostsURL=${1:-""}
    local hostsFile=${2:-"/etc/hosts"}
    local exitStatus=0

    [[ -z "$hostsURL" ]] && return 1

    colorEcho "${BLUE}Downloading hosts from ${hostsURL}..."
    curl -fSL --connect-timeout 5 --max-time 20 \
        -o "/tmp/hosts" "$hostsURL" || exitStatus=$?
    if [[ "$exitStatus" -eq "0" ]]; then
        if [[ "${hostsFile}" == "/etc/hosts" ]]; then
            [[ ! -s "${hostsFile}.orig" ]] && \
                sudo cp -f "${hostsFile}" "${hostsFile}.orig"

            sudo cp -f "${hostsFile}" "${hostsFile}.bak" && \
                sudo mv -f "/tmp/hosts" "${hostsFile}" && \
                flush_dns_cache
        else
            cp -f "${hostsFile}" "${hostsFile}.bak" && \
                mv -f "/tmp/hosts" "${hostsFile}"
        fi

        return 0
    else
        return 1
    fi
}


function reset_hosts() {
    local hostsFile=${1:-"/etc/hosts"}

    [[ -s "${hostsFile}.orig" ]] && \
        sudo cp -f "${hostsFile}.orig" "${hostsFile}"
}


function Git_Clone_Update() {
    local REPONAME=${1:-""}
    local REPODIR=${2:-""}
    local REPOURL=${3:-"github.com"}
    local BRANCH=${4:-""}
    local GIT_COMMAND="git"
    local REPOREMOTE=""
    local DEFAULTBRANCH=""
    local CurrentDir

    if [[ -z "${REPONAME}" ]]; then
        colorEcho "${RED}Error! Repository name can't empty!"
        return 1
    fi

    [[ -z "${REPODIR}" ]] && REPODIR=$(echo ${REPONAME} | awk -F"/" '{print $NF}')

    if [[ "${REPOURL}" == "github.com" ]]; then
        # Accelerate the speed of accessing GitHub
        # https://www.gitclone.com/
        # https://fastgit.org/
        if [[ -n "${GITHUB_MIRROR_USE_CGIT}" && -x "$(command -v cgit)" ]]; then
            GIT_COMMAND="cgit"
        else
            [[ -n "${GITHUB_MIRROR_USE_GITCLONE}" ]] && REPOURL="gitclone.com/github.com"
            [[ -n "${GITHUB_MIRROR_USE_CNPMJS}" ]] && REPOURL="github.com.cnpmjs.org"
            [[ -n "${GITHUB_MIRROR_USE_FASTGIT}" ]] && REPOURL="hub.fastgit.org"
        fi

        REPOREMOTE="https://${REPOURL}/${REPONAME}"
    else
        REPOREMOTE="${REPOURL}/${REPONAME}"
    fi

    ## clear git proxy when using github mirror
    # [[ -n "${GITHUB_MIRROR_USE_CGIT}" && -x "$(command -v cgit)" ]] && set_git_proxy
    # [[ -n "${GITHUB_MIRROR_USE_GITCLONE}" || -n "${GITHUB_MIRROR_USE_CNPMJS}" || -n "${GITHUB_MIRROR_USE_FASTGIT}" ]] && set_git_proxy

    if [[ -d "${REPODIR}/.git" ]]; then
        colorEcho "${BLUE}  Updating ${FUCHSIA}${REPONAME}${BLUE}..."

        CurrentDir=$(pwd)

        cd "${REPODIR}"
        [[ -z "${BRANCH}" ]] && BRANCH=$(${GIT_COMMAND} symbolic-ref --short HEAD 2>/dev/null)
        [[ -z "${BRANCH}" ]] && BRANCH="master"

        ${GIT_COMMAND} pull --rebase --stat origin "${BRANCH}"
        # pull error: fallback to default branch
        if [[ $? != 0 ]]; then
            DEFAULTBRANCH=$(${GIT_COMMAND} ls-remote --symref "${REPOREMOTE}" HEAD \
                        | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}')
            if [[ -n "${DEFAULTBRANCH}" && "${DEFAULTBRANCH}" != "${BRANCH}" ]]; then
                git branch -m "${BRANCH}" "${DEFAULTBRANCH}"

                [[ -s "${REPODIR}/.git/config" ]] && \
                    sed -i "s|${BRANCH}|${DEFAULTBRANCH}|g" "${REPODIR}/.git/config"

                # git fetch origin
                # git branch --unset-upstream
                # git branch -u "origin/${DEFAULTBRANCH}" "${DEFAULTBRANCH}"
                # git symbolic-ref "refs/remotes/origin/HEAD" "refs/remotes/origin/${DEFAULTBRANCH}"

                ${GIT_COMMAND} pull --rebase --stat origin "${DEFAULTBRANCH}"
            fi
        fi

        ## master branch
        # git fetch --depth 1 && git reset --hard origin/master

        ## checkout other branch
        # git remote set-branches --add orgin "'${remote_branch_name}'"
        #     git fetch --depth 1 origin ${remote_branch_name} && \
        #     git checkout ${remote_branch_name}

        cd "${CurrentDir}"
    else
        colorEcho "${BLUE}  Cloning ${FUCHSIA}${REPONAME}${BLUE}..."
        [[ -z "${BRANCH}" ]] && \
            BRANCH=$(${GIT_COMMAND} ls-remote --symref "${REPOREMOTE}" HEAD \
                    | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}')
        [[ -z "${BRANCH}" ]] && BRANCH="master"

        ${GIT_COMMAND} clone -c core.autocrlf=false -c core.filemode=false \
            -c fsck.zeroPaddedFilemode=ignore \
            -c fetch.fsck.zeroPaddedFilemode=ignore \
            -c receive.fsck.zeroPaddedFilemode=ignore \
            --depth=1 --branch "${BRANCH}" "${REPOREMOTE}" "${REPODIR}" || {
                colorEcho "${RED}  git clone of ${FUCHSIA}${REPONAME} ${RED}failed!"
                return 1
            }
    fi

    ## restore git proxy
    # [[ -n "${GLOBAL_PROXY_IP}" && -n "${GLOBAL_PROXY_SOCKS_PORT}" ]] && \
    #     set_git_proxy "${GLOBAL_PROXY_SOCKS_PROTOCOL}://${GLOBAL_PROXY_IP}:${GLOBAL_PROXY_SOCKS_PORT}"
}


# https://stackoverflow.com/questions/3497123/run-git-pull-over-all-subdirectories
function git_update_repo_in_subdir() {
    local SubDir=${1:-""}
    local FindDir TargetDir CurrentDir
    local REPOREMOTE REPONAME REPODIR REPOURL BRANCH
    local DIRLIST=()

    CurrentDir=$(pwd)

    [[ -z "${SubDir}" ]] && SubDir=${CurrentDir}
    [[ ! -d "${SubDir}" ]] && exit 0

    # find . -type d -name ".git" -execdir git pull --rebase --stat origin master \;

    find "${SubDir}" -type d -name ".git" | while read -r FindDir; do
        FindDir="$(realpath "${FindDir}")"
        DIRLIST+=("${FindDir%/*}")
    done

    for TargetDir in "${DIRLIST[@]}"; do
        REPODIR="${TargetDir}"
        cd "${REPODIR}"

        REPOREMOTE=$(git config --get remote.origin.url | head -n1)
        REPONAME=$(echo "${REPOREMOTE}"| sed 's|^http://||;s|^https://||;s|.git$||' | sed 's/.*\/\([^ ]*\/[^ ]*\).*/\1/')
        REPOURL=$(echo "${REPOREMOTE}" | sed 's|.git$||' | sed "s|/${REPONAME}||")
        [[ "${REPOREMOTE}" =~ "://github.com/" ]] && REPOURL="github.com"

        BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null)
        [[ -z "${BRANCH}" ]] && BRANCH="master"

        Git_Clone_Update "${REPONAME}" "${REPODIR}" "${REPOURL}" "${BRANCH}"
    done

    cd "${CurrentDir}"
}

function git_update_repo_in_subdir_parallel() {
    local SubDir=${1:-""}
    local BRANCH=${2:-master}
    local FindDepth=${3:-""}

    [[ -z "${SubDir}" ]] && exit 0
    [[ ! -d "${SubDir}" ]] && exit 0

    if [[ -z "${FindDepth}" ]]; then
        find "${SubDir}" -type d -name ".git" \
            | sed 's/\/.git//' \
            | xargs -P10 -I{} git --git-dir="{}/.git" --work-tree="{}" \
                pull --rebase --stat origin "${BRANCH}"
    else
        find "${SubDir}" -maxdepth ${FindDepth} -type d -name ".git" \
            | sed 's/\/.git//' \
            | xargs -P10 -I{} git --git-dir="{}/.git" --work-tree="{}" \
                pull --rebase --stat origin "${BRANCH}"
    fi
}

function git_get_remote_default_branch() {
    local REPOREMOTE=${1:-""}

    if [[ -z "${REPOREMOTE}" && -d ".git" ]]; then
        REPO_DEFAULT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null)
    else
        [[ -z "${REPOREMOTE}" ]] && exit 0

        ## Github: https://api.github.com/repos/docker/compose
        # REPO_DEFAULT_BRANCH=$(curl -fsL "${REPOREMOTE}" | grep 'default_branch' | cut -d\" -f4)

        REPO_DEFAULT_BRANCH=$(git ls-remote --symref "${REPOREMOTE}" HEAD \
                                | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}')
    fi
}


function Install_cron_job() {
    local cronjob=${1:-""}
    local cronline

    [[ -z "${cronjob}" ]] && return 0

    (crontab -l 2>/dev/null || true; echo "${cronjob}") | crontab - || {
        colorEcho "${RED}  cron job install failed!"
        return 1
    }

    cronline=$(crontab -l | wc -l)

    colorEcho "${FUCHSIA}${cronjob} ${GREEN}installed!"
    colorEcho "${YELLOW}  How to delete this job:"
    colorEcho "${FUCHSIA}  (crontab -l 2>/dev/null | sed \"${cronline}d\") | crontab -"
}


function Install_systemd_Service() {
    # Usage:
    # Install_systemd_Service "subconverter" "/srv/subconverter/subconverter"
    local service_name=$1
    local service_exec=$2
    local service_user=${3:-"nobody"}
    local service_workdir=${4:-""}
    local filename
    local service_file

    [[ $# < 2 ]] && return 1
    [[ -z "$service_name" ]] && return 1
    [[ -z "$service_exec" ]] && return 1

    if [[ -z "$service_workdir" ]]; then
        filename=$(echo ${service_exec} | cut -d" " -f1)
        service_workdir=$(dirname $(readlink -f "$filename"))
    fi

    service_file="/etc/systemd/system/${service_name}.service"
    if [[ ! -s "$service_file" ]]; then
        sudo tee "$service_file" >/dev/null <<-EOF
[Unit]
Description=${service_name}
After=network.target network-online.target nss-lookup.target

[Service]
Type=simple
StandardError=journal
User=${service_user}
AmbientCapabilities=CAP_NET_BIND_SERVICE
ExecStart=${service_exec}
WorkingDirectory=${service_workdir}
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
    fi

    sudo systemctl enable "$service_name" && sudo systemctl restart "$service_name"
    if [[ $(systemctl is-enabled "$service_name" 2>/dev/null) ]]; then
        colorEcho "${GREEN}  systemd service ${FUCHSIA}${service_name}${GREEN} installed!"
    else
        colorEcho "${RED}  systemd service ${FUCHSIA}${service_name}${RED} install failed!"
    fi
}


# Check pacakge is installed
function checkPackageInstalled() {
    local PackageName=${1:-""}
    local PackageLocalFiles=""
    local PackageInstalled="no"

    [[ -n "${PackageName}" ]] || return 1
    [[ -x "$(command -v pacman)" ]] || return 1

    PackageLocalFiles=$(pacman -Ql "${PackageName}" 2>&1)
    if [[ $? -eq 0 ]]; then
        PackageInstalled="yes"
    else
        if [[ "${PackageLocalFiles}" == *"unimplemented"* ]]; then
            if pacman -Qi "${PackageName}" >/dev/null 2>&1; then
                PackageInstalled="yes"
            fi
        fi
    fi

    [[ "${PackageInstalled}" == "yes" ]] && return 0 || return 1
}

# Check pacakge exist and not installed
function checkPackageNeedInstall() {
    local PackageName=${1:-""}
    local PackageInfo=""
    local PackageExist="yes"

    [[ -n "${PackageName}" ]] || return 1
    [[ -x "$(command -v pacman)" ]] || return 1

    PackageInfo=$(pacman -Si "${PackageName}" 2>&1)
    if [[ $? -eq 0 ]]; then
        [[ "${PackageInfo}" =~ "Error:" ]] && PackageExist="no"
    else
        PackageExist="no"
    fi

    if [[ "${PackageExist}" == "yes" ]]; then
        if ! checkPackageInstalled "${PackageName}"; then
            return 0
        fi
    fi

    return 1
}


# Start new screen session and logging to $HOME/screenlog.*
function newScreenSession() {
    local SCREEN_SESSION_NAME=${1:-"default"}
    local SCREEN_SESSION_LOGGING=${2:-"no"}

    if [[ -x "$(command -v screen)" ]]; then
        if [[ -z "$STY" && -z "$TMUX" ]]; then
            mkdir -p "$HOME/.screen" && chmod 700 "$HOME/.screen" && export SCREENDIR="$HOME/.screen"
            if ! grep -q "^term " "$HOME/.screenrc"; then
                echo "term ${TERM}" >> "$HOME/.screenrc"
            fi

            if ! grep -q "^caption always " "$HOME/.screenrc"; then
                tee -a "$HOME/.screenrc" >/dev/null <<-'EOF'
# https://gist.github.com/onsails/1328005/dacbc9903fcea5385bb8ee2fde4e1a367d32889c
# caption always "%?%F%{-b bc}%:%{-b bb}%?%C|%D|%M %d|%H%?%F%{+u wb}%? %L=%-Lw%45>%{+b by}%n%f* %t%{-}%+Lw%-0<"
caption always "%{=}%{+b kR}%H %{+b kY}%M %d %{+b kG}%2c %{+b kB}%?%-Lw%?%{+b kW}%n*%f %kt%?(%u)%?%{+bkB}%?%+Lw%? | %{kR} Load: %l %{kB}"
EOF
            fi

            # logging
            if [[ "${SCREEN_SESSION_LOGGING}" == "yes" ]]; then
                screen -L -Logfile "$HOME/.screen/screen_$(date '+%Y%m%d_%H%M%S').log" -xRR ${SCREEN_SESSION_NAME}
            else
                screen -xRR ${SCREEN_SESSION_NAME}
            fi
        fi
    else
        colorEcho "${FUCHSIA}screen${RED} is not installed!"
        return 1
    fi
}

# Start new tmux session
function newTmuxSession() {
    local TMUX_SESSION_NAME=${1:-"default"}

    ## Logging in tmux session
    # script -f "$HOME/.tmux_logs/tmux_$(date '+%Y%m%d_%H%M%S').log" >/dev/null && exit

    ## tmux-logging
    ## https://github.com/tmux-plugins/tmux-logging
    # if [[ -s "$HOME/.tmux.conf.local" ]]; then
    #     if ! grep -q "tmux-logging" "$HOME/.tmux.conf.local"; then
    #         echo "set -g @plugin 'tmux-plugins/tmux-logging'" \
    #             | tee -a "$HOME/.tmux.conf.local" >/dev/null
    #     fi
    # fi

    if [[ "$(command -v tmux)" ]]; then
        if [[ -z "$STY" && -z "$TMUX" ]]; then
            tmux attach -t ${TMUX_SESSION_NAME} || tmux new -s ${TMUX_SESSION_NAME}
        fi
    else
        colorEcho "${FUCHSIA}tmux${RED} is not installed!"
        return 1
    fi
}

# docker pull: Pull multiple images together
# https://github.com/moby/moby/issues/16106
function dockerPullImages() {
    # usage: 
    # dockerPullImages "node:lts-alpine golang:alpine"

    # https://www.linuxjournal.com/content/parallel-shells-xargs-utilize-all-your-cpu-cores-unix-and-windows
    # nproc: the number of installed processors
    # --ignore=N if possible, exclude N processing units
    echo "$@" | xargs -P "$(nproc --ignore=1)" -n1 docker pull

    # for dockerImage in "$@"; do docker pull $dockerImage; done
}


# https://github.com/chubin/wttr.in
function get_weather() {
    local wttr_city=${1:-""}
    local wttr_format=${2:-""}
    local wttr_lang=${3:-"zh-cn"}
    local wttr_url

    if [[ -z "${wttr_format}" ]]; then
        wttr_url="wttr.in/${wttr_city}"
    else
        wttr_url="wttr.in/${wttr_city}?format=${wttr_format}"
    fi

    curl -fsL --connect-timeout 3 --max-time 10 \
        --noproxy '*' -H "Accept-Language: ${wttr_lang}" --compressed \
        "${wttr_url}"
}

function get_weather_custom() {
    local wttr_city=${1:-""}
    local wttr_format=${2:-""}
    local wttr_lang=${3:-"zh-cn"}
    local wttr_url
    local wttr_weather

    if [[ -z "${wttr_format}" ]]; then
        wttr_format="%l:+%c%C,+%F0%9F%8C%A1%t,+%E2%9B%86%h,+%F0%9F%8E%8F%w,+%E2%98%94%p+%o,+%P"
    fi

    wttr_url="wttr.in/${wttr_city}?format=${wttr_format}"

    wttr_weather=$(curl -fsL --connect-timeout 3 --max-time 10 \
        --noproxy '*' -H "Accept-Language: ${wttr_lang}" --compressed \
        "${wttr_url}")
    [[ $? -eq 0 ]] && colorEcho "${YELLOW}${wttr_weather}"
}

# Bash Function To Rename Files Without Typing Full Name Twice
function mv_rename() {
    if [ "$#" -ne 1 ] || [ ! -e "$1" ]; then
        command mv "$@"
        return
    fi

    read -ei "$1" newfilename
    command mv -v -- "$1" "$newfilename"
}

## Dateutils
# http://www.fresse.org/dateutils/
# apt install -y dateutils
# dateutils.dadd 2018-05-22 +120d
# Usage: date_diff 20201208 20180522
function date_diff() {
    if [[ $# -eq 2 ]]; then
        echo $(( ($(date -d "$1" +%s) - $(date -d "$2" +%s) )/(60*60*24) ))
    fi
}

#  Usage: get_zone_time Asia/Shanghai America/Los_Angeles America/New_York
function get_zone_time() {
    local TZONES="$@"
    local CURRENT_UTC_TIME
    local DISPLAY_FORMAT
    local UTC_TIME
    local LOCAL_TIME
    local ZONE_LIST
    local ZONE_TIME
    local tz

    [[ -z "$TZONES" ]] && TZONES="Asia/Shanghai"
    # /usr/share/zoneinfo
    # Asia/Shanghai America/Los_Angeles America/New_York
    CURRENT_UTC_TIME=$(date -u)

    DISPLAY_FORMAT="%F %T %Z %z"

    UTC_TIME=$(date -u -d "$CURRENT_UTC_TIME" +"$DISPLAY_FORMAT")
    colorEcho "${YELLOW}UTC Time: ${UTC_TIME}"

    LOCAL_TIME=$(date -d "$CURRENT_UTC_TIME" +"$DISPLAY_FORMAT")
    colorEcho "${FUCHSIA}Local Time: ${LOCAL_TIME}"

    ZONE_LIST=($(echo ${TZONES}))
    for tz in ${ZONE_LIST[@]}; do
        ZONE_TIME=$(TZ="$tz" date -d "$CURRENT_UTC_TIME" +"$DISPLAY_FORMAT")
        colorEcho "${BLUE}${tz}: ${ZONE_TIME}"
    done
}


## Sort an array
## https://gist.github.com/suewonjp/7150f3fe449a58b2ce6cbb456882bed6
# tmp=( c d a e b )
# sort_array tmp
# echo ${tmp[*]} ### a b c d e
function sort_array() {
    if [[ -n "$1" ]]; then
        local IFS=$'\n'
        eval "local arr=( \${$1[*]} )"
        arr=( $( sort <<<"${arr[*]}" ) )
        eval "$1=( \${arr[*]} )"
    fi
}

# https://askubuntu.com/questions/597924/wrong-behavior-of-sort-command
function sort_array_lc() {
    if [[ -n "$1" ]]; then
        local IFS=$'\n'
        eval "local arr=( \${$1[*]} )"
        arr=( $( LC_ALL=C sort <<<"${arr[*]}" ) )
        eval "$1=( \${arr[*]} )"
    fi
}


## load SSH keys with Passphrase Protected
## https://www.funtoo.org/Keychain
## http://unix.stackexchange.com/questions/90853/how-can-i-run-ssh-add-automatically-without-password-prompt
## https://www.cyberciti.biz/faq/ssh-passwordless-login-with-keychain-for-scripts/
function load_ssh_keys() {
    local IdentityFiles

    if checkPackageNeedInstall "keychain"; then
        colorEcho "${BLUE}  Installing ${FUCHSIA}${TargetPackage}${BLUE}..."
        sudo pacman --noconfirm -S keychain
    fi

    if [[ ! -x "$(command -v keychain)" ]]; then
        colorEcho "${FUCHSIA}keychain${RED} is not installed!"
        return 1
    fi

    # /usr/bin/keychain --list
    # /usr/bin/keychain --clear

    if [[ -s "$HOME/.ssh/config" ]]; then
        IdentityFiles=$(cat "$HOME/.ssh/config" | grep 'IdentityFile' \
                            | sed -e 's/IdentityFile//' -e "s/^\s*//" -e "s/\s$//" -e "s|~|$HOME|" \
                            | sort | uniq)
        for TargetFile in "${IdentityFiles[@]}"; do
            /usr/bin/keychain ${TargetFile}
        done
    fi

    [[ -z "$HOSTNAME" ]] && HOSTNAME=`uname -n`
    if [[ -s "$HOME/.keychain/$HOSTNAME-sh" ]]; then
        source "$HOME/.keychain/$HOSTNAME-sh"
        /usr/bin/keychain --list
    fi

    # Improve the security of keychain, need to re-enter any passphrases when log in
    if ! grep -q '/usr/bin/keychain --clear' ~/.zshrc >/dev/null 2>&1; then
        echo '' >> ~/.zshrc
        echo '# Improve the security of keychain' >> ~/.zshrc
        echo '# User need to re-enter any passphrases when log in' >> ~/.zshrc
        echo '[[ -x "$(command -v keychain)" ]] && /usr/bin/keychain --clear >/dev/null 2>&1' >> ~/.zshrc
    fi

    if ! grep -q '/usr/bin/keychain --clear' ~/.bash_profile >/dev/null 2>&1; then
        echo '' >> ~/.bash_profile
        echo '# Improve the security of keychain' >> ~/.bash_profile
        echo '# User need to re-enter any passphrases when log in' >> ~/.bash_profile
        echo '[[ -x "$(command -v keychain)" ]] && /usr/bin/keychain --clear >/dev/null 2>&1' >> ~/.bash_profile
    fi
}


## ProgressBar
# bar=''
# for ((i=0;$i<=100;i++)); do
#     printf "Progress:[%-100s]%d%%\r" $bar $i
#     sleep 0.1
#     bar=#$bar
# done
# echo
function draw_progress_bar() {
    # https://stackoverflow.com/questions/238073/how-to-add-a-progress-bar-to-a-shell-script
    # progress bar length in characters
    [[ -z "$PROGRESS_BAR_WIDTH" ]] && PROGRESS_BAR_WIDTH=50

    # Arguments: current value, max value, unit of measurement (optional)
    local __value=$1
    local __max=$2
    local __unit=${3:-""}  # if unit is not supplied, do not display it

    # Calculate percentage
    if (( $__max < 1 )); then __max=1; fi  # anti zero division protection
    local __percentage=$(( 100 - ($__max*100 - $__value*100) / $__max ))

    # Rescale the bar according to the progress bar width
    local __num_bar=$(( $__percentage * $PROGRESS_BAR_WIDTH / 100 ))

    # Draw progress bar
    printf "["
    for b in $(seq 1 $__num_bar); do printf "#"; done
    for s in $(seq 1 $(( $PROGRESS_BAR_WIDTH - $__num_bar ))); do printf " "; done
    if [[ -n "$__unit" ]]; then
        printf "] $__percentage%% ($__value / $__max $__unit)\r"
    else
        printf "] $__percentage%% ($__value / $__max)\r"
    fi
}
## Usage:
# PROGRESS_CNT=100
# PROGRESS_CUR=1
# while true; do
#     PROGRESS_CUR=$(($PROGRESS_CUR+1))
#     # Draw a progress bar
#     draw_progress_bar $PROGRESS_CUR $PROGRESS_CNT "files"
#     # Check if we reached 100%
#     [[ $PROGRESS_CUR == $PROGRESS_CNT ]] && break
#     # sleep 0.1  # Wait before redrawing
# done
# # Go to the newline at the end of progress
# printf "\n"
