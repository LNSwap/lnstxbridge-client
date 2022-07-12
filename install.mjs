/* eslint-disable no-empty */
/* eslint-disable no-undef */
/* eslint-disable semi */

// run this as `npx zx --experimental install.mjs`

$.verbose = false

echo`
₿₿\\      ₿₿\\\\   ₿₿\\  ₿₿₿₿₿₿\\  ₿₿\\      ₿₿\\  ₿₿₿₿₿₿\\  ₿₿₿₿₿₿₿\\  
₿₿ |     ₿₿₿\\  ₿₿ |₿₿  __₿₿\\ ₿₿ | ₿\\  ₿₿ |₿₿  __₿₿\\ ₿₿  __₿₿\\ 
₿₿ |     ₿₿₿₿\\ ₿₿ |₿₿ /  \\__|₿₿ |₿₿₿\\ ₿₿ |₿₿ /  ₿₿ |₿₿ |  ₿₿ |
₿₿ |     ₿₿ ₿₿\\₿₿ |\\₿₿₿₿₿₿\\  ₿₿ ₿₿ ₿₿\\₿₿ |₿₿₿₿₿₿₿₿ |₿₿₿₿₿₿₿  |
₿₿ |     ₿₿ \\₿₿₿₿ | \\____₿₿\\ ₿₿₿₿  _₿₿₿₿ |₿₿  __₿₿ |₿₿  ____/ 
₿₿ |     ₿₿ |\\₿₿₿ |₿₿\\   ₿₿ |₿₿₿  / \\₿₿₿ |₿₿ |  ₿₿ |₿₿ |      
₿₿₿₿₿₿₿₿\\₿₿ | \\₿₿ |\\₿₿₿₿₿₿  |₿₿  /   \\₿₿ |₿₿ |  ₿₿ |₿₿ |      
\\________\\__|  \\__| \\______/ \\__/     \\__|\\__|  \\__|\\__|      


Welcome to LN-STX Bridge Client installation.
Great to see you deciding to join lnswap.org Swap Provider Network. 

Please confirm you have requirements listed below:
1- Bitcoin full Node (unpruned)
2- LND Lightning Node 
3- Always available server/VM/self-hosted node`
let reqMet = await question('y/N? ')
if (reqMet !== 'y') {
    echo('Please install all requirements and try again.')
    $`exit`
}

let tosMet = await question('I understand that this is experimental software that may cause loss of funds. y/N? ')
if (tosMet !== 'y') {
    echo('You need to agree to the recklessness of this network to join.')
    $`exit`
}

// required variables
let BITCOIN_IP = '127.0.0.1'
let BITCOIN_RPC_PORT = '8332'
let BITCOIN_RPC_USER = 'rpcuser'
let BITCOIN_RPC_PASS = 'rpcpass'
let BITCOIN_NETWORK = 'mainnet'
let BITCOIN_COOKIE_FILE = '~/.bitcoin/.cookie'
let BITCOIN_zmqpubrawblock = 'tcp://127.0.0.1:28332'
let BITCOIN_zmqpubrawtx='tcp://127.0.0.1:28333'
let LND_IP = '127.0.0.1'
let LND_GRPC_PORT = '10009'
let LND_CERT_PATH = '~/.lnd/tls.cert'
let LND_MACAROON_PATH = '~/.lnd/data/chain/bitcoin/mainnet/admin.macaroon'
let APP_LNSWAP_API_IP = 'localhost'
let APP_PASSWORD = 'changeme!!!'
let APP_PORT = '9008'
let APP_FOLDER = '~/.lnstx-client'

