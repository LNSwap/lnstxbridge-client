#!/usr/bin/env bash

set -euo pipefail
shopt -s expand_aliases

LOGO="
₿₿\      ₿₿\   ₿₿\  ₿₿₿₿₿₿\  ₿₿\      ₿₿\  ₿₿₿₿₿₿\  ₿₿₿₿₿₿₿\  
₿₿ |     ₿₿₿\  ₿₿ |₿₿  __₿₿\ ₿₿ | ₿\  ₿₿ |₿₿  __₿₿\ ₿₿  __₿₿\ 
₿₿ |     ₿₿₿₿\ ₿₿ |₿₿ /  \__|₿₿ |₿₿₿\ ₿₿ |₿₿ /  ₿₿ |₿₿ |  ₿₿ |
₿₿ |     ₿₿ ₿₿\₿₿ |\₿₿₿₿₿₿\  ₿₿ ₿₿ ₿₿\₿₿ |₿₿₿₿₿₿₿₿ |₿₿₿₿₿₿₿  |
₿₿ |     ₿₿ \₿₿₿₿ | \____₿₿\ ₿₿₿₿  _₿₿₿₿ |₿₿  __₿₿ |₿₿  ____/ 
₿₿ |     ₿₿ |\₿₿₿ |₿₿\   ₿₿ |₿₿₿  / \₿₿₿ |₿₿ |  ₿₿ |₿₿ |      
₿₿₿₿₿₿₿₿\₿₿ | \₿₿ |\₿₿₿₿₿₿  |₿₿  /   \₿₿ |₿₿ |  ₿₿ |₿₿ |      
\________\__|  \__| \______/ \__/     \__|\__|  \__|\__|      
"

INTRO="
Welcome to LN-STX Bridge Client installation.
We're glad you've decided to join the lnswap.org Swap Provider Network. 

Please confirm you have the requirements listed below:
1- Bitcoin full Node (unpruned)
2- LND Lightning Node 
3- Always available server/VM/self-hosted node"

DISCLAIMER="I understand that this is experimental software that may cause loss of funds."

##### DEFAULT SETTINGS #####

DEFAULT_APP_DATA_DIR="$HOME/.lnstx-client"
DEFAULT_LND_DATA_DIR="$HOME/.lnd"
DEFAULT_BITCOIN_IP="127.0.0.1"
DEFAULT_BITCOIN_RPC_PORT="8332"
DEFAULT_BITCOIN_RPC_USER="rpcuser"
DEFAULT_BITCOIN_RPC_PASS="rpcpass"
DEFAULT_BITCOIN_NETWORK="mainnet"
DEFAULT_LND_IP="127.0.0.1"
DEFAULT_LND_GRPC_PORT="10009"
DEFAULT_APP_PASSWORD="changeme!!!"
DEFAULT_ACCESS="tor"

##### UTILITIES #####

PANIC="[ PANIC ]"
ERROR="[ ERROR ]"
WARN="[ WARN ]"
INFO="[ INFO ]"

alias log="logger"
alias log_error='logger "${ERROR}"'
alias log_warn='logger "${WARN}"'
alias log_info='logger "${INFO}"'
alias panic='exit_error "${PANIC}"'

logger() {
    echo "$@"
}

exit_error() {
    logger "$@"
    exit 1
}

sed_fix() {
    # usage: sed_fix <placeholder> <value> <file>
    if [[ "$OSTYPE" == "darwin"* ]]; then 
        sed -i '' "s|\$${1}|${2}|g" "${3}"
    else
        sed -i "s|\$${1}|${2}|g" "${3}"
    fi
}

##### MAIN EXECUTION #####

main() {
    echo "$LOGO"
    echo "$INTRO"
    check_prereq
    set_config
    set_network
    show_config
    check_docker
    install_bridge
}

check_prereq() {
    read -erp "Answer (y/n): " requirements
    if [ "$requirements" != "y" ]; then
        panic "Default requirements not confirmed, quitting."
    fi
    echo
    echo "$DISCLAIMER"
    read -erp "Answer (y/n): " reckless
    if [ "${reckless}" != "y" ]; then
        panic "Disclaimer not confirmed, quitting."
    fi
}

