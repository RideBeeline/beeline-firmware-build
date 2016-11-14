FROM ubuntu:16.04
MAINTAINER Chetan Padia <chet@beeline.co>

## dev tools
RUN sh -c "echo 'deb http://httpredir.debian.org/debian experimental main' >> /etc/apt/sources.list"
RUN apt-key update && apt-get update
RUN apt-get install -y software-properties-common curl git s3cmd
RUN add-apt-repository ppa:team-gcc-arm-embedded/ppa
RUN sh -c 'curl -sL https://deb.nodesource.com/setup_6.x | bash -'
RUN apt-get update
RUN apt-get install --allow-unauthenticated -y build-essential gcc-arm-embedded srecord openocd
RUN apt-get install -y pkg-config nodejs unzip python
## setup openssl 1.1.0 to match Win10 environment
RUN apt-get -t experimental install -y --allow-unauthenticated libssl-dev

ADD nRF51_SDK_10.0.0_dc26b5e.zip /nRF51_SDK_10.0.0_dc26b5e.zip
RUN mkdir -p /nrf51/nRF51_SDK_10.0.0
RUN sh -c 'cd /nrf51/nRF51_SDK_10.0.0 && unzip -q ../../nRF51_SDK_10.0.0_dc26b5e.zip'