await spinner('Searching for bitcoin node...',
    async () => {
        try {
            console.log(chalk.blue('Checking local bitcoin node installation...'))
            const localbitcoind = await $`pidof bitcoind`
            const dockerbitcoind = await $`docker ps | grep -i bitcoin || [[ $? == 1 ]]` // || [[ $? == 1 ]] so grep doesnt exit and $ throws error
            // const bitcoinconf = $`cat ~/.bitcoin/bitcoin.conf`
            if (localbitcoind) {
                    let isTestnet = await $`cat ~/.bitcoin/bitcoin.conf | grep testnet=1 | grep -v '#' || [[ $? == 1 ]]`
                    let rpcPort = await $`cat ~/.bitcoin/bitcoin.conf | grep rpcport= | grep -v '#' || [[ $? == 1 ]]`
                    let rpcUser = await $`cat ~/.bitcoin/bitcoin.conf | grep rpcuser= | grep -v '#' || [[ $? == 1 ]]`
                    let rpcPass = await $`cat ~/.bitcoin/bitcoin.conf | grep rpcpassword= | grep -v '#' || [[ $? == 1 ]]`
                    if (isTestnet.stdout.length > 0) {
                        BITCOIN_RPC_PORT = '18332'
                        BITCOIN_NETWORK = 'testnet'
                        BITCOIN_COOKIE_FILE = '~/.bitcoin/testnet3/.cookie'
                    }
                    if (rpcPort.stdout.length > 0) BITCOIN_RPC_PORT=rpcPort
                    if (rpcUser.stdout.length > 0) BITCOIN_RPC_USER=rpcUser
                    if (rpcPass.stdout.length > 0) BITCOIN_RPC_PASS=rpcPass
            } else if (dockerbitcoind) {
                console.log(chalk.blue('Checking docker bitcoind installation...'))
                let bitcoinIp = await question('Enter your docker Bitcoin Node IP (127.0.0.1): ')
                let bitcoinRpcPort = await question('Enter your docker Bitcoin Node RPC PORT (8332): ')
                let bitcoinRpcUser = await question('Enter your docker Bitcoin Node RPC USERNAME (rpcuser): ')
                let bitcoinRpcPass = await question('Enter your docker Bitcoin Node RPC PASSWORD (rpcpass): ')
                let bitcoinCookieFile = await question('Enter your docker Bitcoin Node COOKIE FILE LOCATION (~/.bitcoin/.cookie): ')
                let bitcoinNetwork = await question('Enter your docker Bitcoin Node IP (mainnet): ')
                if (bitcoinIp.stdout.length > 0) BITCOIN_IP=bitcoinIp
                if (bitcoinRpcPort.stdout.length > 0) BITCOIN_RPC_PORT=bitcoinRpcPort
                if (bitcoinRpcUser.stdout.length > 0) BITCOIN_RPC_USER=bitcoinRpcUser
                if (bitcoinRpcPass.stdout.length > 0) BITCOIN_RPC_PASS=bitcoinRpcPass
                if (bitcoinCookieFile.stdout.length > 0) BITCOIN_COOKIE_FILE=bitcoinCookieFile
                if (bitcoinNetwork.stdout.length > 0) BITCOIN_NETWORK=bitcoinNetwork
            }
        } catch (error) {
            console.log(chalk.red('error ', error.message))
        }
    }
)

console.log(chalk.green(`Found bitcoin node with below data:\n
BITCOIN_IP = ${BITCOIN_IP}
BITCOIN_RPC_PORT = ${BITCOIN_RPC_PORT}
BITCOIN_RPC_USER = ${BITCOIN_RPC_USER}
BITCOIN_RPC_PASS = ${BITCOIN_RPC_PASS}
BITCOIN_NETWORK = ${BITCOIN_NETWORK}
BITCOIN_COOKIE_FILE = ${BITCOIN_COOKIE_FILE}
BITCOIN_zmqpubrawblock = ${BITCOIN_zmqpubrawblock}
BITCOIN_zmqpubrawtx = ${BITCOIN_zmqpubrawtx}
`))

