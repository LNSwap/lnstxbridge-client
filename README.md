# LN-STX Bridge Client

This is a light client to interface with [lnstxbridge](https://github.com/pseudozach/lnstxbridge) to facilitate submarine/atomic swaps between Lightning Network/onchain BTC <-> STX/USDA/(Any SIP10 token) on Stacks

* Allows client to register to main lnstxbridge instance in order to signal supported pairs.
* Accept and Execute trustless swaps
* Running on https://lnswap.org
> In order to join the aggregator lnswap.org send an email to [join@lnswap.org](mailto:join@lnswap.org) to be added to access list.

## install with script (experimental)
* copy and paste the below command into your umbrel/raspiblitz/mynode and follow the instructions  
`bash <(curl -s https://cdn.jsdelivr.net/gh/pseudozach/lnstxbridge-client@main/install.sh)`

## install with docker-compose
* follow instructions at [docker-compose/readme.md](https://github.com/pseudozach/lnstxbridge-client/blob/main/docker-compose/readme.md)

## install - regtest/mocknet
* clone the repo, install requirements and compile  
`git clone https://github.com/pseudozach/lnstxbridge-client.git`  
`cd lnstxbridge-client && npm i && npm run compile`  
* start btc & lnd  
`npm run docker:regtest`
* copy boltz.conf to ~/.lnstx/boltz.conf and modify as needed  
* start the app  
`npm run start`

## Docs
Documentation available at [lnswap docs](https://docs.lnswap.org/quick-start).

## Accounting
if you need to generate yearly reports of your client activity,  
* download and install [balanceofsatoshis](https://github.com/alexbosworth/balanceofsatoshis)  
`npm install -g balanceofsatoshis`  
* generate accounting reports from your LND node
```
bos accounting "chain-receives" --year 2022 -v --disable-fiat --csv > chain_receives_2022.csv
bos accounting "chain-sends" --year 2022 -v --disable-fiat --csv > chain_sends_2022.csv
bos accounting "invoices" --year 2022 -v --disable-fiat --csv > invoices_2022.csv
bos accounting "payments" --year 2022 -v --disable-fiat --csv > payments_2022.csv
```


## Acknowledgements
This is a simplified fork of lnstxbridge which is a fork of [boltz](https://github.com/BoltzExchange)
