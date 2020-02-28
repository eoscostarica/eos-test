FROM ubuntu:18.04

ENV WORK_DIR /opt/application
ENV EOSIO_PACKAGE_URL https://github.com/EOSIO/eos/releases/download/v2.0.1/eosio_2.0.1-1-ubuntu-18.04_amd64.deb
ENV EOSIO_CDT_OLD_URL https://github.com/EOSIO/eosio.cdt/releases/download/v1.6.3/eosio.cdt_1.6.3-1-ubuntu-18.04_amd64.deb
ENV EOSIO_CDT_URL https://github.com/EOSIO/eosio.cdt/releases/download/v1.7.0/eosio.cdt_1.7.0-1-ubuntu-18.04_amd64.deb
ENV GENESIS_JSON $WORKDIR/genesis.json

ENV SEED_NODE_URL http://host.docker.internal:8888
ENV WALLET_URL http://host.docker.internal:8889

# We need the recommended extra installs that come with
# wget package so it can handle SSL calls, also
# we can't remove the lists and apt cache just yet
# so we can install the eosio package properly
# hadolint ignore=DL3008,DL3009,DL3015
RUN apt-get update && apt-get install -y httpie wget build-essential cmake \
    ca-certificates curl apt-transport-https lsb-release gnupg libcurl4-openssl-dev libusb-1.0-0-dev libcurl3-gnutls libicu60 \
  && apt-get install -y --no-install-recommends jq git vim \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Define working directory
WORKDIR $WORK_DIR

RUN wget -O /eosio-v2.0.1.deb $EOSIO_PACKAGE_URL \
  && wget -O /eosio-cdt-v1.7.0.deb $EOSIO_CDT_URL \
  && wget -O /eosio-cdt-v1.6.3.deb $EOSIO_CDT_OLD_URL

RUN apt-get install -y /eosio-v2.0.1.deb

RUN apt-get install -y /eosio-cdt-v1.6.3.deb \
  && git clone https://github.com/EOSIO/eosio.contracts.git /opt/old-eosio.contracts \
  && cd /opt/old-eosio.contracts && git checkout release/1.8.x \
  && ./build.sh -e /usr/opt/eosio/2.0.1 -c /usr/opt/eosio.cdt/1.6.3 -y

RUN apt-get install -y /eosio-cdt-v1.7.0.deb \
  && git clone https://github.com/EOSIO/eosio.contracts.git /opt/eosio.contracts \
  && cd /opt/eosio.contracts && git checkout release/1.9.x \
  && ./build.sh -e /usr/opt/eosio/2.0.1 -c /usr/opt/eosio.cdt/1.7.0 -y

# Copy application code
COPY ./ $WORK_DIR

RUN chmod -R +x $WORK_DIR/scripts/

CMD ["/opt/application/scripts/execute-bios.sh"]
