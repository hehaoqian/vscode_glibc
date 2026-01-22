# Dockerfile for building VS Code sysroot with gcc 10.5.0 and glibc 2.28
# Based on https://code.visualstudio.com/docs/remote/faq
# and https://github.com/microsoft/vscode-linux-build-agent

FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG ARCH=x86_64

# Install dependencies required by crosstool-ng
RUN apt-get update && apt-get install -y \
    gcc g++ gperf bison flex texinfo help2man make libncurses5-dev \
    python3-dev autoconf automake libtool libtool-bin gawk wget bzip2 xz-utils unzip \
    patch rsync meson ninja-build git curl ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install crosstool-ng 1.26.0
ENV CT_VERSION=1.26.0
RUN wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-${CT_VERSION}.tar.bz2 \
    && tar -xjf crosstool-ng-${CT_VERSION}.tar.bz2 \
    && cd crosstool-ng-${CT_VERSION} \
    && ./configure --prefix=/opt/crosstool-ng \
    && make \
    && make install \
    && cd .. \
    && rm -rf crosstool-ng-${CT_VERSION} crosstool-ng-${CT_VERSION}.tar.bz2

ENV PATH="/opt/crosstool-ng/bin:${PATH}"

# Create build directory
WORKDIR /build

RUN groupadd -g 1000 ubuntu && \
    useradd -m -u 1000 -g 1000 ubuntu

RUN chown 1000:1000 /build

USER 1000:1000

# Copy config files and build script
COPY configs/ /build/configs/
COPY build.sh /build/build.sh

# Default command
CMD ["/build/build.sh"]
