# Introduction
Instructions for running lnstxbridge-client through docker-compose. 
The docker-compose consist of the following services:
- lnstxbridge-client backend API (running on port 9003)

You can build your own images, or use images built by us (default latest version in docker-compose)

# Docker build
```
git clone https://github.com/pseudozach/lnstxbridge-client
cd lnstxbridge-client
docker buildx build --platform linux/amd64 -t your_tag_name .
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
##### USDA token contract address
Currently alongside STX and Lightning we support swapping of USDA tokens. We need to provide deployment of the USDA token of the chain we are deploying to:
- contractAddress

# lnstxbridge frontend
As a swap provider client, you shouldn't need to provide a frontend but you will register to an aggregator and aggregator frontend will serve your information and route swaps to you.