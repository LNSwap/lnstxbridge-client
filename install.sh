#!/usr/bin/env bash

echo "
₿₿\      ₿₿\   ₿₿\  ₿₿₿₿₿₿\  ₿₿\      ₿₿\  ₿₿₿₿₿₿\  ₿₿₿₿₿₿₿\  
₿₿ |     ₿₿₿\  ₿₿ |₿₿  __₿₿\ ₿₿ | ₿\  ₿₿ |₿₿  __₿₿\ ₿₿  __₿₿\ 
₿₿ |     ₿₿₿₿\ ₿₿ |₿₿ /  \__|₿₿ |₿₿₿\ ₿₿ |₿₿ /  ₿₿ |₿₿ |  ₿₿ |
₿₿ |     ₿₿ ₿₿\₿₿ |\₿₿₿₿₿₿\  ₿₿ ₿₿ ₿₿\₿₿ |₿₿₿₿₿₿₿₿ |₿₿₿₿₿₿₿  |
₿₿ |     ₿₿ \₿₿₿₿ | \____₿₿\ ₿₿₿₿  _₿₿₿₿ |₿₿  __₿₿ |₿₿  ____/ 
₿₿ |     ₿₿ |\₿₿₿ |₿₿\   ₿₿ |₿₿₿  / \₿₿₿ |₿₿ |  ₿₿ |₿₿ |      
₿₿₿₿₿₿₿₿\₿₿ | \₿₿ |\₿₿₿₿₿₿  |₿₿  /   \₿₿ |₿₿ |  ₿₿ |₿₿ |      
\________\__|  \__| \______/ \__/     \__|\__|  \__|\__|      
"

echo "Welcome to LN-STX Bridge Client installation.
We're glad you've decided to join lnswap.org Swap Provider Network. 

Please confirm you have requirements listed below:
1- Bitcoin full Node (unpruned)
2- LND Lightning Node 
3- Always available server/VM/self-hosted node"
DEFAULT_REQUIREMENTS="n"
read -e -p "y/n: " requirements
requirements="${requirements:-${DEFAULT_REQUIREMENTS}}"
if [ "$requirements" != "y" ] ; then
    echo "Not ready yet, quitting."
    exit
fi

echo -e "\nI understand that this is experimental software that may cause loss of funds."
read -e -p "y/n: " reckless
reckless="${reckless:-${DEFAULT_REQUIREMENTS}}"
if [ "${reckless}" != "y" ] ; then
  echo "Not #reckless yet, quitting."
  exit
fi

echo ""
DEFAULT_APP_DATA_DIR="$HOME/.lnstx-client"
read -e -p "Folder where lnstxbridge client will keep its data [$DEFAULT_APP_DATA_DIR]: " APP_DATA_DIR
APP_DATA_DIR="${APP_DATA_DIR:-${DEFAULT_APP_DATA_DIR}}"

DEFAULT_LND_DATA_DIR="$HOME/.lnd"
read -e -p "Folder where lnd is installed [$DEFAULT_LND_DATA_DIR]: " LND_DATA_DIR
LND_DATA_DIR="${LND_DATA_DIR:-${DEFAULT_LND_DATA_DIR}}"

DEFAULT_BITCOIN_IP="127.0.0.1"
read -e -p "Bitcoin Node IP [$DEFAULT_BITCOIN_IP]: " BITCOIN_IP
BITCOIN_IP="${BITCOIN_IP:-${DEFAULT_BITCOIN_IP}}"

DEFAULT_BITCOIN_RPC_PORT="8332"
read -e -p "Bitcoin Node RPC Port [$DEFAULT_BITCOIN_RPC_PORT]: " BITCOIN_RPC_PORT
BITCOIN_RPC_PORT="${BITCOIN_RPC_PORT:-${DEFAULT_BITCOIN_RPC_PORT}}"

DEFAULT_BITCOIN_RPC_USER="rpcuser"
read -e -p "Bitcoin Node RPC User [$DEFAULT_BITCOIN_RPC_USER]: " BITCOIN_RPC_USER
BITCOIN_RPC_USER="${BITCOIN_RPC_USER:-${DEFAULT_BITCOIN_RPC_USER}}"

DEFAULT_BITCOIN_RPC_PASS="rpcpass"
read -e -p "Bitcoin Node RPC Password [$DEFAULT_BITCOIN_RPC_PASS]: " BITCOIN_RPC_PASS
BITCOIN_RPC_PASS="${BITCOIN_RPC_PASS:-${DEFAULT_BITCOIN_RPC_PASS}}"

DEFAULT_BITCOIN_NETWORK="mainnet"
read -e -p "Bitcoin Node Network [$DEFAULT_BITCOIN_NETWORK]: " BITCOIN_NETWORK
BITCOIN_NETWORK="${BITCOIN_NETWORK:-${DEFAULT_BITCOIN_NETWORK}}"

DEFAULT_LND_IP="127.0.0.1"
read -e -p "LND Node IP [$DEFAULT_LND_IP]: " LND_IP
LND_IP="${LND_IP:-${DEFAULT_LND_IP}}"

DEFAULT_LND_GRPC_PORT="10009"
read -e -p "LND Node GRPC Port [$DEFAULT_LND_GRPC_PORT]: " LND_GRPC_PORT
LND_GRPC_PORT="${LND_GRPC_PORT:-${DEFAULT_LND_GRPC_PORT}}"

DEFAULT_APP_PASSWORD="changeme!!!"
read -e -p "LN-STX Bridge Admin Dashboard Password [$DEFAULT_APP_PASSWORD]: " APP_PASSWORD
APP_PASSWORD="${APP_PASSWORD:-${DEFAULT_APP_PASSWORD}}"

