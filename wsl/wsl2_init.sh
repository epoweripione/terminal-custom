#!/usr/bin/env bash

## https://docs.microsoft.com/zh-cn/windows/wsl/
## https://docs.microsoft.com/zh-cn/windows/wsl/install-win10
## https://docs.microsoft.com/zh-cn/windows/wsl/wsl-config
## Please make sure that virtualization is enabled inside BIOS
## 1. run PowerShell as Admin
# Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
# Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
## or:
# dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
# dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
## 2. restart computer
## 3. make WSL 2 as default architecture
# wsl --set-default-version 2
## 4. install distro from Microsoft Store (https://aka.ms/wslstore)
## 5. list installed distro
# wsl -l
## 6. set a distro to be backed by WSL 2
# wsl --set-version Debian 2
## 5. verify what versions of WSL each distro is using
# wsl -l -v
## set default distro
# wsl --set-default Debian
## restart wsl in PowerShell
# Restart-Service -Name LxssManager
# net stop "LxssManager"; net start "LxssManager"

## Sharing your WSL2 environment with Linux
## https://www.nmelnick.com/2020/07/sharing-your-wsl2-environment-with-linux/
# sudo apt install -y libguestfs-tools
# sudo yum install -y libguestfs libguestfs-tools
## `WSL2` also need a kernel
# sudo apt install -y linux-image-generic
## Virtual machine disk image file:
## Ubuntu distro: /mnt/c/Users/<username>/AppData/Local/Packages/CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc/LocalState/ext4.vhdx
## Debian distro: /mnt/c/Users/<username>/AppData/Local/Packages/TheDebianProject.DebianGNULinux_76v4gfsz19hv4/LocalState/ext4.vhdx
## list distro filesystems
# sudo virt-filesystems -a <image file>
## mount Debian distro
# sudo mkdir -p /mnt/wslDebian
# sudo guestmount -o allow_other \
#     -a /mnt/c/Users/<username>/AppData/Local/Packages/TheDebianProject.DebianGNULinux_76v4gfsz19hv4/LocalState/ext4.vhdx \
#     -i /mnt/wslDebian
## unmount Debian distro
# sudo guestunmount /mnt/wslDebian


[[ -z "$MY_SHELL_SCRIPTS" ]] && MY_SHELL_SCRIPTS="$HOME/terminal-custom"

# Load custom functions
if type 'colorEcho' 2>/dev/null | grep -q 'function'; then
    :
else
    if [[ -s "${MY_SHELL_SCRIPTS}/custom_functions.sh" ]]; then
        source "${MY_SHELL_SCRIPTS}/custom_functions.sh"
    else
        echo "${MY_SHELL_SCRIPTS}/custom_functions.sh not exist!"
        exit 0
    fi
fi

[[ -n "${INSTALLER_CHECK_CURL_OPTION}" ]] && curl_check_opts=(`echo ${INSTALLER_CHECK_CURL_OPTION}`) || curl_check_opts=(-fsL)
[[ -n "${INSTALLER_DOWNLOAD_CURL_OPTION}" ]] && curl_download_opts=(`echo ${INSTALLER_DOWNLOAD_CURL_OPTION}`) || curl_download_opts=(-fSL)

# Use proxy or mirror when some sites were blocked or low speed
set_proxy_mirrors_env

# Check & set global proxy
[[ -z "$GITHUB_NOT_USE_PROXY" ]] && check_set_global_proxy 7891 7890


[[ $(uname -r) =~ "Microsoft" ]] && WSL_VERSION=1
[[ $(uname -r) =~ "microsoft" ]] && WSL_VERSION=2
if [[ -z "$WSL_VERSION" ]]; then
    colorEcho "${RED}Please run this script in ${FUCHSIA}WSL(Windows Subsystem for Linux)${RED}!"
    exit 0
fi


# Custom WSL settings
colorEcho "${BLUE}Custom WSL settings..."
# make drives mounted at /c or /e instead of /mnt/c and /mnt/e.
if [[ ! $(grep -q "automount" /etc/wsl.conf) ]]; then
    sudo tee /etc/wsl.conf >/dev/null <<-'EOF'
