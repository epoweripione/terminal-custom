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

# https://www.nano-editor.org/dist/latest/faq.html
APP_INSTALL_NAME="nano"
EXEC_INSTALL_NAME="nano"

colorEcho "${BLUE}Checking latest version for ${FUCHSIA}${APP_INSTALL_NAME}${BLUE}..."
REMOTE_VERSION=$(curl "${curl_check_opts[@]}" -N https://www.nano-editor.org/download.php \
    | grep -Eo -m1 'nano-([0-9]{1,}\.)+[0-9]{1,}' | head -n1 | cut -d'-' -f2)
DIST_VERSION=$(echo $REMOTE_VERSION | cut -d'.' -f1)

if [[ -x "$(command -v pacman)" ]]; then
    # Remove installed old version
    if checkPackageInstalled "${APP_INSTALL_NAME}"; then
        CURRENT_VERSION=$(${EXEC_INSTALL_NAME} -V | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
        if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
            colorEcho "${BLUE}  Removing ${FUCHSIA}${APP_INSTALL_NAME}${YELLOW}${CURRENT_VERSION}${BLUE}..."
            sudo pacman --noconfirm -R "${APP_INSTALL_NAME}"
            sudo pacman --noconfirm -Rn "${APP_INSTALL_NAME}" || true
        fi
    fi

    # Pre-requisite packages
    PackagesList=(
        ncurses
        libncurses-dev
        libncursesw-dev
        libncurses5-dev
        libncursesw5-dev
        ncurses-devel
        # http://support.moonpoint.com/os/unix/linux/ubuntu/groff_invalid_device.php
        groff
    )
    for TargetPackage in "${PackagesList[@]}"; do
        if checkPackageNeedInstall "${TargetPackage}"; then
            colorEcho "${BLUE}  Installing ${FUCHSIA}${TargetPackage}${BLUE}..."
            sudo pacman --noconfirm -S "${TargetPackage}"
        fi
    done
fi

IS_INSTALL="yes"
IS_UPDATE="no"
CURRENT_VERSION="0.0"

# http://mybookworld.wikidot.com/compile-nano-from-source
if [[ -x "$(command -v ${EXEC_INSTALL_NAME})" ]]; then
    IS_UPDATE="yes"
    CURRENT_VERSION=$(${EXEC_INSTALL_NAME} -V | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
fi

if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
    colorEcho "${BLUE}  Installing ${FUCHSIA}${APP_INSTALL_NAME}${YELLOW}${REMOTE_VERSION}${BLUE} from source..."

    REMOTE_FILENAME="${APP_INSTALL_NAME}-${REMOTE_VERSION}.tar.gz"
    DOWNLOAD_FILENAME="${WORKDIR}/${APP_INSTALL_NAME}.tar.gz"

    DOWNLOAD_URL="https://www.nano-editor.org/dist/v${DIST_VERSION}/${REMOTE_FILENAME}"

    wget -O "${DOWNLOAD_FILENAME}" "$DOWNLOAD_URL" && \
        tar -xzf "${DOWNLOAD_FILENAME}" -C "${WORKDIR}" && \
        mv ${WORKDIR}/${APP_INSTALL_NAME}-* "${WORKDIR}/${APP_INSTALL_NAME}"

    if [[ -d "${WORKDIR}/${APP_INSTALL_NAME}" ]]; then
        colorEcho "${BLUE}  Compiling ${FUCHSIA}${APP_INSTALL_NAME}${BLUE}..."
        cd "${WORKDIR}/${APP_INSTALL_NAME}" && \
        ./configure --prefix=/usr --enable-utf8 >/dev/null && \
        make >/dev/null && \
        sudo make install >/dev/null
    fi
fi

# Change default editor to nano
if [[ "${IS_UPDATE}" == "no" && -x "$(command -v nano)" ]]; then
    if [[ -x "$(command -v update-alternatives)" ]]; then
        sudo update-alternatives --install /usr/bin/editor editor $(which nano) 100
        sudo update-alternatives --config editor
    fi

    # select default sensible-editor from all installed editors
    [[ -x "$(command -v select-editor)" ]] && select-editor

    # What About Distros That Don’t Provide select-editor?
    # export VISUAL="nano"
    # echo 'export VISUAL="nano"' >> "$HOME/.bashrc"
    # echo 'export VISUAL="nano"' >> "$HOME/.zshrc"
fi

cd "${CURRENT_DIR}"