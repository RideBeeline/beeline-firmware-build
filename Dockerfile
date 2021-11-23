FROM ghcr.io/charliebruce/nrf5-docker-build:sdk-17.1.0
MAINTAINER Charlie Bruce <charlie@beeline.co>

RUN apt-get update && \
apt-get install -y libgl1 && \
apt-get clean

RUN pip3 install opencv-python
