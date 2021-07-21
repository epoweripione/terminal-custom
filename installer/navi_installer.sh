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

# navi: An interactive cheatsheet tool for the command-line
# https://github.com/denisidoro/navi
APP_INSTALL_NAME="navi"
GITHUB_REPO_NAME="denisidoro/navi"

EXEC_INSTALL_PATH="/usr/local/bin"
EXEC_INSTALL_NAME="navi"

IS_INSTALL="yes"
IS_UPDATE="no"

CURRENT_VERSION="0.0.0"
VERSION_FILENAME=""

if [[ -x "$(command -v ${EXEC_INSTALL_NAME})" ]]; then
    IS_UPDATE="yes"
    CURRENT_VERSION=$(${EXEC_INSTALL_NAME} --version 2>&1 | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
else
    [[ "${IS_UPDATE_ONLY}" == "yes" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}Checking latest version for ${FUCHSIA}${APP_INSTALL_NAME}${BLUE}..."

    CHECK_URL="https://api.github.com/repos/${GITHUB_REPO_NAME}/releases/latest"
    REMOTE_VERSION=$(curl "${curl_check_opts[@]}" "${CHECK_URL}" | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)
    if version_le $REMOTE_VERSION $CURRENT_VERSION; then
        IS_INSTALL="no"
    fi
fi

if [[ "${IS_INSTALL}" == "yes" ]]; then
    colorEcho "${BLUE}  Installing ${FUCHSIA}${APP_INSTALL_NAME} ${YELLOW}${REMOTE_VERSION}${BLUE}..."
    # Git_Clone_Update "denisidoro/navi" "/opt/navi"
    # if [[ ! -x "$(command -v ${EXEC_INSTALL_NAME})" ]]; then
    #     cd /opt/navi && sudo make BIN_DIR=/usr/local/bin install
    # elif [[ -d "/opt/navi" ]]; then
    #     cd /opt/navi && sudo make update
    # fi

    DOWNLOAD_FILENAME="${WORKDIR}/navi-install.sh"
    DOWNLOAD_URL="https://raw.githubusercontent.com/${GITHUB_REPO_NAME}/master/scripts/install"
    curl "${curl_download_opts[@]}" -o "${DOWNLOAD_FILENAME}" "${DOWNLOAD_URL}" && \
        sudo BIN_DIR=/usr/local/bin bash "${DOWNLOAD_FILENAME}"
fi

# new install
if [[ "${IS_INSTALL}" == "yes" && "${IS_UPDATE}" == "no" && -x "$(command -v ${EXEC_INSTALL_NAME})" ]]; then
    ## shell widget
    # bash
    if [[ ! $(grep "navi widget bash" "$HOME/.bashrc") ]]; then
        echo '' >> "$HOME/.bashrc"
        echo 'eval "$(navi widget bash)"' >> "$HOME/.bashrc"
    fi

    # zsh
    if [[ ! $(grep "navi widget zsh" "$HOME/.zshrc") ]]; then
        echo '' >> "$HOME/.zshrc"
        echo 'eval "$(navi widget zsh)"' >> "$HOME/.zshrc"
    fi

    # Importing featured cheatsheets
    # https://github.com/denisidoro/cheats/blob/master/featured_repos.txt
    featured_repos=(
        "denisidoro/cheats"
        "denisidoro/navi-tldr-pages"
        "denisidoro/dotfiles"
        "mrVanDalo/navi-cheats"
        "chazeon/my-navi-cheats"
        "caojianhua/MyCheat"
        "Kidman1670/cheats"
        "isene/cheats"
        "m42martin/navi-cheats"
    )

    for Target in "${featured_repos[@]}"; do
        user=$(echo ${Target} | cut -d'/' -f1)
        repo=$(echo ${Target} | cut -d'/' -f2)
        Git_Clone_Update "${Target}" "$(navi info cheats-path)/${user}__${repo}"
        # navi repo add "${Target}"
    done

    # use cheatsheets from tldr: https://github.com/tldr-pages/tldr
    # navi --tldr <query>
    if [[ ! -x "$(command -v tldr)" ]]; then
        [[ -x "$(command -v cargo)" ]] && cargo install tealdeer
    fi
    [[ -x "$(command -v tldr)" ]] && tldr --update

    # use cheatsheets from cheat.sh: https://github.com/chubin/cheat.sh
    # navi --cheatsh <query>
    if [[ ! -x "$(command -v cht.sh)" ]]; then
        if checkPackageNeedInstall "rlwrap"; then
            colorEcho "${BLUE}  Installing ${FUCHSIA}rlwrap${BLUE}..."
            sudo pacman --noconfirm -S "rlwrap"
        fi
    
        curl "${curl_download_opts[@]}" "https://cht.sh/:cht.sh" | sudo tee "/usr/local/bin/cht.sh" >/dev/null && \
            sudo chmod +x "/usr/local/bin/cht.sh"
    fi
fi


cd "${CURRENT_DIR}"