await spinner('Searching for lightning node...',
    async () => {
        try {
            console.log(chalk.blue('Checking local lnd installation...'))
            const locallnd = await $`pidof lnd`
            const dockerlnd = await $`docker ps | grep -i lnd || [[ $? == 1 ]]` // || [[ $? == 1 ]] so grep doesnt exit and $ throws error
            if (locallnd) {
                    let isTestnetConf = await $`cat ~/.lnd/lnd.conf | grep bitcoin.testnet=true | grep -v '#' || [[ $? == 1 ]]`
                    let isTestnetProcess = await $`ps -ef | grep -i lnd | grep 'bitcoin.testnet' || [[ $? == 1 ]]`
                    if (isTestnetConf.stdout.length > 0 || isTestnetProcess.stdout.length > 0) {
                        LND_MACAROON_PATH = '~/.lnd/data/chain/bitcoin/testnet/admin.macaroon'
                    }
                    let grpcPort = await $`cat ~/.lnd/lnd.conf | grep rpclisten=localhost: | grep -v '#' || [[ $? == 1 ]]`
                    if (grpcPort.stdout.length > 0) {
                        LND_GRPC_PORT = grpcPort.stdout.split(':')[1]
                    }
            } else if (dockerlnd) {
                console.log(chalk.blue('Checking docker lnd installation...'))
                let lndIp = await question('Enter your docker LND Node IP (127.0.0.1): ')
                let grpcPort = await question('Enter your docker LND Node GRPC PORT (10009): ')
                let lndCertPath = await question('Enter your docker LND TLS Certificate File Path (~/.lnd/tls.cert): ')
                let lndMacaroonPath = await question('Enter your docker LND Admin Macaroon File Path (~/.lnd/data/chain/bitcoin/mainnet/admin.macaroon): ')
                if (lndIp.stdout.length > 0) LND_IP=lndIp
                if (grpcPort.stdout.length > 0) LND_GRPC_PORT=grpcPort
                if (lndCertPath.stdout.length > 0) LND_CERT_PATH=lndCertPath
                if (lndMacaroonPath.stdout.length > 0) LND_MACAROON_PATH=lndMacaroonPath
            }
        } catch (error) {
            console.log(chalk.red('error ', error.message))
        }
    }
)

console.log(chalk.green(`Found LND with below data:\n
LND_IP = ${LND_IP}
LND_GRPC_PORT = ${LND_GRPC_PORT}
LND_CERT_PATH = ${LND_CERT_PATH}
LND_MACAROON_PATH = ${LND_MACAROON_PATH}
`))

let resp = await fetch('https://api.ipify.org')
APP_LNSWAP_API_IP = await resp.text()
// console.log(chalk.green(`Identified Server IP: ${APP_LNSWAP_API_IP}\n`))
let appPort = await question('Choose a publicly reachable port to run the LNSwap Client (9008): ')
let appPassword = await question('Choose a password for dashboard access (changeme!!!): ')
let appFolder = await question('Choose a folder to keep LNSwap Client docker and config files (~/.lnstx-client): ')
if (appPort.stdout?.length > 0) APP_PORT=appPort
if (appPassword.stdout?.length > 0) APP_PASSWORD=appPassword
if (appFolder.stdout?.length > 0) APP_FOLDER=appFolder

console.log(chalk.green(`LNSwap Client Configuration:\n
APP_LNSWAP_API_IP = ${APP_LNSWAP_API_IP}
APP_PORT = ${APP_PORT}
APP_PASSWORD = ${APP_PASSWORD}
APP_FOLDER = ${APP_FOLDER}
`))

// install docker-compose if missing
let test = await $`$(uname -s)`
console.log(test)
let isCompose = await $`command -v docker-compose || [[ $? == 1 ]]`
if (isCompose.stdout?.length === 0) {
    console.log(chalk.blue('Installing docker-compose...'))
    let VERSION = await $`curl --silent https://api.github.com/repos/docker/compose/releases/latest | jq .name -r`
    let DESTINATION = '/usr/local/bin/docker-compose'
    await $`sudo curl -L https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-$(uname -s)-$(uname -m) -o ${DESTINATION}`
    await $`sudo chmod 755 ${DESTINATION}`
    console.log(chalk.green('docker-compose installation completed...'))
}

// # create lnstxbridge-client data folder
await $`mkdir -p ${APP_FOLDER}/data`

