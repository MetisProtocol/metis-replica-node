# Metis Replica Node

It retrives data from L2 nodes, and no blocks lag behind.

# Prerequisite

- Linux(x86_64)
- docker

FYI, check out https://docs.docker.com/engine/install/ if you don't know how to install docker.

## Recommended hardware specification

RAM: 8 GB (4 GB at least)

CPU: 4 cores (2 cores at least)

Storage:

Minimum 50GB for a full node and 300GB for an archive node (make sure it is extendable)

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
$ docker compose up -d
```

It means the start-up was successful if you see the both services are healthy.

```console
$ docker compose ps
NAME                          IMAGE                                          COMMAND                 SERVICE   CREATED              STATUS                        PORTS
metis-replica-node-dtl-1      metisdao/data-transport-layer:20230713210754   "./dtl.sh"              dtl       About a minute ago   Up About a minute (healthy)   7878/tcp
metis-replica-node-l2geth-1   metisdao/l2geth:20230713220744                 "sh /scripts/geth.sh"   l2geth    About a minute ago   Up 57 seconds (healthy)       0.0.0.0:8545-8546->8545-8546/tcp, 8547/tcp
```

## Check syncing status

You can't use `eth_syncing` to check if the node is fully synchronized.

You can compare the block number of the local l2geth with the block number of our public node to determine whether the local service has been synchronized.

If they are equal, which means that your l2geth has synchronized.

```console
$ curl -sS 'http://localhost:8545' --data-raw '{"id":"1","jsonrpc":"2.0","method":"eth_blockNumber","params":[]}' -H 'Content-Type: application/json'  | jq -r '.result' | xargs printf '%d\n'
26510
$ curl -sS 'https://andromeda.metis.io' --data-raw '{"id":"1","jsonrpc":"2.0","method":"eth_blockNumber","params":[]}' -H 'Content-Type: application/json'  | jq -r '.result' | xargs printf '%d\n'
9612875
```
