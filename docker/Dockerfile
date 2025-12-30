# =============================================================================
# Nexus Flight Software Build Container
# =============================================================================

FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

# =============================================================================
# System Dependencies
# =============================================================================

RUN apt-get update && apt-get install -y \
    # Build essentials
    build-essential \
    cmake \
    ninja-build \
    make \
    \
    # Version control
    git \
    git-lfs \
    \
    # Download tools
    wget \
    curl \
    xz-utils \
    \
    # Python (for scripts, testing tools)
    python3 \
    python3-pip \
    python3-venv \
    \
    # Documentation
    doxygen \
    graphviz \
    \
    # Debugging tools
    gdb-multiarch \
    \
    # Serial communication
    minicom \
    picocom \
    \
    # Utilities
    nano \
    vim \
    less \
    tree \
    htop \
    \
    # Library for USB (J-Link support)
    libusb-1.0-0 \
    libusb-1.0-0-dev \
    \
    # Cleanup
    && rm -rf /var/lib/apt/lists/*

# =============================================================================
# TI ARM Compiler (ti-cgt-arm)
# =============================================================================

ARG TI_CGT_VERSION=20.2.7.LTS
ARG TI_CGT_URL=https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-sDOoXkUcde/${TI_CGT_VERSION}/ti_cgt_tms470_${TI_CGT_VERSION}_linux-x64_installer.bin

RUN echo "Downloading TI ARM CGT ${TI_CGT_VERSION}..." \
    && wget -q --show-progress "${TI_CGT_URL}" -O /tmp/ti-cgt-installer.bin \
    && chmod +x /tmp/ti-cgt-installer.bin \
    && echo "Installing TI ARM CGT..." \
    && /tmp/ti-cgt-installer.bin --mode unattended --prefix /opt/ti-cgt-arm \
    && rm /tmp/ti-cgt-installer.bin

ENV PATH="/opt/ti-cgt-arm/ti-cgt-arm_20.2.7.LTS/bin:${PATH}"
ENV TI_ARM_CGT_INSTALL_DIR="/opt/ti-cgt-arm/ti-cgt-arm_20.2.7.LTS"

# Copy TMS570 runtime library from host (ARM-mode big-endian with VFP)
# This library is not included in the Linux distribution but is needed for TMS570LC4357
COPY bsp/tms570lc43/lib/rtsv7R4_A_be_v3D16_eabi.lib /opt/ti-cgt-arm/ti-cgt-arm_20.2.7.LTS/lib/

# Verify toolchain installation and library
RUN armcl 2>&1 | head -1 && \
    echo "Verifying runtime library..." && \
    ls -lh /opt/ti-cgt-arm/ti-cgt-arm_20.2.7.LTS/lib/rtsv7R4_A_be_v3D16_eabi.lib

# =============================================================================
# Python Tools
# =============================================================================

RUN pip3 install --break-system-packages \
    # Serial communication
    pyserial \
    # CCSDS packet handling (for ground station)
    crccheck \
    # Code formatting
    cmake-format \
    # Static analysis
    cppcheck \
    # Documentation
    breathe \
    sphinx

# =============================================================================
# Workspace Setup
# =============================================================================

WORKDIR /workspace

# =============================================================================
# Entry Point
# =============================================================================

CMD ["bash"]
