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
# Subdirectories
# =============================================================================

# HALCoGen wrapper library (TMS570 only)
if(MCU_FAMILY STREQUAL "TMS570")
    add_subdirectory(halcogen)
endif()

# Hardware Abstraction Layer
# add_subdirectory(hal)

# CCSDS packet handling
# add_subdirectory(ccsds)

# PUS services
# add_subdirectory(pus)

# Main application
# add_subdirectory(app)

# =============================================================================
# Main Application Executable
# =============================================================================

add_executable(nexus-fsw
        halcogen/source/HL_sys_main.c
        halcogen/source/HL_sys_startup.c
        halcogen/source/HL_sys_intvecs.asm
        halcogen/source/HL_sys_core.asm
        halcogen/source/HL_sys_mpu.asm
        halcogen/source/HL_sys_pmu.asm
        halcogen/source/HL_sys_phantom.c
)

target_include_directories(nexus-fsw PRIVATE halcogen/include)

target_link_libraries(nexus-fsw PRIVATE 
    halcogen
    ${TI_CGT_INSTALL_DIR}/lib/rtsv7R4_A_be_v3D16_eabi.lib
)

# Link with linker script (must come after object files)
target_link_options(nexus-fsw PRIVATE 
    ${CMAKE_SOURCE_DIR}/halcogen/source/HL_sys_link.cmd
)

# Generate additional output formats
add_custom_command(TARGET nexus-fsw POST_BUILD
        COMMAND ${TI_HEX} -o ${CMAKE_BINARY_DIR}/nexus-fsw.txt $<TARGET_FILE:nexus-fsw>
        COMMENT "Generating TI-TXT output file"
)

# =============================================================================
# Host-based tests (native compilation)
# =============================================================================

if(BUILD_TESTS AND NOT CMAKE_CROSSCOMPILING)
    enable_testing()
    add_subdirectory(test)
endif()
