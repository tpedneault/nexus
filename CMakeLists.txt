cmake_minimum_required(VERSION 3.22)

# Prevent CMake from testing the compiler (cross-compile)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

project(nexus-fsw
        VERSION 0.1.0
        LANGUAGES C ASM
        DESCRIPTION "CCSDS/PUS-compliant Flight Software"
)

# =============================================================================
# Configuration Options
# =============================================================================

set(TARGET_MCU "TMS570LC4357" CACHE STRING "Target microcontroller")
set_property(CACHE TARGET_MCU PROPERTY STRINGS
        TMS570LC4357
)

option(BUILD_TESTS "Build host-based unit tests" OFF)
option(ENABLE_LTO "Enable Link-Time Optimization" OFF)

# =============================================================================
# Include MCU-specific configuration
# =============================================================================

if(TARGET_MCU STREQUAL "TMS570LC4357")
    include(${CMAKE_SOURCE_DIR}/cmake/tms570lc4357-ti.cmake)
else()
    message(FATAL_ERROR "Unsupported TARGET_MCU: ${TARGET_MCU}")
endif()

# =============================================================================
# Global Compiler Settings
# =============================================================================

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

# =============================================================================
# Subdirectories (following layered architecture)
# =============================================================================

# Layer 1: Board Support Package (BSP)
if(MCU_FAMILY STREQUAL "TMS570")
    add_subdirectory(bsp/tms570lc43)
endif()

# Layer 2: Hardware Abstraction Layer (HAL)
add_subdirectory(hal)

# Layer 3: CCSDS packet handling
# add_subdirectory(ccsds)

# Layer 4: PUS services
# add_subdirectory(pus)

# Layer 5: Application services
# add_subdirectory(services)

# Layer 6: Main application
add_subdirectory(app)

# =============================================================================
# Host-based tests (native compilation)
# =============================================================================

if(BUILD_TESTS AND NOT CMAKE_CROSSCOMPILING)
    enable_testing()
    add_subdirectory(test)
endif()
