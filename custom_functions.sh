#######color code########
RED="31m"      # Error message
GREEN="32m"    # Success message
YELLOW="33m"   # Warning message
BLUE="36m"     # Info message

function colorEcho() {
    COLOR=$1
    echo -e "\033[${COLOR}${@:2}\033[0m"
}

# get os type: darwin, windows, linux, bsd, solaris
function get_os_type() {
    local osname=$(uname)
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
}

# Determine which desktop environment is installed from the shell
# OSDesktopENV=$(ps -e | grep -E -i "gnome|kde|mate|cinnamon|lxde|xfce|jwm")
function get_os_desktop() {
    if [[ -n "$XDG_CURRENT_DESKTOP" ]]; then
        OSDesktopENV=$(echo "$XDG_DATA_DIRS" | sed 's/.*\(gnome\|kde\|mate\|cinnamon\|lxde\|xfce\|jwm\).*/\1/')
    else
        OSDesktopENV=$XDG_CURRENT_DESKTOP
    fi
}

function check_release_package_manager() {
    local checkType=$1
    local value=$2

    local release=''
    local systemPackage=''

    local osname=$(uname)
    if [[ -f /etc/redhat-release ]]; then
        release="centos"
        systemPackage="yum"
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
		amd64 | x86_64)
			spruce_type='amd64'
			;;
		i686 | i586 | i486 | i386 | x86)
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
    case "$ARCH" in
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
		*)
            VDIS=""
            ;;
    esac
    return 0
}

function get_os() {
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
    if [[ $os_wsl =~ "Microsoft" ]]; then
        OS='Windows'
    fi
}

function get_os_release() {
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
            OS_RELEASE="$(grep -E '^ID=([a-zA-Z]*)' /etc/os-release | cut -d '=' -f 2)"
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
    if [[ $os_wsl =~ "Microsoft" ]]; then
        OS_RELEASE='windows'
    fi
}

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
    check_os_package_manager yum "CentOS" && return
    check_os_package_manager yum "Red Hat" && return
    check_os_package_manager zypper "SUSE" && return
    check_os_package_manager pkg_tools "OpenBSD" && return
    check_os_package_manager pkg_tools "Bitrig" && return
    check_os_package_manager apk "Alpine Linux" && return

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
    [[ -x "/usr/bin/tazpkg" ]] && OS_PACKAGE_MANAGER="tazpkg" && return
    [[ -x "/usr/bin/swupd" ]] && OS_PACKAGE_MANAGER="swupd" && return

    command -v brew >/dev/null && OS_PACKAGE_MANAGER="homebrew" && return

    return 1
}

function get_os_icon() {
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
            local os_release_id="$(grep -E '^ID=([a-zA-Z]*)' /etc/os-release | cut -d '=' -f 2)"
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
    if [[ $os_wsl =~ "Microsoft" ]]; then
        OS_ICON=$'\uF17A'
    fi
}

# version compare functions
function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; } # >
function version_ge() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" = "$1"; } # >=
function version_lt() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" != "$1"; } # <
function version_le() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" = "$1"; } # <=

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
    # PROTOCOL://USERNAME:PASSWORD@HOST:PORT
    # http://127.0.0.1:8080
    # socks5h://127.0.0.1:8080
    # PASSWORD has special characters:
    # [@ %40] [: %3A] [! %21] [# %23] [$ %24]
    # F@o:o!B#ar$ -> F%40o%3Ao%21B%23ar%24
    local proxy_url=$1

    [[ -z "$proxy_url" ]] && proxy_url="http://127.0.0.1:8080"

    # export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
    # export no_proxy="localhost,127.0.0.0/8,*.local"

    export http_proxy=${proxy_url}
    export HTTPS_PROXY=${proxy_url}
    export ALL_PROXY=${proxy_url}

    # curlrc
    # echo "proxy=${proxy_url}" >> .curlrc
}

