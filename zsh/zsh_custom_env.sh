# export LANG="en_US.UTF-8"
# export LC_ALL="en_US.UTF-8"
# export LC_CTYPE="en_US.UTF-8"

terminal_colors=$(tput colors)
if [[ $terminal_colors -eq 256 ]]; then
    export TERM="xterm-256color"
    PROMPT_EOL_MARK=""
fi

# load-nvmrc: use specified node version for the current directory with .nvmrc
NVM_LOAD_NVMRC_IN_CURRENT_DIRECTORY=false


# env for installer
# APT_NOT_USE_MIRRORS=true
# DOCKER_INSTALLER_NOT_USE_MIRROR=true
# GVM_INSTALLER_NOT_USE_PROXY=true
# NVM_INSTALLER_NOT_USE_MIRROR=true
# NPM_INSTALLER_NOT_USE_MIRROR=true
