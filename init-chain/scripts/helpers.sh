#!/usr/bin/env bash

# Throws error when using unset variable
set -uex

# Alias cleos with endpoint param to avoid repetition
cleos="cleos -u $SEED_NODE_URL --wallet-url $WALLET_URL"
# Alias bcleos with endpoint parameter pointing at local boot node
bcleos="cleos -u http://0.0.0.0:8888 --wallet-url $WALLET_URL"

# Unlocks the default wallet and waits .5 seconds
function unlock_wallet () {
  wallet_name=${1:-default};
  echo "Unlocking $wallet_name wallet..."
  $cleos wallet unlock -n $wallet_name --password $(cat /opt/application/secrets/$wallet_name-wallet-password.txt)
  sleep .5
}

# Creates the default wallet and stores the password
function create_wallet () {
  wallet_name=${1:-main-wallet};
  wallet_secret_name=${2:-main-wallet}
  echo "Creating $wallet_name wallet ..."
  mkdir -p /opt/application/secrets
  $cleos wallet create -n $wallet_name --to-console \
    | awk 'FNR > 3 { print $1 }' \
    | tr -d '"' \
    > /opt/application/secrets/$wallet_name-wallet_password.txt
  sleep .5
}

# Helper function to import private key into the gtchain wallet
function import_private_key () {
  $cleos wallet import -n $1 --private-key $2
}

# Creates an account on the chain
function create_eos_account () {
  $cleos create account eosio $1 $2 $3
}

function create_system_accounts () {
  $bcleos create account eosio eosio.bpay $EOSIO_PUBKEY --use-old-rpc
  $bcleos create account eosio eosio.msig $EOSIO_PUBKEY --use-old-rpc
  $bcleos create account eosio eosio.names $EOSIO_PUBKEY --use-old-rpc
  $bcleos create account eosio eosio.ram $EOSIO_PUBKEY --use-old-rpc
  $bcleos create account eosio eosio.ramfee $EOSIO_PUBKEY --use-old-rpc
  $bcleos create account eosio eosio.saving $EOSIO_PUBKEY --use-old-rpc
  $bcleos create account eosio eosio.stake $EOSIO_PUBKEY --use-old-rpc
  $bcleos create account eosio eosio.token $EOSIO_PUBKEY --use-old-rpc
  $bcleos create account eosio eosio.vpay $EOSIO_PUBKEY --use-old-rpc
  $bcleos create account eosio eosio.rex $EOSIO_PUBKEY --use-old-rpc
}

function install_system_contracts () {
  $bcleos set contract eosio.token $EOSIO_CONTRACTS/eosio.token/ --use-old-rpc
  $bcleos set contract eosio.msig $EOSIO_CONTRACTS/eosio.msig/ --use-old-rpc
}

function create_tokens () {
  $bcleos push action eosio.token create '[ "eosio", "100000000000.0000 SYS"]' -p eosio.token@active --use-old-rpc
  $bcleos push action eosio.token issue '[ "eosio", "100000000000.0000 SYS", "initial supply" ]' -p eosio@active --use-old-rpc
}

function startBoot () {
  mkdir -p /var/log/nodeos;
  nodeos \
    --max-irreversible-block-age -1 \
    --contracts-console \
    --genesis-json $GENESIS_JSON \
    --blocks-dir /opt/data-dir/bocks \
    --data-dir /opt/data-dir \
    --config-dir /opt/data-dir \
    --chain-state-db-size-mb 1024 \
    --http-server-address 0.0.0.0:8888 \
    --p2p-listen-endpoint 0.0.0.0:9999 \
    --p2p-peer-address 192.168.1.113:9876 \
    --enable-stale-production \
    --producer-name eosio \
    --private-key "[\"$EOSIO_WALLET_MASTER_PUBKEY\", \"$EOSIO_WALLET_MASTER_PVTKEY\"]" \
    --plugin eosio::http_plugin \
    --plugin eosio::chain_api_plugin \
    --plugin eosio::chain_plugin \
    --plugin eosio::producer_api_plugin \
    --plugin eosio::producer_plugin \
    2> /var/log/nodeos/error.log \
    > /var/log/nodeos/output.log &
}

function set_system_contract () {
  # get the PREACTIVATE_FEATURE key
  PREACTIVATE_FEATURE=$(http POST \
    $SEED_NODE_URL/v1/producer/get_supported_protocol_features \
    | jq -r '.[] | select(.specification[].value == "PREACTIVATE_FEATURE") | .feature_digest' \
  );

  echo "Activating protocol features...";
  http --ignore-stdin POST \
    $SEED_NODE_URL/v1/producer/schedule_protocol_feature_activations \
    body="{\"protocol_features_to_activate\": [\"$PREACTIVATE_FEATURE\"]}";

  sleep 3s;

  $bcleos set contract eosio $EOSIO_OLD_CONTRACTS/eosio.system/ -p eosio

  echo "Activating protocol features...";
  # GET_SENDER
  $bcleos push action eosio activate '["f0af56d2c5a48d60a4a5b5c903edfb7db3a736a94ed589d0b797df33ff9d3e1d"]' -p eosio

  # FORWARD_SETCODE
  $bcleos push action eosio activate '["2652f5f96006294109b3dd0bbde63693f55324af452b799ee137a81a905eed25"]' -p eosio

  # ONLY_BILL_FIRST_AUTHORIZER
  $bcleos push action eosio activate '["8ba52fe7a3956c5cd3a656a3174b931d3bb2abb45578befc59f283ecd816a405"]' -p eosio

  # RESTRICT_ACTION_TO_SELF
  $bcleos push action eosio activate '["ad9e3d8f650687709fd68f4b90b41f7d825a365b02c23a636cef88ac2ac00c43"]' -p eosio

  # DISALLOW_EMPTY_PRODUCER_SCHEDULE
  $bcleos push action eosio activate '["68dcaa34c0517d19666e6b33add67351d8c5f69e999ca1e37931bc410a297428"]' -p eosio

  # FIX_LINKAUTH_RESTRICTION
  $bcleos push action eosio activate '["e0fb64b1085cc5538970158d05a009c24e276fb94e1a0bf6a528b48fbc4ff526"]' -p eosio

  # REPLACE_DEFERRED
  $bcleos push action eosio activate '["ef43112c6543b88db2283a2e077278c315ae2c84719a8b25f25cc88565fbea99"]' -p eosio

  # NO_DUPLICATE_DEFERRED_ID
  $bcleos push action eosio activate '["4a90c00d55454dc5b059055ca213579c6ea856967712a56017487886a4d4cc0f"]' -p eosio

  # ONLY_LINK_TO_EXISTING_PERMISSION
  $bcleos push action eosio activate '["1a99a59d87e06e09ec5b028a9cbb7749b4a5ad8819004365d02dc4379a8b7241"]' -p eosio

  # RAM_RESTRICTIONS
  $bcleos push action eosio activate '["4e7bf348da00a945489b2a681749eb56f5de00b900014e137ddae39f48f69d67"]' -p eosio

  # WEBAUTHN_KEY
  $bcleos push action eosio activate '["4fca8bd82bbd181e714e283f83e1b45d95ca5af40fb89ad3977b653c448f78c2"]' -p eosio

  # WTMSIG_BLOCK_SIGNATURES
  $bcleos push action eosio activate '["299dcb6af692324b899b39f16d5a530a33062804e41f09dc97e9f156b4476707"]' -p eosio
}