[automount]
enabled = true
root = /
options = "metadata,umask=22,fmask=11"
mountFsTab = false
EOF
fi

# colorEcho "${BLUE}map localhost to \`vEthernet (WSL)\` ip${BLUE}..."
# source "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/wsl/wsl2-map-win-localhost.sh"


# Install packages
colorEcho "${BLUE}Installing ${FUCHSIA}pre-requisite packages${BLUE}..."
sudo apt update && \
    sudo apt install -y apt-transport-https apt-utils ca-certificates \
        lsb-release software-properties-common curl wget

# Use apt mirror & Install pre-requisite packages
if [[ -z "$APT_NOT_USE_MIRRORS" ]]; then
    colorEcho "${BLUE}Setting apt mirror..."
    # mirrors.tuna.tsinghua.edu.cn
    # mirrors.ustc.edu.cn
    APT_MIRROR_URL="mirrors.sjtug.sjtu.edu.cn"
    sudo sed -i \
        -e "s|ftp.debian.org|${APT_MIRROR_URL}|g" \
        -e "s|deb.debian.org|${APT_MIRROR_URL}|g" \
        -e "s|security.debian.org|${APT_MIRROR_URL}|g" /etc/apt/sources.list
fi

# Add custom repositories
colorEcho "${BLUE}Add ${FUCHSIA}custom repositories${BLUE}..."
if [[ -z "$APT_NOT_USE_MIRRORS" ]]; then
    # Use https mirror
    sudo sed -i "s|http://${APT_MIRROR_URL}|https://${APT_MIRROR_URL}|g" /etc/apt/sources.list
fi

## git lfs
## https://github.com/git-lfs/git-lfs/wiki/Tutorial
# if [[ ! -e "/etc/apt/sources.list.d/github_git-lfs.list" ]]; then
#     curl -fsSL "https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh" | sudo bash

#     # echo 'Acquire::http::Proxy::packagecloud-repositories.s3.dualstack.us-west-1.amazonaws.com "http://127.0.0.1:7890/";' \
#     #     | sudo tee -a /etc/apt/apt.conf.d/99proxy >/dev/null
# fi

# .NET Core SDK
# https://docs.microsoft.com/zh-cn/dotnet/core/install/linux-package-manager-debian10
if [[ ! -e "/etc/apt/sources.list.d/microsoft-prod.list" ]]; then
    curl "${curl_download_opts[@]}" -o packages-microsoft-prod.deb "https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb" && \
        sudo dpkg -i packages-microsoft-prod.deb && \
        rm packages-microsoft-prod.deb

    # echo 'Acquire::http::Proxy::packages.microsoft.com "http://127.0.0.1:7890/";' \
    #     | sudo tee -a /etc/apt/apt.conf.d/99proxy >/dev/null
fi

## yarn
## https://yarnpkg.com/zh-Hans/docs/install
# if [[ ! -e "/etc/apt/sources.list.d/yarn.list" ]]; then
#     curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
#     echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
# fi


# Update all repositories & Upgrade
colorEcho "${BLUE}Updating ${FUCHSIA}all repositories & Upgrade${BLUE}..."
sudo apt update && sudo apt upgrade -y


# Install useful packages
colorEcho "${BLUE}Installing ${FUCHSIA}useful packages${BLUE}..."
sudo apt install -y binutils build-essential di dnsutils g++ gcc \
    git htop iproute2 make net-tools netcat-openbsd p7zip psmisc tree unzip zip


# python3
sudo apt install -y python3

# pip
sudo apt install -y build-essential pkg-config python3-dev python3-distutils \
    libssl-dev libcurl4-openssl-dev libcairo2-dev libjpeg-dev libgif-dev libgirepository1.0-dev

# https://pip.pypa.io/en/stable/installing/
curl "https://bootstrap.pypa.io/get-pip.py" -o get-pip.py && \
    noproxy_cmd python3 get-pip.py && \
    rm get-pip.py

