# bullseye is the latest stable release of debian
FROM python:3.13.2-bullseye

RUN apt-get -y upgrade

# avoid stuck build due to user prompt
ARG DEBIAN_FRONTEND=noninteractive

# install mingw-w64 cross-compiler so we can build windows binaries too
RUN apt-get update -y && apt-get -y install mingw-w64 build-essential srecord git

WORKDIR /home

# create and activate virtual environment

COPY requirements.txt /home

RUN pip install --upgrade pip
RUN pip install --trusted-host pypi.python.org -r requirements.txt