# Metis Andromeda Replica

You may not need this, you can use our [public rpc](https://docs.metis.io/building-on-metis/connection-details).

It retrives data from L2 nodes, and no blocks lag behind.

# Required

- docker
- docker-compose

# Setup a replica node

## clone the repository

```
git clone https://github.com/ericlee42/metis-replica-node-guide
```

## Change config

```
cp docker-compose-mainnet.yml docker-compose.yml
```

change `DATA_TRANSPORT_LAYER__L1_RPC_ENDPOINT` config, it's your L1 node rpc endpoint.

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

## Start proxy server

```sh
docker-compose up -d proxy
```

[Proxy server](https://github.com/ericlee42/metis-proxy) is responsible for forwarding traffic to local replica and sequencer node

## RPC exmaple

```console
$ curl --header 'Content-Type: application/json'  'http://localhost:8545' --data-raw '{"id": "1","jsonrpc": "2.0","method": "eth_chainId","params": []}'
{"jsonrpc":"2.0","id":"1","result":"0x440"}

$ curl --header 'Content-Type: application/json'  'http://localhost:8545' --data-raw '{"id": "1","jsonrpc": "2.0","method": "eth_syncing","params": []}'
{"jsonrpc":"2.0","id":"1","result":false}

$ curl --header 'Content-Type: application/json'  'http://localhost:8545' --data-raw '{"id": "1","jsonrpc": "2.0","method": "eth_getBlockByNumber","params": ["latest",false]}'
{"jsonrpc":"2.0","id":"1","result":{"difficulty":"0x1","extraData":"0x000000000000000000000000000000000000000000000000000000000000000000000398232e2064f896018496b4b44b3d62751f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000","gasLimit":"0x4190ab00","gasUsed":"0x0","hash":"0x9e3354e081a54a57190bdb8948a597c840ea5dd496b0322864d4585f4a716892","logsBloom":"0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000","miner":"0x0000000000000000000000000000000000000000","mixHash":"0x0000000000000000000000000000000000000000000000000000000000000000","nonce":"0x0000000000000000","number":"0x0","parentHash":"0x0000000000000000000000000000000000000000000000000000000000000000","receiptsRoot":"0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421","sha3Uncles":"0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347","size":"0x26f","stateRoot":"0x86c9b145f467994ffb6b07274d02bf7bb302a7caac27a97823e1c9f456e3c1e3","timestamp":"0x0","totalDifficulty":"0x1","transactions":[],"transactionsRoot":"0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421","uncles":[]}}

$ curl -X POST 'http://localhost:8080' -H 'Content-Type: application/json' --data-raw '{"id": "1","jsonrpc": "2.0","method": "eth_sendRawTransaction","params": ["0x"]}'
```

Note: The `8546` port is a read-only websocket port for now, you could not use it for `eth_sendRawTransaction` rpc method
