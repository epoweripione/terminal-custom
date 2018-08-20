# Install WSL
https://docs.microsoft.com/zh-cn/windows/wsl/install-win10

# Install Linux Distribution
Install Debian from Microsoft Store

# Update & Install Package
```
sed -i 's|deb.debian.org|mirrors.ustc.edu.cn|g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org|mirrors.ustc.edu.cn|g' /etc/apt/sources.list

apt update && apt install -y dialog apt-utils apt-transport-https

sed -i 's|http://mirrors.ustc.edu.cn|https://mirrors.ustc.edu.cn|g' /etc/apt/sources.list

apt update && \
apt install -y net-tools dnsutils curl iproute2 lrzsz nano htop iotop git unzip p7zip psmisc di python3 python3-pip
```

# ZSH
## Install zsh
`apt install -y zsh`

## Install oh-my-zsh
`sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"`

## Run zsh as default shell
`chsh -s $(which zsh)`
