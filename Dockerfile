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

# GCC 7-2018-q2-update
RUN curl -SL https://developer.arm.com/-/media/Files/downloads/gnu-rm/7-2018q2/gcc-arm-none-eabi-7-2018-q2-update-linux.tar.bz2?revision=bc2c96c0-14b5-4bb4-9f18-bceb4050fee7?product=Downloads,64-bit,,Linux,7-2018-q2-update > /tmp/gcc-arm-none-eabi-7-2018-q2-update-linux.tar.bz2 && \
tar xvjf /tmp/gcc-arm-none-eabi-7-2018-q2-update-linux.tar.bz2 -C /usr/local/ && \
rm /tmp/gcc-arm-none-eabi-7-2018-q2-update-linux.tar.bz2

ENV PATH="${PATH}:/usr/local/gcc-arm-none-eabi-7-2018-q2-update/bin"

# Python3
RUN apt-get update && apt-get install -y python3 python3-pip

RUN pip3 install nrfutil

# OpenCV and dependencies
RUN apt-get install -y libgl1
RUN pip3 install opencv-python

