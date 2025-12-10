# bullseye is the latest stable release of debian
FROM debian:bookworm-slim

# Toolchain version argument is required for CI build system tagging
ARG TOOLCHAIN_VERSION=3.13.9

ARG PYTHON_VERSION=${TOOLCHAIN_VERSION}


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
    && apt-get clean


WORKDIR /home


# Install uv and python 
# Download the latest installer
ADD https://astral.sh/uv/0.9.10/install.sh /uv-installer.sh

# Run the installer then remove it
RUN sh /uv-installer.sh && rm /uv-installer.sh

# Ensure the installed binary is on the `PATH`
ENV PATH="/root/.local/bin/:$PATH"

RUN uv python install ${PYTHON_VERSION}
# Create a virtual environment at /opt/venv using the installed Python
RUN uv venv /opt/venv --python ${PYTHON_VERSION}
# Add the virtual environment to the PATH so 'python' and 'pip' work globally
ENV PATH="/opt/venv/bin:$PATH"
# Set VIRTUAL_ENV so 'uv' knows to use this environment automatically
ENV VIRTUAL_ENV=/opt/venv

COPY requirements-bcore.txt /home/requirements-bcore.txt
RUN uv pip install -r /home/requirements-bcore.txt

COPY requirements-honeypy.txt /home
RUN uv pip install -r /home/requirements-honeypy.txt