# use public ipv4 or create hidden service
echo -e "\nDo you have an IPv4 address that this server is reachable from or is this a self-hosted node that we need to create a tor hidden service?"
DEFAULT_ACCESS="tor"
read -e -p "ip/tor: " access
access="${access:-${DEFAULT_ACCESS}}"
if [ "${access}" != "tor" ] ; then
  echo "Creating tor hidden service..."
  echo "HiddenServiceDir /var/lib/tor/lnswap/" >> /etc/tor/torrc
  echo "HiddenServicePort 9008 127.0.0.1:9008" >> /etc/tor/torrc
  echo "HiddenServicePort 80 127.0.0.1:9009" >> /etc/tor/torrc
  `systemctl restart tor`
  sleep 5
  APP_LNSWAP_API_IP=`cat /var/lib/tor/lnswap/hostname`
else
    read -e -p "Enter your server IP: " APP_LNSWAP_API_IP
fi

DEFAULT_APP_PASSWORD="changeme!!!"
read -e -p "LN-STX Bridge IP Address [$DEFAULT_APP_PASSWORD]: " APP_PASSWORD
APP_PASSWORD="${APP_PASSWORD:-${DEFAULT_APP_PASSWORD}}"


echo -e "\nInstalling lnstxbridge-client with following environment variables: "
echo "APP_DATA_DIR: $APP_DATA_DIR"
echo "LND_DATA_DIR: $LND_DATA_DIR"
echo "BITCOIN_IP: $BITCOIN_IP"
echo "BITCOIN_RPC_PORT: $BITCOIN_RPC_PORT"
echo "BITCOIN_RPC_USER: $BITCOIN_RPC_USER"
echo "BITCOIN_RPC_PASS: $BITCOIN_RPC_PASS"
echo "BITCOIN_NETWORK: $BITCOIN_NETWORK"
echo "LND_IP: $LND_IP"
echo "LND_GRPC_PORT: $LND_GRPC_PORT"
echo "APP_PASSWORD: $APP_PASSWORD"

# install docker-compose if missing
if ! [ -x "$(command -v docker-compose)" ]; then
    echo "trying to install docker-compose..."
    VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | jq .name -r)
    DESTINATION=/usr/local/bin/docker-compose
    sudo curl -L https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-$(uname -s)-$(uname -m) -o $DESTINATION
    sudo chmod 755 $DESTINATION
fi

# create lnstxbridge-client data folder
mkdir -p $APP_DATA_DIR/data

# download docker-compose.yml
cd $APP_DATA_DIR
curl -O "https://cdn.jsdelivr.net/gh/pseudozach/lnstxbridge-client@main/docker-compose/docker-compose.yml"

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macos sed is different
    sed -i '' 's#$APP_DATA_DIR#'$APP_DATA_DIR'#g' docker-compose.yml
    sed -i '' 's#$LND_DATA_DIR#'$LND_DATA_DIR'#g' docker-compose.yml
    sed -i '' 's#$BITCOIN_IP#'$BITCOIN_IP'#g' docker-compose.yml
    sed -i '' 's#$BITCOIN_RPC_PORT#'$BITCOIN_RPC_PORT'#g' docker-compose.yml
    sed -i '' 's#$BITCOIN_RPC_USER#'$BITCOIN_RPC_USER'#g' docker-compose.yml
    sed -i '' 's#$BITCOIN_RPC_PASS#'$BITCOIN_RPC_PASS'#g' docker-compose.yml
    sed -i '' 's#$BITCOIN_NETWORK#'$BITCOIN_NETWORK'#g' docker-compose.yml
    sed -i '' 's#$LND_IP#'$LND_IP'#g' docker-compose.yml
    sed -i '' 's#$LND_GRPC_PORT#'$LND_GRPC_PORT'#g' docker-compose.yml
    sed -i '' 's#$APP_PASSWORD#'$APP_PASSWORD'#g' docker-compose.yml
    sed -i '' 's#$APP_LNSWAP_API_IP#'$APP_LNSWAP_API_IP'#g' docker-compose.yml
else
    sed -i 's#$APP_DATA_DIR#'$APP_DATA_DIR'#g' docker-compose.yml
    sed -i 's#$LND_DATA_DIR#'$LND_DATA_DIR'#g' docker-compose.yml
    sed -i 's#$BITCOIN_IP#'$BITCOIN_IP'#g' docker-compose.yml
    sed -i 's#$BITCOIN_RPC_PORT#'$BITCOIN_RPC_PORT'#g' docker-compose.yml
    sed -i 's#$BITCOIN_RPC_USER#'$BITCOIN_RPC_USER'#g' docker-compose.yml
    sed -i 's#$BITCOIN_RPC_PASS#'$BITCOIN_RPC_PASS'#g' docker-compose.yml
    sed -i 's#$BITCOIN_NETWORK#'$BITCOIN_NETWORK'#g' docker-compose.yml
    sed -i 's#$LND_IP#'$LND_IP'#g' docker-compose.yml
    sed -i 's#$LND_GRPC_PORT#'$LND_GRPC_PORT'#g' docker-compose.yml
    sed -i 's#$APP_PASSWORD#'$APP_PASSWORD'#g' docker-compose.yml
    sed -i 's#$APP_LNSWAP_API_IP#'$APP_LNSWAP_API_IP'#g' docker-compose.yml
fi

# copy boltz.conf template to APP_DATA_DIR/data = /root/.lnstx-client inside container
cd $APP_DATA_DIR/data
curl -O "https://cdn.jsdelivr.net/gh/pseudozach/lnstxbridge-client@main/docker-compose/lnstx-client/boltz.conf"

# start containers
docker-compose up -d
