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

# clash
# https://github.com/Dreamacro/clash
colorEcho ${BLUE} "Checking update for clash..."

IS_INSTALL="yes"
IS_UPDATE="no"
CURRENT_VERSION="0.0.0"

if [[ -s "/srv/clash/clash" ]]; then
    IS_UPDATE="yes"
    CURRENT_VERSION=$(/srv/clash/clash -v 2>&1 | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
else
    [[ "${IS_UPDATE_ONLY}" == "yes" ]] && IS_INSTALL="no"
fi

if [[ "${IS_INSTALL}" == "yes" ]] then
    # CHECK_URL="https://api.github.com/repos/Dreamacro/clash/releases/latest"
    # REMOTE_VERSION=$(wget -qO- $CHECK_URL | grep 'tag_name' | cut -d\" -f4 | cut -d'v' -f2)

    # Pre-release
    REMOTE_VERSION=$(curl -s -N https://github.com/Dreamacro/clash/releases \
        | grep -Eo -m1 '\/releases\/tag\/v([0-9]{1,}\.)+[0-9]{1,}' \
        | grep -Eo '([0-9]{1,}\.)+[0-9]{1,}' | head -n1)
    if version_le $REMOTE_VERSION $CURRENT_VERSION; then
        IS_INSTALL="no"
    fi
fi

if [[ "${IS_INSTALL}" == "yes" ]] then
    colorEcho ${BLUE} "Installing clash ${REMOTE_VERSION}..."

    [[ -z "$OS_INFO_TYPE" ]] && get_os_type
    [[ -z "$OS_INFO_ARCH" ]] && get_arch

    DOWNLOAD_URL="https://github.com/Dreamacro/clash/releases/download/v${REMOTE_VERSION}/clash-${OS_INFO_TYPE}-${OS_INFO_ARCH}-v${REMOTE_VERSION}.gz"

    curl -SL -o "${WORKDIR}/clash-${OS_INFO_TYPE}-${OS_INFO_ARCH}.gz" -C- "$DOWNLOAD_URL" && \
        sudo mkdir -p "/srv/clash" && \
        sudo mv "${WORKDIR}/clash-${OS_INFO_TYPE}-${OS_INFO_ARCH}.gz" "/srv/clash" && \
        cd "/srv/clash" && \
        sudo gzip -d "clash-${OS_INFO_TYPE}-${OS_INFO_ARCH}.gz" && \
        sudo chmod +x "clash-${OS_INFO_TYPE}-${OS_INFO_ARCH}" && \
        sudo ln -sv "/srv/clash/clash-${OS_INFO_TYPE}-${OS_INFO_ARCH}" "/srv/clash/clash" || true

    # geo database
    if [[ -s "/srv/clash/mmdb.ver" ]]; then
        CURRENT_VERSION=$(head -n1 /srv/clash/mmdb.ver)
    else
        CURRENT_VERSION="20000101"
    fi

    CHECK_URL="https://geolite.clash.dev/version"
    REMOTE_VERSION=$(wget -qO- $CHECK_URL)

    if version_gt $REMOTE_VERSION $CURRENT_VERSION; then
        colorEcho ${BLUE} "  Installing clash geo database ${REMOTE_VERSION}..."
        # MMDB_URL="https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb"
        MMDB_URL="https://geolite.clash.dev/Country.mmdb"
        curl -SL -o "${WORKDIR}/Country.mmdb" "$MMDB_URL" && \
            sudo mv -f "${WORKDIR}/Country.mmdb" "/srv/clash/Country.mmdb" && \
            echo ${REMOTE_VERSION} | sudo tee "/srv/clash/mmdb.ver" >/dev/null
    fi

    [[ $(systemctl is-enabled clash 2>/dev/null) ]] || {
        Install_systemd_Service "clash" "/srv/clash/clash -d /srv/clash"
    }

    if [[ "${IS_UPDATE}" == "yes" ]] then
        [[ $(systemctl is-enabled clash 2>/dev/null) ]] && sudo systemctl restart clash && sleep 3
    fi
fi

# nohup /srv/clash/clash -d /srv/clash >/dev/null 2>&1 & disown

cd "${CURRENT_DIR}"