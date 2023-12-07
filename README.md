# Metis Replica Node

It retrives data from L2 nodes, and no blocks lag behind.

# Prerequisite

- Linux(x86_64)
- docker
- docker-compose v2

FYI, check out https://docs.docker.com/engine/install/ if you don't know how to install docker.

## Recommended hardware specification

RAM: 8 GB (4 GB at least)

CPU: 4 cores (2 cores at least)

Storage:

Minimum 50GB for a full node and 250GB for an archive node (make sure it is extendable)

# Setup a replica node

## Clone the repository

```
git clone https://github.com/ericlee42/metis-replica-node
```

## Update configuration

```
cp docker-compose-mainnet.yml docker-compose.yml
```

if you want to use testnet, use `docker-compose-testnet.yml` file instead.

Most configurations can be set through environment variables, please refer to [config.md](./config.md) for details.

**Optional: Archive mode**

if you need an archive node, you can add following environment variables to l2geth service.

```yaml
l2geth:
  environment:
    GCMODE: archive
    # enable debug api if you need it
    RPC_API: eth,net,web3,debug
    WS_API: eth,net,web3,debug
```

**Optional: graphql**

if you need the graphql api, you can add the following to l2geth.

```yaml
# redacted
l2geth:
  entrypoint: ["sh", "/scripts/geth.sh"]
  command:
    - --graphql
    - --graphql.addr=0.0.0.0
    - --graphql.port=8547
    - --graphql.corsdomain=*
    - --graphql.vhosts=*
  ports:
    - 8547:8547
```

**Optional: change volumes**

By default, replica node creates a `chaindata` directory in the current directory.

You can change the volumes configuration in your compose file to customize the storage directory.

```yaml
# redacted
services:
  dtl:
    volumes:
      - ./chaindata/dtl:/data # the volume mapping for dtl

  l2geth:
    volumes:
      - ./chaindata/l2geth:/root/.ethereum # the volume mapping for l2geth
      - ./scripts:/scripts
```

## Start the services

```console
$ docker-compose up -d
```

It means the start-up was successful if you see the both services are healthy.

```console
$ docker-compose ps
NAME                          IMAGE                                          COMMAND                 SERVICE   CREATED              STATUS                        PORTS
metis-replica-node-dtl-1      metisdao/data-transport-layer:20230713210754   "./dtl.sh"              dtl       About a minute ago   Up About a minute (healthy)   7878/tcp
metis-replica-node-l2geth-1   metisdao/l2geth:20230713220744                 "sh /scripts/geth.sh"   l2geth    About a minute ago   Up 57 seconds (healthy)       0.0.0.0:8545-8546->8545-8546/tcp, 8547/tcp
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
