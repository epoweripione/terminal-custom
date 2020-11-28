#!/usr/bin/env bash

trap 'rm -r "$WORKDIR"' EXIT

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

# ☄🌌️ The minimal, blazing-fast, and infinitely customizable prompt for any shell!
# https://github.com/starship/starship
colorEcho ${BLUE} "Checking latest version for starship..."

CHECK_URL="https://api.github.com/repos/starship/starship/releases/latest"
REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

if [[ -x "$(command -v starship)" ]]; then
    ECHO_TYPE="Updating"
    CURRENT_VERSION=$(starship -V | cut -d" " -f2)
else
    CURRENT_VERSION="0.0.0"
    ECHO_TYPE="Installing"
fi

if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
    colorEcho ${BLUE} "  ${ECHO_TYPE} starship ${REMOTE_VERSION}..."
    # curl -fsSL https://starship.rs/install.sh | bash
    curl -SL -o "${WORKDIR}/starship_install.sh" "https://starship.rs/install.sh" && \
        bash "${WORKDIR}/starship_install.sh" --force
fi

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

## powershell
# @'
# ## https://starship.rs/
# if (Get-Command "starship" -ErrorAction SilentlyContinue) {
#     Invoke-Expression (&starship init powershell)
# }
# '@ | Tee-Object $PROFILE -Append | Out-Null
