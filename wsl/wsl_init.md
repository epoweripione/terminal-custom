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

**or**  
```
tee -a ~/.bashrc <<-'EOF'

# Launch Zsh 
if [ -t 1 ]; then 
exec zsh 
fi
EOF
```

# Install custom packages
apt update && apt upgrade -y
apt install -y build-essential curl di dnsutils git htop iproute2 lrzsz nano net-tools p7zip psmisc unzip

# Install python3
```
echo "deb https://mirrors.ustc.edu.cn/debian/ testing main" >> /etc/apt/sources.list
echo 'APT::Default-Release "stable";' | sudo tee -a /etc/apt/apt.conf.d/00local
apt update && apt install -y -t testing python3.6 python-pip
```

# Install Anaconda
1. Download Anaconda from https://www.anaconda.com/download/#linux
2. Install from local dir
```
cd /mnt/d/Downloads
bash Anaconda3-5.2.0-Linux-x86_64.sh
```
