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


# https://www.nano-editor.org/dist/latest/faq.html
# http://mybookworld.wikidot.com/compile-nano-from-source
colorEcho ${BLUE} "Checking latest version for nano..."
if [[ -x "$(command -v pacman)" ]]; then
    # Remove old version nano
    if pacman -Qi nano >/dev/null 2>&1; then
        sudo pacman --noconfirm -R nano >/dev/null 2>&1
    fi

    if [[ ! -x "$(command -v nano)" ]]; then
        # Pre-requisite packages
        PackagesList=(
            ncurses
            ncurses-devel
            libncurses-dev
            libncursesw-dev
            libncurses5-dev
            libncursesw5-dev
        )
        for TargetPackage in "${PackagesList[@]}"; do
            if pacman -Si "$TargetPackage" >/dev/null 2>&1; then
                if ! pacman -Qi "$TargetPackage" >/dev/null 2>&1; then
                    colorEcho ${BLUE} "  Installing $TargetPackage..."
                    sudo pacman --noconfirm -S "$TargetPackage"
                fi
            fi
        done
    fi
fi


# ncurses
# cd "${WORKDIR}" && \
#     curl -fSL http://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.1.tar.gz -o ncurses.tar.gz && \
#     sudo tar zxvf ncurses.tar.gz && \
#     sudo mv ncurses-* ncurses && cd ncurses && \
#     sudo ./configure --prefix=/opt/ncurses >/dev/null && \
#     sudo make >/dev/null && sudo make install >/dev/null

INSTALL_NAME="nano"
IS_INSTALL="yes"
IS_UPDATE="no"
CURRENT_VERSION="0.0"

# compile & install nano
if [[ -x "$(command -v nano)" ]]; then
    IS_UPDATE="yes"
    CURRENT_VERSION=$(nano -V | grep -Eo -m1 '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
fi

REMOTE_VERSION=$(curl -fsL -N https://www.nano-editor.org/download.php \
    | grep -Eo -m1 'nano-([0-9]{1,}\.)+[0-9]{1,}' | head -n1 | cut -d'-' -f2)
    # | grep -m 1 -o 'nano-\([0-9]\)\+\.\([0-9]\)\+' | head -n1 | cut -d'-' -f2)
DIST_VERSION=$(echo $REMOTE_VERSION | cut -d'.' -f1)

if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
    colorEcho ${BLUE} "  Installing ${INSTALL_NAME} ${REMOTE_VERSION} from source..."
    DOWNLOAD_URL="https://www.nano-editor.org/dist/v${DIST_VERSION}/nano-${REMOTE_VERSION}.tar.gz"
    wget -O "${WORKDIR}/nano.tar.gz" "$DOWNLOAD_URL" && \
        tar -xzPf "${WORKDIR}/nano.tar.gz" -C "${WORKDIR}" && \
        mv ${WORKDIR}/nano-* "${WORKDIR}/nano"

    if [[ -d "${WORKDIR}/nano" ]]; then
        colorEcho ${BLUE} "  Compiling nano..."
        cd "${WORKDIR}/nano" && \
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