# bullseye is the latest stable release of debian
FROM python:3.13.2-bullseye

# tzdata presents an interactive prompt to set time zone.
ENV DEBIAN_FRONTEND=noninteractive

ARG TARGETARCH

# Download tools and prerequisites
RUN apt-get update && \
apt-get install -y curl git unzip bzip2 build-essential srecord pkg-config libusb-1.0.0 && \
apt-get clean all 

# Download and install the toolchain
RUN echo "Host architecture: $TARGETARCH" && \
case $TARGETARCH in \
    "amd64") \
        TOOLCHAIN_URL="https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz?rev=e434b9ea4afc4ed7998329566b764309&hash=CA590209F5774EE1C96E6450E14A3E26" \
        ;; \
    "arm64") \
        TOOLCHAIN_URL="https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-aarch64-arm-none-eabi.tar.xz?rev=17baf091942042768d55c9a304610954&hash=06E4C2BB7EBE7C70EA4EA51ABF9AAE2D" \
        ;; \
    *) \
        echo "Unsupported TARGETARCH: \"$TARGETARCH\"" >&2 && \
        exit 1 ;; \
esac && \
curl -SL "${TOOLCHAIN_URL}" > /tmp/toolchain.tar.xz && \
# tar xvjf /tmp/toolchain.tar.bz2 -C /usr/local/ && \
# rm /tmp/toolchain.tar.bz2
tar xf /tmp/toolchain.tar.xz -C /usr/local/ && \
rm /tmp/toolchain.tar.xz 

# Add the toolchain to the PATH
ENV PATH="/usr/local/arm-gnu-toolchain-13.2.Rel1-aarch64-arm-none-eabi/bin/:${PATH}"

RUN apt-get update && \
apt-get install -y libgl1 && \
apt-get clean

RUN pip3 install opencv-python