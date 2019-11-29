#!/bin/bash

# Load custom functions
if type 'colorEcho' 2>/dev/null | grep -q 'function'; then
    :
else
    if [[ -s "$HOME/custom_functions.sh" ]]; then
        source "$HOME/custom_functions.sh"
    else
        echo "$HOME/custom_functions.sh not exist!"
        exit 0
    fi
fi

# https://github.com/chrislim2888/IP2Location-C-Library
install_ip2location_c() {
    if [[ ! -x "$(command -v make)" ]]; then
        colorEcho ${RED} "make is not installed!"
        exit 1
    fi

    if [[ ! -x "$(command -v gcc)" ]]; then
        colorEcho ${RED} "gcc is not installed!"
        exit 1
    fi

    git clone https://github.com/chrislim2888/IP2Location-C-Library $CURRENT_DIR/IP2Location-C-Library && \
        cd $CURRENT_DIR/IP2Location-C-Library && \
        sudo autoreconf -i -v --force && \
        sudo ./configure && sudo make && sudo make install && \
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
    if [[ ! -x "$(command -v python)" ]]; then
        colorEcho ${RED} "python is not installed!"
        exit 1
    fi

    # https://github.com/chrislim2888/IP2Location-Python
    git clone https://github.com/chrislim2888/IP2Location-Python $CURRENT_DIR/IP2Location-Python && \
        cd $CURRENT_DIR/IP2Location-Python && \
        python setup.py build && \
        python setup.py install
}

download_ip2location_db() {
    # https://lite.ip2location.com/ip2location-lite

    # Use your unique download token to download IP2Location databases
    local DOWNLOAD_TOKEN
    local DATABASE_CODE="DB5LITEBIN"

    echo "IP2Location IPv4 Database https://lite.ip2location.com/ip2location-lite"
    echo -n "Download Token? "
    read DOWNLOAD_TOKEN

    [[ -z "$BIN_FILE" ]] && BIN_FILE="IP2LOCATION-LITE-DB5.BIN"

    if [[ -n "$DOWNLOAD_TOKEN" ]]; then
        wget -c -O "/tmp/${BIN_FILE}.zip" \
            https://www.ip2location.com/download/?token=${DOWNLOAD_TOKEN}&file=${DATABASE_CODE} && \
            unzip -qo "/tmp/${BIN_FILE}.zip" "IP2LOCATION-LITE-DB5.BIN" -d "$CURRENT_DIR" && \
            rm -f "/tmp/${BIN_FILE}.zip"
    else
        wget -c -O "/tmp/${BIN_FILE}.zip" \
            https://www.ip2location.com/downloads/sample.bin.db5.zip && \
            unzip -qo "/tmp/${BIN_FILE}.zip" \
                "IP-COUNTRY-REGION-CITY-LATITUDE-LONGITUDE-SAMPLE.BIN" \
                -d "$CURRENT_DIR" && \
            mv "$CURRENT_DIR/IP-COUNTRY-REGION-CITY-LATITUDE-LONGITUDE-SAMPLE.BIN" \
                "$CURRENT_DIR/$BIN_FILE" && \
            rm -f "/tmp/${BIN_FILE}.zip"
    fi
}

#This is the location of bin file
#You must modify for your system
BIN_FILE="IP2LOCATION-LITE-DB5.BIN"


#ip2locationLatLong
CURRENT_DIR=$(pwd)
[[ ! -s "$CURRENT_DIR/ip2locationLatLong" ]] && install_ip2location_c
[[ ! -s "$CURRENT_DIR/$BIN_FILE" ]] && download_ip2location_db


cd ${CURRENT_DIR}
colorEcho ${GREEN} "ip2locationLatLong installed!"