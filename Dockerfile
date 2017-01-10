FROM ubuntu:16.04
MAINTAINER Chetan Padia <chet@beeline.co>

RUN apt-key update && \
    apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:team-gcc-arm-embedded/ppa && \
    sh -c 'curl -sL https://deb.nodesource.com/setup_6.x | bash -' && \
    apt-get update && \
    apt-get install -y curl git unzip build-essential gcc-arm-embedded=6-2016q4-1~xenial1 libssl-dev srecord openocd pkg-config nodejs s3cmd python && \
    apt-get clean all

# NRF51 SDK v10
ADD https://developer.nordicsemi.com/nRF5_SDK/nRF51_SDK_v10.x.x/nRF51_SDK_10.0.0_dc26b5e.zip /nRF51_SDK_10.0.0_dc26b5e.zip
RUN mkdir -p /nrf51/nRF51_SDK_10.0.0 && unzip -q ../../nRF51_SDK_10.0.0_dc26b5e.zip -d /nrf51/nRF51_SDK_10.0.0