function clear_proxy() {
    export http_proxy=
    export HTTPS_PROXY=
    export ALL_PROXY=
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
        NETWORK_INTERFACE_DEFAULT=$(ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//" -e "s/[ \t]//g")
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
    # curl -s http://yourdomainname/getip.php | html2text
    # nodejs:
    # https://github.com/alsotang/externalip
    # https://github.com/sindresorhus/public-ip
    unset WAN_NET_IP

    local remote_host_list
    local target_host

    remote_host_list=(
        https://ifconfig.co/
        https://v4.ident.me/
        http://icanhazip.com/
        http://ipinfo.io/ip
    )

    for target_host in ${remote_host_list[@]}; do
        WAN_NET_IP=$(curl -s -4 --connect-timeout 5 --max-time 10 ${target_host})
        [[ -n "$WAN_NET_IP" ]] && break
    done
    # WAN_NET_IP=`dig +short myip.opendns.com @resolver1.opendns.com`
}

function get_network_wan_ipv6() {
    unset WAN_NET_IPV6

    local remote_host_list
    local target_host

    remote_host_list=(
        https://ifconfig.co/
        https://v6.ident.me/
        http://icanhazip.com/
    )

    for target_host in ${remote_host_list[@]}; do
        WAN_NET_IPV6=$(curl -s -6 --connect-timeout 5 --max-time 10 ${target_host})
        [[ -n "$WAN_NET_IPV6" ]] && break
    done
}

function get_network_wan_geo() {
    unset WAN_NET_IP_GEO

    # Country lookup: China
    WAN_NET_IP_GEO=`curl -s -4 --connect-timeout 5 --max-time 10 https://ifconfig.co/country`
    if [[ -z "$WAN_NET_IP_GEO" ]]; then
        # Country lookup: CN
        WAN_NET_IP_GEO=`curl -s -4 --connect-timeout 5 --max-time 10 https://ifconfig.co/country-iso`
    fi

    if [[ -z "$WAN_NET_IP_GEO" && -x "$(command -v geoiplookup)" ]]; then
        get_network_wan_ipv4
        if [[ -n "$WAN_NET_IP" ]]; then
            WAN_NET_IP_GEO=`geoiplookup ${WAN_NET_IP}`
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
    [[ -n "$WAN_NET_IP" ]] && echo -e "Public IP: ${WAN_NET_IP}"
    [[ -n "$WAN_NET_IPV6" ]] && echo -e "Public IPV6: ${WAN_NET_IPV6}"
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

    [[ -n "$WAN_NET_IP" ]] && echo -e "Public IP: ${WAN_NET_IP}"
    [[ -n "$WAN_NET_IPV6" ]] && echo -e "Public IPV6: ${WAN_NET_IPV6}"
}

function myip_wan_geo() {
    get_network_wan_ipv4
    get_network_wan_geo

    if [[ -n "$WAN_NET_IP_GEO" ]]; then
        echo -e "Public IP: ${WAN_NET_IP}\n${WAN_NET_IP_GEO}"
    else
        echo "Can't get GEO by WAN IP!"
    fi
}


## Set proxy or mirrors env in china
function set_proxy_mirrors_env() {
    # if [[ -z "$WAN_NET_IP_GEO" ]]; then
    #     get_network_wan_geo
    # fi

    # if [[ "${WAN_NET_IP_GEO}" =~ 'China' || "${WAN_NET_IP_GEO}" =~ 'CN' ]]; then
    #     unset APT_NOT_USE_MIRRORS
    #     unset CONDA_NOT_USE_MIRROR
    #     unset DOCKER_INSTALLER_NOT_USE_MIRROR
    #     unset GVM_INSTALLER_NOT_USE_PROXY
    #     unset NVM_INSTALLER_NOT_USE_MIRROR
    #     unset NVS_INSTALLER_NOT_USE_MIRROR
    #     unset NPM_INSTALLER_NOT_USE_MIRROR
    # else
    #     APT_NOT_USE_MIRRORS=true
    #     CONDA_NOT_USE_MIRROR=true
    #     DOCKER_INSTALLER_NOT_USE_MIRROR=true
    #     GVM_INSTALLER_NOT_USE_PROXY=true
    #     NVM_INSTALLER_NOT_USE_MIRROR=true
    #     NVS_INSTALLER_NOT_USE_MIRROR=true
    #     NPM_INSTALLER_NOT_USE_MIRROR=true
    # fi

    if check_webservice_up www.google.com; then
        APT_NOT_USE_MIRRORS=true
        CONDA_NOT_USE_MIRROR=true
        DOCKER_INSTALLER_NOT_USE_MIRROR=true
        GVM_INSTALLER_NOT_USE_PROXY=true
        NVM_INSTALLER_NOT_USE_MIRROR=true
        NVS_INSTALLER_NOT_USE_MIRROR=true
        NPM_INSTALLER_NOT_USE_MIRROR=true
    else
        unset APT_NOT_USE_MIRRORS
        unset CONDA_NOT_USE_MIRROR
        unset DOCKER_INSTALLER_NOT_USE_MIRROR
        unset GVM_INSTALLER_NOT_USE_PROXY
        unset NVM_INSTALLER_NOT_USE_MIRROR
        unset NVS_INSTALLER_NOT_USE_MIRROR
        unset NPM_INSTALLER_NOT_USE_MIRROR
    fi
}


## curl to check webservice is up
# https://stackoverflow.com/questions/12747929/linux-script-with-curl-to-check-webservice-is-up
function check_webservice_up() {
    # How to use:
    # if check_webservice_up www.google.com; then echo "ok"; else echo "something wrong"; fi
    local webservice_url=$1

    [[ -z "$webservice_url" ]] && webservice_url="www.google.com"

    local http=`curl -sL -w "%{http_code}\\n" "${webservice_url}" \-o /dev/null --connect-timeout 3 --max-time 5`
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

    if [ "$exitStatus" -eq "0" ]; then
        # echo "$webservice_url is UP with ${http}"
        return 0
    else
        return 1
    fi

    # return $http
    # exit $exitStatus
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
