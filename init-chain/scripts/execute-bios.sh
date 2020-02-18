#!/usr/bin/env bash
set -ux

source $(dirname $0)/helpers.sh

EOSIO_CONTRACTS=/opt/eosio.contracts/build/contracts
EOSIO_OLD_CONTRACTS=/opt/old-eosio.contracts/build/contracts

create_wallet default $WALLET_PWD_NAME
import_private_key default $EOSIO_WALLET_MASTER_PVTKEY
import_private_key default $EOSIO_PVTKEY
startBoot
echo "Waiting on boot node to start...";
sleep 5s;
create_system_accounts
install_system_contracts
create_tokens
set_system_contract
# initSystemContract
# createStakedAccounts
# regProducers
# startProducers
# vote
# claimRewards
# proxyVotes
# resign
# replaceSystem
# transfer
# log
# transfer
