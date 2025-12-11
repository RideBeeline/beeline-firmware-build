# bullseye is the latest stable release of debian
FROM debian:bookworm-slim

# Toolchain version argument is required for CI build system tagging
ARG TOOLCHAIN_VERSION=python-version

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
    && apt-get clean


#
# Install required Python using uv (https://astral.sh/uv/)
#
WORKDIR /home

# Download installer, run it, then remove it
ADD https://astral.sh/uv/0.9.10/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh
ENV PATH="/root/.local/bin/:$PATH"

# Create a virtual environment at /opt/venv with the desired Python version
RUN uv python install $PYTHON_VERSION
RUN uv venv /opt/venv --python $PYTHON_VERSION

# Add the virtual environment to the PATH so 'python' and 'pip' work globally
ENV PATH="/opt/venv/bin:$PATH"

# Make this the default uv environment globally and for all projects
ENV VIRTUAL_ENV=/opt/venv
ENV UV_PROJECT_ENVIRONMENT=/opt/venv

# Install required python packages
COPY requirements-buildpy.txt .
RUN uv pip install -r requirements-buildpy.txt

COPY requirements-honeypy.txt .
RUN uv pip install -r requirements-honeypy.txt

