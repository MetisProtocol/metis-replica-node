# Metis Andromeda Replica

You may not need this, you can use our [public rpc](https://docs.metis.io/dev/get-started/metis-connection-details).

It retrives data from L2 nodes, and no blocks lag behind.

# Prerequisite

- Linux(x86_64)
- docker
- docker-compose v2

## Recommended hardware specification

RAM: 8 GB

CPU: 4 core(x86_64)

Storage: Minimum 200GB SSD (make sure it is extendable)

# Setup a replica node

## clone the repository

```
git clone https://github.com/ericlee42/metis-replica-node
```

## Change config

```
cp docker-compose-mainnet.yml docker-compose.yml
```

if you want to use testnet, you can use `docker-compose-testnet.yml` file.

you should change `DATA_TRANSPORT_LAYER__L1_RPC_ENDPOINT` environment variable in the `docker-compose.yml`, it's your Ethereum mainnnet rpc endpoint(You can use [infura](https://infura.io/) public serivce).

**Optional: change volumes**

By default, replica node creates a `chaindata` directory in the current directory. You can change the volumes configuration in your compose file to customize the storage directory.

## start the dtl service

```
docker-compose up -d dtl
```

If you get this log below, it means the start-up was successful

```conosle
$ docker-compose logs --tail=10 dtl
{"level":30,"time":1640763281396,"msg":"Service L1_Data_Transport_Service is starting..."}
{"level":30,"time":1640763281400,"msg":"Service L1_Data_Transport_Service is initializing..."}
{"level":30,"time":1640763281400,"msg":"Initializing L1 Data Transport Service..."}
{"level":30,"time":1640763281470,"msg":"Service L1_Transport_Server is initializing..."}
{"level":30,"time":1640763281486,"defaultBackend":"l1","l1GasPriceBackend":"l1","msg":"HTTP Server Options"}
{"level":30,"time":1640763281487,"url":"YOUR_L1_RPC_ENDPOINT","msg":"HTTP Server L1 RPC Provider initialized"}
{"level":30,"time":1640763281487,"url":"https://andromeda.metis.io/?owner=1088","msg":"HTTP Server L2 RPC Provider initialized"}
{"level":30,"time":1640763281487,"msg":"Service L1_Transport_Server has initialized."}
{"level":30,"time":1640763281488,"msg":"Service L2_Ingestion_Service is initializing..."}
{"level":30,"time":1640763281489,"msg":"Service L2_Ingestion_Service has initialized."}
{"level":30,"time":1640763281490,"msg":"Service L1_Data_Transport_Service has initialized."}
{"level":30,"time":1640763281490,"msg":"Service L1_Transport_Server is starting..."}
{"level":30,"time":1640763281491,"msg":"Service L2_Ingestion_Service is starting..."}
{"level":30,"time":1640763281496,"host":"0.0.0.0","port":7878,"msg":"Server started and listening"}
{"level":30,"time":1640763281499,"msg":"Service L1_Transport_Server can stop now"}
{"level":30,"time":1640763283225,"fromBlock":0,"toBlock":1001,"msg":"Synchronizing unconfirmed transactions from Layer 2 (Metis)"}
```

## start the l2geth service

```sh
docker-compose up -d l2geth
```

If you get this log below, it means the start-up was successful

```console
$ docker-compose logs --tail=10 l2geth
DEBUG[12-29|07:37:22.445] Allowed origin(s) for WS RPC interface [*]
INFO [12-29|07:37:22.445] WebSocket endpoint opened                url=ws://[::]:8546
INFO [12-29|07:37:23.259] Unlocked account                         address=0x00000398232E2064F896018496b4b44b3D62751F
INFO [12-29|07:37:23.259] Transaction pool price threshold updated price=0
INFO [12-29|07:37:23.259] Transaction pool price threshold updated price=0
INFO [12-29|07:37:23.259] Initializing Sync Service
INFO [12-29|07:37:23.260] Sealing paused, waiting for transactions
INFO [12-29|07:37:23.260] Set L2 Gas Price                         gasprice=40000000000
INFO [12-29|07:37:23.261] Set L1 Gas Price                         gasprice=150000000000
INFO [12-29|07:37:23.261] Set batch overhead                       overhead=2750
INFO [12-29|07:37:23.261] Set scalar                               scalar=40
INFO [12-29|07:37:23.261] Starting Verifier Loop                   poll-interval=15s timestamp-refresh-threshold=5m0s
INFO [12-29|07:37:23.391] Syncing transaction range                start=0 end=89000 backend=l2
DEBUG[12-29|07:37:24.528] Couldn't add port mapping                proto=tcp extport=30303 intport=30303 interface="UPnP or NAT-PMP" err="no UPnP or NAT-PMP router discovered"
INFO [12-29|07:37:38.274] Syncing transaction range                start=0 end=91100 backend=l2
INFO [12-29|07:37:53.248] Syncing transaction range                start=0 end=92923 backend=l2
INFO [12-29|07:38:08.247] Syncing transaction range                start=0 end=92923 backend=l2
INFO [12-29|07:38:23.231] Syncing transaction range                start=0 end=92924 backend=l2
INFO [12-29|07:38:38.224] Syncing transaction range                start=0 end=92926 backend=l2
```

## RPC example

```console
$ # get chain id
$ curl --data-raw '{
    "id":"1",
    "jsonrpc":"2.0",
    "method":"eth_chainId",
    "params":[]
}' -H 'Content-Type: application/json'  'http://localhost:8545'
{
    "jsonrpc":"2.0",
    "id":"1",
    "result":"0x440"
}
$ # get block by block number
$ curl --data-raw '{
    "id":"1",
    "jsonrpc":"2.0",
    "method":"eth_getBlockByNumber",
    "params":[
        "latest",
        false
    ]
}' -H 'Content-Type: application/json'  'http://localhost:8545'
{
    "jsonrpc":"2.0",
    "id":"1",
    "result":{
        "difficulty":"0x1",
        "extraData":"0x000000000000000000000000000000000000000000000000000000000000000000000398232e2064f896018496b4b44b3d62751f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        "gasLimit":"0x4190ab00",
        "gasUsed":"0x0",
        "hash":"0x9e3354e081a54a57190bdb8948a597c840ea5dd496b0322864d4585f4a716892",
        "logsBloom":"0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        "miner":"0x0000000000000000000000000000000000000000",
        "mixHash":"0x0000000000000000000000000000000000000000000000000000000000000000",
        "nonce":"0x0000000000000000",
        "number":"0x0",
        "parentHash":"0x0000000000000000000000000000000000000000000000000000000000000000",
        "receiptsRoot":"0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
        "sha3Uncles":"0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
        "size":"0x26f",
        "stateRoot":"0x86c9b145f467994ffb6b07274d02bf7bb302a7caac27a97823e1c9f456e3c1e3",
        "timestamp":"0x0",
        "totalDifficulty":"0x1",
        "transactions":[],
        "transactionsRoot":"0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
        "uncles":[]
    }
}
$ # Send a raw trasaction
$ curl --data-raw '{
    "id":"1",
    "jsonrpc":"2.0",
    "method":"eth_sendRawTransaction",
    "params":[
        "0xf86f81eb8503f5476a00825208940f8b20ed4eecf06eee385f837c94966ba5d800318819ac8532c2790000808208a3a0cde205bfcce3c47687362fbbf3a8c83ecb80c419b4fa751334e17db0a06a4010a0459c4b067ca808046fa8f61211d4876eec9394abcfeeb8e73eb4193f15368acf"
    ]
}' -H 'Content-Type: application/json' 'http://localhost:8545'
```

## Enable graphql service

```yaml
  l2geth:
    entrypoint: [ "sh", "/scripts/geth.sh" ]
    command:
      - --graphql
      - --graphql.addr=0.0.0.0
      - --graphql.port=8547
      - --graphql.corsdomain=*
      - --graphql.vhosts=*
    ports:
      - 8547:8547
```
You can follow these steps to place the above code in docker-compose.yml:

1. Clone the metis-replica-node repository to your local machine.
2. Navigate to the root directory of the repository.
3. Open the docker-compose.yml file in a text editor.
4. Find the l2geth section in the file, which should be under the services section.
5. Place the code block you provided under the l2geth section. Make sure to align it with the entrypoint and command sections.
6. Save the docker-compose.yml file.