// # download docker-compose.yml
await $`curl -O "https://cdn.jsdelivr.net/gh/pseudozach/lnstxbridge-client@main/docker-compose/docker-compose.yml" -o ${APP_FOLDER}`

// replace collected data in docker-compose.yml for deployment
console.log(chalk.blue('preparing docker-compose template...'))
let osType = await $`echo $OSTYPE`
if (osType.includes('darwin')) {
    $`sed -i '' 's#$APP_DATA_DIR#'${APP_DATA_DIR}'#g' docker-compose.yml`
    $`sed -i '' 's#$LND_DATA_DIR#'${LND_DATA_DIR}'#g' docker-compose.yml`
    $`sed -i '' 's#$BITCOIN_IP#'${BITCOIN_IP}'#g' docker-compose.yml`
    $`sed -i '' 's#$BITCOIN_RPC_PORT#'${BITCOIN_RPC_PORT}'#g' docker-compose.yml`
    $`sed -i '' 's#$BITCOIN_RPC_USER#'${BITCOIN_RPC_USER}'#g' docker-compose.yml`
    $`sed -i '' 's#$BITCOIN_RPC_PASS#'${BITCOIN_RPC_PASS}'#g' docker-compose.yml`
    $`sed -i '' 's#$BITCOIN_NETWORK#'${BITCOIN_NETWORK}'#g' docker-compose.yml`
    $`sed -i '' 's#$LND_IP#'${LND_IP}'#g' docker-compose.yml`
    $`sed -i '' 's#$LND_GRPC_PORT#'${LND_GRPC_PORT}'#g' docker-compose.yml`
    $`sed -i '' 's#$APP_PASSWORD#'${APP_PASSWORD}'#g' docker-compose.yml`
    $`sed -i '' 's#$APP_LNSWAP_API_IP#'${APP_LNSWAP_API_IP}'#g' docker-compose.yml`
    $`sed -i '' 's#$APP_PORT#'${APP_PORT}'#g' docker-compose.yml`
} else {
    // linux
    $`sed -i 's#$APP_DATA_DIR#'${APP_DATA_DIR}'#g' docker-compose.yml`
    $`sed -i 's#$LND_DATA_DIR#'${LND_DATA_DIR}'#g' docker-compose.yml`
    $`sed -i 's#$BITCOIN_IP#'${BITCOIN_IP}'#g' docker-compose.yml`
    $`sed -i 's#$BITCOIN_RPC_PORT#'${BITCOIN_RPC_PORT}'#g' docker-compose.yml`
    $`sed -i 's#$BITCOIN_RPC_USER#'${BITCOIN_RPC_USER}'#g' docker-compose.yml`
    $`sed -i 's#$BITCOIN_RPC_PASS#'${BITCOIN_RPC_PASS}'#g' docker-compose.yml`
    $`sed -i 's#$BITCOIN_NETWORK#'${BITCOIN_NETWORK}'#g' docker-compose.yml`
    $`sed -i 's#$LND_IP#'${LND_IP}'#g' docker-compose.yml`
    $`sed -i 's#$LND_GRPC_PORT#'${LND_GRPC_PORT}'#g' docker-compose.yml`
    $`sed -i 's#$APP_PASSWORD#'${APP_PASSWORD}'#g' docker-compose.yml`
    $`sed -i 's#$APP_LNSWAP_API_IP#'${APP_LNSWAP_API_IP}'#g' docker-compose.yml`
    $`sed -i 's#$APP_PORT#'${APP_PORT}'#g' docker-compose.yml`
}

// # copy boltz.conf template to APP_DATA_DIR/data = ~/.lnstx-client inside container
await $`curl -O "https://cdn.jsdelivr.net/gh/pseudozach/lnstxbridge-client@main/docker-compose/lnstx-client/boltz.conf" -o ${APP_FOLDER}/data`

// # start containers
console.log(chalk.blue('starting containers...'))
await $`docker-compose up -d`
console.log(chalk.green('LNSwap client installation successfully finished 🚀'))