# Introduction
Instructions for running lnstxbridge-client through docker-compose. 
The docker-compose consist of the following services:
- lnstxbridge-client backend API (running on port 9003)

You can build your own images, or use images built by us (default latest version in docker-compose)

# Docker build
```
git clone https://github.com/pseudozach/lnstxbridge-client
cd lnstxbridge-client
docker buildx create --use
docker buildx build --platform linux/arm64,linux/amd64 -t lnstxbridge-client .
```
# Configuration

Each services needs it own configuration file to be mounted inside docker container at startup. 
You should edit configuration files with your own values.

## lnstxbridge backend API 
Open and edit the `boltz.conf` with your values
### LND
- lnd endpoint
- macaroonpath 
- certpath
### BTC
- bitcoin node endpoint
- cookie
- rpcuser
- rpcpass
### Aggregator URL
- lnstxbridge aggregator instance that your client will register to be a part of the swap provider network.
#### Onchain data
We need to provide information about smart contracts that service will be interacting with
##### Swap contracts
These contracts should be deployed for every deployment of this service and should not be shared with other deployments
- stxswap contract address - latest version under /contracts folder
- sip10swap contract address - latest version under /contracts folder
##### USDA token contract address (optional)
Currently alongside STX and Lightning we support swapping of USDA tokens. We need to provide deployment of the USDA token of the chain we are deploying to:
- contractAddress

# install docker-compose if missing
VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | jq .name -r)
DESTINATION=/usr/local/bin/docker-compose
sudo curl -L https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-$(uname -s)-$(uname -m) -o $DESTINATION
sudo chmod 755 $DESTINATION

# run your lnstxbridge-client as a liquidity provider
cd docker-compose
docker-compose up -d

# lnstxbridge frontend
As a swap provider client, you shouldn't need to provide a frontend but you will register to an aggregator and aggregator frontend will serve your information to end users and route swaps to you.