FROM ghcr.io/charliebruce/nrf5-docker-build:sdk-17.1.0

# Toolchain version argument is required for CI build system tagging
ARG TOOLCHAIN_VERSION=17.1.0

ARG PYTHON_VERSION=3.13.9

RUN apt-get update && \
apt-get install -y libgl1 && \
apt-get clean

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

RUN uv pip install \
    numpy \
    opencv-python