# fix: ERROR: Could not install packages due to an OSError: Missing dependencies for SOCKS support.
noproxy_cmd python3 -m pip install --user -U pysocks

# noproxy_cmd python3 -m pip install --user -U pip
# noproxy_cmd python3 -m pip install --user -U setuptools wheel

# pip list -o | grep -Ev "^-|^Package" | cut -d" " -f1 | xargs -n1 pip install -U


# Parallel SSH Tools
# https://github.com/lilydjwg/pssh
# https://www.escapelife.site/posts/8c0f83d.html
python3 -m pip install --user git+https://github.com/lilydjwg/pssh

## Login with SSH Key
# pssh -i -H "host01 host02" -l root \
#     -x "-o StrictHostKeyChecking=no -i $HOME/.ssh/id_ecdsa" \
#     "hostname -i && uname -a"
## Login with Passphrase Protected SSH Key ( all hosts in ~/.ssh/config )
# pssh -i -H "host01 host02" -A -l root "hostname -i && uname -a"


## Enable broadcast WINS
# colorEcho "${BLUE}Enable broadcast ${FUCHSIA}WINS${BLUE}..."
# sudo apt install -y libnss-winbind
# if [[ ! $(grep "wins" /etc/nsswitch.conf) ]]; then
#     sudo sed -i 's/dns/wins dns/' /etc/nsswitch.conf
# fi
# sudo service winbind start # /etc/init.d/winbind start


# fix ping: socket: Operation not permitted
sudo chmod u+s /bin/ping


## wslu
## https://github.com/wslutilities/wslu
sudo apt install -y gnupg2 apt-transport-https && \
    wget -O - https://access.patrickwu.space/wslu/public.asc | sudo apt-key add - && \
    echo "deb https://access.patrickwu.space/wslu/debian buster main" | sudo tee -a /etc/apt/sources.list && \
    sudo apt update && \
    sudo apt install -y wslu

## translate from a Windows path to a WSL path
# wslpath 'c:\users'


# colorEcho "${BLUE}Install git lfs${BLUE}..."
# sudo apt install -y git-lfs && git lfs install

[[ -s "${MY_SHELL_SCRIPTS}/installer/git-lfs_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/git-lfs_installer.sh"

[[ -s "${MY_SHELL_SCRIPTS}/installer/gitflow_installer.sh" ]] && source "${MY_SHELL_SCRIPTS}/installer/gitflow_installer.sh"

# colorEcho "${BLUE}Installing ${FUCHSIA}.NET Core SDK${BLUE}..."
# sudo apt install -y dotnet-sdk-3.1

# colorEcho "${BLUE}Installing ${FUCHSIA}yarn${BLUE}..."
# sudo apt install -y yarn --no-install-recommends


# SSH
if [[ ! -d "$HOME/.ssh" ]]; then
    mkdir -p $HOME/.ssh && chmod -R 700 $HOME/.ssh/ # && chmod 600 $HOME/.ssh/*
fi


# Change default editor to nano
if [[ -x "$(command -v nano)" ]]; then
    sudo update-alternatives --install /usr/bin/editor editor $(which nano) 100
    # sudo update-alternatives --config editor
fi


# Allow members of the group sudo to execute any command without password prompt
# sudo visudo OR sudo EDITOR=nano visudo
# sudo sed -i 's/%sudo.*/%sudo   ALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers
CommandList=(
    service
    apt
    apt-get
    pacman
    pacapt
    pacaptr
)
for TargetCommand in "${CommandList[@]}"; do
    [[ -x "$(command -v ${TargetCommand})" ]] && \
    echo "%sudo ALL=NOPASSWD:$(which ${TargetCommand})" | sudo tee "/etc/sudoers.d/nopasswd_sudo_command_${TargetCommand}" >/dev/null
done


# Clear bash history
cat /dev/null > "$HOME/.bash_history"


colorEcho "${GREEN}WSL init done, please restart WSL!"