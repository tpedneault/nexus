# =============================================================================
# Nexus Flight Software Development Container
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
    # Serial communication (for future use)
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
    && rm /tmp/ti-cgt-installer.bin \
    && echo "Available runtime libraries:" \
    && ls -1 /opt/ti-cgt-arm/ti-cgt-arm_20.2.7.LTS/lib/ | grep rtsv7R4 \
    && echo "" \
    && echo "NOTE: If rtsv7R4_A_be_v3D16_eabi.lib is missing, you can:" \
    && echo "1. Copy from Windows CCS installation to /workspace/_WINDOWS_CCS_LIBS/" \
    && echo "2. Then run: sudo cp /workspace/_WINDOWS_CCS_LIBS/*.lib /opt/ti-cgt-arm/ti-cgt-arm_20.2.7.LTS/lib/"

ENV PATH="/opt/ti-cgt-arm/ti-cgt-arm_20.2.7.LTS/bin:${PATH}"
ENV TI_ARM_CGT_INSTALL_DIR="/opt/ti-cgt-arm/ti-cgt-arm_20.2.7.LTS"

# Verify toolchain installation
RUN armcl --version

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
# Development User Setup
# =============================================================================

ARG USERNAME=developer
ARG USER_UID=1001
ARG USER_GID=1001

RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
    && apt-get update \
    && apt-get install -y sudo \
    && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && rm -rf /var/lib/apt/lists/*

# Add user to dialout group for serial port access
RUN usermod -aG dialout ${USERNAME}

# =============================================================================
# Workspace Setup
# =============================================================================

WORKDIR /workspace

# Set ownership
RUN chown -R ${USERNAME}:${USERNAME} /workspace

# Switch to developer user
USER ${USERNAME}

# =============================================================================
# Shell Configuration
# =============================================================================

# Git configuration
RUN git config --global init.defaultBranch main \
    && git config --global core.autocrlf input \
    && git config --global pull.rebase false

# Create useful aliases
RUN echo '\n\
# Custom aliases\n\
alias ll="ls -la"\n\
alias build="cmake --build build"\n\
alias rebuild="rm -rf build && cmake --preset debug && cmake --build build"\n\
alias configure="cmake --preset debug"\n\
' >> ~/.bashrc

# =============================================================================
# Entry Point
# =============================================================================

CMD ["bash"]