#!/bin/bash

# usage: ./ssl-check-expire-date.sh ssl-check-expire-date.txt
# txt: each line is a host name

if [[ $# != 1 ]]; then
    echo "Usage: $(basename $0) host-list-file"
    echo "eg: $(basename $0) ssl-check-expire-date.txt"
    exit 1
fi

filename="$1"
while read -r line; do
    if [[ -n "$line" ]]; then
        echo -n "$line: "
        ./ssl-cert-info.sh --host $line --end
    fi
done < "$filename"
