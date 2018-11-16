#!/bin/bash

#######color code########
RED="31m"      # Error message
GREEN="32m"    # Success message
YELLOW="33m"   # Warning message
BLUE="36m"     # Info message

colorEcho() {
	COLOR=$1
	echo -e "\033[${COLOR}${@:2}\033[0m"
}

if [[ $UID -ne 0 ]]; then
	colorEcho ${RED} "Please run this script as root user!"
	exit 0
fi

# Install packages to allow apt to use a repository over HTTPS.
apt update && apt install apt-transport-https ca-certificates curl gnupg2 software-properties-common

# Install docker-ce
# https://docs.docker.com/install/
curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -
add-apt-repository \
	"deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/$(. /etc/os-release; echo "$ID") \
	$(lsb_release -cs) \
	stable"
apt update && apt install -y docker-ce

# Install Docker Compose
# https://docs.docker.com/compose/install/#install-compose
docker_compose_ver=$(wget --no-check-certificate -qO- https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
if [[ -n "$docker_compose_ver" ]]; then
	curl -SL https://github.com/docker/compose/releases/download/$docker_compose_ver/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && \
	chmod +x /usr/local/bin/docker-compose
fi

# Allow your user to access the Docker CLI without needing root.
# sudo usermod -aG docker $USER
