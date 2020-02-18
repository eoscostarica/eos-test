#!/usr/bin/env bash
echo "Starting eosio service ..."
pid=0

term_handler() {
  if [ $pid -ne 0 ]; then
    kill -SIGTERM "$pid";
    wait "$pid";
  fi
  exit 0;
}

start_nodeos() {
  nodeos \
    --config-dir $CONFIG_DIR \
    --data-dir $DATA_DIR \
    --max-transaction-time 1000 \
    -e \
    &
  sleep 5;
  if [ -z "$(pidof nodeos)" ]; then
    echo "DB is dirty most likely, starting with hard replay...";
    nodeos \
      --config-dir $CONFIG_DIR \
      --data-dir $DATA_DIR \
      --max-transaction-time 1000 \
      --hard-replay \
      -e \
      &
  fi
}

trap 'echo "Terminating eosio service...";kill ${!}; term_handler' 2 15;

start_nodeos

pid="$!"

while true
do
  tail -f /dev/null & wait ${!}
done
