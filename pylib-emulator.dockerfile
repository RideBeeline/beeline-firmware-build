# bullseye is the latest stable release of debian
FROM debian:bookworm-slim

# Toolchain version argument is required for CI build system tagging
ARG TOOLCHAIN_VERSION=use-desired-python-version

ARG DESIRED_PYTHON_VERSION
ENV PYTHON_VERSION=${DESIRED_PYTHON_VERSION}


RUN apt-get -y upgrade

# avoid stuck build due to user prompt
ARG DEBIAN_FRONTEND=noninteractive

# install mingw-w64 cross-compiler so we can build windows binaries too
# curl for uv
# and libgl1 for opencv
RUN apt-get update -y && apt-get -y install \
    mingw-w64 \
    build-essential \
    srecord \
    git \
    curl \
    libgl1 \
    libglib2.0-0 \
    cmake \
    clang-format \
    clang-tidy \
    && apt-get clean

#
# Install required Python using uv (https://astral.sh/uv/)
#
WORKDIR /home

# Download installer, run it, then remove it
ADD https://astral.sh/uv/0.9.26/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh
ENV PATH="/root/.local/bin/:$PATH"

RUN uv python install $PYTHON_VERSION

# Make this the default uv environment globally and for all projects to be /home/venv 
# This will be the mount point for the venv named volume
ENV VIRTUAL_ENV=/home/venv
ENV UV_PROJECT_ENVIRONMENT=/home/venv
ENV UV_LINK_MODE=copy

# Set sensible defaults 
ENV UV_NO_PROGRESS=1
ENV UV_NO_DEV=1
ENV UV_LOCKED=1