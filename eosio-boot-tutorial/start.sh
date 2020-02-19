#!/usr/bin/env bash

python3 bios-boot-tutorial.py \
  --cleos="cleos --wallet-url http://127.0.0.1:6666 " \
  --nodeos=nodeos \
  --keosd=keosd \
  --contracts-dir="/opt/eosio.contracts/build/contracts/" \
  --old-contracts-dir="/opt/old-eosio.contracts/build/contracts/" \
  -w \
  -a
