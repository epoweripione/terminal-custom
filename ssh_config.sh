#!/usr/bin/env bash

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


# Disable Password Authentication
sudo sed -i 's/[#]*[ ]*PasswordAuthentication.*/PasswordAuthentication no/g' "/etc/ssh/sshd_config"

# Disable Forwarding
sudo sed -i 's/[#]*[ ]*AllowAgentForwarding.*/AllowAgentForwarding no/g' "/etc/ssh/sshd_config"
sudo sed -i 's/[#]*[ ]*AllowTcpForwarding.*/AllowTcpForwarding no/g' "/etc/ssh/sshd_config"
sudo sed -i 's/[#]*[ ]*X11Forwarding.*/X11Forwarding no/g' "/etc/ssh/sshd_config"


# Restart ssh service
[[ $(systemctl is-enabled ssh 2>/dev/null) ]] && sudo systemctl restart ssh
[[ $(systemctl is-enabled sshd 2>/dev/null) ]] && sudo systemctl restart sshd


## Generate ssh key
## https://linux.die.net/man/1/ssh-keygen
## ssh-keygen [-q] [-b bits] -t type [-N new_passphrase] [-C comment] [-f output_keyfile]
# ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_ed25519 -C "<username@remote-server.org>"
# ssh-keygen -t rsa -b 4096 -C "$(whoami)@$(hostname)-$(date -I)"

## Fix: Load key ... bad permissions
# chmod 600 ~/.ssh/id_ed25519


## Install public key in remote machine's authorized_keys
# ssh-copy-id -i ~/.ssh/id_ed25519.pub username@remote-server.org
## or
# rsync -avz --progress ~/.ssh/id_ed25519.pub username@remote-server.org:
# ssh username@remote-server.org
# mkdir ~/.ssh && \
#     cat ~/id_ed25519.pub >> ~/.ssh/authorized_keys && \
#     rm -f ~/id_ed25519.pub && \
#     chmod 700 ~/.ssh/ && \
#     chmod 600 ~/.ssh/authorized_keys


cd "${CURRENT_DIR}"