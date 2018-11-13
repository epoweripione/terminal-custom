#!/bin/bash

# usage: ./ssl-check-expire-date.sh ssl-check-expire-date.txt
# txt: each line is a host name

filename="$1"
while read -r line; do
    if [[ -n "$line" ]]; then
        echo "$line: "
        ./ssl-cert-info.sh --host $line --end
    fi
done < "$filename"
