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

# https://github.com/chrislim2888/IP2Location-C-Library
install_ip2location_c() {
    git clone https://github.com/chrislim2888/IP2Location-C-Library $CURRENT_DIR/IP2Location-C-Library && \
        cd $CURRENT_DIR/IP2Location-C-Library && \
        sudo autoreconf -i -v --force && \
        sudo ./configure >/dev/null && sudo make >/dev/null && sudo make install >/dev/null && \
        cd data && perl ip-country.pl

    # Compile ip2locationLatLong
    if [[ -s "$CURRENT_DIR/ip2locationLatLong.c" ]]; then
        cd $CURRENT_DIR
        gcc ip2locationLatLong.c \
            -I /usr/local/include \
            -L /usr/local/lib -l IP2Location \
            -o ip2locationLatLong
    fi
}

# https://www.ip2location.com/development-libraries/ip2location/python
install_ip2location_python() {
    # https://github.com/chrislim2888/IP2Location-Python
    git clone https://github.com/chrislim2888/IP2Location-Python $CURRENT_DIR/IP2Location-Python && \
        cd $CURRENT_DIR/IP2Location-Python && \
        python setup.py build && \
        python setup.py install
}

# https://lite.ip2location.com/ip2location-lite
download_ip2location_db() {
    # Use your unique download token to download IP2Location databases
    local DOWNLOAD_TOKEN
    local DATABASE_CODE="DB5LITEBIN"

    echo "IP2Location IPv4 Database https://lite.ip2location.com/ip2location-lite"
    echo -n "Download Token? "
    read DOWNLOAD_TOKEN

    [[ -z "$BIN_FILE" ]] && BIN_FILE="IP2LOCATION-LITE-DB5.BIN"

    if [[ -n "$DOWNLOAD_TOKEN" ]]; then
        wget -c -O "${WORKDIR}/${BIN_FILE}.zip" \
            https://www.ip2location.com/download/?token=${DOWNLOAD_TOKEN}&file=${DATABASE_CODE} && \
            unzip -qo "${WORKDIR}/${BIN_FILE}.zip" "IP2LOCATION-LITE-DB5.BIN" -d "$CURRENT_DIR" && \
            rm -f "${WORKDIR}/${BIN_FILE}.zip"
    else
        wget -c -O "${WORKDIR}/${BIN_FILE}.zip" \
            https://www.ip2location.com/downloads/sample.bin.db5.zip && \
            unzip -qo "${WORKDIR}/${BIN_FILE}.zip" \
                "IP-COUNTRY-REGION-CITY-LATITUDE-LONGITUDE-SAMPLE.BIN" \
                -d "$CURRENT_DIR" && \
            mv "$CURRENT_DIR/IP-COUNTRY-REGION-CITY-LATITUDE-LONGITUDE-SAMPLE.BIN" \
                "$CURRENT_DIR/$BIN_FILE"
    fi
}

#This is the location of bin file
#You must modify for your system
BIN_FILE="IP2LOCATION-LITE-DB5.BIN"


#ip2locationLatLong
# C-Library
if [[ ! -s "$CURRENT_DIR/ip2locationLatLong" ]]; then
    if [[ ! -x "$(command -v make)" ]]; then
        colorEcho "${FUCHSIA}make${RED} is not installed!"
        exit 1
    fi

    if [[ ! -x "$(command -v gcc)" ]]; then
        colorEcho "${FUCHSIA}gcc${RED} is not installed!"
        exit 1
    fi

    install_ip2location_c
fi

# python
if [[ -x "$(command -v pip)" ]]; then
    [[ ! $(pip list | grep IP2Location) ]] && install_ip2location_python
fi

# db
[[ ! -s "$CURRENT_DIR/$BIN_FILE" ]] && download_ip2location_db


cd ${CURRENT_DIR}
colorEcho "${GREEN}ip2locationLatLong installed!"