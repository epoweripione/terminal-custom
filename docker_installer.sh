#!/bin/bash

if [[ $UID -ne 0 ]]; then
    echo "Please run this script as root user!"
    exit 0
fi

# Load custom functions
if type 'colorEcho' 2>/dev/null | grep -q 'function'; then
    :
else
    if [[ -e "$HOME/custom_functions.sh" ]]; then
        source "$HOME/custom_functions.sh"
    else
        echo "$HOME/custom_functions.sh not exist!"
        exit 0
    fi
fi

# Set proxy or mirrors env in china
set_proxy_mirrors_env


# Docker
colorEcho ${BLUE} "Installing Docker..."
# apt install -y docker-ce
# https://github.com/docker/docker-install
if [[ -z "$DOCKER_INSTALLER_NOT_USE_MIRROR" ]]; then
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
else
    curl -fsSL https://get.docker.com | bash -s docker
fi


## Docker Compose
if [[ ! -x "$(command -v docker-compose)" ]]; then
    colorEcho ${BLUE} "Installing Docker Compose..."

    CHECK_URL="https://api.github.com/repos/docker/compose/releases/latest"
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4)
    if [[ -n "$REMOTE_VERSION" ]]; then
        DOWNLOAD_URL=https://github.com/docker/compose/releases/download/$REMOTE_VERSION/docker-compose-`uname -s`-`uname -m`
        curl -SL $DOWNLOAD_URL -o /usr/local/bin/docker-compose && \
            chmod +x /usr/local/bin/docker-compose
    fi
fi

# Allow your user to access the Docker CLI without needing root.
# sudo usermod -aG docker $USER


## ctop
if [[ ! -x "$(command -v ctop)" ]]; then
    colorEcho ${BLUE} "Installing ctop..."
    if uname -m | grep -Eqi "amd64|x86_64"; then
        file_suffix='linux-amd64'
    else
        file_suffix='linux-386'
    fi

    CHECK_URL="https://api.github.com/repos/bcicen/ctop/releases/latest"
    REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4)
    if [[ -n "$REMOTE_VERSION" ]]; then
        DOWNLOAD_URL=https://github.com/bcicen/ctop/releases/download/$REMOTE_VERSION/ctop-`echo $REMOTE_VERSION | cut -c2-`-$file_suffix
        curl -SL $DOWNLOAD_URL -o /usr/local/bin/ctop && \
            chmod +x /usr/local/bin/ctop
    fi
fi
