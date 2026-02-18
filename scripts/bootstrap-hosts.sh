#!/usr/bin/env bash

set -e

HOSTS_FILE="/etc/hosts"

add_host () {
    local $line="$1"
    if ! grep -qF "$line" $HOSTS_FILE; then
        echo "$line" | sudo tee -a $HOSTS_FILE >/dev/null
        echo "Added $line"
    else 
        echo "$line already exists"
    fi
}

add_host "127.0.0.1 api.localhost"
add_host "127.0.0.1 traefik.localhost"
echo "Hosts bootstrap complete."
