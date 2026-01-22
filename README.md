# VS Code Sysroot Builder

[![Build Sysroot](https://github.com/YOUR_USERNAME/vscode_glibc/actions/workflows/build.yml/badge.svg)](https://github.com/YOUR_USERNAME/vscode_glibc/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Build sysroots with **GCC 10.5.0** and **glibc 2.28** for running VS Code Remote Development on older Linux distributions.

## Overview

Starting with VS Code release 1.99 (March 2025), the prebuilt servers distributed by VS Code are only compatible with Linux distributions that are based on glibc 2.28 or later (e.g., Debian 10, RHEL 8, Ubuntu 20.04).

This repository provides sysroots that can be used as a workaround to run VS Code Server on older Linux distributions that don't meet the glibc requirements. The sysroots are built using [crosstool-ng](https://crosstool-ng.github.io/) following the approach documented in the [VS Code Remote Development FAQ](https://code.visualstudio.com/docs/remote/faq#_can-i-run-vs-code-server-on-older-linux-distributions).

## Supported Architectures

- **x86_64** (AMD64)
- **aarch64** (ARM64)

## Toolchain Versions

| Component | Version |
|-----------|---------|
| GCC | 10.5.0 |
| glibc | 2.28 |
| binutils | 2.40 |
| Linux kernel headers | 6.4 |

## Usage

### Download Pre-built Sysroots

Download the pre-built sysroots from the [Releases](../../releases) page.

### Setting Up VS Code Remote Development

1. **Install patchelf** on the remote host (version >= 0.18.x recommended):
   ```bash
   # For Debian/Ubuntu
   apt-get install patchelf

   # Or build from source for newer versions
   git clone https://github.com/NixOS/patchelf
   cd patchelf && ./bootstrap.sh && ./configure && make && make install
   ```

2. **Extract the sysroot** on the remote host:
   ```bash
   tar -xzf vscode-sysroot-x86_64-gcc-10.5.0-glibc-2.28.tar.gz -C /opt/
   ```

3. **Set environment variables** (add to your shell profile, e.g., `~/.bashrc`):
   ```bash
   # For x86_64
   export VSCODE_SERVER_CUSTOM_GLIBC_LINKER=/opt/vscode-sysroot-x86_64-gcc-10.5.0-glibc-2.28/lib/ld-linux-x86-64.so.2
   export VSCODE_SERVER_CUSTOM_GLIBC_PATH=/opt/vscode-sysroot-x86_64-gcc-10.5.0-glibc-2.28/lib
   export VSCODE_SERVER_PATCHELF_PATH=/usr/local/bin/patchelf

   # For aarch64
   export VSCODE_SERVER_CUSTOM_GLIBC_LINKER=/opt/vscode-sysroot-aarch64-gcc-10.5.0-glibc-2.28/lib/ld-linux-aarch64.so.1
   export VSCODE_SERVER_CUSTOM_GLIBC_PATH=/opt/vscode-sysroot-aarch64-gcc-10.5.0-glibc-2.28/lib
   export VSCODE_SERVER_PATCHELF_PATH=/usr/local/bin/patchelf
   ```

4. **Connect** using VS Code Remote - SSH extension.

> **Important:** This approach is a technical workaround and is not an officially supported usage scenario by Microsoft.

## Building Locally

### Prerequisites

- Docker

### Build All Architectures

```bash
# Build the Docker image
docker build -t sysroot-builder:latest .

# Build sysroots for all architectures
mkdir -p output
docker run --rm -v $(pwd)/output:/output sysroot-builder:latest
```

### Build Specific Architecture

```bash
# Build only x86_64
docker run --rm -v $(pwd)/output:/output sysroot-builder:latest /build/build.sh x86_64

# Build only aarch64
docker run --rm -v $(pwd)/output:/output sysroot-builder:latest /build/build.sh aarch64
```

## Artifact Attestations

All release artifacts include [artifact attestations](https://docs.github.com/en/actions/security-guides/using-artifact-attestations-to-establish-provenance-for-builds) to establish provenance for builds.

You can verify the attestation using:
```bash
gh attestation verify vscode-sysroot-x86_64-gcc-10.5.0-glibc-2.28.tar.gz --repo YOUR_USERNAME/vscode_glibc
```

## Project Structure

```
.
├── .github/
│   └── workflows/
│       └── build.yml          # GitHub Actions CI/CD workflow
├── configs/
│   ├── x86_64-gcc-10.5.0-glibc-2.28.config    # crosstool-ng config for x86_64
│   └── aarch64-gcc-10.5.0-glibc-2.28.config   # crosstool-ng config for aarch64
├── Dockerfile                  # Build environment
├── build.sh                    # Build script
├── LICENSE                     # MIT License
└── README.md                   # This file
```

## References

- [VS Code Remote Development FAQ](https://code.visualstudio.com/docs/remote/faq)
- [VS Code Linux Build Agent](https://github.com/microsoft/vscode-linux-build-agent)
- [crosstool-ng Documentation](https://crosstool-ng.github.io/docs/)
- [patchelf](https://github.com/NixOS/patchelf)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Disclaimer

This is an unofficial project and is not affiliated with or endorsed by Microsoft. The sysroot workaround is a technical solution documented by VS Code team but is not an officially supported usage scenario.
