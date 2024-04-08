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

## Quick start from snapshots

We provided public aws ebs snapshot for you if you need them.

l1dtl

snap-052e67eaa50dd7e84

l2geth

snap-0382a5d7113eed8ff

**Don't forget to delete the nodekey if the node key exists**

```
$ rm -rf path-to-l2geth/geth/nodekey
```
