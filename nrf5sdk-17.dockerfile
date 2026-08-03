FROM ghcr.io/charliebruce/nrf5-docker-build:sdk-17.1.0

# Toolchain version argument is required for CI build system tagging
ARG TOOLCHAIN_VERSION=17.1.0

ARG TARGETARCH

ARG DESIRED_PYTHON_VERSION
ENV PYTHON_VERSION=${DESIRED_PYTHON_VERSION}

# Put the ARM GCC toolchain binaries (arm-none-eabi-readelf, etc.) on PATH so
# build tools can find them without an absolute path.
ENV PATH="/usr/local/gcc-arm-none-eabi-9-2020-q2-update/bin:$PATH"

RUN apt-get update && \
apt-get install -y libgl1 libglib2.0-0 cmake bzip2 && \
apt-get clean

# bear (compile_commands.json capture): 
# 3.1.6 is the newest conda-forge bear that runs on this focal
# base - 4.x requires glibc >= 2.33 and focal has 2.31. 
RUN set -eux; \
    case "$TARGETARCH" in \
      amd64) MAMBA_ARCH=linux-64 ;; \
      arm64) MAMBA_ARCH=linux-aarch64 ;; \
      *) echo "unsupported arch: $TARGETARCH" >&2; exit 1 ;; \
    esac; \
    curl -fLs "https://micro.mamba.pm/api/micromamba/${MAMBA_ARCH}/latest" \
      | tar -xj -C /usr/local/bin --strip-components=1 bin/micromamba; \
    MAMBA_ROOT_PREFIX=/opt/mamba micromamba create -y -p /opt/bear -c conda-forge bear=3.1.6; \
    MAMBA_ROOT_PREFIX=/opt/mamba micromamba clean -a -y
ENV PATH="/opt/bear/bin:$PATH"

# install protobuf compiler that's compatible with our pinned protobuf python API (6.33.2)
# protobuf releases use "x86_64" / "aarch_64" (note the underscore) in artifact names.
ENV PROTOC_VERSION=33.2
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        PROTOC_ARCH=x86_64; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        PROTOC_ARCH=aarch_64; \
    else \
        echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1; \
    fi && \
    curl -fLO "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-${PROTOC_ARCH}.zip" && \
    unzip "protoc-${PROTOC_VERSION}-linux-${PROTOC_ARCH}.zip" -d /usr/local && \
    rm "protoc-${PROTOC_VERSION}-linux-${PROTOC_ARCH}.zip"


#
# Install required Python using uv (https://astral.sh/uv/)
#
WORKDIR /home

# Download installer, run it, then remove it
ADD https://astral.sh/uv/0.9.26/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh
ENV PATH="/root/.local/bin/:$PATH"

RUN uv python install $PYTHON_VERSION
# the proto compiler depends on python for the nanopb plugin, so we need to make this available
# it's done here, as in CI no uv sync is done, so this environment would be empty.
# NOTE: this venv gets mounted and uv sync can run on it. THat will update all packages if an update is available, or remove
# if they are not in the uv lock file!
RUN uv venv /home/venv --python $PYTHON_VERSION

# Make this the default uv environment globally and for all projects to be /home/venv 
# This will be the mount point for the venv named volume
ENV PATH="/home/venv/bin:$PATH"
ENV VIRTUAL_ENV=/home/venv
ENV UV_PROJECT_ENVIRONMENT=/home/venv
ENV UV_LINK_MODE=copy

# Set sensible defaults 
ENV UV_NO_PROGRESS=1
ENV UV_NO_DEV=1
ENV UV_LOCKED=1

# finally, install protobuf. make sure the version is pinned and the same across all builds.
RUN uv pip install protobuf==6.33.2