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

[[ -n "${INSTALLER_CHECK_CURL_OPTION}" ]] && curl_check_opts=(`echo ${INSTALLER_CHECK_CURL_OPTION}`) || curl_check_opts=(-fsL)
[[ -n "${INSTALLER_DOWNLOAD_CURL_OPTION}" ]] && curl_download_opts=(`echo ${INSTALLER_DOWNLOAD_CURL_OPTION}`) || curl_download_opts=(-fSL)

# ☄🌌️ The minimal, blazing-fast, and infinitely customizable prompt for any shell!
# https://github.com/starship/starship
APP_INSTALL_NAME="starship"
IS_INSTALL="yes"
CURRENT_VERSION="0.0.0"

if [[ -x "$(command -v starship)" ]]; then
    CURRENT_VERSION=$(starship -V | cut -d" " -f2)
else
    [[ "${IS_UPDATE_ONLY}" == "yes" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}Checking latest version for ${FUCHSIA}${APP_INSTALL_NAME}${BLUE}..."

    CHECK_URL="https://api.github.com/repos/starship/starship/releases/latest"
    REMOTE_VERSION=$(curl "${curl_check_opts[@]}" "${CHECK_URL}" | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_le $REMOTE_VERSION $CURRENT_VERSION; then
        IS_INSTALL="no"
    fi
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}  Installing ${FUCHSIA}${APP_INSTALL_NAME} ${YELLOW}${REMOTE_VERSION}${BLUE}..."
    # curl -fsSL https://starship.rs/install.sh | bash

    curl "${curl_download_opts[@]}" -o "${WORKDIR}/starship_install.sh" "https://starship.rs/install.sh" && \
        bash "${WORKDIR}/starship_install.sh" --force

    ## config
    # mkdir -p ~/.config && touch ~/.config/starship.toml
    if [[ ! -s "$HOME/.config/starship.toml" ]]; then
        mkdir -p "$HOME/.config"
        cp -f "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/zsh/themes/starship.toml" "$HOME/.config"
    fi

    # bash
    if [[ ! $(grep "starship init bash" "$HOME/.bashrc") ]]; then
        echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
    fi

    # zsh
    if [[ ! $(grep "starship init zsh" "$HOME/.zshrc") ]]; then
        echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
    fi
fi

## powershell
# @'
# ## https://starship.rs/
# if (Get-Command "starship" -ErrorAction SilentlyContinue) {
#     Invoke-Expression (&starship init powershell)
# }
# '@ | Tee-Object $PROFILE -Append | Out-Null
