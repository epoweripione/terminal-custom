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


if [[ ! -x "$(command -v pacaptr)" ]]; then
    [[ -s "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/installer/pacaptr_installer.sh" ]] && \
        source "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/installer/pacaptr_installer.sh"
fi


# dnsmasq
if pacman -Si dnsmasq >/dev/null 2>&1; then
    sudo pacman -S --noconfirm dnsmasq
fi

# /etc/dnsmasq.conf
sudo tee -a /etc/dnsmasq.conf >/dev/null <<-'EOF'

port=53
resolv-file=/etc/resolv.dnsmasq.conf
conf-dir=/etc/dnsmasq.d
cache-size=200

# no-resolv
# server=8.8.8.8
# server=1.0.0.1
# server=8.8.4.4
# server=1.1.1.1
# server=208.67.222.222
# server=2620:0:ccc::2
# server=2001:4860:4860::8888
# all-servers

listen-address=127.0.0.1,::1
EOF

# /etc/resolv.dnsmasq.conf
sudo tee /etc/resolv.dnsmasq.conf >/dev/null <<-'EOF'
nameserver 8.8.8.8
nameserver 1.0.0.1
EOF

mkdir /etc/dnsmasq.d

# https://github.com/felixonmars/dnsmasq-china-list
[[ -z "$WORKDIR" ]] && WORKDIR="$(mktemp -d)"
# SERVERS=(114.114.114.114 114.114.115.115 180.76.76.76)
# Not using best possible CDN pop: 1.2.4.8 210.2.4.8 223.5.5.5 223.6.6.6
# Dirty cache: 119.29.29.29 182.254.116.116

CONF_WITH_SERVERS=(accelerated-domains.china google.china apple.china)
CONF_SIMPLE=(bogus-nxdomain.china)

echo "Downloading latest configurations..."
git clone --depth=1 https://gitee.com/felixonmars/dnsmasq-china-list.git "$WORKDIR"

echo "Removing old configurations..."
for _conf in "${CONF_WITH_SERVERS[@]}" "${CONF_SIMPLE[@]}"; do
    rm -f /etc/dnsmasq.d/"$_conf"*.conf
done

echo "Installing new configurations..."
for _conf in "${CONF_SIMPLE[@]}"; do
    cp "$WORKDIR/$_conf.conf" "/etc/dnsmasq.d/$_conf.conf"
done

for _server in "${SERVERS[@]}"; do
    for _conf in "${CONF_WITH_SERVERS[@]}"; do
        cp "$WORKDIR/$_conf.conf" "/etc/dnsmasq.d/$_conf.$_server.conf"
    done

    sed -i "s|^\(server.*\)/[^/]*$|\1/$_server|" /etc/dnsmasq.d/*."$_server".conf
done

echo "Restarting dnsmasq service..."
if hash systemctl 2>/dev/null; then
    systemctl restart dnsmasq
elif hash service 2>/dev/null; then
    service dnsmasq restart
elif hash rc-service 2>/dev/null; then
    rc-service dnsmasq restart
else
    echo "Now please restart dnsmasq since I don't know how to do it."
fi

echo "Cleaning up..."
rm -rf "$WORKDIR"

# systemctl enable dnsmasq && systemctl restart dnsmasq
