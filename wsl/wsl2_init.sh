#!/usr/bin/env bash

# https://docs.microsoft.com/zh-cn/windows/wsl/wsl2-index
# https://docs.microsoft.com/zh-cn/windows/wsl/wsl2-install
# Please make sure that virtualization is enabled inside BIOS
# 1. run PowerShell as Admin
# Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
# Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
# 2. restart computer
# 3. make WSL 2 as default architecture
# wsl --set-default-version 2
# 4. install distro from Microsoft Store (https://docs.microsoft.com/en-us/windows/wsl/install-win10)
# 5. list installed distro
# wsl -l
# 6. set a distro to be backed by WSL 2
# wsl --set-version debian 2
# 5. verify what versions of WSL each distro is using
# wsl -l -v
# restart wsl in PowerShell
# Restart-Service -Name LxssManager
# net stop "LxssManager"; net start "LxssManager"


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

# Use proxy or mirror when some sites were blocked or low speed
set_proxy_mirrors_env


[[ $(uname -r) =~ "Microsoft" ]] && WSL_VERSION=1
[[ $(uname -r) =~ "microsoft" ]] && WSL_VERSION=2
if [[ -z "$WSL_VERSION" ]]; then
    colorEcho ${RED} "Please run this script in WSL(Windows Subsystem for Linux)!"
    exit 0
fi


# Custom WSL settings
colorEcho ${BLUE} "Custom WSL settings..."
# make drives mounted at /c or /e instead of /mnt/c and /mnt/e.
if [[ ! $(grep "automount" /etc/wsl.conf) ]]; then
    sudo tee /etc/wsl.conf >/dev/null <<-'EOF'
[automount]
enabled = true
root = /
options = "metadata,umask=22,fmask=11"
mountFsTab = false
EOF
fi


# Install packages
# Use USTC mirror & Install pre-requisite packages
if [[ -z "$APT_NOT_USE_MIRRORS" ]]; then
    colorEcho ${BLUE} "Setting apt mirror..."
    sudo sed -i \
        -e 's|ftp.debian.org|mirrors.tuna.tsinghua.edu.cn|g' \
        -e 's|deb.debian.org|mirrors.tuna.tsinghua.edu.cn|g' \
        -e's|security.debian.org|mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list
fi

colorEcho ${BLUE} "Installing pre-requisite packages..."
sudo apt update && \
    sudo apt install -y apt-transport-https apt-utils ca-certificates \
        lsb-release software-properties-common curl wget


# Add custom repositories
colorEcho ${BLUE} "Add custom repositories..."
if [[ -z "$APT_NOT_USE_MIRRORS" ]]; then
    # Use https mirror
    sudo sed -i 's|http://mirrors.tuna.tsinghua.edu.cn|https://mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list
fi

# git lfs
# https://github.com/git-lfs/git-lfs/wiki/Tutorial
if [[ ! -e "/etc/apt/sources.list.d/github_git-lfs.list" ]]; then
    curl -fsSL "https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh" | sudo bash

    # echo 'Acquire::http::Proxy::packagecloud-repositories.s3.dualstack.us-west-1.amazonaws.com "http://127.0.0.1:7890/";' \
    #     | sudo tee -a /etc/apt/apt.conf.d/99proxy >/dev/null
fi

# .NET Core SDK
# https://docs.microsoft.com/zh-cn/dotnet/core/install/linux-package-manager-debian10
if [[ ! -e "/etc/apt/sources.list.d/microsoft-prod.list" ]]; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.asc.gpg
    sudo mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/
    wget -q https://packages.microsoft.com/config/debian/10/prod.list
    sudo mv prod.list /etc/apt/sources.list.d/microsoft-prod.list
    sudo chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg
    sudo chown root:root /etc/apt/sources.list.d/microsoft-prod.list

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
colorEcho ${BLUE} "Update all repositories & Upgrade..."
sudo apt update && sudo apt upgrade -y


# Install useful packages
colorEcho ${BLUE} "Install useful packages..."
sudo apt install -y binutils build-essential di dnsutils g++ gcc \
    git htop iproute2 make net-tools p7zip psmisc tree unzip zip


# Enable broadcast WINS
colorEcho ${BLUE} "Enable broadcast WINS..."
sudo apt install -y libnss-winbind

if [[ ! $(grep "wins" /etc/nsswitch.conf) ]]; then
    sudo sed -i 's/dns/wins dns/' /etc/nsswitch.conf
fi
# sudo service winbind start # /etc/init.d/winbind start


# fix ping: socket: Operation not permitted
sudo chmod u+s /bin/ping


## wslu
## https://github.com/wslutilities/wslu
# colorEcho ${BLUE} "Install git wslu..."
# curl -fsSL "https://packagecloud.io/install/repositories/whitewaterfoundry/wslu/script.deb.sh" \
#         | sudo bash && \
#     sudo apt install -y wslu

colorEcho ${BLUE} "Install git lfs..."
sudo apt install -y git-lfs && git lfs install

# colorEcho ${BLUE} "Installing .NET Core SDK..."
# sudo apt install -y dotnet-sdk-3.1

# colorEcho ${BLUE} "Installing yarn..."
# sudo apt install -y yarn --no-install-recommends


# SSH
if [[ ! -d "$HOME/.ssh" ]]; then
    mkdir -p $HOME/.ssh && chmod 700 $HOME/.ssh/ # && chmod 600 $HOME/.ssh/*
fi


# Change default editor to nano
if [[ -x "$(command -v nano)" ]]; then
    sudo update-alternatives --install /usr/bin/editor editor $(which nano) 100
    # sudo update-alternatives --config editor
fi


# Allow members of the group sudo to execute any command without password prompt
# sudo visudo OR sudo EDITOR=nano visudo
# sudo sed -i 's/%sudo.*/%sudo   ALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers
[[ -x "$(command -v service)" ]] && \
    echo "%sudo ALL=NOPASSWD:$(which service)" | sudo tee -a /etc/sudoers >/dev/null

[[ -x "$(command -v apt-get)" ]] && \
    echo "%sudo ALL=NOPASSWD:$(which apt-get)" | sudo tee -a /etc/sudoers >/dev/null

[[ -x "$(command -v pacman)" ]] && \
    echo "%sudo ALL=NOPASSWD:$(which pacman)" | sudo tee -a /etc/sudoers >/dev/null

[[ -x "$(command -v pacapt)" ]] && \
    echo "%sudo ALL=NOPASSWD:$(which pacapt)" | sudo tee -a /etc/sudoers >/dev/null


colorEcho ${GREEN} "WSL init done, please restart WSL!"