#!/bin/sh
set -eou

RETRIES=${RETRIES:-40}
VERBOSITY=${VERBOSITY:-3}

if [ -z "$DATADIR" ]; then
    echo "Must pass DATADIR"
    exit 1
fi
if [ -z "$BLOCK_SIGNER_PRIVATE_KEY" ]; then
    echo "Must pass BLOCK_SIGNER_PRIVATE_KEY"
    exit 1
fi
if [ -z "$BLOCK_SIGNER_PRIVATE_KEY_PASSWORD" ]; then
    echo "Must pass BLOCK_SIGNER_PRIVATE_KEY_PASSWORD"
    exit 1
fi
if [ -z "$L2GETH_GENESIS_URL" ]; then
    echo "Must pass L2GETH_GENESIS_URL"
    exit 1
fi
if [[ -z $BLOCK_SIGNER_ADDRESS ]]; then
    echo "Must pass BLOCK_SIGNER_ADDRESS"
    exit 1
fi

# Check for an existing chaindata folder.
# If it exists, assume it's correct and skip geth init step
GETH_CHAINDATA_DIR=$DATADIR/geth/chaindata

echo "$GETH_CHAINDATA_DIR missing, running geth init"
echo "Retrieving genesis file $L2GETH_GENESIS_URL"
TEMP_DIR=$(mktemp -d)
wget -O "$TEMP_DIR"/genesis.json "$L2GETH_GENESIS_URL"
geth init --datadir=/"$DATADIR" "$TEMP_DIR"/genesis.json

# Delete temp dir
rm -rf $TEMP_DIR

# Check for an existing keystore folder.
# If it exists, assume it's correct and skip geth acount import step
GETH_KEYSTORE_DIR=$DATADIR/keystore
mkdir -p "$GETH_KEYSTORE_DIR"
GETH_KEYSTORE_KEYS=$(find "$GETH_KEYSTORE_DIR" -type f)

if [ ! -z "$GETH_KEYSTORE_KEYS" ]; then
    echo "$GETH_KEYSTORE_KEYS exist, skipping account import if any keys are present"
else
    echo "$GETH_KEYSTORE_DIR missing, running account import"
    echo -n "$BLOCK_SIGNER_PRIVATE_KEY_PASSWORD" >"$DATADIR"/password
    echo -n "$BLOCK_SIGNER_PRIVATE_KEY" >"$DATADIR"/block-signer-key
    geth account import \
        --datadir=/"$DATADIR" \
        --password "$DATADIR"/password \
        "$DATADIR"/block-signer-key
fi

echo "l2geth setup complete"

# start the geth peer node
echo "Starting Geth peer node"
exec geth \
    --datadir "$DATADIR" \
    --verbosity="$VERBOSITY" \
    --password "$DATADIR/password" \
    --allow-insecure-unlock \
    --unlock $BLOCK_SIGNER_ADDRESS \
    --mine \
    --miner.etherbase $BLOCK_SIGNER_ADDRESS \
    --syncmode full \
    --gcmode archive \
    "$@"
