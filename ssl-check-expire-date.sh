#!/usr/bin/env bash

# usage: ./ssl-check-expire-date.sh ssl-check-expire-date.txt
# txt: each line is a host name

if [[ $# != 1 ]]; then
    echo "Usage: $(basename $0) host-list-file"
    echo "eg: $(basename $0) ssl-check-expire-date.txt"
    exit 1
fi

filename="$1"
[[ ! -s "${filename}" ]] && echo "${filename} not exist!" && exit 1

while read -r line; do
    if [[ -n "$line" ]]; then
        echo -n "$line: "
        "${MY_SHELL_SCRIPTS:-$HOME/terminal-custom}/ssl-cert-info.sh" --host $line --end
    fi
done < "$filename"
