FROM debian:bookworm-slim

# Toolchain version argument is required for CI build system tagging
ARG TOOLCHAIN_VERSION=use-desired-python-version

ARG TARGETARCH

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
    unzip \
    libgl1 \
    libglib2.0-0 \
    cmake \
    lcov \
    && apt-get clean

# Install clang-tidy and clang-format from LLVM apt repos
ARG LLVM_VERSION=21
RUN apt-get update -y && apt-get -y install \
    lsb-release \
    software-properties-common \
    gnupg \
    && curl -fsSL https://apt.llvm.org/llvm.sh -o /tmp/llvm.sh \
    && chmod +x /tmp/llvm.sh \
    && /tmp/llvm.sh ${LLVM_VERSION} \
    && apt-get -y install clang-format-${LLVM_VERSION} clang-tidy-${LLVM_VERSION} \
    && ln -sf /usr/bin/clang-format-${LLVM_VERSION} /usr/bin/clang-format \
    && ln -sf /usr/bin/clang-tidy-${LLVM_VERSION} /usr/bin/clang-tidy \
    && ln -sf /usr/bin/run-clang-tidy-${LLVM_VERSION} /usr/bin/run-clang-tidy \
    && rm /tmp/llvm.sh \
    && apt-get -y purge lsb-release software-properties-common \
    && apt-get -y autoremove \
    && apt-get clean

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
# the proto compiler depends on python for the nanopb plugin.
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