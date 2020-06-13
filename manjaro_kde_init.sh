#!/bin/bash

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

# Local WAN IP
if [[ -z "$WAN_NET_IP" ]]; then
    get_network_wan_ipv4
    get_network_wan_geo
fi

if [[ "${WAN_NET_IP_GEO}" =~ 'China' || "${WAN_NET_IP_GEO}" =~ 'CN' ]]; then
    IP_GEO_IN_CHINA="yes"
    Download_Install_Subconverter_Clash
fi

CURRENT_DIR=$(pwd)

# pacman
# Generate custom mirrorlist
if [[ "$IP_GEO_IN_CHINA" == "yes" ]]; then
    sudo pacman-mirrors -i -c China -m rank
fi

# Show colorful output on the terminal
sudo sed -i 's|^#Color|Color|' /etc/pacman.conf

# Do full system update
sudo pacman -Syyu

# Virtualbox
# https://forum.manjaro.org/t/howto-virtualbox-installation-usb-shared-folders/55905
# MANJARO GUEST installation
# Before installation ensure you are using VBoxSVGA graphics
# run `mhwd` to check that it’s using video-virtualbox
# mhwd -li && mhwd-kernel -li
sudo pacman -S virtualbox-guest-utils \
    linux$(uname -r|cut -d'.' -f1-2|sed 's/\.//')-virtualbox-guest-modules
# MANJARO GUEST Configuration
sudo gpasswd -a $USER vboxsf
sudo systemctl enable --now vboxservice
# LINUX Shared folders
# Host Configuration: On the host locate the Settings section in VirtualBox GUI,
# Make the folders Permanent and Automount
tee -a "$HOME/vboxmount.sh" >/dev/null <<-'EOF'
#!/bin/sh
#-----------------------------------------------------------------------------
# Discover VirtualBox shared folders and mount them if it makes sense
# Folders with the same name must exist in the $USER home folder
#-----------------------------------------------------------------------------
if ! type VBoxControl > /dev/null; then
    echo "VirtualBox Guest Additions NOT found" > /dev/stderr
    exit 1
fi

MY_UID="$(id -u)"
MY_GID="$(id -g)"

( set -x; sudo VBoxControl sharedfolder list; )  |  \
    grep      '^ *[0-9][0-9]* *- *'              |  \
    sed  -e 's/^ *[0-9][0-9]* *- *//'            |  \
    while read SHARED_FOLDER; do
        MOUNT_POINT="$HOME/$SHARED_FOLDER"
        if [ -d "$MOUNT_POINT" ]; then
            MOUNTED="$(mount | grep "$MOUNT_POINT")"
            if [ "$MOUNTED" ]; then
                echo "Already mounted :  $MOUNTED"
            else
            (
                set -x
                sudo mount -t vboxsf -o \
                    "nosuid,uid=$MY_UID,gid=$MY_GID" \
                    "$SHARED_FOLDER" "$MOUNT_POINT"
            )
            fi
        fi
    done
EOF

chmod +x "$HOME/vboxmount.sh"
Install_systemd_Service "vboxmount" "$HOME/vboxmount.sh"
