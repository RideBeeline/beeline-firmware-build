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

# GCC ARM toolchain v11.2-2022.02
RUN curl -L -o /opt/gcc-arm-none-eabi.tar.xz https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/binrel/gcc-arm-11.2-2022.02-x86_64-arm-none-eabi.tar.xz 2>/dev/null && \
    tar xf /opt/gcc-arm-none-eabi.tar.xz -C /opt && \
    rm /opt/gcc-arm-none-eabi.tar.xz && \
    ln -s /opt/gcc-arm-11.2-2022.02-x86_64-arm-none-eabi /opt/gcc-arm-none-eabi
ENV PATH="${PATH}:/opt/gcc-arm-none-eabi/bin"

# Python3
RUN apt-get update && apt-get install -y python3 python3-pip

RUN pip3 install nrfutil

# OpenCV and dependencies
RUN apt-get install -y libgl1
RUN pip3 install opencv-python

