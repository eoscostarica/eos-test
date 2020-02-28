# EOS TEST for running a 2.0.1 network from scratch

### Clarification
This is a test project with two ideas, eventually provide a showcase using
docker to provide a private network that could be almost production ready;
the other idea is to ask the community for a bug we're facing with 2.0.x

# UPDATE - 02/28
I recently started to work directly with the python script since is the one that has given me the best results so far.

So the proces goes like this so far:
- We start a producer node and a wallet node, the producer node doesn't have the genesis json information at all.
- The boot node has the genesis.json file, and is the one we interact with for publishing contracts, features and actions.
- Right now, the old version of the smart contracts (needed for activation of `WTMSIG_BLOCK_SIGNATURES` feature), is published using brute force.
- The newest version of the smart contracts (1.9.x) is not being deployed, it keeps failing with roughly the same bugs as the old version of the smart contracts but it never gets published despite of retrying lots of times.

## Running the project
Before you run the project, you should have Docker installed.

The main make target is `run-init-scripts` which takes a while to run but
mainly what it does is:
- It makes sure that producer and wallet nodes are off and brand new (`delete-volumes` and `stop-all` targets)
- Builds and run both producer and wallet scripts (`run-producer`, `build-producer`, `run-wallet` and `build-wallet`)
- Runs the init chain script which builds and starts the docker image that runs them (`run-init-scripts`)

It takes quite a while to run all of that so you can just go ahead and go grab a cup of coffee for now, but once it ends
you can just execute `./scripts/execute-bios.sh` and watch the output, it'll fail stating something like this:
```
Reading WASM from /opt/old-eosio.contracts/build/contracts/eosio.system/eosio.system.wasm...
Publishing contract...
error 2020-02-17T21:56:40.409 cleos     main.cpp:4013                 main                 ] Failed with error: deadline 2020-02-17T21:56:40.396 exceeded by 120us  (2)
deadline 2020-02-17T21:56:40.396 exceeded by 120us
```

The other thing I tried was following along the `boot-tutorial` at the eosio project,
you can see the latest code in the `/eosio-boot-tutorial` directory, and if you want to take
that for a spin, just `make run-boot-tutorial`, and you'll find that the result is the same I got
with my custom docker setup.