set_config() {
    echo
    echo "Setting configuration settings for LN-STX Bridge..."
    read -erp "  Folder where lnstxbridge client will keep its data [$DEFAULT_APP_DATA_DIR]: " APP_DATA_DIR
    APP_DATA_DIR="${APP_DATA_DIR:-${DEFAULT_APP_DATA_DIR}}"
    read -erp "  Folder where lnd is installed [$DEFAULT_LND_DATA_DIR]: " LND_DATA_DIR
    LND_DATA_DIR="${LND_DATA_DIR:-${DEFAULT_LND_DATA_DIR}}"
    read -erp "  Bitcoin Node IP [$DEFAULT_BITCOIN_IP]: " BITCOIN_IP
    BITCOIN_IP="${BITCOIN_IP:-${DEFAULT_BITCOIN_IP}}"
    read -erp "  Bitcoin Node RPC Port [$DEFAULT_BITCOIN_RPC_PORT]: " BITCOIN_RPC_PORT
    BITCOIN_RPC_PORT="${BITCOIN_RPC_PORT:-${DEFAULT_BITCOIN_RPC_PORT}}"
    read -erp "  Bitcoin Node RPC User [$DEFAULT_BITCOIN_RPC_USER]: " BITCOIN_RPC_USER
    BITCOIN_RPC_USER="${BITCOIN_RPC_USER:-${DEFAULT_BITCOIN_RPC_USER}}"
    read -erp "  Bitcoin Node RPC Password [$DEFAULT_BITCOIN_RPC_PASS]: " BITCOIN_RPC_PASS
    BITCOIN_RPC_PASS="${BITCOIN_RPC_PASS:-${DEFAULT_BITCOIN_RPC_PASS}}"
    read -erp "  Bitcoin Node Network [$DEFAULT_BITCOIN_NETWORK]: " BITCOIN_NETWORK
    BITCOIN_NETWORK="${BITCOIN_NETWORK:-${DEFAULT_BITCOIN_NETWORK}}"
    read -erp "  LND Node IP [$DEFAULT_LND_IP]: " LND_IP
    LND_IP="${LND_IP:-${DEFAULT_LND_IP}}"
    read -erp "  LND Node GRPC Port [$DEFAULT_LND_GRPC_PORT]: " LND_GRPC_PORT
    LND_GRPC_PORT="${LND_GRPC_PORT:-${DEFAULT_LND_GRPC_PORT}}"
    read -erp "  LN-STX Client Admin Dashboard Password [$DEFAULT_APP_PASSWORD]: " APP_PASSWORD
    APP_PASSWORD="${APP_PASSWORD:-${DEFAULT_APP_PASSWORD}}"
}

set_network() {
    # use public ipv4 or create hidden service
    echo
    echo "Do you have an IPv4 address that this server is reachable from or is this a self-hosted node that we need to create a tor hidden service?"
    read -erp "Answer (ip/tor): " ACCESS
    ACCESS="${ACCESS:-${DEFAULT_ACCESS}}"
    if [ "${ACCESS}" == "tor" ] || [ "${ACCESS}" == "TOR" ] ; then
        log_info "Creating tor hidden service..."
        {
            echo "HiddenServiceDir /var/lib/tor/lnswap/"
            echo "HiddenServicePort 9008 127.0.0.1:9008"
            echo "HiddenServicePort 80 127.0.0.1:9009"
        } >> /etc/tor/torrc
        log_info "Restarting tor service..."
        eval "systemctl restart tor"
        sleep 5
        APP_LNSWAP_API_IP=$(cat /var/lib/tor/lnswap/hostname)
    elif [ "${ACCESS}" == "ip" ] || [ "${ACCESS}" == "IP" ] ; then
        read -erp "  Enter your server IP: " APP_LNSWAP_API_IP
    else
        panic "Invalid network selection, quitting."
    fi
}

