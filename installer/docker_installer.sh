#!/usr/bin/env bash

# if [[ $UID -ne 0 ]]; then
#     echo "Please run this script as root user!"
#     exit 0
# fi

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

[[ -z "${OS_INFO_TYPE}" ]] && get_os_type
[[ -z "${OS_INFO_ARCH}" ]] && get_arch
[[ -z "${OS_INFO_RELEASE}" ]] && get_os_release

## Docker
# https://github.com/docker/docker-install
if [[ ! -x "$(command -v docker)" ]]; then
    colorEcho "${BLUE}Installing ${FUCHSIA}Docker${BLUE}..."
    if [[ -z "$DOCKER_INSTALLER_NOT_USE_MIRROR" ]]; then
        # curl -fsSL https://get.docker.com | bash -s docker --mirror AzureChinaCloud
        curl -fsSL https://get.docker.com -o "${WORKDIR}/get-docker.sh" && \
            sudo bash "${WORKDIR}/get-docker.sh" --mirror Aliyun
    else
        curl -fsSL https://get.docker.com -o "${WORKDIR}/get-docker.sh" && \
            sudo bash "${WORKDIR}/get-docker.sh"
    fi
fi

if [[ ! -x "$(command -v docker)" ]]; then
    # Oracle Linux、RHEL
    if [[ "$OS_INFO_RELEASE" == "ol" || "$OS_INFO_RELEASE" == "rhel" ]]; then
        # sudo yum -y install docker-engine
        # sudo yum -y remove docker docker-common docker-selinux docker-engine docker-cli
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum -y install docker-ce && \
            sudo systemctl enable docker && \
            sudo systemctl start docker

        # fix: Error response from daemon: OCI runtime create failed: 
        # ...write /proc/self/attr/keycreate: permission denied
        OS_VERSION_ID=$(grep -E '^VERSION_ID=([a-zA-Z]*)' /etc/os-release \
                        | cut -d'=' -f2 | sed 's/\"//g' | cut -d'.' -f1)
        if [[ "$OS_VERSION_ID" == "7" ]]; then
            sudo yum -y install \
                http://mirror.centos.org/centos/7/extras/x86_64/Packages/container-selinux-2.107-1.el7_6.noarch.rpm
        fi
    fi

    # SUSE Linux Enterprise Server
    if [[ "$OS_INFO_RELEASE" == "sles" ]]; then
        sudo zypper in docker && \
            sudo systemctl enable docker && \
            sudo systemctl start docker
    fi
fi

if [[ ! -x "$(command -v docker)" ]]; then
    colorEcho "${FUCHSIA}Docker${RED} is not installed! Please manual install ${FUCHSIA}docker-ce${RED} or ${FUCHSIA}docker-engine${RED}!"
    exit 1
fi


## Docker Compose
IS_INSTALL="yes"
CURRENT_VERSION="0.0.0"

if [[ -x "$(command -v docker-compose)" ]]; then
    CURRENT_VERSION=$(docker-compose -v 2>&1 | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
fi

colorEcho "${BLUE}Checking latest version for ${FUCHSIA}docker-compose${BLUE}..."
CHECK_URL="https://api.github.com/repos/docker/compose/releases/latest"
REMOTE_VERSION=$(curl "${curl_check_opts[@]}" "${CHECK_URL}" | grep 'tag_name' | cut -d\" -f4)
if version_le $REMOTE_VERSION $CURRENT_VERSION; then
    IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}  Installing ${FUCHSIA}docker-compose ${YELLOW}${REMOTE_VERSION}${BLUE}..."

    DOWNLOAD_FILENAME="${WORKDIR}/docker-compose"
    DOWNLOAD_URL="${GITHUB_DOWNLOAD_URL:-https://github.com}/docker/compose/releases/download/$REMOTE_VERSION/docker-compose-`uname -s`-`uname -m`"
    curl "${curl_download_opts[@]}" -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}"

    curl_download_status=$?
    if [[ ${curl_download_status} -gt 0 && -n "${GITHUB_DOWNLOAD_URL}" ]]; then
        DOWNLOAD_URL=$(echo "${DOWNLOAD_URL}" | sed "s|${GITHUB_DOWNLOAD_URL}|https://github.com|")
        curl "${curl_download_opts[@]}" -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}"
        curl_download_status=$?
    fi

    if [[ ${curl_download_status} -eq 0 ]]; then
        mv -f "${DOWNLOAD_FILENAME}" "/usr/local/bin/docker-compose" && \
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
IS_INSTALL="yes"
CURRENT_VERSION="0.0.0"

if [[ -x "$(command -v ctop)" ]]; then
    CURRENT_VERSION=$(ctop -v 2>&1 | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
fi

colorEcho "${BLUE}Checking latest version for ${FUCHSIA}ctop${BLUE}..."
CHECK_URL="https://api.github.com/repos/bcicen/ctop/releases/latest"
REMOTE_VERSION=$(curl "${curl_check_opts[@]}" "${CHECK_URL}" | grep 'tag_name' | cut -d\" -f4)
if version_le $REMOTE_VERSION $CURRENT_VERSION; then
    IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}  Installing ${FUCHSIA}ctop ${YELLOW}${REMOTE_VERSION}${BLUE}..."

    DOWNLOAD_FILENAME="${WORKDIR}/ctop"
    DOWNLOAD_URL="${GITHUB_DOWNLOAD_URL:-https://github.com}/bcicen/ctop/releases/download/$REMOTE_VERSION/ctop-${REMOTE_VERSION}-${OS_INFO_TYPE}-${OS_INFO_ARCH}"
    curl "${curl_download_opts[@]}" -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}"

    curl_download_status=$?
    if [[ ${curl_download_status} -gt 0 && -n "${GITHUB_DOWNLOAD_URL}" ]]; then
        DOWNLOAD_URL=$(echo "${DOWNLOAD_URL}" | sed "s|${GITHUB_DOWNLOAD_URL}|https://github.com|")
        curl "${curl_download_opts[@]}" -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}"
        curl_download_status=$?
    fi

    if [[ ${curl_download_status} -eq 0 ]]; then
        mv -f "${DOWNLOAD_FILENAME}" "/usr/local/bin/ctop" && \
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


cd "${CURRENT_DIR}"