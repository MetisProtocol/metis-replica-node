# Metis Replica Node

This repository is deprecated

please use [metis-ansible](https://github.com/MetisProtocol/metis-ansible) and [metis-charts](https://github.com/metisprotocol/metis-charts) instead.

# Prerequisite

- Linux(x86_64)
- docker
- Ethereum node with full history

FYI, check out https://docs.docker.com/engine/install/ if you don't know how to install docker.

## Recommended hardware specification

AWS c5.2xlarge

gp3 with 200 MB/s throughput

Open 30303 tcp/udp port for p2p connnections

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
$ rm -rf path-to-l2geth/keystore
```

3. Update compose file and env

- Don't delete data of your l2geth, you can still use it!
- Don't change `GCMODE` env you're using
- Must not use the data and configration of l2dtl, current replica node uses l1dtl instead
- You can use the snapshot to spin up your l1dtl service. and we will update the snapshot id in the latest release from time to time.
- The env files have many changes, if you want to own custom configurations, make sure that your understand the result first.

## Quick start from snapshots

We provided public aws ebs snapshot for you if you need them.

l1dtl

snap-052e67eaa50dd7e84

l2geth

snap-0382a5d7113eed8ff

You can use the snapshots on aws us-east-1 region, and copy them to another region you are using.

We don't provide it on oss like s3, because it's very very slow to create, download and restore.

You can use the snapshots to start an rpc in 20 minutes, but you will take more than 5 hours if you use oss.

Finally, Don't forget to delete the nodekey to enable p2p connections

```
$ rm -rf path-to-l2geth/geth/nodekey
```
