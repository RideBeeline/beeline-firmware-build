FROM ubuntu:22.04 AS base
WORKDIR /workdir

# Toolchain version argument is required for CI build system tagging
ARG TOOLCHAIN_VERSION=v3.3.0-preview2

ARG TARGETARCH
ARG NCS_VERSION=${TOOLCHAIN_VERSION}

ARG DESIRED_PYTHON_VERSION
ENV PYTHON_VERSION=${DESIRED_PYTHON_VERSION}

ENV DEBIAN_FRONTEND=noninteractive

# Make sure shell commands fail the build if something goes wrong
SHELL [ "/bin/bash", "-euxo", "pipefail", "-c" ]

# You can find a table at
# https://docs.nordicsemi.com/bundle/ncs-3.3.0-preview2/page/nrf/installation/recommended_versions.html
# NCS v3.3.0-preview2 requires Zephyr SDK 0.17.0.

ARG ZEPHYR_SDK_VERSION=0.17.0
ARG CMAKE_VERSION=4.2.1

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends\
        git \
        wget \
        curl \
        unzip \
        clang-format \
        make \
        ninja-build\
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
        libgl1 \
        libglib2.0-0 \
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


# cmake: install pinned version from official binary release
RUN CMAKE_ARCH=$(uname -m) && \
    wget -q "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-${CMAKE_ARCH}.sh" \
        -O /tmp/cmake.sh && \
    sh /tmp/cmake.sh --prefix=/usr/local --skip-license && \
    rm /tmp/cmake.sh


# --- PYTHON INSTALLATION AND SETUP ---

#
# Install required Python using uv (https://astral.sh/uv/)
#
WORKDIR /home

# Download installer, run it, then remove it
ADD https://astral.sh/uv/0.9.26/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh
ENV PATH="/root/.local/bin/:$PATH"

# Create a virtual environment at /opt/venv with the desired Python version
RUN uv python install $PYTHON_VERSION
RUN uv venv /opt/venv --python $PYTHON_VERSION

# Add the virtual environment to the PATH so 'python' and 'pip' work globally
ENV PATH="/opt/venv/bin:$PATH"

# Make this the default uv environment globally and for all projects
ENV VIRTUAL_ENV=/opt/venv

# Set sensible defaults 
ENV UV_NO_PROGRESS=1
ENV UV_NO_DEV=1
ENV UV_LOCKED=1

# --- ZEPHYR SDK INSTALLATION ---
# This replaces the "Nordic Toolchain Manager". 

# Map Docker's TARGETARCH to Zephyr SDK's architecture naming
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        echo "x86_64" > /tmp/arch; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        echo "aarch64" > /tmp/arch; \
    else \
        # Fallback for local builds
        uname -m > /tmp/arch; \
    fi

# Download and extract the zephyr SDK
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

#
# Python dependencies
# We need both the ncs and the zephyr dependencies!

# Fetch NCS requirements (ADD for cache invalidation on content change)
ADD https://raw.githubusercontent.com/nrfconnect/sdk-nrf/${NCS_VERSION}/doc/requirements.txt /tmp/ncs-requirements.txt

# Fetch Zephyr requirements by parsing the pinned revision from the NCS west manifest.
# Use the GitHub API to discover all requirements*.txt files dynamically (they may change between versions),
# download them all to /tmp/, then install.
RUN uv pip install pyyaml && \
    WEST_YML=$(curl -fsSL "https://raw.githubusercontent.com/nrfconnect/sdk-nrf/${NCS_VERSION}/west.yml") && \
    ZEPHYR_REVISION=$(echo "${WEST_YML}" | \
        python3 -c "import sys, yaml; data=yaml.safe_load(sys.stdin); projects=data['manifest']['projects']; zephyr=next(p for p in projects if p['name']=='zephyr'); print(zephyr['revision'])") && \
    ZEPHYR_REPO=$(echo "${WEST_YML}" | \
        python3 -c "import sys, yaml; data=yaml.safe_load(sys.stdin); projects=data['manifest']['projects']; zephyr=next(p for p in projects if p['name']=='zephyr'); url=zephyr.get('url', ''); print(url.replace('https://github.com/', '') if url else 'nrfconnect/sdk-zephyr')") && \
    echo "Zephyr repo: ${ZEPHYR_REPO}, revision: ${ZEPHYR_REVISION}" && \
    BASE="https://raw.githubusercontent.com/${ZEPHYR_REPO}/${ZEPHYR_REVISION}/scripts" && \
    curl -fsSL "https://api.github.com/repos/${ZEPHYR_REPO}/contents/scripts?ref=${ZEPHYR_REVISION}" | \
        python3 -c "import sys, json; [print(f['name']) for f in json.load(sys.stdin) if f['name'].startswith('requirements') and f['name'].endswith('.txt')]" | \
    while read f; do curl -fsSL "${BASE}/${f}" -o "/tmp/${f}"; done && \
    uv pip install -r /tmp/ncs-requirements.txt -r /tmp/requirements.txt

WORKDIR /workdir

#
# Now we set the default uv project environment to home/venv which will be the named volume mount point
#
ENV UV_PROJECT_ENVIRONMENT=/home/venv
ENV UV_LINK_MODE=copy
