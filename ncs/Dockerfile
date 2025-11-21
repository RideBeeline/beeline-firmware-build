FROM ubuntu:22.04 AS base
WORKDIR /workdir


ARG NCS_VERSION=v3.1.1
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive

# Make sure shell commands fail the build if something goes wrong
SHELL [ "/bin/bash", "-euxo", "pipefail", "-c" ]


RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends\
        git \
        wget \
        curl \
        unzip \
        clang-format \
        make \
        cmake \
        ninja-build \
        gperf \
        device-tree-compiler \
        ccache \
        file \
        dfu-util \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        gcc \
        libncursesw5-dev \
        xz-utils \
        tk-dev \
        libxml2-dev \
        libxmlsec1-dev \
        libffi-dev \
        liblzma-dev \
        locales \
        git-lfs \
        ca-certificates && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* && \
    locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# --- PYTHON INSTALLATION AND SETUP ---

# Install uv and python 
# Download the latest installer
ADD https://astral.sh/uv/0.9.10/install.sh /uv-installer.sh


# Run the installer then remove it
RUN sh /uv-installer.sh && rm /uv-installer.sh

# Ensure the installed binary is on the `PATH`
ENV PATH="/root/.local/bin/:$PATH"

RUN uv python install 3.13.9
# Create a virtual environment at /opt/venv using the installed Python
RUN uv venv /opt/venv --python 3.13.9
# Add the virtual environment to the PATH so 'python' and 'pip' work globally
ENV PATH="/opt/venv/bin:$PATH"
# Set VIRTUAL_ENV so 'uv' knows to use this environment automatically
ENV VIRTUAL_ENV=/opt/venv
# Install pip packages needed for building nRF Connect SDK
RUN uv pip install \
    anytree \
    canopen \
    cbor2 \
    click==8.1.3 \
    cryptography>=44.0.2 \
    ecdsa \
    intelhex \
    packaging \
    progress \
    pyelftools>=0.29 \
    pylint \
    pyYAML \
    west \
    imgtool && \
    uv cache clean


# --- ZEPHYR SDK INSTALLATION ---
# This replaces the "Nordic Toolchain Manager". 
# NCS v3.1.1 requires Zephyr SDK 0.17.0. You can find a table at
# https://docs.nordicsemi.com/bundle/ncs-3.1.1/page/nrf/installation/recommended_versions.html

# Validate that NCS version is supported
RUN if [ "$NCS_VERSION" != "v3.1.1" ]; then \
    echo "Error: This Dockerfile only supports NCS_VERSION=v3.1.1, got: $NCS_VERSION" >&2 && \
    exit 1; \
    fi

ARG ZEPHYR_SDK_VERSION=0.17.0

# Map Docker's TARGETARCH to Zephyr SDK's architecture naming
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        echo "x86_64" > /tmp/arch; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        echo "aarch64" > /tmp/arch; \
    else \
        # Fallback for local builds
        uname -m > /tmp/arch; \
    fi

# Download and extract the SDK
# See https://docs.zephyrproject.org/latest/develop/toolchains/zephyr_sdk.html#toolchain-zephyr-sdk
RUN SDK_ARCH=$(cat /tmp/arch) && \
    SDK_FILE="zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-${SDK_ARCH}_minimal.tar.xz" && \
    wget -q "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_SDK_VERSION}/${SDK_FILE}" && \
    wget -qO - "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_SDK_VERSION}/sha256.sum" | sha256sum --check --ignore-missing && \
    tar xf "${SDK_FILE}" -C /opt/ && \
    rm "${SDK_FILE}"

WORKDIR /opt/zephyr-sdk-${ZEPHYR_SDK_VERSION}

# Run setup.sh to download ONLY arm and riscv toolchains
# This prevents extracting unused toolchains (xtensa, sparc, etc)
# Remove --show-progress from setup.sh to avoid log spam in CI
RUN sed -i 's/--show-progress//g' setup.sh && \
    ./setup.sh -t arm-zephyr-eabi -t riscv64-zephyr-elf -c



# Set environment variables so West knows where the toolchain is
ENV ZEPHYR_TOOLCHAIN_VARIANT=zephyr
ENV ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk-${ZEPHYR_SDK_VERSION}

WORKDIR /workdir
 




