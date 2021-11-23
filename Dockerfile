FROM ghcr.io/charliebruce/nrf5-docker-build:sdk-15.2.0_ubuntu2004 
MAINTAINER Charlie Bruce <charlie@beeline.co>

RUN apt-get update && \
apt-get install -y libgl1 && \
apt-get clean

RUN pip3 install opencv-python
