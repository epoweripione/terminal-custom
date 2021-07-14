#!/usr/bin/env bash

if [[ $UID -ne 0 ]]; then
    echo "Please run this script as root user!"
    exit 0
fi

trap 'rm -rf "$WORKDIR"' EXIT

[[ -z "$WORKDIR" ]] && WORKDIR="$(mktemp -d)"
[[ -z "$CURRENT_DIR" ]] && CURRENT_DIR=$(pwd)

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

[[ -n "${INSTALLER_CHECK_CURL_OPTION}" ]] && curl_check_opts=(`echo ${INSTALLER_CHECK_CURL_OPTION}`) || curl_check_opts=(-fsL)
[[ -n "${INSTALLER_DOWNLOAD_CURL_OPTION}" ]] && curl_download_opts=(`echo ${INSTALLER_DOWNLOAD_CURL_OPTION}`) || curl_download_opts=(-fSL)

# Use proxy or mirror when some sites were blocked or low speed
set_proxy_mirrors_env

# Get os release name
get_os_release

[[ -z "${OS_INFO_TYPE}" ]] && get_os_type
[[ -z "${OS_INFO_ARCH}" ]] && get_arch

## Docker
colorEcho "${BLUE}Installing ${FUCHSIA}Docker${BLUE}..."
# apt install -y docker-ce
# https://github.com/docker/docker-install
if [[ ! -x "$(command -v docker)" ]]; then
    if [[ -z "$DOCKER_INSTALLER_NOT_USE_MIRROR" ]]; then
        # curl -fsSL https://get.docker.com | bash -s docker --mirror AzureChinaCloud
        curl -fsSL https://get.docker.com -o get-docker.sh && \
            bash get-docker.sh --mirror Aliyun
    else
        curl -fsSL https://get.docker.com -o get-docker.sh && \
            bash get-docker.sh
    fi
fi

if [[ ! -x "$(command -v docker)" ]]; then
    # Oracle Linux、RHEL
    if [[ "$OS_INFO_RELEASE" == "ol" || "$OS_INFO_RELEASE" == "rhel" ]]; then
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
    if [[ "$OS_INFO_RELEASE" == "sles" ]]; then
        zypper in docker && \
            systemctl enable docker && \
            systemctl start docker
    fi
fi

if [[ ! -x "$(command -v docker)" ]]; then
    colorEcho "${FUCHSIA}Docker${RED} is not installed! Please manual install ${FUCHSIA}docker-ce${RED} or ${FUCHSIA}docker-engine${RED}!"
    exit 1
fi


## Docker Compose
if [[ ! -x "$(command -v docker-compose)" ]]; then
    colorEcho "${BLUE}Installing ${FUCHSIA}Docker Compose${BLUE}..."

    CHECK_URL="https://api.github.com/repos/docker/compose/releases/latest"
    REMOTE_VERSION=$(curl "${curl_check_opts[@]}" "${CHECK_URL}" | grep 'tag_name' | cut -d\" -f4)
    if [[ -n "$REMOTE_VERSION" ]]; then
        DOWNLOAD_URL="${GITHUB_DOWNLOAD_URL:-https://github.com}/docker/compose/releases/download/$REMOTE_VERSION/docker-compose-`uname -s`-`uname -m`"

        curl "${curl_download_opts[@]}" -o "${WORKDIR}/docker-compose" "$DOWNLOAD_URL" && \
            mv -f "${WORKDIR}/docker-compose" "/usr/local/bin/docker-compose" && \
            chmod +x "/usr/local/bin/docker-compose"
    fi

    ## Compose V2
    ## https://docs.docker.com/compose/cli-command/#installing-compose-v2
    # curl -fsSL -o docker-compose-v2.sh "https://raw.githubusercontent.com/docker/compose-cli/main/scripts/install/install_linux.sh" && \
    #     bash docker-compose-v2.sh
fi

# Allow your user to access the Docker CLI without needing root.
# sudo usermod -aG docker $USER


## ctop
if [[ ! -x "$(command -v ctop)" ]]; then
    colorEcho "${BLUE}Installing ${FUCHSIA}ctop${BLUE}..."

    CHECK_URL="https://api.github.com/repos/bcicen/ctop/releases/latest"
    REMOTE_VERSION=$(curl "${curl_check_opts[@]}" "${CHECK_URL}" | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if [[ -n "$REMOTE_VERSION" ]]; then
        DOWNLOAD_URL="${GITHUB_DOWNLOAD_URL:-https://github.com}/bcicen/ctop/releases/download/$REMOTE_VERSION/ctop-${REMOTE_VERSION}-${OS_INFO_TYPE}-${OS_INFO_ARCH}"

        curl "${curl_download_opts[@]}" -o "${WORKDIR}/ctop" "$DOWNLOAD_URL" && \
            mv -f "${WORKDIR}/ctop" "/usr/local/bin/ctop" && \
            chmod +x "/usr/local/bin/ctop"
    fi
fi


## lazydocker
## https://github.com/jesseduffield/lazydocker
# docker run --rm -it -v \
#     /var/run/docker.sock:/var/run/docker.sock \
#     -v $HOME/.config/lazydocker:/.config/jesseduffield/lazydocker \
#     lazyteam/lazydocker


## docker mirror in china
if [[ -z "$DOCKER_INSTALLER_NOT_USE_MIRROR" && ! -s "/etc/docker/daemon.json" ]]; then
    tee /etc/docker/daemon.json >/dev/null <<-'EOF'
{
    "registry-mirrors": [
        "https://docker.mirrors.sjtug.sjtu.edu.cn",
        "https://mirror.baidubce.com",
        "https://hub-mirror.c.163.com"
    ]
}
EOF

    systemctl daemon-reload && systemctl restart docker
fi