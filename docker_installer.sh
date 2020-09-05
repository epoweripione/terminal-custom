#!/bin/bash

if [[ $UID -ne 0 ]]; then
    echo "Please run this script as root user!"
    exit 0
fi

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

# Set proxy or mirrors env in china
set_proxy_mirrors_env

# Get os release name
get_os_release


## Docker
colorEcho ${BLUE} "Installing Docker..."
# apt install -y docker-ce
# https://github.com/docker/docker-install
if [[ ! -x "$(command -v docker)" ]]; then
    if [[ -z "$DOCKER_INSTALLER_NOT_USE_MIRROR" ]]; then
        # curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
        curl -fsSL https://get.docker.com -o get-docker.sh && \
            bash get-docker.sh --mirror AzureChinaCloud
    else
        curl -fsSL https://get.docker.com -o get-docker.sh && \
            bash get-docker.sh
    fi
fi

if [[ ! -x "$(command -v docker)" ]]; then
    # Oracle Linux、RHEL
    if [[ "$OS_RELEASE" == "ol" || "$OS_RELEASE" == "rhel" ]]; then
        # yum -y install docker-engine
        # yum -y remove docker docker-common docker-selinux docker-engine docker-cli
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        yum -y install docker-ce && \
            systemctl enable docker && \
            systemctl start docker

        # fix: Error response from daemon: OCI runtime create failed: 
        # ...write /proc/self/attr/keycreate: permission denied
        OS_VERSION_ID=$(grep -E '^VERSION_ID=([a-zA-Z]*)' /etc/os-release \
                        | cut -d'=' -f2 | sed 's/\"//g' | cut -d'.' -f1)
        if [[ "$OS_VERSION_ID" == "7" ]]; then
            yum -y install \
                http://mirror.centos.org/centos/7/extras/x86_64/Packages/container-selinux-2.107-1.el7_6.noarch.rpm
        fi
    fi

    # SUSE Linux Enterprise Server
    if [[ "$OS_RELEASE" == "sles" ]]; then
        zypper in docker && \
            systemctl enable docker && \
            systemctl start docker
    fi
fi

if [[ ! -x "$(command -v docker)" ]]; then
    colorEcho ${RED} "Docker is not installed! Please manual install docker-ce or docker-engine!"
    exit 1
fi


## Docker Compose
if [[ ! -x "$(command -v docker-compose)" ]]; then
    colorEcho ${BLUE} "Installing Docker Compose..."

    CHECK_URL="https://api.github.com/repos/docker/compose/releases/latest"
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4)
    if [[ -n "$REMOTE_VERSION" ]]; then
        DOWNLOAD_URL=https://github.com/docker/compose/releases/download/$REMOTE_VERSION/docker-compose-`uname -s`-`uname -m`
        curl -SL -o /tmp/docker-compose -C- $DOWNLOAD_URL && \
            mv -f /tmp/docker-compose /usr/local/bin/docker-compose && \
            chmod +x /usr/local/bin/docker-compose
    fi
fi

# Allow your user to access the Docker CLI without needing root.
# sudo usermod -aG docker $USER


## ctop
if [[ ! -x "$(command -v ctop)" ]]; then
    colorEcho ${BLUE} "Installing ctop..."
    if uname -m | grep -Eqi "amd64|x86_64"; then
        DOWNLOAD_FILE_SUFFIX='linux-amd64'
    else
        DOWNLOAD_FILE_SUFFIX='linux-386'
    fi

    CHECK_URL="https://api.github.com/repos/bcicen/ctop/releases/latest"
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -c2-)
    if [[ -n "$REMOTE_VERSION" ]]; then
        DOWNLOAD_URL=https://github.com/bcicen/ctop/releases/download/v$REMOTE_VERSION/ctop-${REMOTE_VERSION}-${DOWNLOAD_FILE_SUFFIX}
        curl -SL -o /tmp/ctop -C- $DOWNLOAD_URL && \
            mv -f /tmp/ctop /usr/local/bin/ctop && \
            chmod +x /usr/local/bin/ctop
    fi
fi


## lazydocker
# https://github.com/jesseduffield/lazydocker
# https://github.com/jesseduffield/lazydocker/blob/master/docs/keybindings/Keybindings_en.md
# if [[ ! -x "$(command -v lazydocker)" ]]; then
#     colorEcho ${BLUE} "Installing lazydocker..."
#     if uname -m | grep -Eqi "amd64|x86_64"; then
#         DOWNLOAD_FILE_SUFFIX='Linux_x86_64.tar.gz'
#     else
#         DOWNLOAD_FILE_SUFFIX='Linux_32-bit.tar.gz'
#     fi

#     CHECK_URL="https://api.github.com/repos/jesseduffield/lazydocker/releases/latest"
#     REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -c2-)
#     if [[ -n "$REMOTE_VERSION" ]]; then
#         DOWNLOAD_URL=https://github.com/jesseduffield/lazydocker/releases/download/v$REMOTE_VERSION/lazydocker_${REMOTE_VERSION}_${DOWNLOAD_FILE_SUFFIX}
#         curl -SL $DOWNLOAD_URL -o /tmp/lazydocker.tar.gz && \
#             mkdir -p /tmp/lazydocker && \
#             tar -zxPf /tmp/lazydocker.tar.gz -C /tmp/lazydocker && \
#             mv -f /tmp/lazydocker/lazydocker /usr/local/bin/lazydocker && \
#             chmod +x /usr/local/bin/lazydocker && \
#             rm -f /tmp/lazydocker.tar.gz && \
#             rm -rf /tmp/lazydocker
#     fi
# fi


## docker mirror in china
if [[ -z "$DOCKER_INSTALLER_NOT_USE_MIRROR" ]]; then
    tee /etc/docker/daemon.json <<-'EOF'
{
    "registry-mirrors": [
        "https://docker.mirrors.sjtug.sjtu.edu.cn",
        "https://reg-mirror.qiniu.com",
        "http://7924d745.m.daocloud.io",
        "http://hub-mirror.c.163.com",
        "https://mirror.ccs.tencentyun.com"
    ]
}
EOF

    systemctl daemon-reload && systemctl restart docker
fi