#!/bin/bash
# Build script for VS Code sysroot with gcc 10.5.0 and glibc 2.28
# This script builds sysroots for x86_64 and aarch64 architectures using crosstool-ng

set -e

# Configuration
GCC_VERSION="10.5.0"
GLIBC_VERSION="2.28"
BUILD_DIR="/build"
OUTPUT_DIR="/output"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Build sysroot for a specific architecture
build_sysroot() {
    local arch=$1
    local config_file=$2
    local target_triple=$3

    log_info "Building sysroot for ${arch} (${target_triple})..."

    # Create working directory
    local work_dir="${BUILD_DIR}/toolchain-${arch}"
    mkdir -p "${work_dir}"
    cd "${work_dir}"

    # Copy config file
    cp "${BUILD_DIR}/configs/${config_file}" .config

    # Build the toolchain
    log_info "Running crosstool-ng build for ${arch}..."
    ct-ng build

    # Copy sysroot to output
    local sysroot_src="${work_dir}/${target_triple}/${target_triple}/sysroot"
    local sysroot_dst="${OUTPUT_DIR}/sysroot-${arch}-glibc-${GLIBC_VERSION}"

    if [ -d "${sysroot_src}" ]; then
        log_info "Copying sysroot to output directory..."
        mkdir -p "${sysroot_dst}"
        cp -a "${sysroot_src}/"* "${sysroot_dst}/"

        # Add version info
        echo "GCC: ${GCC_VERSION}" > "${sysroot_dst}/VERSION"
        echo "GLIBC: ${GLIBC_VERSION}" >> "${sysroot_dst}/VERSION"
        echo "Architecture: ${arch}" >> "${sysroot_dst}/VERSION"
        echo "Build date: $(date -u +%Y-%m-%d)" >> "${sysroot_dst}/VERSION"

        log_info "Sysroot for ${arch} built successfully!"
    else
        log_error "Sysroot directory not found: ${sysroot_src}"
        exit 1
    fi
}

# Parse command line arguments
ARCH="${1:-all}"

case "${ARCH}" in
    x86_64)
        mkdir -p "${OUTPUT_DIR}"
        build_sysroot "x86_64" "x86_64-gcc-${GCC_VERSION}-glibc-${GLIBC_VERSION}.config" "x86_64-linux-gnu"
        ;;
    aarch64)
        mkdir -p "${OUTPUT_DIR}"
        build_sysroot "aarch64" "aarch64-gcc-${GCC_VERSION}-glibc-${GLIBC_VERSION}.config" "aarch64-linux-gnu"
        ;;
    all)
        mkdir -p "${OUTPUT_DIR}"
        build_sysroot "x86_64" "x86_64-gcc-${GCC_VERSION}-glibc-${GLIBC_VERSION}.config" "x86_64-linux-gnu"
        build_sysroot "aarch64" "aarch64-gcc-${GCC_VERSION}-glibc-${GLIBC_VERSION}.config" "aarch64-linux-gnu"
        ;;
    *)
        log_error "Unknown architecture: ${ARCH}"
        echo "Usage: $0 [x86_64|aarch64|all]"
        exit 1
        ;;
esac

log_info "Build complete! Sysroots are available in ${OUTPUT_DIR}"
ls -la "${OUTPUT_DIR}"
