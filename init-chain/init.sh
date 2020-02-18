#!/usr/bin/env bash

# if [[ -f ".env" ]]; then
#   export $(cat .env | xargs)
# fi


echo "Building the docker image...";
docker build \
  -t issue/init-chain:latest \
  init-chain;

echo "Running the scripts..."
docker run \
  -it --entrypoint bash \
  --env GENESIS_JSON=$GENESIS_JSON \
  --env EOSIO_PVTKEY=$EOSIO_PVTKEY \
  --env EOSIO_PUBKEY=$EOSIO_PUBKEY \
  --env EOSIO_WALLET_MASTER_PVTKEY=$EOSIO_WALLET_MASTER_PVTKEY \
  --env EOSIO_WALLET_MASTER_PUBKEY=$EOSIO_WALLET_MASTER_PUBKEY \
  --env WALLET_URL=$WALLET_URL \
  --env WALLET_PWD_NAME=$WALLET_PWD_NAME \
  --env SEED_NODE_URL=$SEED_NODE_URL \
  issue/init-chain:latest;
