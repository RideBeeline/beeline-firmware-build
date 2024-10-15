FROM python:3.10.13-bullseye

RUN apt-get -y upgrade

# avoid stuck build due to user prompt
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get -y install build-essential srecord

WORKDIR /home

# create and activate virtual environment

COPY requirements.txt /home

RUN pip install --upgrade pip
RUN pip install --trusted-host pypi.python.org -r requirements.txt