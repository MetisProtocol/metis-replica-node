# Metis Replica Node

Replica node is using P2P now.

# Prerequisite

- Linux(x86_64)
- docker
- Ethereum node with full history

FYI, check out https://docs.docker.com/engine/install/ if you don't know how to install docker.

## Recommended hardware specification

AWS c5.2xlarge

gp3 with 200 MB/s throughput

# Setup a replica node

If you want to upgrade from the legacy replica node, please refer to this documentation.

## Clone the repository

```
git clone https://github.com/MetisProtocol/metis-replica-node
```

## Update configuration

```
cp docker-compose-mainnet.yml docker-compose.yml
```

Most configurations can be set through environment variables, please refer to [config.md](./config.md) for details.

Add your eth rpc to the `.env` file

```
DATA_TRANSPORT_LAYER__L1_RPC_ENDPOINT=https://eth-node-example.com
```

**Optional: Archive mode**

if you need an archive node, you can add following environment variables to l2geth service.

```yaml
l2geth:
  environment:
    GCMODE: archive
```

**Optional: change volumes**

By default, replica node creates a `chaindata` directory in the current directory.

You can change the volumes configuration in your compose file to customize the storage directory.

```yaml
# redacted
services:
  dtl:
    volumes:
      - ./chaindata/l1dtl:/data # the volume mapping for dtl

  l2geth:
    volumes:
      - ./chaindata/l2geth:/root/.ethereum # the volume mapping for l2geth
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

## Upgrade from legacy replica node

1. Prepare an ETH L1 node without history prune

Not an archive node, but transaction and event logs should be retained

Why?

Since we use p2p to setup a node, you can't trust your peers.

Many transactions, for example, deposits from L1, you can't verify them from p2p.

so it's a security consideration.

If you use your self maintained go-ethereum client

please don't set very high value for following key, 100 is recommended value.

if you use rpc from a third party, the value can set very high like 100k due to they have optimized for the queries.

```
DATA_TRANSPORT_LAYER__LOGS_PER_POLLING_INTERVAL=100
DATA_TRANSPORT_LAYER__TRANSACTIONS_PER_POLLING_INTERVAL=100
```

2. Delete configurations for legacy replica node

```
$ rm -rf ./chaindata/l2geth/keystore
```

3. Update compose file and env

**NOTE: legacy replica node uses L2 DTL, you can't use the data and configration.**

## Quick start from snapshots

We provided public aws ebs snapshot for you if you need them.

l1dtl

snap-048e442e36aac56d2

archived l2geth

snap-040e6cd4c9a877911

You can use the snapshots on aws us-east-1 region, and copy them to another region.

1. You need to delete the nodekey to enable p2p connections

```
$ rm -rf ./chaindata/l2geth/geth/nodeky
```

2. You must add `GCMODE=archived` env to the l2geth service if you use the l2geth snapshot
