# Docker Toolchain

This directory contains the Docker configuration for building Nexus flight software.

## Building the Toolchain

```bash
make toolchain-build
```

This will download and install:
- TI ARM Code Generation Tools (ti-cgt-arm) v20.2.7.LTS
- CMake, Ninja, and other build tools
- Python development tools
- TMS570 runtime library (copied from `bsp/tms570lc43/lib/`)

## Using the Toolchain

The Makefile handles running commands in the Docker container automatically:

```bash
make configure    # Configure CMake
make build        # Build firmware
make test         # Run tests
```

## Manual Container Access

For debugging or manual operations:

```bash
make toolchain-shell
```

## Rebuilding

If you need to update the toolchain or rebuild from scratch:

```bash
make toolchain-rebuild
```
