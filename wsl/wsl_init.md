# Install WSL
https://docs.microsoft.com/zh-cn/windows/wsl/install-win10

# Install Linux Distribution
Install **Debian** from **Microsoft Store**

# Update & Upgrade
```
sed -i 's|deb.debian.org|mirrors.ustc.edu.cn|g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org|mirrors.ustc.edu.cn|g' /etc/apt/sources.list

apt update && apt install -y dialog apt-utils apt-transport-https

sed -i 's|http://mirrors.ustc.edu.cn|https://mirrors.ustc.edu.cn|g' /etc/apt/sources.list

apt update && apt upgrade -y
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
```
apt update && apt upgrade -y
apt install -y build-essential curl di dnsutils git htop iproute2 lrzsz nano net-tools p7zip psmisc unzip
```

# Install python3
```
# add testing repo
echo "deb https://mirrors.ustc.edu.cn/debian/ testing main" >> /etc/apt/sources.list && \
    echo 'APT::Default-Release "stable";' | sudo tee -a /etc/apt/apt.conf.d/00local

# install python3.6, pip3
apt update && apt install -y -t testing python3.6 python3-pip

# fix pip list warning
mkdir -p ~/.pip && \
cat >> ~/.pip/pip.conf <EOF
[global]
format=columns
EOF

# fix TypeError: '>' not supported between instances of 'Version' and 'Version'
pip3 install --ignore-installed pip

# upgrade outdated packages
pip3 list -o | grep -E -v '^-|^Package' | cut -d ' ' -f 1 | xargs -n1 pip3 install -U

# fix some package install error: 
# It is a distutils installed project and thus we cannot accurately determine which files belong to it which would lead to only a partial uninstall
# pip install -I <package name>==<latest version>
# example: pip install -I pyxdg==0.26
```

# Install Anaconda
1. Download Anaconda from https://www.anaconda.com/download/#linux
`curl -SL -O https://repo.anaconda.com/archive/Anaconda3-5.2.0-Linux-x86_64.sh`

2. Install
`bash Anaconda3-5.2.0-Linux-x86_64.sh`

3. zsh: add Anaconda to PATH
`echo -e "\nexport PATH=\"/root/anaconda3/bin:\$PATH\"" >> ~/.zshrc`

4. conda repo mirrors in china
```
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/free/ && \
    conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/main/ && \
    conda config --set show_channel_urls yes

# extra repo
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/conda-forge/ && \
    conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/msys2/ && \
    conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/bioconda/ && \
    conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/menpo/
```

# Install Miniconda
1. Download Anaconda from https://www.anaconda.com/download/#linux
`curl -SL -O https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh`

2. Install
`bash Miniconda3-latest-Linux-x86_64.sh`

3. zsh: add Miniconda to PATH
`echo -e "\nexport PATH=\"/root/miniconda3/bin:\$PATH\"" >> ~/.zshrc`

4. conda repo mirrors in china
```
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/free/ && \
    conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/main/ && \
    conda config --set show_channel_urls yes

# extra repo
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/conda-forge/ && \
    conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/msys2/ && \
    conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/bioconda/ && \
    conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/menpo/
```
