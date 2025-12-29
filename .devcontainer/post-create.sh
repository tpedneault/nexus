#!/bin/bash
# =============================================================================
# Post-Create Script for Dev Container
# Runs after the container is created for the first time
# =============================================================================

set -e

echo "========================================"
echo " Nexus Dev Container Setup"
echo "========================================"

# Check for ARM-mode runtime library and copy from host if available
TI_LIB_DIR="/opt/ti-cgt-arm/ti-cgt-arm_20.2.7.LTS/lib"
NEEDED_LIB="rtsv7R4_A_be_v3D16_eabi.lib"

if [ ! -f "${TI_LIB_DIR}/${NEEDED_LIB}" ]; then
    echo ""
    echo "WARNING: ARM-mode runtime library missing from TI compiler!"
    echo "Looking for library in project reference..."
    
    # Check if we can find it in the Windows CCS installation via mounted volume
    WINDOWS_CCS_LIB="/workspace/_WINDOWS_CCS_LIBS/${NEEDED_LIB}"
    if [ -f "${WINDOWS_CCS_LIB}" ]; then
        echo "Found library in Windows CCS, copying..."
        sudo cp "${WINDOWS_CCS_LIB}" "${TI_LIB_DIR}/"
        echo "Library copied successfully!"
    else
        echo "ERROR: Could not find ${NEEDED_LIB}"
        echo "Please manually copy from Windows CCS installation:"
        echo "  From: C:\\ti\\ccs1281\\ccs\\tools\\compiler\\ti-cgt-arm_20.2.7.LTS\\lib\\${NEEDED_LIB}"
        echo "  To:   ${TI_LIB_DIR}/${NEEDED_LIB}"
    fi
fi

# Create build directory if it doesn't exist
mkdir -p /workspace/build

# Configure CMake if CMakeLists.txt exists
if [ -f /workspace/CMakeLists.txt ]; then
    echo ""
    echo "Configuring CMake with TI compiler..."

    cmake --preset debug

    # Create symlink for clangd
    ln -sf /workspace/build/compile_commands.json /workspace/compile_commands.json

    echo "CMake configuration complete!"
fi

# Display toolchain info
echo ""
echo "Toolchain Information:"
echo "----------------------"
armcl --version | head -1
cmake --version | head -1
ninja --version

echo ""
echo "Runtime Libraries Available:"
ls -1 ${TI_LIB_DIR} | grep rtsv7R4

echo ""
echo "========================================"
echo " Setup Complete!"
echo "========================================"
echo ""
echo "Quick Start:"
echo "  1. Build:    cmake --build build"
echo "  2. Clean:    rm -rf build && cmake --preset debug"
echo "  3. Rebuild:  cmake --build build --clean-first"
echo ""
echo "Flash from Windows host:"
echo "  Use Code Composer Studio or UniFlash"
echo ""
