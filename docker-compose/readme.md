# Introduction
Follow these instructions for running lnstxbridge-client through docker-compose. 
The docker-compose consist of the following service:
- lnstxbridge-client backend API (running on port 9003)

You can build your own images, or use images built by lnswap.org (default latest version in docker-compose)

# Docker build (optional)
```
git clone https://github.com/pseudozach/lnstxbridge-client
cd lnstxbridge-client
docker buildx create --use
docker buildx build --platform linux/arm64,linux/amd64 -t lnstxbridge-client .
```
# Configuration

Each services needs its own configuration file to be mounted inside docker container at startup. 
You should edit configuration files with your own values.

## lnstxbridge backend API 
Open and edit the `docker-compose/lnstx-client/boltz.conf` with your values
### LND
- lnd endpoint
- macaroonpath 
- certpath
### BTC
- bitcoin node endpoint
- cookie
### Aggregator URL
- lnstxbridge aggregator instance that your client will register to be a part of the swap provider network.
### Onchain data
We need to provide information about smart contracts that service will be interacting with
### Swap contracts
These contracts should be the same with your aggregator.
- stxswap contract address
- sip10swap contract address
#### USDA token contract address (optional)
Currently alongside STX and Lightning we support swapping of USDA tokens. We need to provide deployment of the USDA token of the chain we are deploying to:
- contractAddress

# Start the Bridge 
* install docker-compose if missing
```
VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | jq .name -r)
DESTINATION=/usr/local/bin/docker-compose
sudo curl -L https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-$(uname -s)-$(uname -m) -o $DESTINATION
sudo chmod 755 $DESTINATION
```  
* start the client with docker-compose  
```
cd docker-compose
docker-compose up -d
```  

## lnstxbridge admin dashboard (optional)
[Admin dashboard](https://github.com/pseudozach/lnstxbridge-dashboard) shows bridge account funds, previous swaps and balance status.
 
[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Fpseudozach%2Flnstxbridge-dashboard\&env=NEXT\_PUBLIC\_BACKEND\_URL\&envDescription=URL%20of%20LN-STX%20Bridge%20Backend)

# lnstxbridge frontend
As a swap provider client, you don't need to provide a frontend. You will register to an aggregator and aggregator frontend will serve your information to end users and route swaps to you.