show_config() {
    echo
    echo "Installing lnstxbridge-client with following environment variables: "
    echo "  APP_DATA_DIR: $APP_DATA_DIR"
    echo "  LND_DATA_DIR: $LND_DATA_DIR"
    echo "  BITCOIN_IP: $BITCOIN_IP"
    echo "  BITCOIN_RPC_PORT: $BITCOIN_RPC_PORT"
    echo "  BITCOIN_RPC_USER: $BITCOIN_RPC_USER"
    echo "  BITCOIN_RPC_PASS: $BITCOIN_RPC_PASS"
    echo "  BITCOIN_NETWORK: $BITCOIN_NETWORK"
    echo "  LND_IP: $LND_IP"
    echo "  LND_GRPC_PORT: $LND_GRPC_PORT"
    echo "  APP_PASSWORD: $APP_PASSWORD"
    echo "  ACCESS: $ACCESS"
    echo "  APP_LNSWAP_API_IP: $APP_LNSWAP_API_IP"

    # TODO: should $APP_HIDDEN_SERVICE and $APP_PORT be here?
}

check_docker() {
    # install docker-compose if missing
    if ! [ -x "$(command -v docker-compose)" ]; then
        echo "trying to install docker-compose..."
        VERSION=$(curl -sS https://api.github.com/repos/docker/compose/releases/latest | jq .name -r)
        DESTINATION=/usr/local/bin/docker-compose
        sudo curl -L https://github.com/docker/compose/releases/download/"${VERSION}"/docker-compose-"$(uname -s)"-"$(uname -m)" -o $DESTINATION
        sudo chmod 755 $DESTINATION
    fi
}

install_bridge() {
    # create lnstxbridge-client data folder
    mkdir -p "$APP_DATA_DIR/data"
    cd "$APP_DATA_DIR" || exit
    # download docker-compose.yml
    curl -sSO "https://cdn.jsdelivr.net/gh/pseudozach/lnstxbridge-client@main/docker-compose/docker-compose.yml"
    # replace variables in docker-compose.yml
    sed_fix "APP_DATA_DIR" "$APP_DATA_DIR" "$APP_DATA_DIR/docker-compose.yml"
    sed_fix "LND_DATA_DIR" "$LND_DATA_DIR" "$APP_DATA_DIR/docker-compose.yml"
    sed_fix "BITCOIN_IP" "$BITCOIN_IP" "$APP_DATA_DIR/docker-compose.yml"
    sed_fix "BITCOIN_RPC_PORT" "$BITCOIN_RPC_PORT" "$APP_DATA_DIR/docker-compose.yml"
    sed_fix "BITCOIN_RPC_USER" "$BITCOIN_RPC_USER" "$APP_DATA_DIR/docker-compose.yml"
    sed_fix "BITCOIN_RPC_PASS" "$BITCOIN_RPC_PASS" "$APP_DATA_DIR/docker-compose.yml"
    sed_fix "BITCOIN_NETWORK" "$BITCOIN_NETWORK" "$APP_DATA_DIR/docker-compose.yml"
    sed_fix "LND_IP" "$LND_IP" "$APP_DATA_DIR/docker-compose.yml"
    sed_fix "LND_GRPC_PORT" "$LND_GRPC_PORT" "$APP_DATA_DIR/docker-compose.yml"
    sed_fix "APP_PASSWORD" "$APP_PASSWORD" "$APP_DATA_DIR/docker-compose.yml"
    sed_fix "APP_LNSWAP_API_IP" "$APP_LNSWAP_API_IP" "$APP_DATA_DIR/docker-compose.yml"
    
    # TODO: should $APP_HIDDEN_SERVICE and $APP_PORT be set here?
    
    # copy boltz.conf template to APP_DATA_DIR/data = /root/.lnstx-client inside container
    cd "$APP_DATA_DIR/data" || exit
    curl -sSO "https://cdn.jsdelivr.net/gh/pseudozach/lnstxbridge-client@main/docker-compose/lnstx-client/boltz.conf"
    
    # start containers
    docker-compose up -d
}

main

echo
echo "END OF SCRIPT"
exit 0
