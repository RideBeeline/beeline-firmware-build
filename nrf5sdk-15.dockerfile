FROM ghcr.io/charliebruce/nrf5-docker-build:sdk-15.2.0

# Toolchain version argument is required for CI build system tagging
ARG TOOLCHAIN_VERSION=15.2.0

ARG DESIRED_PYTHON_VERSION
ENV PYTHON_VERSION=${DESIRED_PYTHON_VERSION}


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

#
# Install required python packages
#
COPY requirements-buildpy.txt .
RUN CC=gcc-9 CXX=g++-9 FC=gfortran-9 uv pip install -r requirements-buildpy.txt

