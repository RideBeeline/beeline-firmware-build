FROM ubuntu:20.04
MAINTAINER Charlie Bruce <charlie@beeline.co>

# tzdata presents an interactive prompt to set time zone.
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y curl git unzip bzip2 build-essential libssl-dev srecord pkg-config lib32z1 && \
    apt-get clean all

# NRF51 SDK v10
ADD https://developer.nordicsemi.com/nRF5_SDK/nRF51_SDK_v10.x.x/nRF51_SDK_10.0.0_dc26b5e.zip /nRF51_SDK_10.0.0_dc26b5e.zip
RUN mkdir -p /nrf51/nRF51_SDK_10.0.0 && unzip -q ../../nRF51_SDK_10.0.0_dc26b5e.zip -d /nrf51/nRF51_SDK_10.0.0

# GCC 9-2020-q2-update
RUN curl -SL https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/9-2020q2/gcc-arm-none-eabi-9-2020-q2-update-x86_64-linux.tar.bz2 > /tmp/gcc-arm-none-eabi-9-2020-q2-update-linux.tar.bz2 && \
tar xvjf /tmp/gcc-arm-none-eabi-9-2020-q2-update-linux.tar.bz2 -C /usr/local/ && \
rm /tmp/gcc-arm-none-eabi-9-2020-q2-update-linux.tar.bz2

ENV PATH="${PATH}:/usr/local/gcc-arm-none-eabi-9-2020-q2-update/bin"

# Python3
RUN apt-get update && apt-get install -y python3 python3-pip

RUN pip3 install nrfutil

# OpenCV and dependencies
RUN apt-get install -y libgl1
RUN pip3 install opencv-python

