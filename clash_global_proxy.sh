## https://computingforgeeks.com/how-to-set-system-wide-proxy-on-ubuntu-debian/
## Add this file to: /etc/profile.d/

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

    export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
    # export no_proxy="localhost,127.0.0.0/8,*.local"

    export {http,https,ftp,all}_proxy=${proxy_url}

    # for curl
    export {HTTP,HTTPS,FTP,ALL}_PROXY=${proxy_url}
    export NO_PROXY="localhost,127.0.0.1,localaddress,.localdomain.com"

    # curlrc
    # echo "proxy=${proxy_url}" >> .curlrc
}

function clear_proxy() {
    unset {http,https,ftp,all}_proxy
    unset {HTTP,HTTPS,FTP,ALL}_PROXY
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

## test the availability of a socks5 proxy
function check_socks5_proxy_up() {
    # How to use:
    # if check_socks5_proxy_up 127.0.0.1:1080 www.google.com; then echo "ok"; else echo "something wrong"; fi
    local socks_proxy_url
    local webservice_url
    local exitStatus=0

    [[ $# > 0 ]] && socks_proxy_url=$1
    [[ $# > 1 ]] && webservice_url=$2

    [[ -z "$socks_proxy_url" ]] && socks_proxy_url="127.0.0.1:1080"
    [[ -z "$webservice_url" ]] && webservice_url="www.google.com"

    curl -sSf -I --connect-timeout 3 --max-time 5 \
        --socks5-hostname "${socks_proxy_url}" \
        "${webservice_url}" > /dev/null || exitStatus=$?

    if [ "$exitStatus" -eq "0" ]; then
        return 0
    else
        return 1
    fi
}

## Setting global proxy by clash
function set_global_proxy_by_clash() {
    local PROXY_ADDRESS=$1

    [[ -z "$PROXY_ADDRESS" ]] && PROXY_ADDRESS="127.0.0.1:7891"

    if check_socks5_proxy_up ${PROXY_ADDRESS}; then
        set_proxy "socks5h://${PROXY_ADDRESS}"
        # set_apt_proxy_by_clash
        # set_wget_proxy_by_clash
    else
        clear_proxy
        # rm -f "/etc/apt/apt.conf.d/80proxy"
        # rm -f "$HOME/.wgetrc"
    fi
}

if ! check_webservice_up www.google.com; then
    set_global_proxy_by_clash
fi