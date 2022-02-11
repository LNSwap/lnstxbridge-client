# LN-STX Bridge Client

### do not use - under heavy development -  

This is a light client to interface with [lnstxbridge](https://github.com/pseudozach/lnstxbridge) to facilitate submarine/atomic swaps between Lightning Network/onchain BTC <-> STX/USDA/(Any SIP10 token) on Stacks

* Allows client to register to main lnstxbridge instance in order to signal supported pairs.
* Accept and Execute trustless swaps

## install
* clone the repo, install requirements and compile  
`git clone https://github.com/pseudozach/lnstxbridge-client.git`  
`cd lnstxbridge-client && npm i && npm run compile`  
* start btc & lnd  
`npm run docker:regtest`
* copy boltz.conf to ~/.lnstx/boltz.conf and modify as needed  
* start the app  
`npm run start`

## Docs

Updated documentation to be made available at [lnswap docs](https://docs.lnswap.org/quick-start).

## Acknowledgements

This is a simplified fork of lnstxbridge which is a fork of [boltz](https://github.com/BoltzExchange)
