-include .env
EOSIO_PVTKEY=5JtBeSgEtTDMS2gKDuJ5beF28BEvibLohdG1oD6W389greggjat
EOSIO_PUBKEY=EOS8hG5XKMrSep4xzZq3ivQ5mLn3apLTpCmmbDP1L272nrBnz9yqG
EOSIO_WALLET_MASTER_PVTKEY=5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3
EOSIO_WALLET_MASTER_PUBKEY=EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV
GENESIS_JSON=./genesis.json
WALLET_PWD_NAME=default
IP=$(shell ipconfig getifaddr en0 || hostname -I | awk '{print $$1}')
WALLET_URL=http://$(IP):8889
SEED_NODE_URL=http://$(IP):8888

PRODUCER_TAG="issue/test-producer:$(shell git ls-files -s services/producer | git hash-object --stdin)"
WALLET_TAG="issue/test-wallet:$(shell git ls-files -s services/wallet | git hash-object --stdin)"
BOOT_TUTORIAL_TAG="issue/boot-tutorial:$(shell git ls-files -s eosio-boot-tutorial | git hash-object --stdin)"

ifneq ("$(wildcard .env)", "")
	export $(shell sed 's/=.*//' .env)
endif

MAKE_ENV := EOSIO_PVTKEY EOSIO_PUBKEY
MAKE_ENV := GENESIS_JSON
MAKE_ENV += EOSIO_WALLET_MASTER_PVTKEY EOSIO_WALLET_MASTER_PUBKEY
MAKE_ENV += WALLET_URL SEED_NODE_URL

SHELL_EXPORT := $(foreach v,$(MAKE_ENV),$(v)='$($(v))')

print:
	@echo $(SHELL_EXPORT)

stop-all:
	@./stop-services.sh

delete-volumes: stop-all
	@sudo rm -Rf \
		services/producer/data-dir \
		services/wallet/data-dir;

build-boot-tutorial:
	@docker build \
		-t $(BOOT_TUTORIAL_TAG) \
		./eosio-boot-tutorial;

build-wallet:
	@docker build \
		-t $(WALLET_TAG) \
		services/wallet;

build-producer:
	@docker build \
		-t $(PRODUCER_TAG) \
		services/producer;

run-boot-tutorial: build-boot-tutorial
	@docker run \
		-it --entrypoint bash \
		$(BOOT_TUTORIAL_TAG)

run-producer: build-producer
	@docker run \
		-dit \
		--env DATA_DIR=/root/data-dir \
		--env CONFIG_DIR=/opt/application/config \
		--volume $(PWD)/services/producer/data-dir:/root/data-dir \
		-p 0.0.0.0:8888:8888 \
		-p 0.0.0.0:9876:9876 \
		$(PRODUCER_TAG)

run-wallet: build-wallet
	@docker run \
		-dit \
		--env DATA_DIR=/root/data-dir \
		--env CONFIG_DIR=/opt/application/config \
		--volume $(PWD)/services/wallet/data-dir:/root/data-dir \
		-p 0.0.0.0:8889:8888 \
		$(WALLET_TAG)

run-init-scripts: delete-volumes run-producer run-wallet
	@$(SHELL_EXPORT) $(PWD)/init-chain/init.sh

.DEFAULT_GOAL := run-init-scripts
