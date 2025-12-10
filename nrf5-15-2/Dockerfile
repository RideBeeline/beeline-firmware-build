FROM ghcr.io/charliebruce/nrf5-docker-build:sdk-15.2.0

ARG TOOLCHAIN_VERSION=15.2.0



# Temporarily install GCC 9 from the Ubuntu toolchain PPA so numpy can compile
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libgl1 \
        libglib2.0-0 \
        software-properties-common \
        ca-certificates && \
    add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc-9 \
        g++-9 \
        gfortran-9 \
        make \
        ninja-build \
        pkg-config \
        libopenblas-dev \
        libopenblas-base && \
    apt-mark manual libopenblas-base && \
    rm -rf /var/lib/apt/lists/*

# Install uv and python 
# Download the latest installer
ADD https://astral.sh/uv/0.9.10/install.sh /uv-installer.sh


# Run the installer then remove it
RUN sh /uv-installer.sh && rm /uv-installer.sh

# Ensure the installed binary is on the `PATH`
ENV PATH="/root/.local/bin/:$PATH"

# We use Python 3.13 everywhere else but there are no numpy wheels for 3.13 and compiling from source 
RUN uv python install 3.13.9
# Create a virtual environment at /opt/venv using the installed Python
RUN uv venv /opt/venv --python 3.13.9
# Add the virtual environment to the PATH so 'python' and 'pip' work globally
ENV PATH="/opt/venv/bin:$PATH"
# Set VIRTUAL_ENV so 'uv' knows to use this environment automatically
ENV VIRTUAL_ENV=/opt/venv



RUN CC=gcc-9 CXX=g++-9 FC=gfortran-9 uv pip install \
    numpy \
    opencv-python

# Clean up unnecessary build tools to reduce image size
RUN apt-get purge -y \
    gcc-9 \
    g++-9 \
    gfortran-9 \
    ninja-build \
    pkg-config \
    libopenblas-dev \
    software-properties-common && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libgl1 \
        libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/*

