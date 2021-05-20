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

# Python3 & pip
PackagesList=(
    python3
)
for TargetPackage in "${PackagesList[@]}"; do
    if checkPackageNeedInstall "${TargetPackage}"; then
        colorEcho "${BLUE}  Installing ${FUCHSIA}${TargetPackage}${BLUE}..."
        sudo pacman --noconfirm -S "${TargetPackage}"
    fi
done

if [[ ! -x "$(command -v pip)" ]]; then
    if [[ -x "$(command -v python3)" ]]; then
        python3 -m pip install --user -U pip
    elif [[ -x "$(command -v python)" ]]; then
        python -m pip install --user -U pip
    fi

    if [[ -d "$HOME/.local/bin" ]]; then
        export PATH=$PATH:$HOME/.local/bin
    fi
fi

# httpie
# https://httpie.io/
if [[ ! -x "$(command -v http)" ]]; then
    if [[ -x "$(command -v pip)" ]]; then
        pip install --user -U setuptools
        # clear_all_proxy
        pip install --user -U pysocks
        pip install --user -U httpie
    fi
fi
